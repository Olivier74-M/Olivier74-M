# Prompt Templates Setup Guide

## Overview

This script creates the `prompt_templates` table and populates it with 6 professional document generation prompts for different trade specialties.

---

## Step 1: Open Supabase SQL Editor

1. Go to: https://supabase.com/dashboard/project/dqdgtsnxxhzrpfkpgcww/sql/new
2. You should see a blank SQL editor

---

## Step 2: Copy the SQL Script

```bash
cat ~/Olivier74-M/supabase/prompt-templates-setup.sql
```

---

## Step 3: Paste and Run

1. **Paste the ENTIRE contents** into the SQL editor
2. **Click "Run"** button (or press Cmd/Ctrl + Enter)
3. **Wait for completion** - should take 2-3 seconds

---

## ✅ Expected Result

You should see a table with 6 rows showing:

| template_key | display_name | trade_category | active | created_at |
|--------------|--------------|----------------|--------|------------|
| architect_proposal | Architectural Design Proposal | architect | true | [timestamp] |
| electrician_proposal | Electrical Work Proposal | electrician | true | [timestamp] |
| gc_proposal | General Contractor Proposal | general_contractor | true | [timestamp] |
| hvac_estimate | HVAC Estimate | hvac | true | [timestamp] |
| landscaper_proposal | Landscaping Design Proposal | landscaper | true | [timestamp] |
| plumber_estimate | Plumbing Service Estimate | plumber | true | [timestamp] |

---

## 🔍 Verify It Worked

Run this query in a new SQL editor tab:

```sql
-- Check table structure
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'prompt_templates'
ORDER BY ordinal_position;

-- View all templates
SELECT
  template_key,
  display_name,
  trade_category,
  LENGTH(system_prompt) as prompt_length,
  includes_line_items,
  active
FROM prompt_templates
ORDER BY trade_category;
```

**Expected:**
- 10 columns (id, template_key, display_name, trade_category, system_prompt, expected_output_format, includes_line_items, description, active, created_at, updated_at)
- 6 prompt templates
- All marked as `active = true`
- All have `includes_line_items = true`

---

## 📋 What Was Created

### Table Structure

```sql
prompt_templates
├── id (uuid)
├── template_key (text, unique) - e.g., 'hvac_estimate'
├── display_name (text) - e.g., 'HVAC Estimate'
├── trade_category (text) - e.g., 'hvac'
├── system_prompt (text) - The full prompt with placeholders
├── expected_output_format (text) - Default: 'markdown'
├── includes_line_items (boolean) - Whether to expect line items
├── description (text) - What the template is for
├── active (boolean) - Can disable without deleting
├── created_at (timestamptz)
└── updated_at (timestamptz)
```

### 6 Trade-Specific Prompts

1. **HVAC Estimate** - Educational, reassuring tone focused on comfort
2. **General Contractor Proposal** - Comprehensive renovation proposals
3. **Architectural Design Proposal** - Inspiring but practical design proposals
4. **Plumbing Service Estimate** - Straightforward, honest service estimates
5. **Electrical Work Proposal** - Safety-focused with code compliance
6. **Landscaping Design Proposal** - Creative with maintenance reality

### Features

✅ **Indexed** for fast lookups by key and category
✅ **RLS enabled** - Service role can manage, users can read
✅ **Triggers** for auto-updating `updated_at` timestamp
✅ **Placeholder system** - Prompts use `{variable_name}` placeholders
✅ **Flexible** - Can add/edit templates without code changes

---

## 🎯 How It Works in the Workflow

When generating a document:

1. User selects document type (e.g., "HVAC Estimate")
2. n8n fetches the template: `SELECT * FROM prompt_templates WHERE template_key = 'hvac_estimate'`
3. n8n assembles context from captures (images, audio transcripts, text notes)
4. n8n replaces placeholders in the prompt:
   - `{property_details}` → "1,200 sq ft ranch, built 1985"
   - `{client_concern}` → "High energy bills, uneven heating"
   - etc.
5. n8n sends complete prompt + context to GPT-4
6. GPT-4 generates professional document
7. n8n saves to `documents` table

---

## 🔧 Updating Templates

To update a prompt template:

```sql
UPDATE prompt_templates
SET system_prompt = 'Your updated prompt here...',
    updated_at = NOW()
WHERE template_key = 'hvac_estimate';
```

To add a new template:

```sql
INSERT INTO prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  includes_line_items,
  description
) VALUES (
  'new_template_key',
  'Display Name',
  'trade_category',
  'Your prompt with {placeholders}...',
  true,
  'Description of what this template does'
);
```

To disable a template (without deleting):

```sql
UPDATE prompt_templates
SET active = false
WHERE template_key = 'template_to_disable';
```

---

## ❌ Troubleshooting

### Error: "function update_updated_at_column() does not exist"

**Solution:** You need to run the documents table setup first (it creates the shared trigger function):

```bash
cat ~/Olivier74-M/supabase/documents-table-clean-install.sql
```

Then run the prompt templates script.

### Error: "duplicate key value violates unique constraint"

**Solution:** Templates already exist. Either:

1. Delete existing templates first:
   ```sql
   DELETE FROM prompt_templates;
   ```

2. Or drop and recreate the table:
   ```sql
   DROP TABLE IF EXISTS prompt_templates CASCADE;
   ```

Then run the setup script again.

---

## 🚀 Next Steps

After successful setup:

1. ✅ Documents table created
2. ✅ Prompt templates loaded
3. **Next:** Build the "Generate Document" n8n workflow
4. **Then:** Integrate with Softr web interface

---

## 📝 Testing a Template

Test fetching and using a template:

```sql
-- Fetch the HVAC template
SELECT
  template_key,
  display_name,
  system_prompt,
  includes_line_items
FROM prompt_templates
WHERE template_key = 'hvac_estimate';

-- Preview what the prompt looks like
SELECT
  display_name,
  LEFT(system_prompt, 200) || '...' as prompt_preview
FROM prompt_templates
WHERE active = true
ORDER BY trade_category;
```

---

**Ready?** Run the SQL script and let me know when you see the 6 templates! 🎉
