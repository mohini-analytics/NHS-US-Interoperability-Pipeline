# Use Case 1: Cross-Border Patient Identity Matching

## Clinical Scenario
Sarah Jennings arrives at a New York emergency department. She has been treated for bipolar disorder at the NHS Devon Partnership Trust for three years. Her NHS records have been transmitted ahead of her arrival via FHIR R4.

The US EHR system must determine: is this patient already registered, or does she need a new record created?

Without a reliable matching strategy, two outcomes are equally dangerous - creating a duplicate record that fragments her clinical history, or incorrectly merging her record with another patient's.

---

## Business Problem
Patients moving between NHS and US healthcare systems cannot be reliably matched due to the absence of a shared unique identifier. The NHS Number is a universal 10-digit identifier used across all NHS organisations. 
The US has no equivalent national patient identifier - each hospital creates its own Medical Record Number (MRN), and these are not interoperable across organisations.

This is not a technical gap. It is a structural one. No amount of FHIR standardisation resolves it without a deliberate matching strategy.

---

## Root Cause Analysis

| Factor | Detail | Impact |
|---|---|---|
| No shared identifier | NHS Number has no US equivalent | Cannot perform exact-match lookup |
| Organisation-specific MRNs | Each US hospital creates its own MRN | Same patient may have different IDs at different providers |
| No national US patient index | No federal registry to cross-reference | Probabilistic matching is the only option |
| Name variation | Legal name vs preferred name differences across systems | Demographic matching produces false negatives |

**Result if unresolved:**
- Duplicate patient records created at US intake
- Clinical history fragmented across duplicate records
- The treating clinician makes decisions without a full history
- Patient safety risk - particularly critical for Sarah's mental health medications and crisis management plan

---

## FHIR-Based Solution

FHIR R4 Patient resource supports multiple identifiers with explicit system URLs. This enables a structured matching strategy:

**Step 1 - Exact identifier match attempt**
Query the US EHR: does any existing patient record contain an identifier with system `https://fhir.nhs.uk/Id/nhs-number` and Sarah's NHS Number value?
```json
GET /Patient?identifier=https://fhir.nhs.uk/Id/nhs-number|9000000033
```

If a match is found -> link records, do not create duplicates.

**Step 2 - Demographic match if no identifier match**
Query using name and date of birth:
```
GET /Patient?family=Jennings&given=Sarah&birthdate=1990-05-15
```

Evaluate results using a confidence scoring model:
- Exact name + exact DOB = high confidence (>90%) -> auto-link
- Exact name + near DOB = medium confidence (70-89%) -> flag for manual review
- Partial name match = low confidence (<70%) -> create new record, flag for reconciliation

**Step 3 - Store NHS Number as external reference**
Regardless of the match outcome, the NHS Number must be stored as an external identifier on the US patient record:
```json
{
  "identifier": [
    {
      "use": "secondary",
      "system": "https://fhir.nhs.uk/Id/nhs-number",
      "value": "9000000033"
    },
    {
      "use": "usual",
      "system": "http://hospital.us/mrn",
      "value": "US-NEW-MRN-001"
    }
  ]
}
```

This preserves the audit trail and enables future cross-reference if the patient presents at another US provider.

---

## Acceptance Criteria
```
Given a FHIR Patient resource is received from an NHS system
When the US EHR processes the incoming record
Then the system must query for existing records using the NHS Number identifier
  AND if an exact match is found, the records must be linked without creating a duplicate
  AND the NHS Number must be stored as a secondary identifier on the US record
  AND a new MRN must be generated if no existing record is found
  AND if only a demographic match is found with confidence below 90%, the record must be flagged for manual clinical review before linking
  AND an AuditEvent resource must be created, recording the matching decision and confidence score
```

---

## Business Impact

**Clinical:**
- Eliminates duplicate record creation for cross-border patients
- Ensures the treating clinician has access to complete clinical history, including Sarah's medication history and crisis plan
- Reduces risk of adverse events caused by incomplete information

**Financial:**
- Duplicate records cause claim denials when two records exist for the same patient- the payer cannot adjudicate correctly
- Manual record reconciliation costs an estimated $25-$118 per incident (MGMA research)

**Regulatory:**
- GDPR requires data minimisation - storing unnecessary duplicate records violates this principle
- HIPAA requires accurate patient identification for billing - duplicate records create compliance exposure
