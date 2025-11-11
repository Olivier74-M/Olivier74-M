-- ============================================
-- Bracework: Documents Table - Clean Install
-- This version handles existing objects gracefully
-- ============================================

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_documents_updated_at ON documents;

-- Drop and recreate the function
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create or replace the documents table
CREATE TABLE IF NOT EXISTS documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  markdown TEXT,
  line_items_json JSONB DEFAULT '[]'::jsonb,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'final', 'archived')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes (will skip if they exist)
CREATE INDEX IF NOT EXISTS idx_documents_job_id ON documents(job_id);
CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(status);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON documents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_documents_line_items ON documents USING GIN (line_items_json);

-- Recreate the trigger
CREATE TRIGGER update_documents_updated_at
  BEFORE UPDATE ON documents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Service role can manage all documents" ON documents;

-- Create policy
CREATE POLICY "Service role can manage all documents"
  ON documents FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Create or replace the view
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

-- Create or replace helper function
CREATE OR REPLACE FUNCTION get_latest_document(p_job_id UUID)
RETURNS TABLE (
  id UUID,
  markdown TEXT,
  line_items_json JSONB,
  status TEXT,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    d.id,
    d.markdown,
    d.line_items_json,
    d.status,
    d.created_at
  FROM documents d
  WHERE d.job_id = p_job_id
  ORDER BY d.created_at DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Success message (will show in results)
SELECT 'Documents table setup completed successfully!' as status;
