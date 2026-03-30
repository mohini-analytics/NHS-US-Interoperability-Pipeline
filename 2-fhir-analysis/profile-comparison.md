# Gap Analysis: UK Core vs. US Core Patient Profiles

## Overview
To move Sarah’s data from the UK (NHS) to the US (Private), we must bridge the "Structural Gap." The US Core profile has stricter mandatory requirements than the UK Core due to different regulatory environments.

| Feature | UK Core (NHS) | US Core (Private/RCM) | Priority |
| :--- | :--- | :--- | :--- |
| **Primary Identifier** | 10-digit NHS Number | Local MRN / Insurance ID | **Critical** |
| **Race & Ethnicity** | Optional / Clinical | **Mandatory** (OMB Standards) | **High** |
| **Verification** | NHS Number Status Ext | Real-time Eligibility (270) | **High** |
| **Gender Identity** | Administrative Gender | Gender + Birth Sex Extension | **Medium** |
| **Address** | UK Postcode Format | US State/Zip Code Format | **Medium** |

## Key Findings
1. **The "Race" Block:** Sarah's NHS record is technically "invalid" for a US system because it lacks the mandatory OMB Race/Ethnicity extensions.
2. **Identity Fragmentation:** Without a US national ID, we must map the NHS Number to a "Placeholder Identifier" until a US Medical Record Number (MRN) is assigned.
