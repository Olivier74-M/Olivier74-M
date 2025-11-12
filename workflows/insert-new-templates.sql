-- Insert 12 new prompt templates to complete the Bracework template system
-- 6 missing estimate/proposal templates + 6 inspection report templates
-- Run this in Supabase SQL Editor

-- ============================================
-- MISSING ESTIMATE/PROPOSAL TEMPLATES (6)
-- ============================================

-- 1. HVAC Proposal
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'hvac_proposal',
  'HVAC System Proposal',
  'hvac',
  'I''m an HVAC contractor writing a comprehensive proposal for a major system installation or replacement.

Project Details:
Property Info: {property_info}
Current System: {current_system}
Client''s Needs: {client_needs}
Proposed Solution: {proposed_solution}
System Specifications: {system_specs}
Energy Efficiency Benefits: {efficiency_benefits}

Please write a detailed HVAC proposal with this approach:

Tone: expert, educational, focused on comfort and long-term value
Structure:
1. Understanding of their current situation and needs
2. Assessment of existing system (age, efficiency, issues)
3. Recommended system and why it''s the right fit
4. Energy efficiency and cost savings over time
5. Installation scope and process
6. Investment breakdown (equipment, labor, extras)
7. Timeline and what to expect
8. Warranty and service plans
9. Financing options (if applicable)
10. Next steps

Keep it:
- Educational about system sizing and efficiency ratings
- Clear about what makes a quality installation
- Focused on their comfort, air quality, and energy savings
- Transparent about the investment and long-term value

Emphasize:
- Proper sizing and load calculations
- Quality of equipment and installation
- Energy savings compared to current system
- Indoor air quality improvements
- Warranty coverage and service plans
- Licensed, insured, certified technicians
- What''s included in the installation (permits, disposal, startup, etc.)

Avoid:
- Overselling features they don''t need
- Confusing technical jargon without explanation
- Pressure tactics or limited-time offers
- Unclear pricing or hidden costs',
  'markdown',
  true,
  'Comprehensive HVAC proposal for major system installations and replacements',
  true
);

-- 2. Plumber Proposal
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'plumber_proposal',
  'Plumbing Project Proposal',
  'plumber',
  'I''m a plumber writing a proposal for a larger plumbing project (bathroom/kitchen remodel, repipe, sewer line replacement, etc.).

Project Details:
Property Info: {property_info}
Scope of Work: {scope_of_work}
Current Issues: {current_issues}
Proposed Solution: {proposed_solution}
Materials Specified: {materials}
Code Requirements: {code_requirements}

Please write a thorough plumbing proposal:

Tone: straightforward, trustworthy, detail-oriented
Structure:
1. Overview of the project and current situation
2. Scope of work (what we''re doing, step by step)
3. Materials and fixtures specified
4. How we protect the home during work
5. Code compliance and permits
6. Investment breakdown by major component
7. Timeline and sequencing
8. Cleanup and final inspection
9. Warranty information
10. Next steps

Keep it:
- Detailed about what''s included and what''s not
- Clear about material quality and options
- Honest about potential complications
- Focused on doing it right, not just fast

Emphasize:
- Quality materials and proper installation
- Code compliance and permits
- How we minimize disruption
- Warranty on parts and labor
- Licensed and insured
- What happens if we encounter unexpected issues
- Protection of their property during work

Include:
- Specific fixture models/specs (if selected)
- Permits and inspection process
- Cleanup and debris removal
- Testing and commissioning
- How changes or additions are handled',
  'markdown',
  true,
  'Detailed plumbing proposal for larger projects and remodels',
  true
);

-- 3. Electrician Estimate
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'electrician_estimate',
  'Electrical Service Estimate',
  'electrician',
  'I''m an electrician writing an estimate for a specific electrical service or repair.

Service Details:
Work Requested: {work_requested}
Current Situation: {current_situation}
Proposed Solution: {proposed_solution}
Safety Concerns: {safety_concerns}

Please write a clear electrical estimate:

Tone: safety-focused, professional, straightforward
Structure:
1. What you need done
2. What we found/assessed
3. Our solution and why it''s safe and up to code
4. What''s included in the price
5. Timeline
6. Next steps

Keep it:
- Safety-focused without being alarmist
- Clear about code requirements
- Straightforward about what''s included
- Honest about what else might be needed

Emphasize:
- Safety and code compliance
- Licensed and insured
- Quality materials and workmanship
- Warranty coverage
- Permits if required

Include:
- Parts and labor breakdown
- Any permits or inspections needed
- How long the work takes
- What''s guaranteed
- When we can schedule it

Avoid:
- Overwhelming with electrical terminology
- Upselling unnecessary work
- Vague "might need" language without specifics',
  'markdown',
  true,
  'Straightforward electrical estimate for service calls and repairs',
  true
);

-- 4. General Contractor Estimate
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'gc_estimate',
  'General Contractor Estimate',
  'general_contractor',
  'I''m a general contractor writing an estimate for a smaller renovation or repair project.

Project Details:
Work Requested: {work_requested}
Property Info: {property_info}
Scope of Work: {scope_of_work}
Timeline Estimate: {timeline}

Please write a professional GC estimate:

Tone: confident, organized, clear
Structure:
1. Understanding of what you want done
2. Scope of work overview
3. What''s included (materials, labor, permits, etc.)
4. Timeline estimate
5. Investment breakdown
6. Next steps

Keep it:
- Well-organized and easy to understand
- Clear about what''s in scope vs. out of scope
- Transparent about the process
- Focused on getting it done right

Emphasize:
- Experience with this type of work
- Quality of workmanship
- Project management and coordination
- Licensed and insured
- What''s included in the price
- How we handle the unexpected

Include:
- Labor and materials breakdown
- Permits and inspections
- Timeline estimate
- Payment schedule
- How changes are handled
- Warranty information

Avoid:
- Overpromising on timeline
- Vague scope that leads to disputes
- Hidden costs or surprise fees',
  'markdown',
  true,
  'Professional estimate for smaller GC renovation and repair projects',
  true
);

-- 5. Landscaper Estimate
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'landscaper_estimate',
  'Landscaping Service Estimate',
  'landscaper',
  'I''m a landscaper writing an estimate for a specific landscaping service (cleanup, planting, mulching, lawn care, etc.).

Service Details:
Work Requested: {work_requested}
Property Conditions: {property_conditions}
Proposed Work: {proposed_work}
Materials/Plants: {materials}

Please write a clear landscaping estimate:

Tone: nature-focused, practical, helpful
Structure:
1. What you''d like done
2. What we''ll do (specific tasks)
3. Materials and plants we''ll use
4. Timeline and scheduling
5. Investment
6. Maintenance tips
7. Next steps

Keep it:
- Specific about what tasks are included
- Clear about plant selections and why they work
- Realistic about timing (weather-dependent)
- Helpful about ongoing care

Emphasize:
- Right plants for their conditions
- Quality of materials (mulch, soil, etc.)
- Professional installation
- Cleanup included
- Seasonal timing considerations

Include:
- Specific plant varieties and sizes
- Soil amendments or preparations
- Mulch or ground cover materials
- Cleanup and debris removal
- How weather might affect timing
- Basic care instructions

Avoid:
- Overpromising plant growth or results
- Selling plants that won''t thrive in their conditions
- Unclear scope that leads to "while we''re here" additions',
  'markdown',
  true,
  'Clear landscaping estimate for specific services and installations',
  true
);

-- 6. Architect Estimate
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'architect_estimate',
  'Architectural Services Estimate',
  'architect',
  'I''m an architect writing an estimate for architectural services on a smaller project (addition, renovation, consultation, etc.).

Project Details:
Project Type: {project_type}
Scope of Services: {scope_of_services}
Deliverables: {deliverables}
Timeline: {timeline}

Please write a professional architectural services estimate:

Tone: creative but practical, clear about value
Structure:
1. Understanding of their project goals
2. Scope of architectural services
3. What we''ll deliver (drawings, specs, etc.)
4. Design process and timeline
5. Fee structure
6. Next steps

Keep it:
- Clear about what services are included
- Specific about deliverables
- Transparent about the design process
- Focused on value of good design

Emphasize:
- How design solves their specific needs
- What deliverables they''ll receive
- Our process for keeping them involved
- Licensed architect
- How we work with contractors/engineers

Include:
- Specific deliverables (# of drawings, revisions, etc.)
- Design phases and what each includes
- Timeline estimates
- Fee breakdown (by phase if applicable)
- What additional services cost (engineering, permits, etc.)
- How revisions and changes are handled

Avoid:
- Vague "design services" without specifics
- Underselling the value of design
- Overpromising on timeline (permits, approvals)
- Unclear about what''s extra vs. included',
  'markdown',
  true,
  'Professional architectural services estimate for smaller projects',
  true
);

-- ============================================
-- INSPECTION REPORT TEMPLATES (6)
-- ============================================

-- 7. HVAC Inspection Report
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'hvac_inspection_report',
  'HVAC System Inspection Report',
  'hvac',
  'I''m an HVAC technician writing a detailed inspection report after evaluating a heating and cooling system.

Inspection Details:
Property: {property_info}
System Age: {system_age}
Inspection Findings: {findings}
Photos/Evidence: {evidence_notes}
Safety Concerns: {safety_concerns}
Recommendations: {recommendations}

Please write a thorough HVAC inspection report:

Tone: objective, thorough, educational (not salesy)
Structure:
1. Property and system overview
2. Heating system assessment
   - Age and condition
   - Performance testing results
   - Issues found
3. Cooling system assessment
   - Age and condition
   - Performance testing results
   - Issues found
4. Air quality and ventilation
5. Safety concerns (if any)
6. Efficiency observations
7. Immediate needs vs. future considerations
8. Recommendations prioritized by urgency

Keep it:
- Objective and fact-based
- Clear about what''s working vs. what''s not
- Educational about what we found
- Helpful for decision-making

Emphasize:
- Safety issues (immediate attention)
- Efficiency problems (costing them money)
- Age-related wear (plan ahead)
- What''s normal vs. concerning
- Photos/evidence of issues

Include:
- Specific measurements and observations
- Severity/urgency of each issue
- Expected lifespan of components
- Consequences of not addressing issues
- Recommended timeline for repairs/replacement

Avoid:
- Alarmist language
- Selling services (just report facts)
- Vague "might need" statements
- Technical jargon without explanation

Format each finding with:
- What we found
- Why it matters
- Urgency level (immediate/soon/plan ahead)
- Typical cost range if relevant',
  'markdown',
  false,
  'Objective HVAC system inspection report for building trust and identifying issues',
  true
);

-- 8. Plumber Inspection Report
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'plumber_inspection_report',
  'Plumbing System Inspection Report',
  'plumber',
  'I''m a plumber writing an inspection report after evaluating a property''s plumbing system.

Inspection Details:
Property: {property_info}
System Age: {system_age}
Inspection Scope: {inspection_scope}
Findings: {findings}
Photos/Evidence: {evidence_notes}
Issues Identified: {issues}

Please write a detailed plumbing inspection report:

Tone: straightforward, honest, thorough
Structure:
1. Property overview and system age
2. Water supply system
   - Pipe materials and condition
   - Water pressure
   - Shut-off valves
   - Issues found
3. Drainage and waste system
   - Drain flow
   - Vent system
   - Issues found
4. Water heater assessment
   - Age, type, condition
   - Safety concerns
   - Performance
5. Fixtures and fittings
6. Visible leaks or moisture
7. Code compliance concerns
8. Recommendations prioritized by urgency

Keep it:
- Fact-based and objective
- Clear about severity of issues
- Honest about what needs attention now vs. later
- Helpful for planning

Emphasize:
- Active leaks (immediate issue)
- Safety concerns (gas, water heater, etc.)
- Code violations
- Age-related issues to plan for
- Hidden problems we found

Include:
- Specific observations and measurements
- Urgency level for each issue
- Consequences if not addressed
- Estimated lifespan of aging components
- Photos/evidence referenced

Avoid:
- Scare tactics
- Selling services
- Vague "might be a problem" statements
- Assuming problems we can''t see

Format each finding with:
- Location and what we found
- Why it''s a concern
- Urgency (immediate/soon/monitor/plan ahead)
- Typical cost range to address',
  'markdown',
  false,
  'Thorough plumbing system inspection report documenting conditions and issues',
  true
);

-- 9. Electrician Inspection Report
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'electrician_inspection_report',
  'Electrical System Inspection Report',
  'electrician',
  'I''m an electrician writing an inspection report after evaluating a property''s electrical system.

Inspection Details:
Property: {property_info}
System Age: {system_age}
Panel Info: {panel_info}
Inspection Findings: {findings}
Safety Concerns: {safety_concerns}
Code Issues: {code_issues}

Please write a thorough electrical inspection report:

Tone: safety-focused, clear, objective
Structure:
1. Property and electrical system overview
2. Main panel assessment
   - Age, type, capacity
   - Condition and labeling
   - Available capacity
   - Safety concerns
3. Branch circuits and wiring
   - Wiring types observed
   - Condition
   - Issues found
4. Grounding and bonding
5. GFCI/AFCI protection
6. Safety hazards identified
7. Code compliance issues
8. Recommendations prioritized by safety urgency

Keep it:
- Safety-focused without being alarmist
- Clear about what''s dangerous vs. what''s outdated
- Objective and evidence-based
- Educational about electrical safety

Emphasize:
- Immediate safety hazards
- Code violations
- Lack of required protection (GFCI/AFCI)
- Capacity issues
- Fire hazards
- Shock hazards

Include:
- Specific findings with locations
- Severity and urgency of each issue
- Current code requirements
- Consequences of not addressing issues
- Recommended timeline for corrections

Avoid:
- Overstating minor issues
- Assuming hidden problems without evidence
- Selling services (report facts only)
- Technical jargon without explanation

Format each finding with:
- Location and specific observation
- Safety concern or code reference
- Urgency level (immediate/high/moderate/low)
- Recommended correction
- Typical cost range if helpful

Priority levels:
- IMMEDIATE: Active hazard, safety risk
- HIGH: Code violation, potential hazard
- MODERATE: Outdated but functional, plan upgrade
- LOW: Improvement opportunity, not required',
  'markdown',
  false,
  'Safety-focused electrical system inspection report identifying hazards and code issues',
  true
);

-- 10. General Contractor Inspection Report
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'gc_inspection_report',
  'General Contractor Inspection Report',
  'general_contractor',
  'I''m a general contractor writing an inspection report after evaluating a property for renovation or repair needs.

Inspection Details:
Property: {property_info}
Property Age: {property_age}
Areas Inspected: {areas_inspected}
Findings: {findings}
Photos/Evidence: {evidence_notes}
Client''s Concerns: {client_concerns}

Please write a comprehensive property inspection report:

Tone: professional, thorough, practical
Structure:
1. Property overview and inspection scope
2. Structural observations
   - Foundation
   - Framing
   - Roof structure
   - Concerns found
3. Exterior condition
   - Siding/cladding
   - Windows and doors
   - Roof covering
   - Gutters and drainage
4. Interior condition
   - Walls and ceilings
   - Floors
   - Doors and trim
   - Moisture issues
5. Systems overview (if applicable)
   - Brief notes on HVAC, plumbing, electrical
   - Recommend specialist inspections
6. Priority findings and recommendations
7. Scope of work considerations

Keep it:
- Organized by area/system
- Clear about what''s cosmetic vs. structural
- Practical about repair vs. replace decisions
- Focused on helping them plan

Emphasize:
- Structural or safety issues
- Water damage or moisture problems
- Code compliance concerns
- Items affecting project scope/budget
- Issues requiring specialist evaluation

Include:
- Specific locations and observations
- Severity of each issue
- Whether it affects their project goals
- Ballpark complexity/cost if helpful
- Recommendations for specialists

Avoid:
- Overstating cosmetic issues
- Making structural claims without engineering
- Promising exact pricing
- Scope creep beyond what was discussed

Format findings by:
- Area/system
- Observation
- Impact on project
- Urgency/priority
- Recommended action

Note when specialist evaluation is recommended:
- Structural engineer for foundation/framing concerns
- HVAC, plumbing, electrical specialists
- Roofing specialist for major roof issues
- Mold/environmental specialist if suspected',
  'markdown',
  false,
  'Comprehensive GC property inspection report for renovation planning',
  true
);

-- 11. Landscaper Inspection Report
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'landscaper_inspection_report',
  'Landscape Site Assessment Report',
  'landscaper',
  'I''m a landscaper writing a site assessment report after evaluating a property''s landscape conditions and opportunities.

Assessment Details:
Property: {property_info}
Site Conditions: {site_conditions}
Existing Landscape: {existing_landscape}
Client''s Goals: {client_goals}
Observations: {observations}
Opportunities: {opportunities}

Please write a helpful landscape assessment report:

Tone: nature-focused, educational, opportunity-oriented
Structure:
1. Property overview and site context
2. Existing conditions
   - Trees and major plants
   - Lawn and ground covers
   - Hardscape elements
   - Drainage patterns
3. Site analysis
   - Sun/shade patterns
   - Soil conditions
   - Drainage and water issues
   - Access and utilities
4. Existing plant health assessment
5. Problem areas identified
6. Opportunities for improvement
7. Recommendations by priority

Keep it:
- Focused on both problems and opportunities
- Realistic about site conditions
- Educational about what grows well there
- Practical about maintenance needs

Emphasize:
- Drainage issues or standing water
- Soil quality and amendments needed
- Sun exposure for different areas
- Existing plants worth keeping vs. removing
- Opportunities to enhance the space
- Seasonal considerations

Include:
- Specific observations by area
- Why certain things aren''t thriving
- What would work well in each area
- Maintenance realities
- Phasing options if budget is a concern

Avoid:
- Overwhelming with botanical names
- Recommending plants that won''t thrive there
- Ignoring maintenance requirements
- Being negative about existing landscape

Format observations by area:
- Location description
- Current condition
- Issues or limitations
- Opportunities
- Priority for attention

Note important factors:
- Soil type and quality
- Drainage patterns
- Sun/shade throughout the day
- Existing irrigation
- Seasonal interest
- Wildlife considerations
- Maintenance level required',
  'markdown',
  false,
  'Educational landscape assessment identifying site conditions and opportunities',
  true
);

-- 12. Architect Inspection Report
INSERT INTO public.prompt_templates (
  template_key,
  display_name,
  trade_category,
  system_prompt,
  expected_output_format,
  includes_line_items,
  description,
  active
) VALUES (
  'architect_inspection_report',
  'Architectural Site Assessment Report',
  'architect',
  'I''m an architect writing a site assessment report after evaluating a property for design opportunities and constraints.

Assessment Details:
Property: {property_info}
Property Type: {property_type}
Client''s Vision: {client_vision}
Site Observations: {observations}
Design Opportunities: {opportunities}
Constraints: {constraints}

Please write a thoughtful architectural assessment report:

Tone: creative but analytical, opportunity-focused
Structure:
1. Property overview and context
2. Existing conditions
   - Building characteristics
   - Spatial layout
   - Architectural style
   - Structural observations
3. Site analysis
   - Orientation and views
   - Natural light
   - Circulation and flow
   - Relationship to outdoor spaces
4. Zoning and code considerations
5. Design opportunities identified
6. Constraints and challenges
7. Preliminary thoughts on approach
8. Recommendations for next steps

Keep it:
- Balanced between creative vision and practical realities
- Clear about opportunities and constraints
- Inspiring about what''s possible
- Realistic about complexity and approvals

Emphasize:
- How the space could better serve their needs
- Natural light and views
- Flow and circulation issues
- Structural or code implications
- Unique characteristics worth preserving or highlighting
- Zoning or permitting considerations

Include:
- Observations about spatial quality
- How current layout does/doesn''t work
- Opportunities for improvement
- Constraints (structural, code, budget reality)
- Preliminary design concepts if appropriate
- Need for specialist consultations

Avoid:
- Overpromising what''s possible
- Ignoring budget or code realities
- Too much technical jargon
- Designing without understanding needs fully

Format observations by:
- Existing condition
- How it affects their goals
- Design opportunity
- Constraints to consider
- Priority/impact

Note when additional consultations needed:
- Structural engineer for load-bearing changes
- Soils engineer for foundation work
- Energy consultant for efficiency goals
- Historic preservation if applicable
- Zoning attorney for complex issues
- MEP engineers for major system changes

Consider:
- Building orientation and solar
- View corridors
- Natural ventilation
- Privacy
- Scale and proportion
- Character of neighborhood
- Future flexibility',
  'markdown',
  false,
  'Thoughtful architectural assessment balancing design vision with practical constraints',
  true
);

-- ============================================
-- VERIFICATION QUERY
-- ============================================
-- Run this after inserting to verify all templates were added:

SELECT
  template_key,
  display_name,
  trade_category,
  includes_line_items,
  active
FROM public.prompt_templates
ORDER BY trade_category, template_key;

-- You should now have 18 total templates:
-- - 6 trades × 2 document types (estimate + proposal) = 12
-- - 6 trades × 1 inspection report = 6
-- Total: 18 templates
