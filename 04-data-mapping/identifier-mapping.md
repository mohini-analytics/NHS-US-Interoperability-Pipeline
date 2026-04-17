# Identifier Mapping: NHS UK Core to US Core

## Why Identifiers Matter
Patient identifiers are the foundation of safe data exchange.
Before any clinical data can be used, the receiving system
must know with certainty which patient it belongs to.

A wrong identifier match means a clinician makes decisions
using another patient's clinical history. In a mental health
context - where medication history and crisis plans are
safety-critical - this is a direct patient safety risk.

## Identifier Comparison Table

| Element | NHS UK Core | US Core | Migration Action |
|---|---|---|---|
| Primary Patient ID | NHS Number - 10-digit, Modulus 11 validated | MRN - hospital-specific, no national standard | Store NHS Number as external reference. Generate new MRN on US intake. |
| ID System URL | `https://fhir.nhs.uk/Id/nhs-number` | Hospital-specific URL e.g. `http://hospital.us/mrn` | Both must be present in identifier array with correct system URLs |
| National Coverage | Universal - every NHS patient has one | None - no US national patient identifier exists | Probabilistic matching required when NHS Number not found in US system |
| Clinician ID | GMC Number (General Medical Council) | NPI - National Provider Identifier | Map where possible - document unmapped clinicians |
| Organisation ID | ODS Code | NPI (Organisational) | Requires manual mapping - no automated translation |
| Verification Status | `Extension-UKCore-NHSNumberVerificationStatus` required | Not applicable | Drop on transformation - not recognised by US systems |

## FHIR Representation

### NHS Number in UK Core Patient resource
```json
{
  "identifier": [
    {
      "extension": [
        {
          "url": "https://fhir.hl7.org.uk/StructureDefinition/Extension-UKCore-NHSNumberVerificationStatus",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "https://fhir.hl7.org.uk/CodeSystem/UKCore-NHSNumberVerificationStatusEngland",
                "code": "01",
                "display": "Number present and verified"
              }
            ]
          }
        }
      ],
      "system": "https://fhir.nhs.uk/Id/nhs-number",
      "value": "9000000033"
    }
  ]
}
```

### NHS Number preserved as external reference in US Core Patient resource
```json
{
  "identifier": [
    {
      "use": "usual",
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "MR",
            "display": "Medical record number"
          }
        ]
      },
      "system": "http://hospital.smarthealth.org",
      "value": "US-MRN-001"
    },
    {
      "use": "secondary",
      "system": "https://fhir.nhs.uk/Id/nhs-number",
      "value": "9000000033"
    }
  ]
}
```

## Key Risk
There is no US equivalent of the NHS Number. The same patient
can be registered at multiple US hospitals with different MRNs
and no automatic deduplication. This is why the NHS Number must
be preserved - it is the only persistent cross-border identifier
available for this patient.
