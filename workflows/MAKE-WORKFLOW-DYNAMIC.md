# Make Generate Document Workflow Dynamic

## Overview
Currently, the workflow has hardcoded values for `job_id` and `template_key`. This guide will help you make it dynamic so it works with ANY job_id passed to the webhook.

## Changes Needed

### Node 2: "Fetch Prompt Template"
**Current:** Hardcoded to `eq.hvac_estimate`
**Fix:**
1. Click on "Fetch Prompt Template" node
2. Find the query parameter `template_key`
3. Turn ON expression mode
4. Change value to: `=eq.{{$('Webhook – Generate Document').first().json.document_type}}`

This will use the `document_type` from the webhook request (e.g., "hvac_estimate", "inspection_report", etc.)

---

### Node 3: "Fetch All Captures for Job"
**Current:** Hardcoded to `eq.8f7ecc15-3b91-480c-90b2-b186f0a46bba`
**Fix:**
1. Click on "Fetch All Captures for Job" node
2. Find the query parameter `job_id`
3. Turn ON expression mode
4. Change value to: `=eq.{{$('Webhook – Generate Document').first().json.job_id}}`

This will fetch captures for whatever job_id is sent to the webhook.

---

### Node 4: "Assemble Context from Captures"
**Current:** Doesn't include job_id in output
**Fix:** Replace the entire JavaScript code with the code from `workflows/node4-dynamic-code.js`

**Key change:** Adds this line near the top:
```javascript
const jobId = $('Webhook – Generate Document').first().json.job_id;
```

And includes `job_id: jobId` in the return statement.

---

### Node 5: "Build GPT-4 Vision Prompt"
**Current:** Doesn't pass through job_id
**Fix:** Replace the entire JavaScript code with the code from `workflows/node5-dynamic-code.js`

**Key changes:**
- Gets job_id from Node 4's output
- Includes job_id in the return statement

---

### Node 7: "Extract & Parse Response"
**Current:** Hardcoded job_id: `'8f7ecc15-3b91-480c-90b2-b186f0a46bba'`
**Fix:** Replace the entire JavaScript code with the code from `workflows/node7-dynamic-code.js`

**Key change:** Gets job_id from Node 4:
```javascript
const jobId = $('Assemble Context from Captures').first().json.job_id;
```

---

### Node 8: "Save Document to Supabase"
**Current:** Hardcoded URL
**Fix:**
1. Click on "Save Document to Supabase" node
2. Find the URL field
3. Turn ON expression mode
4. Change to: `={{$env.SUPABASE_URL}}/rest/v1/documents`

(The JSON body should already be using `$json.job_id` which will work once Node 7 is updated)

---

## Testing After Changes

Once all changes are made, test with DIFFERENT job_ids:

### Test 1: Original job_id
```bash
curl -X POST http://localhost:5678/webhook-test/generate-document \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": "8f7ecc15-3b91-480c-90b2-b186f0a46bba",
    "document_type": "hvac_estimate"
  }'
```

### Test 2: Different job_id (if you have another job with captures)
```bash
curl -X POST http://localhost:5678/webhook-test/generate-document \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": "YOUR-OTHER-JOB-ID-HERE",
    "document_type": "hvac_estimate"
  }'
```

Each should generate a document for THAT specific job's captures.

---

## Summary of What Gets Passed

```
Webhook → job_id, document_type
   ↓
Node 2 → Uses document_type to fetch correct template
   ↓
Node 3 → Uses job_id to fetch captures for that job
   ↓
Node 4 → Assembles captures + passes job_id through
   ↓
Node 5 → Builds GPT prompt + passes job_id through
   ↓
Node 6 → Calls GPT-4 API
   ↓
Node 7 → Parses response + gets job_id from Node 4
   ↓
Node 8 → Saves document linked to correct job_id
```

---

## Order of Changes (Recommended)

1. Start with Node 4 (add job_id to output)
2. Then Node 7 (get job_id from Node 4)
3. Then Node 5 (pass through job_id)
4. Then Node 3 (use dynamic job_id filter)
5. Then Node 2 (use dynamic template_key)
6. Finally Node 8 (use $env.SUPABASE_URL)

Test after EACH change to make sure nothing breaks!
