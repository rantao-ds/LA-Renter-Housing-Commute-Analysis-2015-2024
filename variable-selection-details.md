## 1. Variables Selected from IPUMS USA
 
#### 1. Survey Identifiers and Weights
* `YEAR` / `MULTYEAR` / `SAMPLE`: Survey year and pooled sample identifiers
* `SERIAL` / `PERNUM`: Household and individual person identifiers
* `HHWT` / `PERWT`: Household and personal survey weights used for population-level estimates and weighted analysis
* `CPI99`: Price index factor used to adjust historical incomes for inflation

#### 2. Geography & Housing Unit Metrics
* `PUMA`: Public Use Microdata Area geographic boundaries
* `OWNERSHIP` / `OWNERSHIPD`: Homeownership status and detailed codes
* `RENT`: Monthly gross rent amount
* `UNITSSTR`: Housing unit structure type (e.g., single-family vs. multi-family structure)
* `BEDROOMS`: Number of bedrooms in the housing unit
* `VEHICLES`: Number of vehicles available in the household

#### 3. Demographics & Household Structure
* `RELATE` / `RELATED`: Relationship to the head of household
* `SEX` / `AGE`: Gender and age
* `RACE` / `RACED`: Racial identity and detailed classification codes
* `HISPAN` / `HISPAND`: Hispanic/Latino origin and detailed classification codes
* `EDUC` / `EDUCD`: Educational levels

#### 4. Employment & Personal Income
* `EMPSTAT` / `EMPSTATED`: Detailed labor force and employment status
* `UHRSWORK`: Usual weekly hours worked
* `INCTOT`: Total personal income from all sources
* `INCWAGE`: Wage and salary earnings
* `HHINCOME`: Total combined household income

#### 5. Commuting & Transportation
* `TRANWORK`: Primary transit mode of travel to work
* `CARPOOL`: Carpooling status
* `TRANTIME`: One-way commute travel time (in minutes)

For detailed information about the variables and codes, please refer to the attached [IPUMS Codebook](https://github.com/user-attachments/files/30113444/code.pdf).



## 2. Engineered Variables

### person_id

The `person_id` variable uniquely identifies each person by combining the ACS year, household serial number, and person number within that household (e.g., `2019_342924_1`).

### type_hrwrk

The `type_hrwrk` variable categorizes hours worked per week into `part_time` (20–34 hours/week), `full_time` (35–40 hours/week), or `over_time` (more than 40 hours/week). Workers reporting fewer than 20 hours per week were excluded based on the stable worker criteria.

### wfh

The `wfh` variable identifies whether a renter works from home based on commuting status.


### transit_group

The `transit_group` variable recategorizes `TRANWORK` based on ACS/IPUMS transportation mode classifications into the following categories:
* `private_auto`: "auto, truck, or van", "motorcycle"
* `public_transit`: "bus", "bus or trolley bus", "bus or streetcar", "light rail, streetcar, or trolley", "subway or elevated", "long-distance or commuter train", "ferryboat"
* `active_transit`: "bicycle", "walked only"
* `other_transit`: "taxicab or ride-hailing services", "other"
* `wfh`: "worked at home"


### race_ethnicity

The `race_ethnicity` variable combines `RACE` and `HISPAN` responses into six analytical categories:
* `hispanic`: Anyone identified as Hispanic, regardless of race
* `nh_white`: Non-Hispanic White
* `nh_black`: Non-Hispanic Black or African American
* `nh_asian`: Non-Hispanic Chinese, Japanese, or other Asian/Pacific Islander
* `nh_native`: Non-Hispanic American Indian or Alaska Native
* `nh_other`: Non-Hispanic Other, or non-Hispanic with two or more major races


### hh_group

The `hh_group` variable categorizes households into the four groups mentioned earlier: `family`, `mixed`, `roommate`, `single`.


### n_hh & family_size (Mixed Household)

* The `n_hh` variable identifies the number of household members in a multi-person household (including the head), regardless of their relationship with the head. 

* In family and roommate households, `n_hh` identifies the total number of family or roommate members (including the head). 

* In mixed households, `n_hh` identifies the total number of household members included in the analytical group.

* The `family_size` variable counts only the household members who share a family relationship with the head in mixed households. Roommates are not included.


### n_workers & family_workers

* The `n_workers` and `family_workers` variables both identify the number of family members (including the head) who meet the study's stable worker criteria.
* In mixed households, `family_workers` counts only the stable working household members who share a family relationship with the head (excluding stable working roommates).


### roommate_workers (Mixed Household)

The `roommate_workers` variable identifies the number of stable working roommates in a mixed household.


### num_dependent_children 

The `num_dependent_children` variable identifies the number of family members under the age of 18.


### FTOTINC (Mixed Household)

The `FTOTINC` (Family Total Income) variable represents the aggregated income of all family-related members living in a mixed household. It sums the individual incomes (`INCTOT`) of all related family members (including the head), regardless of employment status, while excluding roommate income.

> **Note:** For mixed renter households in group two, `FTOTINC` is used as the household income measure and relabeled as `HHINCOME` for consistency with family households.


### worker_type 

The `worker_type` variable categorizes the number of family workers (`n_workers` in family household and `family_workers` in mixed household) into `single_earner` and `multiple_earners`.


### rent_burden

The `rent_burden` variable represents the percentage of income spent on housing rent, calculated individually for each household as follows:

* **Single Renter Household:**  

  `rent_burden = ((RENT * 12) / HHINCOME) * 100`


* **Roommate Renter Household:**

  `rent_burden = (((RENT * 12) / n_hh) / INCTOT) * 100`  
  
  *(Rent is assumed to be equally shared among household members)*


* **Family Renter Household:**
  
  `rent_burden = ((RENT * 12) / HHINCOME) * 100`


* **Mixed Renter Household (Family Members):**
  
  `rent_burden = (((RENT * 12) * (family_size / n_hh)) / FTOTINC) * 100`  

  *(Household rent is allocated based on the family's share of total household members: `family_size / n_hh`)*


* **Mixed Renter Household (Roommates):**
  
  `rent_burden = (((RENT * 12) / n_hh) / INCTOT) * 100`  

  *(Rent is assumed to be equally shared among household members)*



### range_burden

The `range_burden` variable categorizes `rent_burden` into:
* `affordable`: 30% or less
* `burdened`: 30%–50%
* `severely_burdened`: 50%–70%
* `extreme`: 70% or more (up to 100%)


### income_tier 

The `income_tier` variable categorizes income into three tiers, with quantiles calculated separately for each ACS 5-year sample period and analytical household category (individual-level groups use individual income, while household-level groups use household income):

* `low_income`: Bottom 30th percentile
* `middle_income`: 30th to 80th percentile
* `upper_income`: 80th to 100th percentile

