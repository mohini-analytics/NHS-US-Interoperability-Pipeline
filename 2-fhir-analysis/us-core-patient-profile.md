# FHIR Patient Resource: US Core Profile (US Standard)

## Profile Overview
* **Profile:** [US Core Patient](http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient)
* **Primary Identifiers:** Medical Record Number (MRN) and Health Insurance Member ID.
* **Key Constraint:** Must include **OMB Race and Ethnicity** categories. These are mandatory (Must Support) in the US, unlike in the UK.

## Sarah’s US Data (JSON Representation)
Note the addition of mandatory US extensions that were not present in the UK record.

```json
{
  "resourceType": "Patient",
  "id": "us-sarah-jennings",
  "meta": {
    "profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"]
  },
  "extension": [
    {
      "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
      "extension": [
        { "url": "ombCategory", "valueCoding": { "system": "urn:oid:2.16.840.1.113883.6.238", "code": "2106-3", "display": "White" } }
      ]
    },
    {
      "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
      "extension": [
        { "url": "ombCategory", "valueCoding": { "system": "urn:oid:2.16.840.1.113883.6.238", "code": "2186-5", "display": "Not Hispanic or Latino" } }
      ]
    }
  ],
  "identifier": [
    {
      "use": "usual",
      "type": { "coding": [{ "system": "http://terminology.hl7.org/CodeSystem/v2-0203", "code": "MR", "display": "Medical record number" }] },
      "system": "http://hospital.smarthealth.org",
      "value": "SH-445566"
    }
  ],
  "name": [{ "family": "Jennings", "given": ["Sarah"] }],
  "gender": "female",
  "birthDate": "1990-05-15"
}
