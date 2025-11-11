# Bracework MVP - Implementation Status

**Date:** November 11, 2025
**Status Review:** Comparing current implementation against PRD v1.0

---

## ✅ **COMPLETED: AI Normalization Pipeline**

We've successfully built the **bottom half** of the architecture diagram - the data capture and normalization layer:

### What's Working:

1. **Webhook Endpoint** ✅
   - POST endpoint at `/new-capture`
   - Receives: text, media (image_url/audio_url), org_id

2. **Job Creation** ✅
   - Creates job records in Supabase `jobs` table
   - Links captures to jobs via `job_id`

3. **Image Processing Pipeline** ✅
   - Fetch image from URL
   - Upload to Supabase Storage (`images` bucket)
   - Generate signed URLs
   - Store metadata in `captures` table (type: 'image')

4. **Audio Processing Pipeline** ✅
   - Fetch audio from URL
   - **Whisper AI transcription** (OpenAI)
   - Store transcript in `captures` table (type: 'audio')

5. **Data Normalization** ✅
   - Pass-through node extracts and normalizes data
   - Proper job_id flow through the pipeline
   - Metadata tracking (received_at, source, etc.)

6. **Database Schema (Partial)** ✅
   - `jobs` table
   - `captures` table with columns:
     - id, job_id, type, kind, source, status
     - audio_url, transcript
     - received_at, created_at
   - Supabase Storage buckets
   - RLS policies (assumed configured)

---

## ❌ **NOT YET BUILT: AI Scribe Layer**

According to the PRD and diagram, we're **missing the entire AI processing layer** that turns raw captures into business documents.

### What's Missing:

#### 1. **Documents Table** (PRD Section 5)
```sql
CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id UUID REFERENCES jobs(id),
  markdown TEXT,
  line_items_json JSONB,
  status TEXT DEFAULT 'draft', -- 'draft' | 'final'
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 2. **AI Scribe Workflow** (PRD Section 6 & 8)

**Missing n8n nodes:**

a. **Assemble Context Node**
   - Gather all captures for a job
   - Combine: transcripts + OCR text + user notes
   - Prepare context for LLM

b. **AI Scribe - Markdown Generator** (Prompt 1)
   - Input: Assembled context
   - LLM: GPT-4 or similar
   - Output: Structured Markdown with sections:
     ```markdown
     # Summary
     ## Scope of Work
     ## Materials & Labor
     ## Assumptions
     ## Next Steps
     ```

c. **AI Scribe - Line Items Generator** (Prompt 2)
   - Input: Same context
   - LLM: GPT-4 or similar
   - Output: JSON array:
     ```json
     [
       {
         "item": "Replace faucet",
         "qty": 1,
         "unit": "ea",
         "unit_price": 120,
         "total": 120
       }
     ]
     ```

d. **Write to Documents Table**
   - Insert markdown + line_items_json
   - Link to job_id
   - Set status = 'draft'

e. **Notification System**
   - Send email/SMS with link to Softr workspace
   - "Your document is ready: [link]"

#### 3. **OCR for Images** (Optional but in PRD)
- Extract text from images
- Store in `captures.ocr_text` column
- Feed into AI Scribe context

#### 4. **Glide Mobile App** (Capture Interface)
- Not built yet
- Current workaround: Using curl/webhook directly
- PRD requires: Simple "Apple Notes-like" interface

#### 5. **Softr Workspace** (Delivery Layer)
- Not built yet
- Should display:
  - Jobs list
  - Job details with captures timeline
  - Document view with rendered Markdown
  - Copy buttons (Copy Summary, Copy All, Copy Line Items)
  - Regenerate button

---

## 🎯 **NEXT STEPS: Priority Order**

Based on PRD Section 10 (MVP Build Order), here's what to build next:

### Phase 1: Complete the AI Pipeline (Most Important!)

**Goal:** End-to-end from capture → AI-generated document

1. **Add `documents` table to Supabase**
   ```sql
   -- Run this in Supabase SQL Editor
   CREATE TABLE documents (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
     markdown TEXT,
     line_items_json JSONB,
     status TEXT DEFAULT 'draft',
     created_at TIMESTAMPTZ DEFAULT NOW(),
     updated_at TIMESTAMPTZ DEFAULT NOW()
   );

   -- Add RLS policies
   ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

   CREATE POLICY "Users can view own org documents"
     ON documents FOR SELECT
     USING (job_id IN (
       SELECT id FROM jobs WHERE org_id = auth.jwt()->>'org_id'
     ));
   ```

2. **Build "Assemble Context" node in n8n**
   - After both image and audio branches complete
   - Query all captures for the current job_id
   - Combine into single context string:
     ```
     User Note: [original text]
     Transcripts: [all audio transcripts]
     Image Context: [OCR text if available]
     ```

3. **Build "AI Scribe - Generate Markdown" node**
   - HTTP Request to OpenAI API (GPT-4)
   - System prompt: "You are a professional field notes assistant..."
   - User prompt: Include assembled context
   - Parse response → extract markdown

4. **Build "AI Scribe - Generate Line Items" node**
   - Similar OpenAI call
   - Different prompt focused on pricing/itemization
   - Parse JSON response

5. **Build "Save Document" node**
   - Insert into `documents` table
   - Include: job_id, markdown, line_items_json, status='draft'

6. **Build "Send Notification" node**
   - Email via SendGrid/Mailgun or
   - Use Supabase Edge Function
   - Include link to Softr workspace (build next)

### Phase 2: Build Softr Workspace

**Goal:** User can view and copy AI-generated documents

1. **Connect Softr to Supabase**
   - Set up Softr data source
   - Import tables: jobs, captures, documents

2. **Create Softr Pages:**
   - **Dashboard:** List of jobs
   - **Job Detail:** Captures timeline + document preview
   - **Document View:**
     - Render markdown (use markdown component)
     - Add copy buttons
     - Add "Regenerate" button (triggers n8n webhook)

3. **Set up Authentication**
   - Softr memberships
   - Link to Supabase RLS policies

### Phase 3: Build Glide Capture App

**Goal:** Replace curl testing with real mobile interface

1. **Create Glide App**
   - "New Note" screen with:
     - Title input
     - Body text area
     - Photo upload (max 5)
     - Audio upload (max 90s)
     - Job selection (optional)
   - Submit button → POST to n8n webhook

2. **Test End-to-End**
   - Capture from Glide
   - Verify n8n processes
   - Check Softr displays correctly

### Phase 4: Pilot Testing

1. Run 10 end-to-end tests (per PRD Section 11)
2. Onboard 5 pilot users
3. Gather feedback
4. Iterate

---

## 📊 **Current Progress: ~40% Complete**

### Completed:
- ✅ Data Layer (Supabase storage + basic tables)
- ✅ Capture Pipeline (webhook → normalize → store)
- ✅ Media Processing (images + audio)
- ✅ Whisper Transcription

### In Progress:
- 🔄 AI Scribe Layer (next priority)

### Not Started:
- ❌ Documents generation
- ❌ Softr workspace
- ❌ Glide capture app
- ❌ Notifications
- ❌ OCR (optional)

---

## 🚀 **Immediate Next Action**

**Start with the AI Scribe workflow** because:
1. It's the core value proposition ("AI field-notes assistant")
2. Everything else depends on having documents to display
3. It completes the n8n pipeline (per MVP Build Order step 2)

**First concrete step:**
```sql
-- Add the documents table to Supabase
```

Then build the n8n nodes to:
1. Assemble context from captures
2. Call GPT-4 to generate markdown + line items
3. Save to documents table
4. Send notification

---

## 📋 **Questions to Clarify**

Before building the AI Scribe:

1. **LLM Choice:** Use OpenAI GPT-4? Or GPT-3.5-turbo for cost savings?
2. **Prompt Templates:** Do you have specific Scribe prompts written, or should we draft them?
3. **Trigger:** Should AI processing happen:
   - Immediately after each capture? OR
   - Only when user clicks "Generate Document"?
4. **Multiple Captures:** How to handle when a job has 5+ photos + 3 voice memos?
   - Process all together?
   - Process incrementally as they arrive?

---

## 💡 **Recommendation**

**Focus next on completing the n8n AI Scribe workflow** (Phase 1 above). This will:
- Prove the core value of Bracework
- Allow end-to-end testing without Glide/Softr
- Use your existing n8n skills
- Demonstrate AI capabilities to pilots

Once AI is working, Softr and Glide become "just presentation layers" that are much easier to build.

**Would you like to start building the AI Scribe workflow now?**
