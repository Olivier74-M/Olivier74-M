# Generate Document Workflow Design

## Overview

This workflow generates professional trade documents (estimates, proposals) using GPT-4 Vision by assembling context from all captures (images, audio, text) for a job and applying trade-specific prompt templates.

---

## Workflow Trigger

**Type:** Webhook (Manual)

**Trigger Source:** Softr web interface - User clicks "Generate [Document Type]" button

**Input Payload:**
```json
{
  "job_id": "uuid",
  "document_type": "hvac_estimate",  // template_key from prompt_templates
  "user_id": "uuid",
  "org_id": "uuid"
}
```

---

## Workflow Nodes

### 1. Webhook Trigger
**Node Type:** Webhook
**Purpose:** Receive document generation request from Softr

**Configuration:**
- Method: POST
- Authentication: None (or API key if needed)
- Response Mode: Using 'Respond to Webhook' node

**Output:**
```json
{
  "job_id": "uuid",
  "document_type": "hvac_estimate",
  "user_id": "uuid",
  "org_id": "uuid"
}
```

---

### 2. Fetch Prompt Template
**Node Type:** Supabase (Query Rows)
**Purpose:** Get the appropriate prompt template for the document type

**Configuration:**
- Table: `prompt_templates`
- Filter: `template_key` = `{{$json.document_type}}`
- Return Fields: All
- Limit: 1

**Output:**
```json
{
  "template_key": "hvac_estimate",
  "display_name": "HVAC Estimate",
  "system_prompt": "I'm an HVAC contractor...",
  "includes_line_items": true,
  "trade_category": "hvac"
}
```

---

### 3. Fetch All Captures for Job
**Node Type:** Supabase (Query Rows)
**Purpose:** Get ALL captures (images, audio, text) for this job

**Configuration:**
- Table: `captures`
- Filter: `job_id` = `{{$json.job_id}}`
- Order By: `created_at` ASC
- Return All Fields

**Output (Multiple Items):**
```json
[
  {
    "id": "uuid",
    "job_id": "uuid",
    "media_type": "image",
    "image_url": "https://...",
    "image_analysis": "Photo shows HVAC unit exterior...",
    "signed_url": "https://supabase.co/storage/...",
    "created_at": "2025-01-15T10:30:00Z"
  },
  {
    "id": "uuid",
    "job_id": "uuid",
    "media_type": "audio",
    "audio_url": "https://...",
    "transcript": "Customer mentioned high energy bills...",
    "created_at": "2025-01-15T10:35:00Z"
  },
  {
    "id": "uuid",
    "job_id": "uuid",
    "media_type": "text",
    "content": "1,200 sq ft ranch built 1985",
    "created_at": "2025-01-15T10:40:00Z"
  }
]
```

---

### 4. Assemble Context from Captures
**Node Type:** Code (JavaScript)
**Purpose:** Organize all captures into structured context for the prompt

**Logic:**
```javascript
// Separate captures by type
const images = $input.all().filter(c => c.json.media_type === 'image');
const audio = $input.all().filter(c => c.json.media_type === 'audio');
const text = $input.all().filter(c => c.json.media_type === 'text');

// Build context object
const context = {
  // Image insights (most important)
  images: images.map(img => ({
    url: img.json.signed_url,
    analysis: img.json.image_analysis,
    timestamp: img.json.created_at
  })),

  // Audio transcripts
  transcripts: audio.map(a => a.json.transcript).join('\n\n'),

  // Text notes
  notes: text.map(t => t.json.content).join('\n\n'),

  // Summary for GPT-4
  image_count: images.length,
  has_audio: audio.length > 0,
  has_notes: text.length > 0,

  // Combined text summary
  all_text_context: [
    images.map(img => `IMAGE: ${img.json.image_analysis}`).join('\n'),
    audio.map(a => `AUDIO TRANSCRIPT: ${a.json.transcript}`).join('\n'),
    text.map(t => `NOTE: ${t.json.content}`).join('\n')
  ].filter(Boolean).join('\n\n')
};

return [{ json: context }];
```

**Output:**
```json
{
  "images": [
    {
      "url": "https://...",
      "analysis": "Photo shows...",
      "timestamp": "2025-01-15T10:30:00Z"
    }
  ],
  "transcripts": "Customer mentioned high energy bills...",
  "notes": "1,200 sq ft ranch built 1985",
  "image_count": 3,
  "has_audio": true,
  "has_notes": true,
  "all_text_context": "IMAGE: Photo shows HVAC unit...\n\nAUDIO TRANSCRIPT: Customer mentioned...\n\nNOTE: 1,200 sq ft..."
}
```

---

### 5. Build GPT-4 Prompt
**Node Type:** Code (JavaScript)
**Purpose:** Combine prompt template + context into final GPT-4 message

**Logic:**
```javascript
// Get the prompt template from earlier node
const template = $('Fetch Prompt Template').item.json.system_prompt;
const context = $input.item.json;

// Get the images for GPT-4 Vision
const images = context.images || [];

// Build the user message
const userMessage = `
Here's all the information from my site visit:

${context.all_text_context}

${context.image_count > 0 ? `\n\nI've also included ${context.image_count} photos from the site.` : ''}
`.trim();

// Prepare GPT-4 Vision message format
const messages = [
  {
    role: "system",
    content: template
  },
  {
    role: "user",
    content: [
      {
        type: "text",
        text: userMessage
      },
      // Add images for GPT-4 Vision
      ...images.map(img => ({
        type: "image_url",
        image_url: {
          url: img.url,
          detail: "high"  // High detail for technical analysis
        }
      }))
    ]
  }
];

return [{
  json: {
    messages: messages,
    model: "gpt-4-vision-preview",
    max_tokens: 4000,
    temperature: 0.7
  }
}];
```

**Output:**
```json
{
  "messages": [
    {
      "role": "system",
      "content": "I'm an HVAC contractor writing..."
    },
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Here's all the information from my site visit..."
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
  "model": "gpt-4-vision-preview",
  "max_tokens": 4000,
  "temperature": 0.7
}
```

---

### 6. Call GPT-4 Vision API
**Node Type:** HTTP Request
**Purpose:** Generate the professional document

**Configuration:**
- Method: POST
- URL: `https://api.openai.com/v1/chat/completions`
- Authentication: Bearer Token
  - Token: `{{$env.OPENAI_API_KEY}}`
- Headers:
  - `Content-Type`: `application/json`
- Body Type: JSON
- Body: `={{$json}}`  (passes through the prepared request from previous node)

**Output:**
```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "created": 1234567890,
  "model": "gpt-4-vision-preview",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "# HVAC System Assessment & Proposal\n\n## What You Told Us\n\nYou mentioned..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 1500,
    "completion_tokens": 800,
    "total_tokens": 2300
  }
}
```

---

### 7. Extract & Parse Response
**Node Type:** Code (JavaScript)
**Purpose:** Extract markdown content and optionally parse line items

**Logic:**
```javascript
const response = $input.item.json;
const generatedContent = response.choices[0].message.content;
const tokensUsed = response.usage.total_tokens;

// Check if template expects line items
const includesLineItems = $('Fetch Prompt Template').item.json.includes_line_items;

let lineItemsJson = [];
let markdownOnly = generatedContent;

// If line items expected, try to extract them
// (This is optional - depends on whether we ask GPT to output JSON)
// For now, we'll just save the full markdown
if (includesLineItems) {
  // Future: Parse line items from markdown tables or JSON blocks
  // For MVP: Just save as markdown, user can manually extract
}

return [{
  json: {
    markdown: generatedContent,
    line_items_json: lineItemsJson,
    tokens_used: tokensUsed,
    status: 'draft'
  }
}];
```

**Output:**
```json
{
  "markdown": "# HVAC System Assessment & Proposal\n\n## What You Told Us...",
  "line_items_json": [],
  "tokens_used": 2300,
  "status": "draft"
}
```

---

### 8. Save Document to Supabase
**Node Type:** Supabase (Insert Row)
**Purpose:** Store generated document in database

**Configuration:**
- Table: `documents`
- Fields:
  - `job_id`: `={{$('Webhook').item.json.job_id}}`
  - `markdown`: `={{$json.markdown}}`
  - `line_items_json`: `={{$json.line_items_json}}`
  - `status`: `={{$json.status}}`

**Output:**
```json
{
  "id": "new-uuid",
  "job_id": "original-job-uuid",
  "markdown": "# HVAC System...",
  "line_items_json": [],
  "status": "draft",
  "created_at": "2025-01-15T11:00:00Z",
  "updated_at": "2025-01-15T11:00:00Z"
}
```

---

### 9. Respond to Webhook
**Node Type:** Respond to Webhook
**Purpose:** Send success response back to Softr

**Configuration:**
- Response Code: 200
- Response Body:
```json
{
  "success": true,
  "document_id": "={{$json.id}}",
  "job_id": "={{$('Webhook').item.json.job_id}}",
  "status": "Document generated successfully",
  "preview": "={{$json.markdown.substring(0, 200)}}..."
}
```

---

## Error Handling

### Node: Error Handler (if any node fails)
**Node Type:** Error Trigger
**Purpose:** Catch and log errors

**Actions:**
1. Log error to Supabase `error_logs` table
2. Respond to webhook with error message:
```json
{
  "success": false,
  "error": "Failed to generate document",
  "details": "{{$json.error.message}}"
}
```

---

## Environment Variables Needed

```bash
OPENAI_API_KEY=sk-...
SUPABASE_URL=https://dqdgtsnxxhzrpfkpgcww.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
```

---

## Testing the Workflow

### Test Payload

```bash
curl -X POST https://your-n8n-instance.com/webhook/generate-document \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": "your-test-job-uuid",
    "document_type": "hvac_estimate",
    "user_id": "your-user-uuid",
    "org_id": "your-org-uuid"
  }'
```

### Expected Flow

1. ✅ Webhook receives request
2. ✅ Fetches "hvac_estimate" template from Supabase
3. ✅ Fetches all captures for the job
4. ✅ Assembles context (images, transcripts, notes)
5. ✅ Builds GPT-4 Vision request with images
6. ✅ Calls OpenAI API
7. ✅ Parses response
8. ✅ Saves document to Supabase
9. ✅ Returns success with document_id

### Expected Output

```json
{
  "success": true,
  "document_id": "uuid",
  "job_id": "uuid",
  "status": "Document generated successfully",
  "preview": "# HVAC System Assessment & Proposal\n\n## What You Told Us\n\nYou mentioned concerns about high energy bills and uneven heating throughout your 1,200 sq ft ranch home..."
}
```

---

## Key Features

✅ **Multi-modal AI**: Combines images (via GPT-4 Vision), audio transcripts, and text notes
✅ **Trade-specific**: Uses specialized prompts for different trade professions
✅ **Professional output**: Generates customer-ready documents in markdown
✅ **Database-driven**: Templates stored in Supabase for easy updates
✅ **High-quality image analysis**: Uses GPT-4 Vision "high detail" mode
✅ **Flexible**: Can add new document types without changing workflow

---

## Future Enhancements

1. **Structured Line Items**: Train GPT to output JSON blocks for line items
2. **Multi-version Support**: Keep multiple versions of documents
3. **Feedback Loop**: Allow users to refine documents with additional prompts
4. **PDF Export**: Convert markdown to PDF (future phase)
5. **Email Delivery**: Auto-send documents to clients
6. **Analytics**: Track which document types are most popular

---

## Integration with Softr

### Softr Button Configuration

**Button Label:** "Generate HVAC Estimate"

**Action:** Custom Action → Webhook

**Webhook URL:** `https://your-n8n-instance.com/webhook/generate-document`

**Payload:**
```javascript
{
  "job_id": "{job_id}",          // From Softr record
  "document_type": "hvac_estimate",  // Static per button
  "user_id": "{logged_in_user.id}",
  "org_id": "{logged_in_user.org_id}"
}
```

**On Success:** Redirect to document view page

**On Error:** Show error message

---

**Ready to build this in n8n?** Let's start with creating the workflow JSON! 🚀
