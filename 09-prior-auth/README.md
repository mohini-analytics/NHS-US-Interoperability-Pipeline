# Prior Authorization - CMS-0057-F and Da Vinci Implementation

## What this section covers

CMS-0057-F, the Interoperability and Prior Authorization Final Rule, requires US payers to implement FHIR R4 APIs for prior authorization by January 2026. This section documents the regulatory requirements, the Da Vinci implementation workflow, and provides sample FHIR bundles with a working compliance validator script.

## Why prior auth matters for NHS to US interoperability

Prior authorization is the first point at which NHS patient data quality failures become financially visible. When a UK patient's SNOMED CT diagnosis codes have not been translated to ICD-10-CM, the payer's rules engine cannot evaluate coverage criteria - the prior auth request fails before clinical review begins. The gaps identified in 02-fhir-analysis/ directly cause the prior auth failures documented here.

## What this section demonstrates

This section maps regulatory obligations to testable technical requirements - the core BA skill in FHIR interoperability projects. It shows understanding of CMS compliance timelines, Da Vinci specification workflows, and the ability to operationalise compliance checks into working code.

**See also:** [RCM Analytics and Denial Management](../10-revenue-cycle/denial-management.md) for the downstream financial consequences when prior auth fails.

## Files in this section

| File | Purpose |
|---|---|
| cms-0057-f-requirements.md | Four APIs, compliance deadlines, operational requirements |
| davinci-workflow.md | CRD to DTR to PAS workflow specification |
| compliance-validator.py | Python script validating ClaimResponse against CMS requirements |
| sample-bundles/ | Approved, denied, and pended ClaimResponse JSON examples |
