# Use Case 2: FHIR-Based Prior Authorisation Denial Prevention

## Clinical Scenario
Sarah Jennings requires a prescription for lithium carbonate 
(a mood stabiliser for her bipolar disorder) and a referral 
to a psychiatrist within her first week in New York.

Her US provider submits a prior authorisation request to her 
insurance payer. The payer's system receives the request but 
cannot auto-adjudicate it because:
- Her diagnosis is coded in SNOMED CT (NHS standard), 
  not ICD-10-CM (US billing standard)
- Her medication is coded using dm+d (NHS drug codes), 
  not RxNorm (US drug codes)

The claim is denied. Manual rework begins.

---

## Business Problem
Prior authorisation denials represent one of the largest sources 
of preventable revenue loss in US healthcare. When NHS clinical 
data arrives in a US system without terminology translation, the 
payer's automated adjudication system cannot process it.

According to MGMA research (via Vyne Medical, 2023), three of 
the top four causes of denials occur at the front end of the 
revenue cycle - specifically during registration and data intake 
where external clinical data is most likely to arrive in 
non-standard formats.

The manual cost to rework a single denied claim is estimated 
between $25 and $118. The 2023 CAQH Index reports the US 
healthcare industry could save $18.3 billion annually by 
transitioning to fully electronic, standardised administrative 
transactions.

---

## Root Cause Analysis

| Data Element | NHS Format | US Required Format | Result if Not Translated |
|---|---|---|---|
| Diagnosis | SNOMED CT code `13746004` (Bipolar disorder) | ICD-10-CM code `F31.9` (Bipolar disorder, unspecified) | Payer cannot identify covered diagnosis -> denial |
| Medication | dm+d code for lithium carbonate | RxNorm code `49568` (lithium carbonate) | Pharmacy benefit cannot process -> manual review triggered |
| Procedure | OPCS-4 code | CPT code | Prior auth request rejected - wrong code system |

**Why SNOMED and ICD-10-CM do not map automatically:**
SNOMED CT is a clinical terminology designed for granular 
clinical documentation. ICD-10-CM is a billing classification 
designed for insurance reimbursement. They overlap but are 
not equivalent. A SNOMED code for "Bipolar disorder type I, 
current episode manic, severe, without psychotic features" 
maps to multiple possible ICD-10-CM codes depending on the 
billing context. This requires an active terminology 
translation service, not a static lookup table.

---

## FHIR-Based Solution

Implementing US Core FHIR R4 at the point of prior 
authorisation request ensures all clinical data arrives 
in payer-processable format.

**Condition resource - required coding:**
```json
{
  "resourceType": "Condition",
  "code": {
    "coding": [
      {
        "system": "http://hl7.org/fhir/sid/icd-10-cm",
        "code": "F31.9",
        "display": "Bipolar disorder, unspecified"
      }
    ]
  }
}
```

**MedicationRequest resource - required coding:**
```json
{
  "resourceType": "MedicationRequest",
  "medicationCodeableConcept": {
    "coding": [
      {
        "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
        "code": "49568",
        "display": "lithium carbonate"
      }
    ]
  }
}
```

The transformation middleware must validate these resources 
against the US Core profile before submission to the payer 
system.

---

## Acceptance Criteria
```
Given a prior authorisation request is generated for a cross-border patient
When clinical data is transmitted via FHIR R4 to the payer system
Then all Condition resources must contain at least one ICD-10-CM coded entry
  AND all MedicationRequest resources must contain RxNorm coded medications
  AND the submitted Bundle must declare conformance to the US Core profile 
      in each resource's meta.profile element
  AND the payer system must return an authorisation decision within 24 hours
      for requests where all mandatory fields are present and correctly coded
  AND any resource failing US Core validation must be rejected by the 
      middleware before submission — not passed to the payer in invalid state
  AND a FHIR OperationOutcome resource must be returned for any rejected 
      resource, specifying which element failed validation and why
```

---

## Business Impact

**Financial (quantified):**
- Baseline denial rate for prior authorisations: typically 
  10-15% in US healthcare (MGMA data)
- Target denial rate with FHIR-compliant data submission: <5%
- Rework cost per denied claim: $25-$118 (MGMA estimate)
- At scale: a provider submitting 1,000 prior auth requests 
  per month saves an estimated $25,000-$118,000 monthly 
  in rework costs alone

**Clinical:**
- Sarah receives her lithium prescription without delay
- No gap in mental health medication - critical for 
  a patient with bipolar disorder, where medication 
  continuity directly impacts clinical outcomes

**Regulatory:**
- US Core FHIR R4 is mandated by the ONC 21st Century 
  Cures Act for certified EHR systems
- Payers who receive non-conformant data are not obligated 
  to process it - FHIR conformance is both a clinical and 
  a compliance requirement
