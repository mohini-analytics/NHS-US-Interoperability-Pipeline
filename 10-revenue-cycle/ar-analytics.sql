-- ====================================================================================================================================================================================
-- AR ANALYTICS - NHS TO US INTEROPERABILITY PIPELINE
-- Revenue Cycle Management: Prior Auth Decision Analytics
-- ====================================================================================================================================================================================
-- PIPELINE POSITION:
-- This file covers the prior authorisation stage of RCM.
-- For downstream billing denial analysis using window functions,
-- see 05-sql-analysis/window-function-analysis.sql.
-- Together, these files cover the full RCM denial pipeline:
-- Prior Auth Decision -> Claim Submission -> Denial Pattern Analysis
-- ====================================================================================================================================================================================


-- ====================================================================================================================================================================================
-- QUERY 1: Denial Rate by Reason Code
-- ====================================================================================================================================================================================
-- Business question: Which denial reasons are driving the most volume?
-- CMS-0057-F link: Structured denial reason codes are mandatory from
--                  January 2026 - this query only works if that field
--                  is populated, making it a compliance check in itself.
-- Business use: Identifies top denial categories for process improvement.
--         High volume of CARC 11 (diagnosis/procedure mismatch) points
--         to SNOMED CT -> ICD-10-CM translation failures upstream.
-- ====================================================================================================================================================================================

SELECT
    denial_reason_code,
    denial_reason_description,
    COUNT(*) AS denial_count,
    SUM(claim_amount) AS total_revenue_at_risk,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2
    ) AS percentage_of_total_denials,
    -- UK transfer cohort flag — connects denial patterns to
    -- interoperability failures identified in 02-fhir-analysis
    SUM(CASE WHEN patient_origin = 'UK_TRANSFER' THEN 1 ELSE 0 END) AS uk_transfer_denials
FROM prior_auth_decisions
WHERE review_action_code = 'A4'  -- A4 = denied
GROUP BY denial_reason_code, denial_reason_description
ORDER BY denial_count DESC;


-- ====================================================================================================================================================================================
-- QUERY 2: Prior Auth Turnaround Time - CMS Compliance Tracking
-- ====================================================================================================================================================================================
-- Business question: Are we meeting CMS-0057-F response time mandates?
-- CMS-0057-F link: 72 hours for urgent requests, 7 days for standard.
--                  Breach of these timelines is a reportable violation
--                  from March 2026.
-- Business use: Feeds into public reporting requirements. Identifies payers
--         or request types that consistently breach timelines.
-- ====================================================================================================================================================================================

SELECT
    request_id,
    patient_origin,
    urgency_flag,
    submitted_timestamp,
    decision_timestamp,
    DATEDIFF(hour, submitted_timestamp, decision_timestamp) AS hours_to_decision,
    CASE
        WHEN urgency_flag = 'urgent'
             AND DATEDIFF(hour, submitted_timestamp, decision_timestamp) <= 72
            THEN 'COMPLIANT'
        WHEN urgency_flag = 'standard'
             AND DATEDIFF(day, submitted_timestamp, decision_timestamp) <= 7
            THEN 'COMPLIANT'
        ELSE 'BREACH'
    END AS cms_compliance_status
FROM prior_auth_decisions
ORDER BY submitted_timestamp DESC;


-- ====================================================================================================================================================================================
-- QUERY 3: Monthly Auto-Approval Rate Tracking
-- ====================================================================================================================================================================================
-- Business question: What proportion of requests are being auto-approved
--                    vs pended to manual nurse/director review?
-- CMS-0057-F link: CMS expects auto-approval rates to increase as
--                  FHIR-based prior auth matures. Low auto-approval
--                  rates indicate documentation gaps at submission.
-- Business use: Month-on-month trend shows whether DTR implementation is
--         reducing manual review burden as intended.
-- ====================================================================================================================================================================================

SELECT
    DATE_TRUNC('month', submitted_timestamp) AS month,
    COUNT(*) AS total_requests,
    SUM(CASE WHEN review_action_code = 'A1'
             AND auto_approved = true THEN 1 ELSE 0 END) AS auto_approved,
    SUM(CASE WHEN review_action_code = 'WQ' THEN 1 ELSE 0 END) AS pended_to_nurse,
    SUM(CASE WHEN review_action_code = 'A4' THEN 1 ELSE 0 END) AS denied,
    ROUND(
        SUM(CASE WHEN auto_approved = true THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS auto_approval_rate_pct,
    -- UK transfer cohort breakdown — tracks whether interoperability
    -- improvements reduce manual review for this patient population
    SUM(CASE WHEN patient_origin = 'UK_TRANSFER' THEN 1 ELSE 0 END) AS uk_transfer_total,
    SUM(CASE WHEN patient_origin = 'UK_TRANSFER'
             AND review_action_code = 'A4' THEN 1 ELSE 0 END) AS uk_transfer_denied
FROM prior_auth_decisions
GROUP BY DATE_TRUNC('month', submitted_timestamp)
ORDER BY month;
