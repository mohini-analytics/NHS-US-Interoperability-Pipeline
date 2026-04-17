# HL7 FHIR Standards and Profile Conformance

## Overview
This document defines the technical standard requirements for migrating Sarah Jennings' clinical record from NHS UK Core FHIR R4 to US Core FHIR R4, and documents the conformance validation approach used in this project.

---

## 1. Standards Landscape

| Standard | Version Used | Jurisdiction | Governing Body |
|---|---|---|---|
| [HL7 FHIR R4](https://hl7.org/fhir/R4/) | R4 (4.0.1) | Global | HL7 International |
| [UK Core Implementation Guide](https://simplifier.net/hl7fhirukcorer4) | UK Core R4 | United Kingdom | NHS England / HL7 UK |
| [US Core Implementation Guide](https://www.hl7.org/fhir/us/core/) | US Core STU4 | United States | HL7 US Realm |

**Why R4 specifically:**
FHIR R4 is the first version to achieve Normative status for core resources, including Patient, Observation, and Condition.
In the US, it is the regulatory floor mandated by the [ONC 21st Century Cures Act Final Rule](https://www.healthit.gov/curesrule/).
In the UK, it is the standard for NHS England's current implementation programme.

---

## 2. Profile Comparison: UK Core vs US Core

Both profiles extend the base FHIR R4 Patient resource but add jurisdiction-specific constraints.

### 2A. Extensions

| Extension | UK Core | US Core | Migration Action |
|---|---|---|---|
| Race | Not present | `us-core-race` - **Must Support** | Default to "Unknown" - flag for manual collection at registration |
| Ethnicity | Not present | `us-core-ethnicity` - **Must Support** | Default to "Unknown" - flag for manual collection at registration |
| Birth Sex | Not present | `us-core-birthsex` - Must Support | Default to "UNK" - flag for manual collection |
| NHS Number Verification Status | `Extension-UKCore-NHSNumberVerificationStatus` - present | Not applicable | Drop on transformation - not recognised by US systems |
| Ethnic Category | `Extension-UKCore-EthnicCategory` using NHS ethnic codes | Not applicable | Map NHS ethnic category codes to CDC Race and Ethnicity ValueSet during transformation |

**Important mapping note on ethnicity:**
The UK uses NHS ethnic category codes (e.g. A = White British, C = Any other White background). The US CDC Race and Ethnicity ValueSet uses OMB categories (e.g. 2106-3 = White, 2054-5 = Black or African American). 
These do not map 1:1. The transformation layer must apply a best-effort mapping and flag ambiguous cases for manual review rather than silently defaulting.

### 2B. Identifiers

| Identifier | UK Core | US Core | Migration Action |
|---|---|---|---|
| Primary Patient ID | NHS Number (10-digit, Modulus 11 validated, system: `https://fhir.nhs.uk/Id/nhs-number`) | MRN - hospital-specific, no national standard | Store NHS Number as external reference identifier. Generate a new MRN on the US intake. |
| Clinician ID | GMC Number | NPI (National Provider Identifier) | Map where possible - document unmapped clinicians |
| Organisation ID | ODS Code | NPI (Organizational) | Requires manual mapping - no automated translation exists |

**The identifier gap is the core patient safety risk:**
There is no US equivalent of the NHS Number. Without a shared national identifier, the same patient can be registered multiple times across different US providers with no automatic deduplication.
This is why the NHS Number must be preserved as an external reference rather than discarded during migration.

### 2C. Terminology Systems

| Clinical Concept | NHS System | US System | Gap |
|---|---|---|---|
| Diagnoses | SNOMED CT | ICD-10-CM (billing) + SNOMED CT (clinical) | Partial overlap - billing codes require active translation |
| Medications | dm+d (Dictionary of Medicines and Devices) | RxNorm | No direct mapping - requires terminology service |
| Lab Results | SNOMED CT | LOINC | Significant overlap but not complete |
| Procedures | OPCS-4 | CPT | Structural differences - manual mapping required |

---

## 3. Conformance Requirements

For a FHIR resource to be **conformant** with a profile, it must:

1. Declare the profile in `meta.profile`
2. Include all elements marked as `1..1` (required)
3. Be capable of processing all elements marked as `Must Support`
4. Use only values from bound ValueSets where binding is `required`

**Must Support vs Required - the distinction matters:**

A `required` element must be present, or the resource is invalid.
A `Must Support` element must be processable by the receiving system even if it is not present in the source - the system cannot simply ignore it. 
This is why missing race/ethnicity data triggers a validation warning rather than an error - the element is Must Support but not required.

---

## 4. Validation Approach Used in This Project

Rather than running automated FSH validation tooling (which requires a local HAPI server setup), this project demonstrates conformance through structured API testing and manual profile review.

**Step 1 -> Profile review:**
Each UK Core and US Core profile was reviewed directly from the official specification sources linked above. Key constraints were documented in the gap analysis files in this repository.

**Step 2 -> Live API testing:**
GET requests were made against the [HAPI FHIR R4 public test server](https://hapi.fhir.org/baseR4) using Postman. Responses were manually reviewed against the US Core profile requirements - specifically checking for the presence of mandatory elements and correct identifier system URLs.
Full API call documentation is in `/3-api-calls/`.

**Step 3 -> Synthetic resource validation:**
The synthetic Patient resources in `/2-fhir-analysis/` were manually constructed to conform to their respective profiles - UK Core Patient and US Core Patient - with correct system URLs, required extensions, and appropriate identifier structures.

**Production validation approach:**
In a real implementation, conformance would be validated using:
- [HL7 FHIR Validator](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator)
- [Inferno Test Framework](https://inferno-framework.github.io/) for US Core compliance testing
- [HAPI FHIR Validation API](https://hapifhir.io/hapi-fhir/docs/validation/introduction.html)

---

## References
- [HL7 FHIR R4 Specification](https://hl7.org/fhir/R4/)
- [UK Core R4 Implementation Guide — Simplifier](https://simplifier.net/hl7fhirukcorer4)
- [US Core STU4 Implementation Guide — HL7](https://www.hl7.org/fhir/us/core/)
- [ONC 21st Century Cures Act Final Rule](https://www.healthit.gov/curesrule/)
- [SMART on FHIR — HL7](https://hl7.org/fhir/smart-app-launch/)
- [HAPI FHIR Public Test Server](https://hapi.fhir.org/baseR4)
- [HL7 FHIR Validator Tool](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator)
