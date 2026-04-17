# Cross-Border Data Privacy Analysis: GDPR to HIPAA

## Overview
Moving Sarah Jennings' clinical record from the NHS (UK) to a US health system requires navigating a transition between two fundamentally different regulatory frameworks.

This document identifies the compliance requirements, conflicts, and BA responsibilities at each stage of the data transfer pipeline.

---

## 1. Regulatory Context

| Framework | Jurisdiction | Governing Body | Primary Focus |
|---|---|---|---|
| [UK GDPR](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/) | United Kingdom | ICO (Information Commissioner's Office) | Individual data rights and sovereignty |
| [HIPAA](https://www.hhs.gov/hipaa/index.html) | United States | HHS Office for Civil Rights | Healthcare data portability and billing accountability |

Both frameworks protect patient data but approach it from fundamentally different angles. GDPR treats data as belonging to the individual. HIPAA treats data as a regulated asset within a healthcare transaction system.

---

## 2. Key Mapping and Compliance Gaps

| Feature | GDPR (UK) | HIPAA (US) | BA Requirement |
|---|---|---|---|
| **Legal Basis for Processing** | Explicit Consent or Public Task | Treatment, Payment, or Operations (TPO) - no explicit consent required | Ensure a valid Patient Consent resource is attached to the FHIR Bundle at transfer |
| **Patient Rights** | Right to Erasure (Right to be Forgotten) | Right to Amend and Access only - no erasure right | Document which rights apply at each stage of the pipeline and in which jurisdiction |
| **Data Residency** | Strictly controlled - data must remain in UK/EU unless adequacy decision exists | No federal residency requirement | Require a Data Transfer Agreement and Business Associate Agreement (BAA) before any data leaves UK jurisdiction |
| **Breach Notification** | 72 hours to ICO | 60 days to HHS for breaches affecting 500+ individuals | Define breach notification responsibilities in the BAA |
| **Minimum Necessary** | Data minimisation principle | Minimum Necessary standard | FHIR Bundle should contain only resources required for the clinical encounter - not the full patient history |

---

## 3. The Critical Conflict: Right to Erasure vs. HIPAA Retention

This is the most significant legal tension in cross-border clinical data exchange and has no clean resolution.

**The Problem:**

Under UK GDPR, a patient has the right to request erasure of their personal data. Under HIPAA, a US covered entity is required to retain medical records for a minimum of six years from the date of creation or last effective date.

**The Scenario:**

Sarah Jennings requests erasure of her UK records after relocating to the US. Her NHS trust must comply with GDPR. However, her US provider has already received and acted on that data - and is now legally required to retain it under HIPAA.

**The BA Requirement:**

The transformation pipeline must include a consent management layer that:

1. Records the legal basis for data transfer at the point of export
2. Documents whose jurisdiction's retention rules apply to each copy of the data
3. Ensures the US system can receive and record amendment requests even if it cannot fulfil erasure requests

This conflict must be documented in the Business Associate Agreement and disclosed to the patient before transfer.

---

## 4. Technical Controls

### 4.1 Data in Transit
- **TLS 1.2+ encryption** required for all FHIR API calls
- Applies to both NHS Spine connections and US EHR endpoints
- Verified in this project via HTTPS on all Postman API calls

### 4.2 Access Control
- **OAuth 2.0 with SMART on FHIR scopes** restricts what data each application can access
- Scope `Patient/*.read` limits access to read-only patient data
- Scope should be narrowed to specific resources where possible
  e.g. `Patient/[id].read` rather than `Patient/*.read`
- This implements the Principle of Least Privilege required by both GDPR (data minimisation) and HIPAA (minimum necessary)

### 4.3 Audit Logging
- Both GDPR and HIPAA require audit trails of who accessed what data and when
- FHIR [AuditEvent resource](https://hl7.org/fhir/R4/auditevent.html) provides a standardised mechanism for this
- Every data access in the transfer pipeline should generate an AuditEvent resource

---

## 5. Data Protection Impact Assessment (DPIA)

A DPIA is required under GDPR Article 35 when processing is likely to result in a high risk," cross-border health data transfer meets this threshold.

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| PII exposure during API transit | Medium | Critical | TLS 1.2+ on all connections |
| Unauthorised access to patient record | Medium | Critical | OAuth 2.0 SMART on FHIR scopes |
| Patient identifier mismatch — wrong record accessed | High | Critical | NHS Number validation before transfer |
| Erasure request cannot be fulfilled in US system | High | High | Document in BAA, disclose to patient pre-transfer |
| Audit trail gaps between jurisdictions | Medium | High | FHIR AuditEvent resource at every pipeline stage |

---

## References
- [UK GDPR - ICO Guidance](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/)
- [HIPAA Privacy Rule - HHS](https://www.hhs.gov/hipaa/for-professionals/privacy/index.html)
- [FHIR AuditEvent Resource - HL7](https://hl7.org/fhir/R4/auditevent.html)
- [SMART on FHIR Authorisation - HL7](https://hl7.org/fhir/smart-app-launch/)
- [UK-US Data Bridge Agreement - GOV.UK](https://www.gov.uk/government/publications/uk-us-data-bridge-supporting-documents)
