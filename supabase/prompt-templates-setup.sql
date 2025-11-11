-- ============================================
-- Bracework: Prompt Templates Table Setup
-- ============================================
-- Stores professional prompt templates for different trade specialties
-- ============================================

-- ============================================
-- 1. CREATE PROMPT_TEMPLATES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS prompt_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Template identification
  template_key TEXT NOT NULL UNIQUE,  -- e.g., 'hvac_estimate', 'gc_proposal'
  display_name TEXT NOT NULL,         -- e.g., 'HVAC Estimate', 'General Contractor Proposal'
  trade_category TEXT NOT NULL,       -- e.g., 'hvac', 'general_contractor', 'plumber'

  -- Prompt content
  system_prompt TEXT NOT NULL,        -- The full prompt template with placeholders

  -- Output configuration
  expected_output_format TEXT DEFAULT 'markdown',  -- 'markdown', 'json', etc.
  includes_line_items BOOLEAN DEFAULT false,       -- Does this generate line items?

  -- Metadata
  description TEXT,                   -- What this template is for
  example_output TEXT,                -- Optional example of output
  active BOOLEAN DEFAULT true,        -- Can be disabled without deleting

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. CREATE INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_prompt_templates_key ON prompt_templates(template_key);
CREATE INDEX IF NOT EXISTS idx_prompt_templates_category ON prompt_templates(trade_category);
CREATE INDEX IF NOT EXISTS idx_prompt_templates_active ON prompt_templates(active);

-- ============================================
-- 3. CREATE UPDATED_AT TRIGGER
-- ============================================
-- Reuse the same function created for documents table
CREATE TRIGGER update_prompt_templates_updated_at
  BEFORE UPDATE ON prompt_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 4. ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE prompt_templates ENABLE ROW LEVEL SECURITY;

-- Allow service role full access (for n8n)
CREATE POLICY "Service role can manage all templates"
  ON prompt_templates FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Allow authenticated users to read active templates
CREATE POLICY "Users can read active templates"
  ON prompt_templates FOR SELECT
  TO authenticated
  USING (active = true);

-- ============================================
-- 5. INSERT PROMPT TEMPLATES
-- ============================================

-- Template 1: HVAC Estimate
INSERT INTO prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  includes_line_items,
  description
) VALUES (
  'hvac_estimate',
  'HVAC Estimate',
  'hvac',
  'I'm an HVAC contractor writing a professional estimate for a homeowner.

Here's what I know from my site visit:

Property Details: {property_details}
Client's Main Concern: {client_concern}
Inspection Findings: {inspection_findings}
My Recommended Solution: {recommended_solution}

Please write a professional estimate in this style:

Tone: educational, reassuring, confident (like you're explaining to a friend who trusts you)
Structure:
1. Brief summary of what they told you (the problem)
2. What you found during inspection
3. Why you recommend this solution (focus on their comfort, energy savings, peace of mind)
4. The investment and timeline
5. Simple next steps

Keep it:
- Warm but professional
- Easy to read (short paragraphs)
- Focused on benefits to THEM, not technical specs
- Clear about what's included

Avoid:
- Overly salesy language
- Too much HVAC jargon
- Scare tactics
- Confusion about pricing',
  true,
  'Professional HVAC estimate template focusing on customer benefits and education'
);

-- Template 2: General Contractor Proposal
INSERT INTO prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  includes_line_items,
  description
) VALUES (
  'gc_proposal',
  'General Contractor Proposal',
  'general_contractor',
  'I'm a general contractor writing a proposal for a home renovation project.

Project Details:
Property Info: {property_info}
Client's Goals: {client_goals}
Scope of Work: {scope_of_work}
Timeline Estimate: {timeline}
Budget Range: {budget_range}

Please write a professional proposal with this approach:

Tone: confident, detail-oriented, collaborative
Structure:
1. Project vision (what we're building together)
2. Scope of work (organized by phase or area)
3. Our process and timeline
4. Investment breakdown
5. Why we're the right fit
6. Next steps

Keep it:
- Clear and organized
- Focused on their vision becoming reality
- Transparent about process and timeline
- Professional but approachable

Include:
- Specific deliverables for each phase
- What's included vs. what's extra
- How we handle changes and communication
- Payment schedule tied to milestones',
  true,
  'Comprehensive general contractor proposal for home renovation projects'
);

-- Template 3: Architectural Design Proposal
INSERT INTO prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  includes_line_items,
  description
) VALUES (
  'architect_proposal',
  'Architectural Design Proposal',
  'architect',
  'I'm an architect writing a proposal for a design project.

Project Context:
Property: {property_context}
Client's Vision: {client_vision}
Design Challenges: {design_challenges}
Scope of Services: {scope_of_services}
Deliverables: {deliverables}

Please write a compelling design proposal:

Tone: creative, thoughtful, inspiring (but grounded in practical realities)
Structure:
1. Understanding of their vision
2. Design approach and philosophy for this project
3. Scope of services (by design phase)
4. Deliverables and timeline
5. Fee structure
6. What makes our process unique
7. Next steps

Keep it:
- Inspirational but practical
- Clear about what each design phase delivers
- Transparent about decision points
- Focused on collaboration and their input

Emphasize:
- How design solves their specific challenges
- The value of thoughtful design (not just pretty drawings)
- Our process for keeping them involved
- How we balance vision with budget and feasibility',
  true,
  'Professional architectural design proposal emphasizing vision and collaboration'
);

-- Template 4: Plumbing Service Estimate
INSERT INTO prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  includes_line_items,
  description
) VALUES (
  'plumber_estimate',
  'Plumbing Service Estimate',
  'plumber',
  'I'm a plumber writing an estimate for a homeowner.

Service Call Details:
Issue Reported: {issue_reported}
What I Found: {findings}
Recommended Fix: {recommended_fix}
Why This Approach: {reasoning}
Alternative Options: {alternatives}

Please write a clear, trustworthy estimate:

Tone: straightforward, honest, helpful (like a neighbor who happens to be an expert)
Structure:
1. What you called me about
2. What I found (the real issue)
3. My recommended solution and why
4. What it costs and what's included
5. Other options (if applicable)
6. How long it takes
7. Next steps

Keep it:
- Simple and jargon-free
- Honest about what's needed now vs. later
- Clear about what the price includes
- Reassuring without overselling

Include:
- Parts and labor breakdown
- Warranty information
- What happens if we find additional issues
- How we protect their home during work',
  true,
  'Straightforward plumbing estimate focused on honesty and clarity'
);

-- Template 5: Electrical Work Proposal
INSERT INTO prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  includes_line_items,
  description
) VALUES (
  'electrician_proposal',
  'Electrical Work Proposal',
  'electrician',
  'I'm an electrician writing a proposal for electrical work.

Project Info:
Work Requested: {work_requested}
Current Situation: {current_electrical}
Code Requirements: {code_requirements}
Proposed Solution: {proposed_solution}
Safety Considerations: {safety_notes}

Please write a professional electrical proposal:

Tone: safety-focused, knowledgeable, thorough
Structure:
1. Overview of requested work
2. Current electrical assessment
3. Proposed solution (meets code + client needs)
4. Safety upgrades recommended
5. Scope of work (detailed)
6. Investment breakdown
7. Timeline and process
8. Permits and inspections
9. Next steps

Keep it:
- Safety-focused without being alarmist
- Clear about code requirements
- Detailed about what's included
- Educational about electrical systems

Emphasize:
- Code compliance and permits
- Safety improvements
- Quality of materials and workmanship
- Warranty and guarantees
- Licensed and insured',
  true,
  'Detailed electrical proposal emphasizing safety and code compliance'
);

-- Template 6: Landscaping Design Proposal
INSERT INTO prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  includes_line_items,
  description
) VALUES (
  'landscaper_proposal',
  'Landscaping Design Proposal',
  'landscaper',
  'I'm a landscaper writing a proposal for a landscape design/build project.

Project Details:
Property Info: {property_info}
Client's Vision: {landscape_vision}
Site Conditions: {site_conditions}
Proposed Design: {design_concept}
Planting Plan: {planting_details}
Hardscape Elements: {hardscape_details}

Please write an inspiring landscape proposal:

Tone: creative, nature-focused, practical (balance beauty with maintenance reality)
Structure:
1. Their vision for the space
2. Site opportunities and challenges
3. Design concept (the overall plan)
4. Planting plan (right plants, right places)
5. Hardscape elements (patios, paths, features)
6. Installation process and timeline
7. Maintenance expectations
8. Investment breakdown
9. Next steps

Keep it:
- Inspiring but realistic
- Clear about maintenance needs
- Focused on year-round appeal
- Transparent about what thrives in their conditions

Emphasize:
- How design fits their lifestyle and property
- Plant selection for their climate/soil/sun
- Sustainability and water-wise choices
- How it looks across seasons
- Realistic maintenance expectations',
  true,
  'Creative landscaping proposal balancing aesthetics with practical maintenance'
);

-- ============================================
-- 6. VERIFICATION QUERY
-- ============================================
SELECT
  template_key,
  display_name,
  trade_category,
  active,
  created_at
FROM prompt_templates
ORDER BY trade_category, display_name;
