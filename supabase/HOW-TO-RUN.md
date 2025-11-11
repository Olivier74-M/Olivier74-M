# How to Run the Documents Table Setup

## ⚠️ IMPORTANT: Run This Way

The previous script had formatting issues. Use this new fixed version instead.

---

## Step 1: Copy the Fixed SQL Script

```bash
cat ~/Olivier74-M/supabase/documents-table-setup-fixed.sql
```

---

## Step 2: Open Supabase SQL Editor

1. Go to: https://supabase.com/dashboard/project/dqdgtsnxxhzrpfkpgcww/sql/new
2. You should see a blank SQL editor

---

## Step 3: Paste and Run

1. **Paste the ENTIRE contents** of `documents-table-setup-fixed.sql`
2. **Click "Run"** button (or press Cmd/Ctrl + Enter)
3. **Wait for completion** - should take 2-3 seconds

---

## ✅ Expected Result

You should see:
```
Success. No rows returned
```

This means all tables, indexes, triggers, and policies were created successfully!

---

## 🔍 Verify It Worked

Run this query in a NEW SQL editor tab:

```sql
-- Check the table exists
SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'documents'
ORDER BY ordinal_position;
```

**Expected columns:**
- id (uuid)
- job_id (uuid)
- markdown (text)
- line_items_json (jsonb)
- status (text)
- created_at (timestamp with time zone)
- updated_at (timestamp with time zone)

---

## 🎉 If Successful

Once you see the columns listed correctly, you're done!

Tell Claude "Table created successfully!" and we'll move to building the n8n AI Scribe nodes.

---

## ❌ If You Get Errors

### Error: "relation 'jobs' does not exist"

**Problem:** The documents table references the jobs table, but it doesn't exist.

**Solution:** First create the jobs table:

```sql
CREATE TABLE IF NOT EXISTS jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id TEXT,
  title TEXT,
  status TEXT DEFAULT 'open',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

Then run the documents script again.

---

### Error: "function gen_random_uuid() does not exist"

**Solution:** Enable the extension first:

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

Then run the documents script again.

---

### Any Other Error

Copy the **full error message** and share it with Claude. We'll fix it together!

---

## 🔄 Starting Over (if needed)

If you need to delete everything and start fresh:

```sql
DROP TABLE IF EXISTS documents CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS get_latest_document(UUID) CASCADE;
DROP VIEW IF EXISTS documents_with_jobs CASCADE;
```

Then run the setup script again.
