# BA Deliverables: NHS-to-US FHIR R4 Integration

## Document Information

| Field | Detail |
|---|---|
| Project | NHS UK Core to US Core FHIR R4 Interoperability Pipeline |
| Author | Mohini Rana - Applications Analyst, NHS Devon Partnership Trust |
| Version | 1.0 |
| Date | March 2026 |
| Status | Draft for Review |

---

# Section 1: Business Requirements Document (BRD)

## 1.1 Executive Summary

NHS and US healthcare systems use incompatible FHIR R4 profiles,
terminology systems, and patient identifiers. When patients 
transition between these systems - as in the case of Sarah Jennings,
a UK patient with bipolar disorder and Type 1 diabetes relocating 
to New York - their clinical records cannot be safely received or 
used without active transformation.

This project defines the business requirements for a FHIR-based 
interoperability pipeline that enables safe, accurate, and 
standards-compliant exchange of patient data between NHS UK Core 
R4 and US Core R4 systems.

---

## 1.2 Problem Statement

**Current State:**
A patient transferring from an NHS trust to a US health system 
must either carry paper records or rely on the receiving clinician 
to start from scratch. When digital records are transmitted, they 
arrive in UK Core FHIR format - which US EHR systems cannot 
directly consume because:

- Terminology systems are incompatible (SNOMED CT vs ICD-10-CM,
  dm+d vs RxNorm)
- Patient identifiers are incompatible (NHS Number vs MRN)
- Profile constraints differ (US Core mandates race/ethnicity 
  extensions not present in NHS records)

**Consequences:**
- Clinical history is incomplete at point of care
- Prior authorisation and claim submissions fail due to 
  missing or wrong-format codes
- Manual rework costs $25–$118 per incident (MGMA)
- The US healthcare industry loses an estimated $18.3 billion 
  annually to preventable administrative data failures 
  (2023 CAQH Index)

**Desired State:**
A transformation middleware layer that automatically converts 
NHS UK Core FHIR R4 resources into US Core FHIR R4 compliant 
resources - preserving clinical meaning, maintaining audit 
trails, and satisfying both GDPR and HIPAA requirements.

---

## 1.3 Objectives

| # | Objective | Success Measure |
|---|---|---|
| 1 | Enable safe patient identity matching across NHS and US systems | Zero duplicate records created for patients with valid NHS Numbers |
| 2 | Translate clinical terminology to US billing standards | 100% of Condition resources contain ICD-10-CM codes on US intake |
| 3 | Translate medication codes to US pharmacy standards | 100% of MedicationRequest resources contain RxNorm codes on US intake |
| 4 | Validate data quality before transmission | Zero records with critical validation failures reaching US EHR |
| 5 | Maintain compliance with GDPR and HIPAA simultaneously | Full audit trail via AuditEvent resources at every pipeline stage |

---

## 1.4 Scope

**In Scope:**
- Patient resource transformation (UK Core -> US Core)
- Condition resource terminology translation (SNOMED CT -> ICD-10-CM)
- MedicationRequest terminology translation (dm+d -> RxNorm)
- Observation resource coding validation (LOINC / SNOMED CT)
- Pre-transfer data quality validation layer
- Patient identity matching strategy
- GDPR / HIPAA compliance framework

**Out of Scope:**
- Real-time EHR integration (this project documents the transformation logic - implementation requires engineering)
- HL7 v2 legacy system migration
- Clinical decision support
- Billing system integration beyond prior authorisation

---

## 1.5 Assumptions

- Source system exports data in UK Core FHIR R4 format
- Receiving system accepts US Core FHIR R4 compliant resources
- A terminology translation service (e.g. NLM UMLS) is available for SNOMED CT to ICD-10-CM mapping
- A Business Associate Agreement (BAA) exists between sending and receiving organisations before any transfer occurs
- Patient has provided consent for international data transfer

---

## 1.6 Constraints

- NHS Number must be preserved - it cannot be discarded or 
  overwritten during transformation
- Race and ethnicity data not present in NHS records - US system 
  must handle absent Must Support elements gracefully
- GDPR Right to Erasure may conflict with HIPAA retention 
  requirements - documented in `/6-compliance/hipaa-gdpr-analysis.md`
- Terminology mapping is not always 1:1 - ambiguous mappings 
  must be flagged for clinical review, not silently defaulted

---

## 1.7 Success Criteria

The pipeline is considered successful when:

1. A UK Core Patient resource can be transformed into a 
   US Core Patient resource with zero validation errors 
   against the US Core StructureDefinition
2. All Condition resources contain ICD-10-CM codes 
   accepted by a US payer adjudication system
3. Patient identity matching produces zero false positive 
   matches (wrong patient linked to wrong record)
4. Every transformation generates an AuditEvent resource 
   suitable for GDPR and HIPAA audit purposes
5. Pre-transfer validation catches 100% of BLOCK-level 
   data quality failures before they reach the US EHR

---

# Section 2: User Stories

## Story 1 — Patient Identity Matching
```
As a US clinician receiving a transferred NHS patient
I want the EHR to automatically attempt patient matching 
using the NHS Number
So that I do not create a duplicate record and the patient's 
full clinical history is available at the point of care
```

**Acceptance Criteria:** See Section 3, AC-001

---

## Story 2 — Diagnosis Code Translation
```
As a US medical billing specialist
I want all diagnoses in transferred NHS records to be 
expressed in ICD-10-CM format
So that I can submit prior authorisation requests and 
insurance claims without manual recoding
```

**Acceptance Criteria:** See Section 3, AC-002

---

## Story 3 — Medication Code Translation
```
As a US pharmacist receiving a transferred medication list
I want all medications to be expressed in RxNorm format
So that I can process prescriptions through the US pharmacy 
benefit system without manual intervention
```

**Acceptance Criteria:** See Section 3, AC-003

---

## Story 4 — Pre-Transfer Data Quality Validation
```
As a data governance officer responsible for cross-border 
patient data exchange
I want all FHIR resources to be validated against 
predefined quality rules before transmission
So that data quality failures are caught at source rather 
than discovered at the point of clinical care
```

**Acceptance Criteria:** See Section 3, AC-004

---

## Story 5 — Race and Ethnicity Handling
```
As a US registration staff member receiving a transferred 
NHS patient record
I want the system to alert me when mandatory US Core 
fields (race, ethnicity, birth sex) are absent from the 
incoming record
So that I can collect this information directly from the 
patient at registration without it blocking the intake process
```

**Acceptance Criteria:** See Section 3, AC-005

---

## Story 6 — Audit and Compliance Trail
```
As a compliance officer responsible for GDPR and HIPAA 
obligations
I want every data transformation and transfer event to 
generate a FHIR AuditEvent resource
So that I can demonstrate to regulators that patient data 
was handled lawfully and securely at every stage of 
the pipeline
```

**Acceptance Criteria:** See Section 3, AC-006

---

# Section 3: Acceptance Criteria

## AC-001: Patient Identity Matching
```
Given a FHIR Patient resource is received from an NHS system
  containing an identifier with system 
  'https://fhir.nhs.uk/Id/nhs-number'
When the US EHR processes the incoming resource
Then the system must query existing records using the NHS Number
  AND if an exact NHS Number match is found,
      the records must be linked without creating a new MRN record
  AND if no exact match is found,
      a demographic match must be attempted using name and date of birth
  AND if demographic match confidence is below 90%,
      the record must be flagged for manual clinical review
      before any linking occurs
  AND the NHS Number must be stored as a secondary identifier
      on the resulting US patient record regardless of match outcome
  AND an AuditEvent resource must be created recording
      the match decision, confidence score, and operator ID
```

---

## AC-002: Diagnosis Code Translation
```
Given a FHIR Condition resource is received containing 
  SNOMED CT coded diagnoses
When the transformation middleware processes the resource
Then the output Condition resource must contain at least 
  one ICD-10-CM coded entry in the code.coding array
  AND the ICD-10-CM system URL must be 
      'http://hl7.org/fhir/sid/icd-10-cm'
  AND where a SNOMED CT code maps to multiple ICD-10-CM codes,
      the mapping must be flagged for clinical review
      rather than defaulted silently
  AND the original SNOMED CT code must be preserved 
      as an additional coding entry for clinical reference
  AND the transformed resource must declare conformance to 
      US Core Condition profile in meta.profile
```

---

## AC-003: Medication Code Translation
```
Given a FHIR MedicationRequest resource is received 
  containing dm+d coded medications
When the transformation middleware processes the resource
Then the output MedicationRequest must contain at least 
  one RxNorm coded entry
  AND the RxNorm system URL must be 
      'http://www.nlm.nih.gov/research/umls/rxnorm'
  AND where no RxNorm mapping exists for a dm+d code,
      the resource must be HELD and a manual mapping 
      task created - it must not be transmitted with 
      an empty medication code
  AND the transformed resource must declare conformance 
      to US Core MedicationRequest profile in meta.profile
```

---

## AC-004: Pre-Transfer Data Quality Validation
```
Given a FHIR Bundle is prepared for cross-border transmission
When the pre-transfer validation layer processes the Bundle
Then each Patient resource must be validated for NHS Number presence
  AND Patient resources missing a valid NHS Number must be 
      BLOCKED from transmission with a FHIR OperationOutcome 
      returned specifying the failed element path
  AND each Observation resource must be validated for 
      LOINC or SNOMED CT coding
  AND Observations with unrecognised coding systems must be 
      FLAGGED - transmittable with warning - not blocked
  AND each MedicationRequest must be validated for RxNorm coding
  AND MedicationRequests without RxNorm codes must be HELD 
      for terminology translation before transmission
  AND a complete validation report must be generated as 
      an AuditEvent resource before any transmission occurs
```

---

## AC-005: Race and Ethnicity Collection
```
Given a US Core Patient resource is created from an NHS record
  where us-core-race and us-core-ethnicity extensions are absent
When the resource is imported into the US EHR
Then the system must not reject the resource due to 
  absent race/ethnicity data
  AND the system must create a registration intake task 
      alerting staff that race and ethnicity data is required
  AND the task must remain open until the data is 
      collected from the patient directly
  AND the system must not default race or ethnicity to 
      any value without explicit patient confirmation
```

---

## AC-006: Audit and Compliance Trail
```
Given any transformation or transmission event occurs 
  in the FHIR interoperability pipeline
When the event completes - whether successfully or with errors
Then a FHIR AuditEvent resource must be created containing:
    - event type (transform / transmit / validate / match)
    - outcome (success / failure / warning)
    - agent (system or operator performing the action)
    - entity (patient resource and specific resource ID affected)
    - timestamp in UTC
  AND the AuditEvent must be retained for a minimum of 
      six years to satisfy HIPAA record retention requirements
  AND the AuditEvent must be accessible via FHIR API query 
      by authorised compliance officers
  AND AuditEvents must be generated even for failed 
      transmissions - the absence of a record must never 
      mean the event did not occur
```

---

## Traceability Matrix

| User Story | Business Requirement | Acceptance Criteria | Use Case |
|---|---|---|---|
| Story 1 - Patient Matching | BR-01: Enable safe identity matching | AC-001 | Use Case 1 |
| Story 2 - Diagnosis Translation | BR-02: Translate to US billing standards | AC-002 | Use Case 2 |
| Story 3 - Medication Translation | BR-02: Translate to US billing standards | AC-003 | Use Case 2 |
| Story 4 - Data Quality Validation | BR-04: Validate before transmission | AC-004 | Use Case 3 |
| Story 5 - Race/Ethnicity Handling | BR-01 + BR-04 | AC-005 | Use Case 1 + 3 |
| Story 6 - Audit Trail | BR-05: GDPR/HIPAA compliance | AC-006 | Compliance folder |
