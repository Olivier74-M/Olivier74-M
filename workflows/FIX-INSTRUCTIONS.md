# Manual Fix Instructions for n8n Workflow

**READ THIS FIRST**: Follow these steps IN ORDER. Each fix builds on the previous one.

---

## Fix #1: Connect Webhook to Merge (MOST CRITICAL)

### Problem:
The Merge node only has ONE input (from Create Job). It needs TWO inputs to combine the job data with the original webhook data.

### Steps:

1. **Open your workflow** in n8n editor

2. **Click on the "Webhook – New Capture" node** to select it

3. **Look at the output connection dot** (the small circle on the right side of the node)
   - You should see ONE connection line going to "Create Job"

4. **Click and drag from the Webhook output dot** to create a NEW connection

5. **Drag the line to the "Merge" node**
   - Hover over the Merge node
   - n8n will show you which input to connect to
   - Connect to **Input 2** (the second input)

6. **Verify the connections**:
   - Webhook should now have TWO lines coming out:
     - One to "Create Job"
     - One to "Merge"
   - Merge should now have TWO lines coming in:
     - One from "Create Job" (Input 1)
     - One from "Webhook" (Input 2)

### Visual Check:
```
         ┌──→ Create Job ──→ Merge (Input 1)
         │                      ↓
Webhook──┤                 Pass-through
         │
         └─────────────────→ Merge (Input 2)
```

**✅ After this fix**: The webhook data (image_url, text, etc.) will now flow into the Merge node.

---

## Fix #2: Extract job_id in Pass-through Node

### Problem:
The job_id from Create Job isn't being extracted, so it can't flow through the pipeline.

### Steps:

1. **Click on the "Pass-through" node** to open it

2. **Scroll down to the Assignments section**

3. **Click "+ Add Assignment"** (at the bottom of the assignments list)

4. **Configure the new assignment**:
   - **Name**: `job_id`
   - **Type**: `String`
   - **Value**: `={{ $input.item(0).json[0].id }}`
     - Or try: `={{ $('Create Job').item.json[0].id }}`
     - (Use whichever works - the first one references the first input to Merge)

5. **Move this assignment to the TOP** of the list (optional but cleaner)

6. **Click "Save"** (or click outside the node)

### What this does:
Extracts the `id` field from the Create Job response and stores it as `job_id` so it flows forward.

**✅ After this fix**: The job_id will be available in $json.job_id for all downstream nodes.

---

## Fix #3: Pass job_id Forward in Usable URL Node

### Problem:
The Usable URL node doesn't pass the job_id forward, so it won't reach the Upsert node.

### Steps:

1. **Click on the "Usable URL" node** to open it

2. **Scroll down to the Assignments section**

3. **Click "+ Add Assignment"** (at the bottom of the assignments list)

4. **Configure the new assignment**:
   - **Name**: `job_id`
   - **Type**: `String`
   - **Value**: `={{ $json.job_id }}`

5. **Click "Save"**

### What this does:
Carries the job_id through to the final Upsert node.

**✅ After this fix**: The Upsert Capture node will have access to job_id.

---

## Fix #4: Fix Broken Template Syntax in Upsert Capture

### Problem:
Several body parameters have incomplete template expressions (missing closing brackets).

### Steps:

1. **Click on the "Supabase – Upsert Capture (image)" node** to open it

2. **Scroll to Body Parameters**

3. **Fix each broken parameter** by finding and editing them:

#### Parameter: `file_path`
- **Current (broken)**: `` `{{ $json.file_path ``
- **Change to**: `={{ $json.file_path }}`

#### Parameter: `mime`
- **Current (broken)**: `` `{{ $json.mime ``
- **Change to**: `={{ $json.mime }}`

#### Parameter: `storage_id`
- **Current (broken)**: `` `{{ $node['Upload to Supabase'].json.id ``
- **Change to**: `={{ $node['Upload to Supabase'].json.id }}`

#### Parameter: `signed_url`
- **Current (broken)**: `` `{{ ($env.SUPABASE_URL ``
- **Change to**: `={{ $json.signed_url }}`
  - (Note: We already have the full signed_url from Usable URL node, so we can just reference it directly)

#### Parameter: `received_at`
- **Current (broken)**: `` `{{ $json.meta?.received_at ``
- **Change to**: `={{ $json.received_at }}`

4. **Click "Save"**

### What this does:
Fixes the template syntax so the Upsert can successfully insert data into Supabase.

**✅ After this fix**: The Upsert will successfully create capture records in your database.

---

## Optional Fix: Pass-through (no image) Node

If you want the "no image" branch to also work correctly, add job_id there too:

1. **Click on "Pass-through (no image)" node**

2. **Add a new assignment**:
   - **Name**: `job_id`
   - **Type**: `String`
   - **Value**: `={{ $json.job_id }}`

3. **Click "Save"**

---

## Testing Your Fixed Workflow

After making all the fixes above:

1. **Save the workflow** (top right button)

2. **Activate the workflow** (toggle switch)

3. **Send a test webhook**:

```bash
curl -X POST http://localhost:5678/webhook/new-capture \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Test capture with image",
    "media": {
      "image_url": "https://picsum.photos/800/600",
      "kind": "image"
    },
    "org_id": "test-org-123"
  }'
```

4. **Check the execution log** in n8n:
   - Click on "Executions" (left sidebar)
   - Find your test execution
   - Click on it to see the data flow

5. **Verify each node**:
   - ✅ **Webhook**: Received the data
   - ✅ **Create Job**: Created a job record (check for `id` in output)
   - ✅ **Merge**: Has data from BOTH inputs
   - ✅ **Pass-through**: Has job_id + image_url + text
   - ✅ **Has Image?**: Takes TRUE branch
   - ✅ **Fetch Image**: Downloads the image
   - ✅ **Upload to Supabase**: Uploads successfully
   - ✅ **Sign URL**: Generates signed URL
   - ✅ **Usable URL**: Has job_id + signed_url
   - ✅ **Upsert Capture**: Successfully inserts into database

6. **Check your Supabase database**:
   - Go to your Supabase project
   - Check the `jobs` table → should have a new row
   - Check the `captures` table → should have a new row with matching `job_id`

---

## Common Issues & Troubleshooting

### "Merge node shows error: No data in input 1"
→ Make sure the "Create Job" connection is to Input 1 of Merge

### "Merge node shows error: No data in input 2"
→ Make sure the "Webhook" connection is to Input 2 of Merge

### "Has Image? always goes to FALSE branch"
→ The Merge fix (#1) wasn't applied correctly. Check that webhook data reaches Merge.

### "job_id is null in Upsert"
→ Check Fix #2 (Pass-through) and Fix #3 (Usable URL) are applied correctly

### "Upsert fails with 'unexpected token' error"
→ Check Fix #4 (template syntax) is applied correctly

---

## What Each Fix Accomplishes

| Fix | What It Solves | Impact |
|-----|----------------|--------|
| #1: Connect Webhook → Merge | Original data (image_url, text) now flows through | Image pipeline will run |
| #2: Extract job_id in Pass-through | job_id available for downstream nodes | Captures can link to jobs |
| #3: Pass job_id in Usable URL | job_id reaches the Upsert node | Database relationship established |
| #4: Fix template syntax | Upsert can successfully insert data | No more syntax errors |

---

## Summary

**Order matters!** Do the fixes in sequence:
1. ✅ Connect Webhook to Merge
2. ✅ Add job_id extraction in Pass-through
3. ✅ Add job_id in Usable URL
4. ✅ Fix template syntax in Upsert

After all fixes, your workflow will:
- ✅ Receive webhook data correctly
- ✅ Create job records
- ✅ Process images through the full pipeline
- ✅ Link captures to jobs via job_id
- ✅ Store everything in Supabase successfully

**Estimated time**: 10-15 minutes

---

**Questions?** Let me know if any step is unclear or if you encounter errors!
