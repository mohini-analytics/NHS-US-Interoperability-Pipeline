# FHIR Patient Resource: UK Core Profile (NHS Standard)

## Profile Overview
* **Profile:** [UK Core Patient](https://simplifier.net/hl7fhirukcorer4/ukcore-patient)
* **Primary Identifier:** 10-digit NHS Number.
* **Key Constraint:** The NHS Number must include an extension indicating the "NHS Number Verification Status" (e.g., Number present and verified).

## Sarah’s UK Data (JSON Representation)
This snippet shows how Sarah's data is structured in an NHS SystmOne or EMIS system.

```json
{
  "resourceType": "Patient",
  "id": "nhs-sarah-jennings",
  "meta": {
    "profile": ["[https://fhir.hl7.org.uk/StructureDefinition/UKCore-Patient](https://fhir.hl7.org.uk/StructureDefinition/UKCore-Patient)"]
  },
  "identifier": [
    {
      "extension": [
        {
          "url": "[https://fhir.hl7.org.uk/StructureDefinition/Extension-UKCore-NHSNumberVerificationStatus](https://fhir.hl7.org.uk/StructureDefinition/Extension-UKCore-NHSNumberVerificationStatus)",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "[https://fhir.hl7.org.uk/CodeSystem/UKCore-NHSNumberVerificationStatusEngland](https://fhir.hl7.org.uk/CodeSystem/UKCore-NHSNumberVerificationStatusEngland)",
                "code": "01",
                "display": "Number present and verified"
              }
            ]
          }
        }
      ],
      "system": "[https://fhir.nhs.uk/Id/nhs-number](https://fhir.nhs.uk/Id/nhs-number)",
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
