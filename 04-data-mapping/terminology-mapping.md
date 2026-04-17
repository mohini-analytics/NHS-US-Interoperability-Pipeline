# Terminology Mapping: NHS UK Core to US Core

## The Core Problem
NHS and US healthcare systems use different coding systems for
the same clinical concepts. This is called a semantic
interoperability gap - the data is syntactically valid FHIR
but clinically meaningless to the receiving system because
it speaks a different vocabulary.

## Terminology Systems Comparison

| Clinical Domain | NHS System | US System | Gap Assessment |
|---|---|---|---|
| Diagnoses | SNOMED CT | ICD-10-CM (billing) | Partial overlap - requires active translation service |
| Medications | dm+d (Dictionary of Medicines and Devices) | RxNorm | No direct mapping - terminology service required |
| Lab Results / Observations | SNOMED CT | LOINC | Significant overlap but not complete |
| Procedures | OPCS-4 | CPT | Structural differences - manual mapping required |
| Ethnicity | NHS Ethnic Category codes | CDC OMB Race and Ethnicity ValueSet | Does not map 1:1 - ambiguous cases need clinical review |

## Detailed Mapping Examples

### Diagnosis: Bipolar Disorder
| System | Code | Display |
|---|---|---|
| SNOMED CT (NHS) | `13746004` | Bipolar disorder |
| ICD-10-CM (US) | `F31.9` | Bipolar disorder, unspecified |
| ICD-10-CM (US) | `F31.0` | Bipolar disorder, current episode hypomanic |

Note: One SNOMED code can map to multiple ICD-10-CM codes
depending on clinical context. This ambiguity requires a
terminology translation service - not a static lookup table.

### Medication: Lithium Carbonate
| System | Code | Display |
|---|---|---|
| dm+d (NHS) | `9487801000001109` | Lithium carbonate 250mg capsules |
| RxNorm (US) | `49568` | lithium carbonate |

### Lab Result: HbA1c
| System | Code | Display |
|---|---|---|
| SNOMED CT (NHS) | `1107481000000106` | HbA1c level |
| LOINC (US) | `4548-4` | Hemoglobin A1c/Hemoglobin.total in Blood |

## Why This Matters for RCM
US insurance payers require ICD-10-CM codes on claims.
A diagnosis submitted in SNOMED CT will be rejected during
adjudication - the payer's system cannot identify a covered
diagnosis and denies the claim.

The cost of manual rework per denied claim is $25–$118
(MGMA research). At scale, systematic terminology mismatch
represents millions in preventable revenue loss annually.

## Transformation Logic
The middleware must:
1. Detect the source coding system from `coding.system` URL
2. Query a terminology translation service for equivalent codes
3. Add US-required codes as additional entries in the coding array
4. Preserve the original NHS codes for clinical reference
5. Flag ambiguous mappings for clinical review - never silently default
