# Supabase Documents Table Setup Guide

## Quick Start

Follow these steps to add the `documents` table to your Supabase database.

---

## Step 1: Open Supabase SQL Editor

1. Go to your Supabase dashboard: https://supabase.com/dashboard
2. Select your project: **dqdgtsnxxhzrpfkpgcww**
3. Click **"SQL Editor"** in the left sidebar
4. Click **"New Query"**

---

## Step 2: Run the SQL Script

1. **Open the SQL file** on your computer:
   ```bash
   cat ~/Olivier74-M/supabase/documents-table-setup.sql
   ```

2. **Copy the entire contents** of the file

3. **Paste into the Supabase SQL Editor**

4. **Click "Run"** (or press Cmd/Ctrl + Enter)

5. **Check for success message**: "Success. No rows returned"

---

## Step 3: Verify the Setup

Run this verification query in the SQL Editor:

```sql
-- Check table was created
SELECT table_name
FROM information_schema.tables
WHERE table_name = 'documents';

-- Check columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'documents'
ORDER BY ordinal_position;

-- Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'documents';
```

**Expected output:**
- Table name: `documents`
- Columns: `id`, `job_id`, `markdown`, `line_items_json`, `status`, `version`, `created_at`, `updated_at`, `prompt_version`, `tokens_used`
- Row security: `true`

---

## Step 4: Check Table in Table Editor (Optional)

1. Click **"Table Editor"** in left sidebar
2. You should see **"documents"** in the tables list
3. Click on it to view the structure

---

## What Was Created

The script created:

✅ **documents table** with all required columns
✅ **Indexes** for fast queries (job_id, status, created_at)
✅ **RLS policies** (users can only access their org's documents)
✅ **Triggers** for auto-updating `updated_at` timestamp
✅ **Helper functions**:
   - `get_latest_document(job_id)` - Get newest document for a job
   - `archive_old_documents()` - Auto-archive old versions
✅ **View**: `documents_with_jobs` - Documents joined with job info

---

## Troubleshooting

### Error: "relation 'jobs' does not exist"

**Solution:** Make sure your `jobs` table exists first. Run:

```sql
CREATE TABLE IF NOT EXISTS jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL,
  title TEXT,
  status TEXT DEFAULT 'open',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Error: "relation 'profiles' does not exist"

**Solution:** The RLS policies reference a `profiles` table. If you don't have one, either:

1. **Create a profiles table:**
   ```sql
   CREATE TABLE profiles (
     id UUID PRIMARY KEY REFERENCES auth.users(id),
     org_id UUID NOT NULL,
     email TEXT
   );
   ```

2. **Or simplify the RLS policies** (remove org_id checks temporarily):
   ```sql
   -- Simpler policy for testing
   CREATE POLICY "Public access for now"
     ON documents FOR ALL
     USING (true);
   ```

### Error: "function gen_random_uuid() does not exist"

**Solution:** Use `uuid_generate_v4()` instead:

```sql
-- Replace gen_random_uuid() with uuid_generate_v4()
-- Or enable the extension:
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

---

## Testing the Table

After setup, you can test with:

```sql
-- Insert a test document (use a real job_id from your jobs table)
INSERT INTO documents (job_id, markdown, line_items_json, status)
VALUES (
  (SELECT id FROM jobs LIMIT 1), -- Use first job_id
  '# Summary\n\nThis is a test document.\n\n## Scope of Work\n\n- Test item 1\n- Test item 2',
  '[
    {"item": "Test item", "qty": 1, "unit": "ea", "unit_price": 100, "total": 100}
  ]'::jsonb,
  'draft'
);

-- View the test document
SELECT * FROM documents ORDER BY created_at DESC LIMIT 1;

-- Clean up test data
DELETE FROM documents WHERE markdown LIKE '%test document%';
```

---

## Next Steps

After the table is created successfully:

1. ✅ Continue to **Step 2**: Build "Assemble Context" node in n8n
2. This node will query captures and prepare data for the AI
3. Then we'll build the GPT-4 integration to generate documents

---

## Need Help?

If you encounter any errors:
1. Copy the full error message
2. Share it with Claude
3. We'll troubleshoot together!

---

**Ready?** Run the SQL script in Supabase and let me know when it's done! 🚀
