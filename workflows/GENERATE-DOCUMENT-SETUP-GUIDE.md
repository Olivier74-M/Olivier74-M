# Generate Document Workflow Setup Guide

## Overview

This guide walks you through importing and configuring the "Generate Document" workflow in n8n.

---

## Prerequisites

Before importing this workflow, make sure you have:

1. ✅ **Documents table** created in Supabase
2. ✅ **Prompt templates table** created and populated with 6 templates
3. ✅ **Captures** with data (images, audio, text) for testing
4. ✅ **Environment variables** configured in n8n:
   - `OPENAI_API_KEY`
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_KEY`

---

## Step 1: Import the Workflow

### Option A: Via n8n UI

1. Open n8n: https://your-n8n-instance.com
2. Click **"Workflows"** in the left sidebar
3. Click **"+ Add workflow"** button (top right)
4. Click **"Import from File"**
5. Select: `~/Olivier74-M/workflows/generate-document-workflow.json`
6. Click **"Import"**

### Option B: Via File Upload

1. Copy the workflow JSON:
   ```bash
   cat ~/Olivier74-M/workflows/generate-document-workflow.json
   ```
2. In n8n, click **"..."** menu → **"Import from File"**
3. Paste the JSON content
4. Click **"Import"**

---

## Step 2: Verify Workflow Structure

After import, you should see **9 nodes** in this order:

```
Webhook – Generate Document
  ↓
Fetch Prompt Template
  ↓
Fetch All Captures for Job
  ↓
Assemble Context from Captures
  ↓
Build GPT-4 Vision Prompt
  ↓
Call GPT-4 Vision API
  ↓
Extract & Parse Response
  ↓
Save Document to Supabase
  ↓
Respond to Webhook
```

---

## Step 3: Configure Environment Variables

Make sure these are set in your n8n environment:

```bash
# OpenAI API Key
OPENAI_API_KEY=sk-proj-...

# Supabase Configuration
SUPABASE_URL=https://dqdgtsnxxhzrpfkpgcww.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
```

### How to Check:

1. Click on any HTTP Request node (e.g., "Call GPT-4 Vision API")
2. Look for expressions like `{{$env.OPENAI_API_KEY}}`
3. If they resolve correctly, you're good!

---

## Step 4: Get the Webhook URL

1. Click on the **"Webhook – Generate Document"** node
2. Click **"Test URL"** or **"Production URL"**
3. Copy the URL (it should look like):
   ```
   https://your-n8n-instance.com/webhook/generate-document
   ```
4. Save this URL - you'll need it for Softr integration

---

## Step 5: Test with Sample Data

### Test Payload

Create a test file:

```bash
cat > /tmp/test-generate-doc.json <<'EOF'
{
  "job_id": "YOUR_TEST_JOB_ID",
  "document_type": "hvac_estimate",
  "user_id": "test-user-uuid",
  "org_id": "test-org-uuid"
}
EOF
```

**Important:** Replace `YOUR_TEST_JOB_ID` with an actual job_id from your Supabase `jobs` table that has captures associated with it.

### Run the Test

```bash
curl -X POST https://your-n8n-instance.com/webhook/generate-document \
  -H "Content-Type: application/json" \
  -d @/tmp/test-generate-doc.json
```

---

## Step 6: Verify Each Node

### Manual Execution Test

1. Click the **"Execute Workflow"** button (play icon, top right)
2. Enter test data when prompted
3. Watch each node execute in sequence
4. Check for green checkmarks ✅ on each node

### Node-by-Node Verification

#### Node 1: Webhook – Generate Document
**Expected Output:**
```json
{
  "job_id": "uuid",
  "document_type": "hvac_estimate",
  "user_id": "uuid",
  "org_id": "uuid"
}
```

#### Node 2: Fetch Prompt Template
**Expected Output:**
```json
[
  {
    "template_key": "hvac_estimate",
    "display_name": "HVAC Estimate",
    "system_prompt": "I'm an HVAC contractor...",
    "includes_line_items": true
  }
]
```
**If Error:** Check that prompt_templates table exists and has data

#### Node 3: Fetch All Captures for Job
**Expected Output:** Array of captures (images, audio, text)
```json
[
  {
    "id": "uuid",
    "job_id": "uuid",
    "media_type": "image",
    "signed_url": "https://...",
    "image_analysis": "Photo shows..."
  }
]
```
**If Error:** Check that captures exist for this job_id

#### Node 4: Assemble Context from Captures
**Expected Output:**
```json
{
  "images": [...],
  "transcripts": "...",
  "notes": "...",
  "image_count": 3,
  "audio_count": 1,
  "text_count": 2,
  "all_text_context": "IMAGE ANALYSIS: ...\n\nAUDIO TRANSCRIPT: ..."
}
```

#### Node 5: Build GPT-4 Vision Prompt
**Expected Output:**
```json
{
  "model": "gpt-4-vision-preview",
  "messages": [
    {
      "role": "system",
      "content": "I'm an HVAC contractor..."
    },
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Here's all the information..."
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "https://...",
            "detail": "high"
          }
        }
      ]
    }
  ],
  "max_tokens": 4000,
  "temperature": 0.7
}
```

#### Node 6: Call GPT-4 Vision API
**Expected Output:**
```json
{
  "id": "chatcmpl-...",
  "choices": [
    {
      "message": {
        "content": "# HVAC System Assessment & Proposal..."
      }
    }
  ],
  "usage": {
    "total_tokens": 2300
  }
}
```
**If Error:**
- Check `OPENAI_API_KEY` is valid
- Check account has credits
- Check model name is correct

#### Node 7: Extract & Parse Response
**Expected Output:**
```json
{
  "markdown": "# HVAC System Assessment & Proposal\n\n## What You Told Us...",
  "line_items_json": [],
  "tokens_used": 2300,
  "status": "draft"
}
```

#### Node 8: Save Document to Supabase
**Expected Output:**
```json
[
  {
    "id": "new-document-uuid",
    "job_id": "original-job-uuid",
    "markdown": "# HVAC System...",
    "line_items_json": [],
    "status": "draft",
    "created_at": "2025-01-15T...",
    "updated_at": "2025-01-15T..."
  }
]
```
**If Error:**
- Check `SUPABASE_SERVICE_KEY` is correct
- Check documents table exists
- Check RLS policies allow service_role access

#### Node 9: Respond to Webhook
**Expected Output:**
```json
{
  "success": true,
  "document_id": "uuid",
  "job_id": "uuid",
  "status": "Document generated successfully",
  "preview": "# HVAC System Assessment & Proposal...",
  "tokens_used": 2300
}
```

---

## Step 7: Verify Document in Supabase

After successful execution, check the database:

```sql
-- View the generated document
SELECT
  id,
  job_id,
  LEFT(markdown, 100) as markdown_preview,
  status,
  created_at
FROM documents
ORDER BY created_at DESC
LIMIT 1;

-- Full markdown content
SELECT markdown
FROM documents
ORDER BY created_at DESC
LIMIT 1;
```

---

## Common Issues & Solutions

### Error: "template_key not found"

**Problem:** Document type doesn't match any template

**Solution:** Check available templates:
```sql
SELECT template_key, display_name FROM prompt_templates WHERE active = true;
```

Use one of the returned `template_key` values in your test payload.

---

### Error: "No captures found for job"

**Problem:** The job_id has no captures

**Solution:** Either:
1. Use a different job_id that has captures
2. Or create test captures:

```sql
-- Insert test image capture
INSERT INTO captures (job_id, media_type, image_url, image_analysis, signed_url)
VALUES (
  'your-job-id',
  'image',
  'https://example.com/photo.jpg',
  'Photo shows HVAC unit exterior. Unit appears to be 15+ years old based on weathering. Rust visible on cabinet.',
  'https://your-supabase-storage-url.com/signed-image-url'
);

-- Insert test text capture
INSERT INTO captures (job_id, media_type, content)
VALUES (
  'your-job-id',
  'text',
  '1,200 sq ft ranch home, built 1985. Customer reports high energy bills and uneven heating.'
);
```

---

### Error: "OpenAI API quota exceeded"

**Problem:** No credits in OpenAI account

**Solution:**
1. Go to: https://platform.openai.com/settings/organization/billing
2. Add credits to your account
3. Retry the workflow

---

### Error: "Invalid signature" from Supabase

**Problem:** Signed URLs have expired

**Solution:**
1. Regenerate signed URLs for images in captures
2. Or update the captures processing workflow to create longer-lived signed URLs

---

### Error: "Column 'updated_at' does not exist"

**Problem:** Documents table missing column

**Solution:** Run the fix script:
```bash
cat ~/Olivier74-M/supabase/fix-missing-column.sql
```
Paste into Supabase SQL Editor and run.

---

## Step 8: Activate the Workflow

Once testing is successful:

1. Click the **"Active"** toggle switch (top right)
2. The workflow is now live and will respond to webhook requests
3. The **Production URL** is now active

---

## Step 9: Integrate with Softr

### Create Custom Action in Softr

1. In Softr, go to your Job Details page
2. Add a **Custom Button** for each document type
3. Configure the button:

**Button 1: Generate HVAC Estimate**
- **Label:** "Generate HVAC Estimate"
- **Action:** Custom Action → Webhook
- **URL:** `https://your-n8n-instance.com/webhook/generate-document`
- **Method:** POST
- **Headers:**
  - `Content-Type`: `application/json`
- **Body:**
  ```json
  {
    "job_id": "{record.id}",
    "document_type": "hvac_estimate",
    "user_id": "{logged_in_user.id}",
    "org_id": "{logged_in_user.org_id}"
  }
  ```
- **On Success:** Show message: "Document generated! Redirecting..."
- **Redirect to:** Document view page

**Repeat for other document types:**
- "Generate GC Proposal" → `"document_type": "gc_proposal"`
- "Generate Architect Proposal" → `"document_type": "architect_proposal"`
- etc.

---

## Testing from Softr

1. Open a job in Softr that has captures
2. Click "Generate HVAC Estimate"
3. Wait 10-30 seconds (GPT-4 Vision can be slow)
4. You should see success message
5. View the generated document

---

## Performance Optimization

### Expected Execution Times

- **Webhook → Fetch Template:** < 1 second
- **Fetch Captures:** < 1 second
- **Assemble Context:** < 1 second
- **Build Prompt:** < 1 second
- **GPT-4 Vision API:** 10-30 seconds (depends on image count)
- **Parse Response:** < 1 second
- **Save to Supabase:** < 1 second
- **Total:** 15-35 seconds

### Tips to Reduce Execution Time

1. **Limit image count:** Only include most relevant photos (max 5-10)
2. **Use image detail: "low"** for less critical images (faster, cheaper)
3. **Reduce max_tokens:** If documents are consistently shorter than 4000 tokens
4. **Use GPT-4 instead of GPT-4 Vision** for jobs with no images

---

## Cost Estimation

### GPT-4 Vision Pricing (as of 2025)

- **Input:** $0.01 per 1K tokens
- **Output:** $0.03 per 1K tokens
- **Images (high detail):** ~$0.0425 per image

### Example Cost per Document

**Scenario:** 5 images + 500 tokens context + 1000 tokens output

```
Images: 5 × $0.0425 = $0.2125
Input tokens: 500 × $0.01/1000 = $0.005
Output tokens: 1000 × $0.03/1000 = $0.03
Total: ~$0.25 per document
```

**Monthly estimate:** 100 documents/month = $25

---

## Monitoring & Debugging

### View Workflow Executions

1. In n8n, click **"Executions"** in left sidebar
2. See all workflow runs with success/failure status
3. Click any execution to see detailed node-by-node output

### Enable Debug Mode

1. Edit workflow
2. Click **"Settings"** (gear icon, top right)
3. Enable **"Save execution data"**
4. Enable **"Save manual executions"**

### Check Logs

```bash
# n8n logs (if self-hosted)
docker logs -f n8n

# Supabase logs
# Go to: https://supabase.com/dashboard/project/dqdgtsnxxhzrpfkpgcww/logs/explorer
```

---

## Next Steps

After the workflow is working:

1. ✅ Create Softr buttons for all 6 document types
2. ✅ Test with real job data
3. ✅ Create document view/edit pages in Softr
4. ✅ Add copy-to-clipboard functionality for generated markdown
5. ✅ (Optional) Build document version history
6. ✅ (Optional) Add email delivery of documents

---

## Support

If you encounter issues:

1. Check the node-by-node verification above
2. Review the common issues section
3. Check n8n execution logs
4. Verify Supabase data with SQL queries

---

**Ready?** Import the workflow and start generating professional documents! 🚀
