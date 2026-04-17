# Technical Data Mapping: NHS UK Core to US Core

## What Is This Document?
This document defines the transformation rules for moving 
Sarah's patient data from a UK FHIR format to a US FHIR format.

Think of it like a translation dictionary- 
for each piece of data that exists in the UK record,
we define exactly what to do with it when it arrives in the US system.

A "Transformer" is the middleware software that reads these rules
and automatically converts the data before it reaches the US EHR.

---

## Patient Resource Mapping Table

| Source Field (UK Core) | Target Field (US Core) | Transformation Rule | Plain English Explanation |
|---|---|---|---|
| `Patient.identifier` (NHS Number) | `Patient.identifier` (External Reference) | Store NHS Number as an external reference identifier using system `http://hl7.org/fhir/sid/passport-GBR` until a US MRN is assigned | The NHS Number cannot be used as a US patient ID. We store it as a reference so clinicians know where the record came from, but the US system creates its own ID. |
| `Patient.name` | `Patient.name` | Direct copy - no changes needed | Names transfer as-is. Family name and given name fields are identical in both profiles. |
| `Patient.gender` | `Patient.gender` + `us-core-birthsex` extension | Copy gender value. Set birthsex to "UNK" (Unknown) if not present in source | The NHS uses one gender field. The US uses two : administrative gender and birth sex. If birth sex is not recorded in the NHS record, we mark it as Unknown and flag for manual completion. |
| `Patient.address.postalCode` | `Patient.address.postalCode` | Validate against US ZIP code format (5 digits). If UK postcode detected, flag for manual address update | A UK postcode like "NW1 6XE" will fail US address validation. The system detects this and asks staff to collect a US address at registration. |
| **NOT IN SOURCE** | `extension:us-core-race` | Default value: `"UNK"` (Unknown). Create intake task for manual completion at registration | Race data does not exist in NHS records. The US system needs it for regulatory reporting. We set it to Unknown and create a task so registration staff can collect it from Sarah directly. |
| **NOT IN SOURCE** | `extension:us-core-ethnicity` | Default value: `"UNK"` (Unknown). Create intake task for manual completion at registration | Same as above-  ethnicity is not collected by NHS systems but is required by US Core. |
| `extension:UKCore-NHSNumberVerificationStatus` | **Not applicable in US** | Drop this field during transformation | This extension tells NHS systems whether the NHS Number has been verified. US systems do not use it and will not understand it. We remove it cleanly rather than passing unrecognised data. |

---

## How the Transformer Works- Step by Step

1. **Detect the source profile**
   The transformer reads the `meta.profile` field in the incoming FHIR resource.
   If it contains `UKCore-Patient`, the UK-to-US transformation rules are applied.

2. **Map what exists**
   Fields that exist in both profiles (name, gender, birthdate) are copied directly
   or with minor formatting adjustments.

3. **Handle what is missing**
   Fields required by US Core but absent from UK Core (race, ethnicity, birth sex)
   are set to "Unknown" and a manual intake task is created in the US system.

4. **Drop what is incompatible**
   UK-specific extensions (NHS Number Verification Status) are removed
   so the US system does not receive unrecognised data that could cause errors.

5. **Assign a temporary identifier**
   The NHS Number is stored as an external reference.
   A new US MRN is created when Sarah registers at the US provider.

---

## Key Risk: What Happens If This Mapping Is Not Done?

If Sarah's raw UK FHIR record is sent directly to a US EHR without transformation:

- The US system may **reject the record entirely** 
  because mandatory fields (race, ethnicity) are missing
- The NHS Number may be **misread as an MRN**, 
  creating a false patient identity in the US system
- The unrecognised NHS verification extension may 
  **trigger a validation error**, blocking the import
- Sarah arrives at the emergency department 
  with **no accessible clinical history** - 
  a direct patient safety risk

This is why a FHIR transformation layer is not optional 
in cross-border data exchange. It is a clinical governance requirement.
