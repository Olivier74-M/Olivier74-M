# FieldScribe n8n Workflows

This directory contains the n8n workflow configurations for the FieldScribe AI normalization pipeline.

## Files

- **`new-capture-processor-original.json`** - Your original workflow (with connection issue)
- **`new-capture-processor-FIXED.json`** - Corrected workflow with proper connections
- **`WORKFLOW-FIX-GUIDE.md`** - Detailed explanation of the issue and solution

## Quick Start: Import the Fixed Workflow

1. Open n8n at `http://localhost:5678`
2. Click **"Import from File"** or **"+"** → **"Import from File"**
3. Select `new-capture-processor-FIXED.json`
4. Review the connections (should look like the diagram below)
5. Test with a webhook call

## Visual Comparison

### Original (Broken)
```
Webhook → Create Job → [DISCONNECTED]

          [Merge] (no inputs) → Pass-through → Has Image? → ...
```

### Fixed
```
                 ┌→ Create Job ──┐
                 │               ↓
Webhook ─────────┤             Merge → Pass-through → Has Image? → ...
                 │               ↑
                 └───────────────┘
```

## Data Flow

The corrected workflow ensures:

1. **Job Creation First**: Every capture gets a job record in Supabase
2. **Data Preservation**: Original webhook data is merged with job metadata
3. **ID Propagation**: The `job_id` flows through the entire pipeline
4. **Proper Storage**: Captures table correctly links to jobs table

## Key Changes Made

### 1. Connection: Webhook → Merge (Input 2)
Preserves the original webhook payload (image_url, text, org_id, etc.)

### 2. Connection: Create Job → Merge (Input 1)
Brings the newly created job record (with id) into the pipeline

### 3. Pass-through Node
Added job_id extraction:
```javascript
job_id: {{$input.first().json[0]?.id}}
```

### 4. Usable URL Node
Added job_id passthrough:
```javascript
job_id: {{$('Pass-through').item.json.job_id}}
```

### 5. Upsert Capture Node
Now correctly receives and stores the job_id

## Testing

Send a test webhook:

```bash
curl -X POST http://localhost:5678/webhook/new-capture \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Foundation crack observed on north wall",
    "media": {
      "image_url": "https://picsum.photos/800/600",
      "kind": "image"
    },
    "org_id": "test-org-123"
  }'
```

Expected result:
- ✅ New record in `jobs` table
- ✅ New record in `captures` table with matching `job_id`
- ✅ Image uploaded to Supabase Storage
- ✅ Signed URL generated and stored

## Environment Variables

Make sure these are set in your n8n environment:

```bash
SUPABASE_URL=https://dqdgtsnxxhzrpfkpgcww.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Next Steps

After importing the fixed workflow:

1. **Test the image pipeline** with a real image URL
2. **Build the voice pipeline** (similar structure, but with transcription)
3. **Add error handling** for failed uploads/API calls
4. **Implement the text-only pipeline** (no media processing needed)
5. **Add the AI Scribe module** that processes these captures

## Architecture Context

This workflow is part of the larger FieldScribe system:

```
FIELD CAPTURE → DATA LAYER → [THIS PIPELINE] → AI PROCESSING → DELIVERY
```

You are currently building: **AI Normalization Pipeline**
- ✅ Webhook endpoint
- ✅ Job creation
- ✅ Image pipeline (fetch → upload → sign → store)
- ⏳ Voice pipeline (next)
- ⏳ Text-only pipeline (next)
- ⏳ AI Scribe integration (future)

## Support

If you encounter issues:
1. Check the execution log in n8n
2. Verify your Supabase credentials
3. Ensure the `jobs` and `captures` tables exist
4. Review `WORKFLOW-FIX-GUIDE.md` for detailed troubleshooting

---

**Last Updated**: 2025-11-09
**Status**: Fixed and ready for testing
