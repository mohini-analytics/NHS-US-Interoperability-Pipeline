-- =======================================================================================================================================================================================================================================================================
-- RCM Denial Pattern Analysis (Advanced SQL)
-- Purpose: Use Window Functions to identify financial risks in the US Payer environment.
-- ================================================
-- BUSINESS CONTEXT:
-- The 2023 CAQH Index reports the US healthcare industry could save $18.3 billion annually through improved administrative data quality. These queries identify where denial patterns are emerging so revenue cycle teams can intervene before losses compound.
-- ========================================================================================================================================================================================================================================================================

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 1: Rolling Denial Rate by Payer
-- Logic: Uses AVG() OVER with ROWS BETWEEN to calculate a 3-month moving average per payer.
-- Business Use: Smooths out single-month spikes to reveal whether a payer's denial behaviour is genuinely trending upward- enabling proactive contract renegotiation before the trend becomes a revenue crisis.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    payer_name,
    claim_month,
    total_claims,
    denied_claims,
    ROUND(denied_claims * 100.0 / total_claims, 2) 
        AS monthly_denial_pct,
    ROUND(
        AVG(denied_claims * 100.0 / total_claims) 
        OVER (
            PARTITION BY payer_name 
            ORDER BY claim_month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_3mo_avg
FROM monthly_claim_summary
ORDER BY payer_name, claim_month;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 2: High-Impact Denial Ranking
-- Logic: Uses RANK() OVER to order denial reasons by total revenue lost, and calculates each reason's percentage contribution to total losses.
-- Business Use: Directs denial prevention resources efficiently. Rather than treating all denial reasons equally, this query shows which 20% of the reasons are causing 80% of the financial damage.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    denial_reason_code,
    SUM(claim_amount) AS total_lost_revenue,
    RANK() OVER (
        ORDER BY SUM(claim_amount) DESC
    ) AS priority_rank,
    ROUND(
        SUM(claim_amount) * 100.0 / SUM(SUM(claim_amount)) OVER (), 
        2
    ) AS pct_of_total_loss
FROM denied_claims
GROUP BY denial_reason_code
ORDER BY priority_rank;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 3: Provider Performance Variance
-- Logic: Uses AVG() OVER PARTITION BY to compare each provider's denial rate against their department average.
-- Business Use: Identifies outlier providers whose denial rates significantly exceed department norms, flagging where targeted workflow training or coding support would have the highest impact on revenue recovery.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    provider_name,
    department,
    ROUND(denied_claims * 100.0 / total_claims, 2) 
        AS provider_denial_rate,
    ROUND(
        AVG(denied_claims * 100.0 / total_claims) 
        OVER (PARTITION BY department), 
        2
    ) AS dept_avg_denial_rate,
    ROUND(
        (denied_claims * 100.0 / total_claims) - 
        AVG(denied_claims * 100.0 / total_claims) 
        OVER (PARTITION BY department), 
        2
    ) AS variance_from_dept_avg
FROM provider_claim_summary
ORDER BY department, variance_from_dept_avg DESC;

-- ================================================================================================================================================================================================================================================================================
-- BUSINESS IMPACT SUMMARY
-- Query 1: Identifies payers trending toward higher denials
--           → enables proactive contract renegotiation
-- Query 2: Ranks denial reasons by financial impact
--           → directs denial prevention resources efficiently
-- Query 3: Flags providers performing above department average
--           → targets training and workflow intervention
-- Combined insight: Addresses the $25-$118 per-claim rework
-- cost identified in MGMA research (via 2023 CAQH Index),
-- and the front-end data quality failures that cause
-- the majority of preventable denials.
-- =================================================================================================================================================================================================================================================================================
