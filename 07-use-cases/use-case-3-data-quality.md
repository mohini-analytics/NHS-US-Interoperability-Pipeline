# Use Case 3: Pre-Transfer Data Quality Validation

## Clinical Scenario
Before Sarah Jennings' NHS record is transmitted to the US 
system, a validation layer runs against the FHIR Bundle.

It finds:
- Her Observation resources use a non-standard coding system 
  that is neither LOINC nor SNOMED CT
- One of her MedicationRequest resources is missing the 
  RxNorm code
- Her address is in UK postcode format

Without pre-transfer validation, all three issues would 
reach the US EHR silently - creating clinical records that 
look complete but contain data that the system cannot 
correctly interpret.

---

## Business Problem
FHIR resources that are technically valid - they parse 
without errors - can still be clinically unusable if they 
contain the wrong coding systems, missing required elements, 
or jurisdiction-specific data formats that the receiving 
system does not recognise.

The problem is that these failures are often silent. The 
data arrives, the system accepts it, but the clinical 
content is invisible to the treating team. A blood pressure 
reading coded with an unrecognised system does not appear 
in the vital signs view. A medication coded with dm+d does 
not appear in the medication reconciliation tool.

Pre-transfer validation catches these failures before they 
become clinical risks.

---

## Root Cause Analysis

| Issue | Root Cause | Clinical Consequence |
|---|---|---|
| Non-standard observation coding | NHS systems may use local codes not in LOINC or SNOMED | Vital signs and lab results invisible to US clinician |
| Missing RxNorm codes | NHS dm+d codes not automatically translated | Medication reconciliation incomplete - adverse drug event risk |
| UK postcode format | Address validation not enforced at source | Address fields fail US system validation - patient contact impossible |
| Missing NHS Number | Emergency admissions sometimes bypass identifier capture | Patient cannot be safely matched to existing records |
| Absent race/ethnicity | Not collected by NHS systems | US Core Must Support elements absent - validation warnings at every downstream system |

---

## FHIR-Based Solution

A validation middleware layer runs before any FHIR Bundle 
is transmitted from the NHS system to the US EHR.

**Validation rules applied:**
```
Rule 1: Patient.identifier must include an entry with
        system = 'https://fhir.nhs.uk/Id/nhs-number'
        → FAIL: block transmission, create incident ticket

Rule 2: Observation.code.coding must include at least one
        entry with system = 'http://loinc.org' OR 
        'http://snomed.info/sct'
        → FAIL: flag resource, allow transmission with warning

Rule 3: MedicationRequest.medicationCodeableConcept.coding 
        must include RxNorm system entry
        → FAIL: hold for terminology translation before transmission

Rule 4: Patient.address.postalCode must match US ZIP format
        (5 digits) if destination system is US-based
        → FAIL: flag for manual address update at registration

Rule 5: us-core-race and us-core-ethnicity extensions absent
        → WARNING: create intake task for registration staff
```

**Severity tiers:**
- **BLOCK** - data cannot be safely transmitted. Transmission 
  halted. Incident ticket created.
- **HOLD** - data requires transformation before transmission. 
  Queued for terminology service.
- **FLAG** - data can transmit but receiving team must be 
  notified. Intake task created.
- **WARNING** - data is incomplete but not unsafe. Logged 
  for audit purposes.

---

## Acceptance Criteria
```
Given that a FHIR Bundle is prepared for cross-border transmission
When the pre-transfer validation layer processes the Bundle
Then each Patient resource must be checked for a valid NHS Number identifier
  AND any Patient resource missing a valid NHS Number must be BLOCKED from transmission
  AND each Observation resource must be checked for LOINC or SNOMED CT coding
  AND Observations with unrecognised coding systems must be FLAGGED with a warning
  AND each MedicationRequest must contain at least one RxNorm coded entry
  AND MedicationRequests without RxNorm codes must be HELD for terminology translation
  AND a FHIR OperationOutcome resource must be generated for every validation failure
      containing the resource ID, element path, severity level, and recommended action
  AND the complete validation report must be accessible as an AuditEvent resource
      for regulatory compliance purposes
```

---

## Business Impact

**Patient Safety:**
- Silent data failures are the most dangerous category 
  in clinical informatics - the clinician does not know 
  what they do not know
- Pre-transfer validation converts silent failures into 
  visible, actionable incidents before they reach the 
  point of care

**Financial:**
- Every data quality failure that reaches the US EHR 
  requires manual remediation - estimated $25-$118 per 
  incident (MGMA)
- Validation at source is orders of magnitude cheaper 
  than remediation at destination

**Regulatory:**
- HIPAA requires covered entities to implement reasonable 
  safeguards for PHI - data quality validation is a 
  technical safeguard
- GDPR requires accuracy as a core data protection 
  principle - validation at transfer point supports 
  this requirement
- FHIR OperationOutcome resources provide the audit trail 
  required by both frameworks

**Operational:**
- Reduces burden on US registration staff who currently 
  collect missing data manually at intake
- Enables systematic tracking of data quality trends 
  across NHS source systems over time
