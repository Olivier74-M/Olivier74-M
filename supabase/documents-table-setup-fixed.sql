-- ============================================
-- Bracework MVP: Documents Table Setup (FIXED)
-- ============================================
-- Run this entire script in Supabase SQL Editor
-- ============================================

-- ============================================
-- 1. CREATE DOCUMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,

  -- AI Generated Content
  markdown TEXT,
  line_items_json JSONB DEFAULT '[]'::jsonb,

  -- Metadata
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'final', 'archived')),

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_documents_job_id ON documents(job_id);
CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(status);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON documents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_documents_line_items ON documents USING GIN (line_items_json);

-- ============================================
-- 3. CREATE UPDATED_AT TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_documents_updated_at
  BEFORE UPDATE ON documents
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 4. ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Allow service role to bypass RLS for n8n webhooks
CREATE POLICY "Service role can manage all documents"
  ON documents FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================
-- 5. CREATE HELPER VIEW
-- ============================================
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

-- ============================================
-- 6. CREATE HELPER FUNCTION
-- ============================================
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

-- ============================================
-- VERIFICATION: Run these to check setup
-- ============================================
-- SELECT table_name FROM information_schema.tables WHERE table_name = 'documents';
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'documents' ORDER BY ordinal_position;
