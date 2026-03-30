# NHS to US Healthcare Interoperability Pipeline
### FHIR R4 | REST APIs | HL7 | NHS UK Core | US Core | SQL | HIPAA | GDPR

---

## Project Overview

When a patient with bipolar disorder moves from the UK to the US, 
their NHS clinical records - diagnoses coded in SNOMED CT, 
medications in dm+d, identifiers as NHS Numbers - are invisible 
to US EHR systems. This project analyses that gap and documents 
a FHIR R4 transformation approach to bridge it.

---

## Business Problem

Over 1.3 million British citizens live in the US. When they 
transition between healthcare systems, their clinical history - 
diagnoses, medications, allergies, procedures - exists in 
incompatible formats. This project maps the technical gap and 
proposes a FHIR-based interoperability solution, connecting 
the clinical data problem to its Revenue Cycle Management 
financial consequences.

---

## Technical Skills Demonstrated

- FHIR R4 resource analysis - UK Core and US Core profiles compared
- REST API calls using Postman against the HAPI FHIR R4 public server
- JSON structure analysis and transformation mapping
- SQL data quality analysis including window functions for RCM denial patterns
- HL7 v2 context - understanding what FHIR R4 solves compared to legacy messaging
- HIPAA and GDPR compliance framework comparison for cross-border data exchange
- RCM workflow mapping - eligibility, claims, denial patterns, financial impact
- Healthcare BA deliverables - BRD, user stories, acceptance criteria, traceability matrix

---

## NHS Context

The author worked as Applications Analyst at NHS Devon Partnership 
Trust - a mental health NHS trust - configuring SystmOne clinical 
templates, questionnaires, and protocols following the full NHS change 
lifecycle. This project bridges that hands-on NHS clinical systems 
experience with US healthcare data standards, demonstrating 
interoperability literacy across both systems from a BA perspective.

---

## Tools Used

HAPI FHIR R4 Public Server | Postman | SQL | GitHub |  
HL7 FHIR R4 Specification | UK Core Simplifier (NHS England) |  
US Core HL7 Specification | CAQH Index 2023

---

## Repository Structure
```
/NHS-US-Interoperability-Pipeline
├── /1-problem-statement      Clinical scenario and industry analysis
├── /2-fhir-analysis          UK Core vs US Core profile comparison
├── /3-api-calls              Postman API documentation and screenshots
├── /4-data-mapping           Identifier, terminology and RCM mapping
├── /5-sql-analysis           Data quality and denial pattern SQL queries
├── /6-compliance             HIPAA, GDPR and HL7 standards analysis
├── /7-use-cases              Patient matching, denial prevention, data quality
└── /8-deliverables           BRD, user stories, acceptance criteria
```

---

## Key Finding

A UK patient record cannot be directly imported into a US EHR 
without transformation. The gap exists at three levels:

1. **Identifier** - NHS Number has no US equivalent. Patient 
   matching requires a probabilistic strategy.
2. **Terminology** - SNOMED CT diagnoses must be translated to 
   ICD-10-CM for US billing. dm+d medications must be translated 
   to RxNorm.
3. **Profile** - US Core mandates race and ethnicity extensions 
   not present in NHS records.

Without resolving these three gaps, clinical data arrives at the 
US system technically valid but clinically unusable - and 
financially unprocessable for insurance claims.
