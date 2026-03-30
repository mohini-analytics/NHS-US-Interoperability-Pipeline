# Technical Data Mapping: NHS UK Core to US Core

## Mapping Logic: Patient Resource
This table defines the logic for the "Transformer" middleware.

| Source Element (UK Core) | Target Element (US Core) | Transformation Logic |
| :--- | :--- | :--- |
| `Patient.identifier` (NHS No) | `Patient.identifier` (External) | Map to system `http://hl7.org/fhir/sid/us-npi` or local MRN |
| `Patient.name` | `Patient.name` | Direct Map (1:1) |
| `Patient.address.postalCode` | `Patient.address.postalCode` | Regex Validation for US 5-digit Zip |
| **MISSING** | `extension:us-core-race` | **Default to "Unknown"** and trigger manual intake task |
| **MISSING** | `extension:us-core-ethnicity` | **Default to "Unknown"** and trigger manual intake task |
| `extension:UKCore-NHSNumberVerificationStatus` | **N/A** | **Drop during transformation** (Not used in US) |

## Implementation Note
For the "Sarah Jennings" use case, the mapping engine must detect the `UKCore` profile in the `meta.profile` field and trigger the **UK-to-US-Transformation-Logic** before attempting to POST the data to the US EHR endpoint.
