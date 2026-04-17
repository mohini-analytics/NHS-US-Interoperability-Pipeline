# Gap Analysis: UK Core vs. US Core Patient Profiles

## What Is This Document?
Before we can move Sarah's data from an NHS system to a US EHR, 
we need to understand what is different between the two systems.
This document identifies those differences and flags which ones 
are critical to fix before the data can be used in the US.

Think of it like a checklist before sending a parcel internationally- 
some items are allowed everywhere, some need special labelling, 
and some are not permitted at all.

## The Structural Gap Table

| Feature | UK Core (NHS) | US Core (US/RCM) | Priority | Why It Matters in Plain English |
|---|---|---|---|---|
| **Primary Identifier** | 10-digit NHS Number | Local MRN or Insurance ID | 🔴 Critical | The NHS Number means nothing to a US hospital. Without a US ID, the system cannot file a claim or match Sarah to an existing record. A placeholder must be created on arrival. |
| **Race & Ethnicity** | Optional | Mandatory (OMB Standards) | 🟠 High | US law requires race and ethnicity data for reporting and equity tracking. Sarah's NHS record has none. The US system will reject or flag the record as incomplete. |
| **Identity Verification** | NHS Number Verification Status | Real-time Insurance Eligibility Check (X12 270) | 🟠 High | The NHS verifies who you are via your NHS Number. The US verifies whether your insurance is active. These are completely different checks serving different purposes. |
| **Gender Fields** | Single administrative gender field | Gender identity + birth sex as separate fields | 🟡 Medium | US Core separates legal/administrative gender from birth sex to support inclusive care. NHS uses a single field. The data needs splitting on transformation. |
| **Address Format** | UK Postcode (e.g. NW1 6XE) | US State + ZIP Code (e.g. NY 10001) | 🟡 Medium | A UK postcode will fail validation in a US system. The address field needs reformatting or manual intake. |

## Key Findings

**Finding 1 - The Race Block**
Sarah's NHS record is technically incomplete for a US system.
The US Core profile marks Race and Ethnicity as "Must Support"-
meaning the receiving system must be able to process these fields.
Since her NHS record has no race data, the transformation engine 
must default to "Unknown" and flag the record for manual completion 
at US patient registration.

This is not a data quality failure on the NHS side- 
it is a regulatory difference between two healthcare systems.

**Finding 2- Identity Fragmentation**
There is no universal US patient identifier equivalent to the NHS Number.
Each US hospital creates its own Medical Record Number (MRN).
When Sarah registers at a US provider for the first time, 
a new MRN is created. Her NHS Number must be stored as an 
"external identifier" for reference- not used for billing or matching.

This is one of the biggest patient safety risks in cross-border data exchange:
without a shared identifier, duplicate records can be created,
leading to incomplete clinical history at the point of care.
