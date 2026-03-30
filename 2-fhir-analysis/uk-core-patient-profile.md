# FHIR Patient Resource: UK Core Profile (NHS Standard)

## Profile Overview
- **Profile:** [UK Core Patient](https://simplifier.net/hl7fhirukcorer4/ukcore-patient)
- **Primary Identifier:** 10-digit NHS Number.
- **Key Constraint:** The NHS Number must include an extension indicating 
the "NHS Number Verification Status" (e.g., Number present and verified).

## Sarah's UK Data (JSON Representation)
This snippet shows how Sarah's data is structured in an NHS SystmOne or EMIS system.
```json
{
  "resourceType": "Patient",
  "id": "nhs-sarah-jennings",
  "meta": {
    "profile": [
      "https://fhir.hl7.org.uk/StructureDefinition/UKCore-Patient"
    ]
  },
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
      "value": "9876543210"
    }
  ],
  "name": [
    {
      "family": "Jennings",
      "given": ["Sarah"]
    }
  ],
  "gender": "female",
  "birthDate": "1990-05-15",
  "address": [
    {
      "line": ["12 High Street"],
      "city": "London",
      "postalCode": "NW1 6XE",
      "country": "England"
    }
  ]
}
```

## Key Constraints This Profile Enforces
- NHS Number is the required primary identifier
- NHS Number Verification Status extension is mandatory- a record without it is technically incomplete
- Verification status must use the UKCore-NHSNumberVerificationStatusEngland CodeSystem
- No requirement for race or ethnicity data- contrast with US Core which mandates this
- Address should include country field for cross-border context
- No concept of insurance member ID- NHS is a single-payer system with universal coverage

## Why This Matters for Interoperability
When Sarah's record leaves an NHS system and enters a US EHR:
- Her NHS Number has no equivalent in the US- the receiving system cannot use it for patient matching
- The verification status extension is UK-specific - a US system will not recognise or process it
- Her address is UK-formatted- US systems expect state and ZIP code, not postcode
- No race/ethnicity data exists in her NHS record- but US Core marks these fields as Must Support, meaning the receiving system must handle their absence gracefully
