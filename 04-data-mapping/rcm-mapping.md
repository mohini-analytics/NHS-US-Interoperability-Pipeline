# RCM Workflow Mapping: NHS to US Healthcare

## Overview
Revenue Cycle Management (RCM) is the financial process US
healthcare providers use to track patient care from registration
to final payment. It does not exist in the NHS - which is a
single-payer system funded through taxation.

When NHS patients transition to US healthcare, their clinical
data must be not only clinically usable but also financially
processable for the US insurance system.

## NHS vs US Healthcare Model

| Feature | NHS (UK) | US Private Insurance |
|---|---|---|
| Funding model | Tax-funded, universal coverage | Payer-provider system - insurance required |
| Patient billing | Free at point of care | Patient responsible for co-pay and deductible |
| Coding purpose | Clinical documentation and statistics | Clinical documentation AND insurance billing |
| Primary coding system | SNOMED CT | ICD-10-CM (diagnoses), CPT (procedures) |
| Prior authorisation | Not required | Required for many procedures and medications |
| Claim submission | Not applicable | 837 transaction (EDI standard) |
| Remittance advice | Not applicable | 835 transaction (EOB - Explanation of Benefits) |

## The RCM Impact of Poor Interoperability

When Sarah Jennings' NHS records arrive at a US provider
without terminology translation:

**Stage 1 - Registration and Eligibility**
- Insurance eligibility check (X12 270/271 transaction) requires
  correct patient demographics
- UK postcode format fails US address validation
- Insurance member ID unknown - eligibility check cannot run

**Stage 2 - Prior Authorisation**
- Psychiatry referral requires prior auth submission
- Auth request needs ICD-10-CM diagnosis codes
- NHS record contains SNOMED CT - payer rejects request
- Manual rework required: estimated 11–22 minutes per transaction

**Stage 3 - Claim Submission**
- Claim requires ICD-10-CM diagnosis and CPT procedure codes
- dm+d medication codes not recognised by billing system
- Claim denied - missing or invalid codes

**Stage 4 - Denial Management**
- Denied claim requires manual review and resubmission
- Cost per rework: $25–$118 (MGMA)
- 90% of denials are avoidable with correct data at intake

## Financial Scale

According to the 2023 CAQH Index:
- US healthcare industry spends $18.3 billion annually on
  administrative transactions that could be automated
- Eligibility verification and prior authorisation represent
  the largest savings opportunities
- Manual claim processing costs 5–10x more than electronic

## How FHIR R4 Fixes This

FHIR R4 with US Core profile compliance ensures:
- Patient demographics arrive in US-compatible format
- Diagnoses are ICD-10-CM coded for billing
- Medications are RxNorm coded for pharmacy processing
- Prior auth requests contain all required clinical data
- Claims can be auto-adjudicated rather than manually reviewed

This is why FHIR interoperability is not just a technical
standard - it is a financial governance requirement for
US healthcare organisations receiving international patients.

## References
- [2023 CAQH Index Report](https://www.caqh.org/hubfs/43908627/drupal/2024-01/2023_CAQH_Index_Report.pdf)
- [MGMA Denial Research via Vyne Medical](https://vynemedical.com/blog/tackling-rising-denial-rates-in-2023/)
- [X12 EDI Healthcare Transactions](https://x12.org/products/transaction-sets)
