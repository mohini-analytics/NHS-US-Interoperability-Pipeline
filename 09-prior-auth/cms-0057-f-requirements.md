# CMS-0057-F Requirements - Interoperability and Prior Authorization Final Rule

## Overview

CMS-0057-F was finalised in February 2024. It requires impacted payers - including Medicare Advantage, Medicaid, CHIP, and QHP issuers - to implement FHIR R4 APIs that modernise prior authorization and improve data sharing across the US healthcare system. For NHS patients transferring to US healthcare, this rule directly governs how their clinical data must be structured for 
prior auth submission.

---

## The Four APIs

### 1. Patient Access API - Enhanced
**Who uses it:** Patients, via third-party health apps connected to their payer.  
**What it contains:** Claims data, encounter data, clinical data, and - new under CMS-0057-F - prior authorization decisions and status.  
**Compliance deadline:** January 1, 2026.  
**Relevance to this project:** A UK patient can use the Patient Access API to retrieve their US prior auth history, providing continuity of documentation across payer transitions.

### 2. Provider Access API - New
**Who uses it:** In-network providers, querying payer systems on behalf of patients.  
**What it contains:** Claims, encounters, clinical data, and prior auth information for attributed patients.  
**Compliance deadline:** January 1, 2027.  
**Relevance to this project:** A US provider receiving an NHS patient can query the payer directly for what clinical information they already hold, reducing documentation gaps that cause clinical denials.

### 3. Payer-to-Payer API - Re-introduced
**Who uses it:** Payers, exchanging member data when a patient switches insurance.  
**What it contains:** Five years of claims data and prior authorization history.  
**Compliance deadline:** January 1, 2027.  
**Relevance to this project:** Establishes the principle of longitudinal data portability. An NHS patient switching US payers benefits from the same continuity mechanism, though NHS data must first be transformed to the US Core FHIR format.

### 4. Prior Authorization API - New
**Who uses it:** Providers submitting prior auth requests to payers.
**What it contains:** FHIR-based prior auth requests and responses replacing legacy fax and phone workflows.  
**Compliance deadline Phase 1:** January 1, 2026 - prior auth process requirements begin. Payers must meet the 72-hour urgent / 7-day standard turnaround times and return structured denial reason codes.    
**Compliance deadline Phase 2:** January 1, 2027 — full Prior Authorization API implementation required. Payers must support FHIR-based electronic prior auth submission and response.

---

## Operational Requirements

### Response Time Mandates
CMS-0057-F sets mandatory turnaround times for prior authorization decisions:

| Request Type | Maximum Decision Time |
|---|---|
| Urgent / Expedited | 72 hours |
| Standard | 7 calendar days |

Breach of these timelines is a reportable violation. Public reporting of prior auth metrics begins in March 2026, covering approval rates, denial rates, and turnaround time compliance by payer.

### Denial Reason Requirements
Under CMS-0057-F, payers must return a **specific reason code** for every prior authorization denial. Free text alone is insufficient. This requirement enables:
- Systematic denial pattern analysis (see 10-revenue-cycle/ar-analytics.sql)
- Faster appeals - providers can respond to a specific code rather than interpreting an unstructured narrative
- Regulatory oversight - CMS can aggregate denial reason data across payers

The structured denial reason maps to the `adjudication.reason` field in the FHIR ClaimResponse resource. See sample-bundles/denied-claimresponse.json for implementation example.

### Continuity of Care Requirement
When a prior auth denial is issued, payers must provide information on what documentation would be needed for approval. This is operationalised through the DTR questionnaire workflow - see davinci-workflow.md.

---

## NHS Interoperability Intersection

CMS-0057-F assumes all prior auth requests arrive with:
- ICD-10-CM diagnosis codes
- RxNorm medication codes
- US Core compliant patient demographics

NHS records contain SNOMED CT diagnoses, dm+d medication codes, and NHS Number identifiers. Without the transformation documented in 02-fhir-analysis/ and 04-data-mapping/, an NHS patient's prior auth request will fail CMS-0057-F compliant systems at the point of submission.

---

## References

- [CMS-0057-F Final Rule - Federal Register](https://www.federalregister.gov/documents/2024/02/08/2024-00895/medicare-and-medicaid-programs-patient-protection-and-affordable-care-act-interoperability-and-prior)
- [Da Vinci Prior Authorization Support IG](https://hl7.org/fhir/us/davinci-pas/)
