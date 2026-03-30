# Clinical Scenario: The "Data Gap" for a Transatlantic Patient

## The Patient
Name: Sarah Jennings  
Origin: London, UK (NHS Patient)  
Relocation: New York, USA (Private Insurance)  

## The Conflict
Sarah has Type 1 Diabetes and a history of Bipolar Disorder managed by the NHS (using SystmOne). Upon moving to the US, her new provider needs her:
1. **Medication History:** (Insulin and Mood Stabilizers)
2. **Lab Trends:** (HbA1c levels from the last 3 years)
3. **Clinical Notes:** (Crisis management plans)

## The "Old Way" (Manual Failure)
Sarah carries a 50-page PDF. The US doctor cannot "import" this into their Epic EHR. The data is "dead." To bill her insurance (RCM), the doctor must manually re-code her UK diagnoses into US-compliant ICD-10-CM codes. 

## The "FHIR Way" (Our Solution)
We will map Sarah's **NHS UK Core** data (JSON) directly to **US Core** resources. This project demonstrates how to automate the translation of her clinical history so it is "Billable" and "Searchable" the moment she lands.
