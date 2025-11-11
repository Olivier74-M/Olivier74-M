-- ============================================
-- Bracework MVP: Documents Table Setup
-- ============================================
-- This script creates the documents table for storing
-- AI-generated markdown and line items from the AI Scribe
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
  version INTEGER DEFAULT 1,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Optional: Store the prompts used for regeneration
  prompt_version TEXT,

  -- Optional: Store token usage for billing
  tokens_used INTEGER
);

-- 2. CREATE INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_documents_job_id ON documents(job_id);
CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(status);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON documents(created_at DESC);

-- Index for JSONB line_items queries (optional but useful)
CREATE INDEX IF NOT EXISTS idx_documents_line_items ON documents USING GIN (line_items_json);

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

-- 4. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view documents for jobs in their organization
CREATE POLICY "Users can view own org documents"
  ON documents FOR SELECT
  USING (
    job_id IN (
      SELECT id FROM jobs
      WHERE org_id = (
        SELECT org_id FROM profiles
        WHERE id = auth.uid()
      )
    )
  );

-- Policy: Users can insert documents for jobs in their organization
CREATE POLICY "Users can insert own org documents"
  ON documents FOR INSERT
  WITH CHECK (
    job_id IN (
      SELECT id FROM jobs
      WHERE org_id = (
        SELECT org_id FROM profiles
        WHERE id = auth.uid()
      )
    )
  );

-- Policy: Users can update documents for jobs in their organization
CREATE POLICY "Users can update own org documents"
  ON documents FOR UPDATE
  USING (
    job_id IN (
      SELECT id FROM jobs
      WHERE org_id = (
        SELECT org_id FROM profiles
        WHERE id = auth.uid()
      )
    )
  );

-- Policy: Users can delete documents for jobs in their organization
CREATE POLICY "Users can delete own org documents"
  ON documents FOR DELETE
  USING (
    job_id IN (
      SELECT id FROM jobs
      WHERE org_id = (
        SELECT org_id FROM profiles
        WHERE id = auth.uid()
      )
    )
  );

-- 5. CREATE HELPFUL VIEW (Optional but useful)
-- ============================================
-- View that combines documents with job information
CREATE OR REPLACE VIEW documents_with_jobs AS
SELECT
  d.id,
  d.job_id,
  d.markdown,
  d.line_items_json,
  d.status,
  d.version,
  d.created_at,
  d.updated_at,
  j.title as job_title,
  j.org_id,
  j.customer_id,
  -- Count of captures for this job
  (SELECT COUNT(*) FROM captures WHERE job_id = d.job_id) as capture_count
FROM documents d
JOIN jobs j ON d.job_id = j.id;

-- 6. ADD HELPFUL FUNCTIONS
-- ============================================

-- Function to get the latest document for a job
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

-- Function to archive old document versions when creating new ones
CREATE OR REPLACE FUNCTION archive_old_documents()
RETURNS TRIGGER AS $$
BEGIN
  -- When a new document is created, archive all previous documents for the same job
  UPDATE documents
  SET status = 'archived'
  WHERE job_id = NEW.job_id
    AND id != NEW.id
    AND status = 'draft';

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER archive_old_documents_trigger
  AFTER INSERT ON documents
  FOR EACH ROW
  EXECUTE FUNCTION archive_old_documents();

-- 7. GRANT PERMISSIONS (if using service role)
-- ============================================
-- Grant access to authenticated users
GRANT ALL ON documents TO authenticated;
GRANT ALL ON documents TO service_role;

-- Grant access to the view
GRANT SELECT ON documents_with_jobs TO authenticated;
GRANT SELECT ON documents_with_jobs TO service_role;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these after creating the table to verify setup

-- Check table structure
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'documents'
-- ORDER BY ordinal_position;

-- Check indexes
-- SELECT indexname, indexdef
-- FROM pg_indexes
-- WHERE tablename = 'documents';

-- Check RLS policies
-- SELECT policyname, permissive, roles, cmd, qual
-- FROM pg_policies
-- WHERE tablename = 'documents';

-- ============================================
-- TEST INSERT (optional - for testing)
-- ============================================
-- INSERT INTO documents (job_id, markdown, line_items_json, status)
-- VALUES (
--   'YOUR-JOB-ID-HERE',
--   '# Summary\n\nTest document',
--   '[{"item": "Test", "qty": 1, "unit_price": 100}]'::jsonb,
--   'draft'
-- );

-- ============================================
-- CLEANUP (if you need to start over)
-- ============================================
-- DROP TRIGGER IF EXISTS archive_old_documents_trigger ON documents;
-- DROP TRIGGER IF EXISTS update_documents_updated_at ON documents;
-- DROP FUNCTION IF EXISTS archive_old_documents();
-- DROP FUNCTION IF EXISTS get_latest_document(UUID);
-- DROP FUNCTION IF EXISTS update_updated_at_column();
-- DROP VIEW IF EXISTS documents_with_jobs;
-- DROP TABLE IF EXISTS documents CASCADE;
