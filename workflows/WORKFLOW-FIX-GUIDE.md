# Workflow Fix Guide: Create Job Node Connection

## Problem Identified

Your "Create Job" node is disconnected from the rest of the pipeline. Here's what's happening:

```
Current (broken):
Webhook → Create Job → [NOWHERE]
                       [Merge has NO inputs] → Pass-through → ...

Correct flow should be:
Webhook → Create Job → Merge ← [also needs webhook data]
                        ↓
                   Pass-through → Has Image? → ...
```

## The Issue

1. **Create Job** creates a record in Supabase and returns the new job data (including `job_id`)
2. **But** this data never reaches the **Merge** node
3. **Merge** needs TWO inputs:
   - Input 1: Original webhook payload (with image_url, text, etc.)
   - Input 2: Job data from "Create Job" (with the new job_id)

## The Solution

### Step 1: Connect Create Job to Merge

In your n8n workflow:
1. Click and drag from the **Create Job** output dot
2. Connect it to the **Merge** node (Input 1)

### Step 2: Connect Webhook to Merge (preserve original data)

You need the original webhook data too:
1. Click and drag from the **Webhook – New Capture** output dot
2. Connect it to the **Merge** node (Input 2)

This creates two connections into Merge:
```
       ┌─→ Create Job ─→ Merge (Input 1)
       │                  ↓
Webhook┤                  Pass-through
       │                  ↓
       └─────────────→ Merge (Input 2)
```

### Step 3: Update Pass-through node to include job_id

Add this assignment to your "Pass-through" node:

```json
{
  "name": "job_id",
  "value": "={{$input.first().json.id}}",
  "type": "string"
}
```

This extracts the job `id` from the Create Job response and includes it in the normalized data.

### Step 4: Update "Usable URL" node

Add the job_id to the "Usable URL" node so it flows to the final Upsert:

```json
{
  "name": "job_id",
  "value": "={{$json.job_id}}",
  "type": "string"
}
```

## Why This Matters

The **job_id** ties everything together:
- Each capture (image/voice/text) belongs to a job
- You can query: "Show me all captures for job X"
- Enables grouping related field inputs together
- Critical for your "Contractor Dashboard" to organize data

## Expected Data Flow

After the fix:

```json
{
  "job_id": "uuid-from-create-job",
  "normalized": {
    "text": "Cracked foundation needs repair",
    "lang_hint": "en"
  },
  "media": {
    "image_url": "https://...supabase.co/storage/.../signed_url"
  },
  "meta": {
    "source": "webhook",
    "received_at": "2025-11-09T10:30:00Z"
  }
}
```

This complete record gets stored in your `captures` table with proper job linkage.

## Testing the Fix

Send a test webhook:

```bash
curl -X POST http://localhost:5678/webhook/new-capture \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Test capture",
    "media": {
      "image_url": "https://example.com/test.jpg",
      "kind": "image"
    },
    "org_id": "test-org-123"
  }'
```

Check your Supabase tables:
1. **jobs** table should have a new record
2. **captures** table should have a record with that job_id

---

## Quick Reference: Merge Node Modes

n8n's Merge node has different modes. For this use case, use:

- **Mode**: `Combine`
- **Combine By**: `Merge By Position` (default)

This merges the first item from each input into a single object.
