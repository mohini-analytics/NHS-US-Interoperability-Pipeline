# NHS to US Healthcare Interoperability Pipeline
FHIR R4 | Da Vinci CRD/DTR/PAS | CMS-0057-F | CDS Hooks | NHS UK Core | US Core | RCM Analytics | SQL | HIPAA | GDPR

---

## Project Overview

When a patient with bipolar disorder moves from the UK to the US, their NHS  clinical records - diagnoses coded in SNOMED CT, medications in dm+d, identifiers as NHS Numbers - are invisible to US EHR systems. This project analyses that gap, documents a FHIR R4 transformation approach to bridge it, and extends into the prior authorization and revenue cycle workflows that break when that gap is not resolved.

---

## Business Problem

Over 1.3 million British citizens live in the US. When they transition between healthcare systems, their clinical history - diagnoses, medications, allergies, procedures - exists in incompatible formats. This project maps the technical gap and proposes a FHIR-based interoperability solution, connecting the clinical data problem to its prior authorization failures and Revenue Cycle Management financial consequences.

US payers face an additional deadline. CMS-0057-F requires FHIR R4 prior authorization APIs to be live by January 2026. Organisations receiving international patients must resolve NHS to US data format gaps before prior auth submission - or face automatic denials and reportable compliance breaches.

---

## Key Findings

A UK patient record cannot be directly imported into a US EHR without transformation. The gap exists at three levels:

1. **Identifier** - NHS Number has no US equivalent. Patient matching requires a probabilistic strategy.
2. **Terminology** - SNOMED CT diagnoses must be translated to ICD-10-CM for US billing. DM+d medications must be translated to RxNorm.
3. **Profile** - US Core mandates race and ethnicity extensions not present in NHS records.

Without resolving these three gaps, clinical data arrives at the US system technically valid but clinically unusable - and financially unprocessable for insurance claims.

These gaps have direct prior auth and RCM consequences:
- **Gap 1** causes patient matching failures - administrative denials at eligibility
- **Gap 2** causes CARC 11 denials - diagnosis inconsistent with procedure
- **Gap 3** causes DTR documentation gaps - requests pended beyond the 7-day CMS timeline

---

## Technical Skills Demonstrated

- FHIR R4 resource analysis - UK Core and US Core profiles compared
- REST API calls using Postman - GET queries against NHS sandbox and HAPI FHIR
- POST requests - ClaimResponse resources submitted and validated against HAPI FHIR R4
- JSON structure analysis and transformation mapping
- CMS-0057-F regulatory mapping - four APIs, compliance deadlines, denial requirements
- Da Vinci CRD, DTR, PAS workflow specification
- Empirical FHIR validation finding - server-level validation insufficient for CMS compliance
- SQL data quality analysis including window functions for RCM denial patterns
- RCM analytics - denial rate by CARC code, turnaround compliance, auto-approval tracking
- HL7 v2 context - understanding what FHIR R4 solves compared to legacy messaging
- HIPAA and GDPR compliance framework comparison for cross-border data exchange
- Healthcare BA deliverables - BRD, user stories, acceptance criteria, traceability matrix

---

## NHS Clinical Context

The author worked as Applications Analyst at NHS Devon Partnership Trust - a mental health NHS trust - configuring SystmOne clinical templates, questionnaires, and protocols following the full NHS change lifecycle. This project bridges that hands-on NHS clinical systems experience with US healthcare data standards, demonstrating interoperability literacy across both systems from a BA perspective.

---

## Tools Used

HAPI FHIR R4 Public Server | NHS FHIR Sandbox | Postman | SQL | GitHub | 
HL7 FHIR R4 Specification | UK Core Simplifier (NHS England) | 
US Core HL7 Specification | Da Vinci Implementation Guides | CAQH Index 2023

---

## Repository Structure

| Folder | Contents |
|---|---|
| 01-problem-statement | Clinical scenario and industry analysis |
| 02-fhir-analysis | UK Core vs US Core profile comparison |
| 03-api-calls | Postman GET API calls - NHS sandbox and HAPI FHIR |
| 04-data-mapping | Identifier, terminology and RCM workflow mapping |
| 05-sql-analysis | Data quality queries and RCM denial pattern analysis |
| 06-compliance | HIPAA, GDPR and HL7 standards analysis |
| 07-use-cases | Patient matching, denial prevention, data quality |
| 08-deliverables | BRD, user stories, acceptance criteria |
| 09-prior-auth | CMS-0057-F requirements, Da Vinci CRD/DTR/PAS workflow, ClaimResponse bundles validated via Postman |
| 10-revenue-cycle | Denial management framework, AR analytics SQL, prior auth to billing revenue chain |

---

## Empirical Finding - FHIR Validation vs CMS Compliance

During Postman testing in 09-prior-auth/, the HAPI FHIR R4 server accepted a ClaimResponse resource with 201 Created even when the mandatory `use: preauthorization` field was absent. This proves that FHIR server-level 
validation does not enforce CMS-0057-F business rules. A ClaimResponse without this field cannot be distinguished from a billing claim by receiving systems. Application-layer compliance checking is required - this is the 
gap that prior auth workflow tools must address.

This finding was discovered through hands-on API testing, not from documentation - it demonstrates the difference between knowing a standard and having tested it in practice.
