-- ============================================
-- Fix: Add missing updated_at column
-- ============================================

-- Add the updated_at column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'documents'
    AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE documents
    ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
  END IF;
END $$;

-- Drop and recreate the trigger function
DROP TRIGGER IF EXISTS update_documents_updated_at ON documents;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger
CREATE TRIGGER update_documents_updated_at
  BEFORE UPDATE ON documents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Now recreate the view (it will work now that updated_at exists)
CREATE OR REPLACE VIEW documents_with_jobs AS
SELECT
  d.id,
  d.job_id,
  d.markdown,
  d.line_items_json,
  d.status,
  d.created_at,
  d.updated_at,
  j.title as job_title,
  j.org_id,
  (SELECT COUNT(*) FROM captures WHERE job_id = d.job_id) as capture_count
FROM documents d
JOIN jobs j ON d.job_id = j.id;

-- Verify columns now exist
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'documents'
ORDER BY ordinal_position;
