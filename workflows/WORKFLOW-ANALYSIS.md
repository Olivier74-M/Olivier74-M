# Workflow Analysis: Bracework – New Capture Processor

**Analysis Date**: 2025-11-09
**Workflow ID**: jUyC91tMAZ4Wy4ne

---

## Current Data Flow

Here's what your workflow does RIGHT NOW:

```
Webhook – New Capture
    ↓
Create Job (creates job in Supabase)
    ↓
Merge (receives ONLY job data)
    ↓
Pass-through (tries to extract data but...)
    ↓
Has Image? (checks for image_url)
    ↓ (true)                    ↓ (false)
Fetch Image              Pass-through (no image)
    ↓
Move Binary Data
    ↓
Upload to Supabase
    ↓
Sign URL
    ↓
Usable URL
    ↓
Supabase – Upsert Capture (image)
```

---

## CRITICAL ISSUES FOUND

### 🔴 Issue #1: Merge Node Has Only ONE Input (Needs TWO)

**Current connections:**
- ✅ Create Job → Merge (Input 0)
- ❌ Webhook → Merge (Input 1) **MISSING!**

**Why this is a problem:**
The Merge node is supposed to combine TWO data sources:
1. The job data from "Create Job" (has job id, status, etc.)
2. The original webhook data (has image_url, text, org_id, etc.)

Right now, the webhook data NEVER reaches the Merge node. This means:
- The Pass-through node can't access `$json.media?.image_url` (doesn't exist)
- The Has Image? check will always be FALSE
- Your image pipeline never runs
- No data reaches the final Upsert

**Webhook data sent:**
```json
{
  "text": "Foundation crack",
  "media": {
    "image_url": "https://example.com/photo.jpg",
    "kind": "image"
  },
  "org_id": "org-123"
}
```

**What Merge currently receives (ONLY job data):**
```json
[
  {
    "id": "uuid-here",
    "source": "webhook",
    "status": "open",
    "kind": "image",
    "org_id": "org-123"
  }
]
```

**What Merge SHOULD receive (both sources):**
```json
Input 0 (from Create Job):
{
  "id": "uuid-here",
  "source": "webhook",
  "status": "open",
  "kind": "image",
  "org_id": "org-123"
}

Input 1 (from Webhook):
{
  "text": "Foundation crack",
  "media": {
    "image_url": "https://example.com/photo.jpg",
    "kind": "image"
  },
  "org_id": "org-123"
}
```

---

### 🟡 Issue #2: Pass-through Node Doesn't Extract job_id

**Current assignments in Pass-through:**
- ✅ raw
- ✅ normalized.text
- ✅ normalized.lang_hint
- ✅ media.image_url
- ✅ meta.source
- ✅ meta.received_at
- ❌ job_id **MISSING!**

Even if the Merge worked correctly, the job_id from Create Job isn't being extracted and passed forward. This means the Upsert Capture node won't have a job_id to store.

---

### 🟡 Issue #3: Usable URL Node Doesn't Pass job_id Forward

**Current assignments in Usable URL:**
- ✅ file_path
- ✅ signed_path
- ✅ signed_url
- ✅ bucket
- ✅ mime
- ✅ received_at
- ❌ job_id **MISSING!**

The job_id needs to flow through every node in the pipeline so it reaches the final Upsert.

---

### 🔴 Issue #4: Broken Template Syntax in Upsert Capture

**Current broken body parameters:**

```javascript
"file_path": "`{{ $json.file_path"           // ❌ Missing }}`
"mime": "`{{ $json.mime"                     // ❌ Missing }}`
"storage_id": "`{{ $node['Upload to Supabase'].json.id"  // ❌ Missing }}`
"signed_url": "`{{ ($env.SUPABASE_URL"       // ❌ Missing )}}`
"received_at": "`{{ $json.meta?.received_at" // ❌ Missing }}`
```

These will cause the Upsert to fail with syntax errors.

---

## What Should Happen vs. What Actually Happens

### Expected Behavior:
1. Webhook receives capture data
2. Create Job creates a job record, returns job with id
3. Merge combines webhook data + job data
4. Pass-through normalizes and includes job_id
5. Has Image? checks for image_url → TRUE
6. Image pipeline processes the image
7. Upsert stores capture with job_id link

### Actual Behavior:
1. Webhook receives capture data ✅
2. Create Job creates a job record ✅
3. Merge receives ONLY job data (no webhook data) ❌
4. Pass-through can't find image_url (doesn't exist) ❌
5. Has Image? → always FALSE ❌
6. Goes to "Pass-through (no image)" branch
7. Upsert fails due to broken syntax ❌

---

## Summary of Problems

| Issue | Severity | Impact |
|-------|----------|--------|
| Webhook not connected to Merge | 🔴 CRITICAL | Image pipeline never runs |
| job_id not extracted in Pass-through | 🟡 HIGH | Captures not linked to jobs |
| job_id not passed in Usable URL | 🟡 HIGH | Captures not linked to jobs |
| Broken template syntax in Upsert | 🔴 CRITICAL | Database insert fails |

---

## Root Cause

The fundamental issue is that **the original webhook data is lost** after Create Job. The Merge node was intended to solve this, but it's only receiving data from Create Job, not from the Webhook.

This is a classic n8n pattern issue: when you want to create a resource (job) but also keep the original data, you need to split the flow and merge it back together.

---

## Next Steps

I'll provide step-by-step manual instructions to fix these issues in the proper order:

1. Fix the Merge node connections (most critical)
2. Add job_id extraction in Pass-through
3. Add job_id passthrough in Usable URL
4. Fix the broken template syntax in Upsert Capture

These fixes will enable:
- ✅ Proper data flow through the pipeline
- ✅ Image processing working correctly
- ✅ Captures linked to jobs via job_id
- ✅ Successful database inserts
