-- =============================================================================================================================================================================================================================================================
-- FHIR Patient Data Quality Analysis
-- Purpose: Identify systemic data quality issues that prevent safe NHS to US Core data exchange.
-- =============================================================================================================================================================================================================================================================
-- CLINICAL CONTEXT:
-- These queries support safe cross-border patient data migration.
-- Poor data quality at the source creates three risks:
-- 1. Patient safety: wrong patient matched to the wrong record
-- 2. Clinical: incomplete history at point of care
-- 3. Financial: claim denials due to missing or wrong coding
-- =============================================================================================================================================================================================================================================================

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 1: NHS Number Validation (Modulus 11 Prep)
-- Logic: Identifies missing, malformed, or wrong-system IDs.
-- Clinical Risk: Without a valid NHS Number, the receiving US system cannot safely match this patient to existing records, creating duplicate patient risk.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    patient_id,
    full_name,
    identifier_system,
    identifier_value,
    CASE 
        WHEN identifier_system != 'https://fhir.nhs.uk/Id/nhs-number' 
            THEN 'ACTION REQUIRED: WRONG IDENTIFIER SYSTEM'
        WHEN identifier_value IS NULL 
            THEN 'CRITICAL: MISSING NHS NUMBER'
        WHEN LENGTH(identifier_value) != 10 
            THEN 'ERROR: INVALID LENGTH (EXPECTED 10)'
        ELSE 'VALID FORMAT'
    END AS validation_status
FROM patient_records
ORDER BY validation_status DESC;

-- NOTE: A valid format (10 digits, correct system URL) is necessary but not sufficient. Full Modulus 11 checksum validation requires application-layer logic. This query is the first triage step.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 2: Cross-Border Coding Compliance
-- Logic: Ensures Observations use US-standard (LOINC) or UK-standard (SNOMED CT) to prevent data loss during cross-border transfer.
-- Clinical Risk: An observation with an unrecognised coding system will be ignored by the receiving EHR, meaning critical lab results or vitals become invisible to the treating clinician.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    observation_id,
    coding_system,
    coding_code,
    CASE
        WHEN coding_system IS NULL 
            THEN 'MISSING SYSTEM'
        WHEN coding_system NOT IN (
            'http://loinc.org', 
            'http://snomed.info/sct'
        ) 
            THEN 'NON-COMPLIANT TERMINOLOGY'
        ELSE 'VALID'
    END AS compliance_check
FROM observations
WHERE observation_date > '2025-01-01'
ORDER BY compliance_check DESC;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query 3: Duplicate Record Detection (Fuzzy Match)
-- Logic: Identifies patients with the same Name and DOB but different patient IDs, a common consequence of cross-border migrations where no shared identifier exists.
-- Clinical Risk: Duplicate records mean a clinician may access an incomplete record, missing prior diagnoses, medications, or allergy information.
-- Note: Name/DOB matching is an approximation. Production systems should combine with phonetic matching and additional demographic fields for higher confidence.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    full_name,
    date_of_birth,
    COUNT(*) AS record_count,
    STRING_AGG(patient_id, ' | ') AS duplicate_ids
FROM patient_records
GROUP BY full_name, date_of_birth
HAVING COUNT(*) > 1
ORDER BY record_count DESC;
