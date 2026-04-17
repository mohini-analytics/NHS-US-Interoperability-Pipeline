# Sample ClaimResponse Bundles

Three FHIR R4 ClaimResponse resources representing the three possible prior authorization outcomes under the Da Vinci PAS specification.

| File | Outcome Code | Meaning |
|---|---|---|
| approved-claimresponse.json | A1 | Approved - preAuthRef returned |
| denied-claimresponse.json | A4 | Denied - CARC 11 reason code |
| pended-claimresponse.json | WQ | Pended - awaiting manual review |

## Validation

All three bundles were submitted to the HAPI FHIR R4 public server via Postman and received 201 Created responses. Screenshots of the server responses are in the parent folder.

## Key field - denied bundle

The denied bundle contains `adjudication.reason` with CARC code 11 (Diagnosis inconsistent with procedure). This field is mandatory under CMS-0057-F. Its absence would be a compliance violation.
The clinical context is an NHS patient whose SNOMED CT diagnosis was not translated to ICD-10-CM before prior auth submission.

## Key field - approved bundle

The approved bundle contains `extension.valueString: PA-2024-00123` which is the preAuthRef number. This number must appear on the subsequent 837 billing claim. If it is missing, the claim receives an automatic technical denial - see 10-revenue-cycle/denial-management.md.
