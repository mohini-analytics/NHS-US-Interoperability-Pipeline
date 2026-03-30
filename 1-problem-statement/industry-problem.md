# Industry Analysis: The Economic Cost of Non-Interoperability

## The Global "Interoperability Gap"
As patients migrate between the UK (Single-Payer/NHS) and the US (Multi-Payer/Private), their data hits a "digital wall." This fragmentation creates a massive financial and clinical burden for both providers and patients.

## 1. The US Financial Impact (Revenue Cycle Management)
In the US healthcare market, data quality is a direct driver of financial performance. Poor interoperability leads to "dirty data," which triggers insurance claim denials.

* **The Denial Crisis:** According to MGMA research, **over one-third (33%) of US healthcare leaders** report claim denial rates exceeding 10%, a threshold that indicates significant revenue leakage.
* **Front-End Root Causes:** MGMA identifies that **three of the top four causes of denials** occur at the "front-end" of the revenue cycle, specifically during registration, eligibility verification, and charge capture, making clean data intake the single highest- leverage intervention point for providers.
* **The Rework Cost:** Beyond the lost revenue, the administrative burden is high. Industry estimates place the **average cost to manually rework a single denied claim between $25 and $118**, representing a significant burden on stretched revenue cycle teams.
* **The Scale of Opportunity:** The **2023 CAQH Index** reports that the US healthcare industry could save **$18.3 billion annually** by transitioning to fully electronic administrative transactions, with eligibility verification and prior authorisations representing the largest areas of potential savings.

## 2. The NHS vs. US Coding Mismatch
The primary technical barrier is "Semantic Interoperability"- systems using different standardised vocabularies for the same clinical concepts:
* **Diagnosis:** The NHS uses **SNOMED CT** for clinical documentation; US systems require **ICD-10-CM** for insurance billing.
* **Medications:** The NHS uses **dm+d** (Dictionary of Medicines and Devices); the US uses **RxNorm**.
* **Administrative:** The NHS relies on the 10-digit **NHS Number**; US providers use fragmented **MRNs (Medical Record Numbers)** and Payer-specific IDs.

## 3. Regulatory Tension (GDPR vs. HIPAA)
* **UK/GDPR:** Prioritises individual data sovereignty and the "Right to Erasure."
* **US/HIPAA:** Prioritises "Portability" for insurance continuity and "Accountability" for billing entities (Covered Entities).
* **The Challenge:** Building a pipeline that ensures **PHI (Protected Health Information)** is handled according to HIPAA Security Rules while maintaining the data lineage required by GDPR.

## The Solution: FHIR R4
This project **utilises** the **HL7 FHIR R4 standard** to act as the universal translator. By mapping NHS UK Core profiles to US Core profiles, we can automate the "Clean Claim" process, reducing administrative waste and ensuring patient safety during international transitions.

---

## References & Data Sources

1. **2023 CAQH Index Report:** * [A New Normal: Impact of Pandemic on Healthcare Administration](https://www.caqh.org/hubfs/43908627/drupal/2024-01/2023_CAQH_Index_Report.pdf)
   * *Key Insight:* $18.3B potential savings through digital transformation of administrative transactions.

2. **MGMA Research (via Vyne Medical):**
   * [Tackling Rising Denial Rates (Secondary Source)](https://vynemedical.com/blog/tackling-rising-denial-rates-in-2023/)
   * *Key Insight:* One-third of providers see denial rates >10%; Identifies front-end data intake as the primary source of denials.

3. **HL7 FHIR Specifications:**
   * [HL7 FHIR R4 Patient Resource](https://hl7.org/fhir/R4/patient.html)
   * [Simplifier.net - HL7 FHIR UK Core R4 Project Home](https://simplifier.net/hl7fhirukcorer4)
