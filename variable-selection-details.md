### The following variables were selected and processed for the analysis:

#### 1. Survey Identifiers and Weights
* `YEAR` / `MULTYEAR` / `SAMPLE`: Survey year and pooled sample identifiers
* `SERIAL` / `PERNUM`: Household and individual person identifiers
* `HHWT` / `PERWT`: Household and personal survey weights (used for population representativeness)
* `CPI99`: Price index factor used to adjust historical incomes for inflation

#### 2. Geography & Housing Unit Metrics
* `PUMA`: Public Use Microdata Area geographic boundaries
* `OWNERSHIP` / `OWNERSHIPD`: Homeownership status and detailed codes
* `RENT`: Monthly gross rent amount
* `UNITSSTR`: Building structure type (e.g., single-family vs. multi-family building)
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




### The additional variables added for analysis:

***person_id***

The `person_id` variable uniquely identifies each person by combining the ACS year, household serial number, and person number within that household (e.g., `2019_342924_1`).

***type_hrwrk*** 

The `type_hrwrk` variable categorizes hours worked per week into `part_time` (20–34 hours/week), `full_time` (35–40 hours/week), or `over_time` (more than 40 hours/week).

***wfh***

The `wfh` variable identifies whether the work is remote.


***transit_group***

The `transit_group` variable categorizes transit mode (`TRANWORK`) into `private_auto` ("auto, truck, or van", "motorcycle"), `public_transit` ("bus", "bus or trolley bus", "bus or streetcar", "light rail, streetcar, or trolley", "subway or elevated", "long-distance or commuter train", "ferryboat"), `active_transit` ("bicycle", "walked only"), `other_transit` ("taxicab or ride-hailing services", "other"), and `wfh` ("worked at home").

***race_ethnicity***

The `race_ethnicity` variable combines `RACE` and `HISPAN` into six categories: `hispanic` (anyone identified as Hispanic, regardless of race), `nh_white` (non-Hispanic White), `nh_black` (non-Hispanic Black or African American), `nh_asian` (non-Hispanic Chinese, Japanese, or other Asian/Pacific Islander), `nh_native` (non-Hispanic American Indian or Alaska Native), and `nh_other` (non-Hispanic Other, or non-Hispanic with two or more major races).


***hh_group***

The `hh_group` variable categorizes households into the four groups mentioned earlier: `family`, `mixed`, `roommate`, `single`.


***n_hh (family & roommate & mixed household)*** & ***family_size (mixed household)***

The `n_hh` variable identifies the number of household members in a multi-person household (including the head), regardless of their relationship with the head. 

In family and roommate households, `n_hh` identifies the total number of family or roommate members (including the head). 
In mixed households, `n_hh` identifies the total number of both family and roommate members (including the head).

The `family_size` variable counts only the household members who share a family relationship with the head in mixed households. Roommates are not included.


***n_workers (family household)*** & ***family_workers (mixed household)***

The `n_workers` and `family_workers` variables both identify the number of family members (including the head) who are stable workers in a household. In mixed households, `family_workers` counts only the stable working household members who share a family relationship with the head. Stable working roommates are not included.


***roommate_workers (mixed household)***

The `roommate_workers` variable identifies the number of stable working roommates in a mixed household.


***num_dependent_children (family & mixed household)***

The `num_dependent_children` variable identifies the number of family members under the age of 18.


***FTOTINC (mixed household)***

The `FTOTINC` (Family Total Income) variable represents the aggregated income of all family-related members living in a mixed household. It sums the individual incomes(`INCTOT`)  of all related family members (including the head) regardless of whether they meet the study's specific criteria for a 'stable worker', while excluding the income of roommates.


***worker_type (family & mixed household)***

The `worker_type` variable categorizes the number of `n_workers` in family household  and `family_workers` in mixed household into `single_earner` and `multiple_earners`.


***rent_burden***

The `rent_burden` variable represents the percentage of income spent on housing rent, calculated individually for each household as follows:

Single Renter Household: `rent_burden` = (`RENT` * 12) / `HHINCOME` * 100  

Roommate Renter Household : `rent_burden` = ((`RENT` * 12) / `n_hh`) / `INCTOT` * 100

Family Renter Household: `rent_burden` = (`RENT` * 12) / `HHINCOME` * 100

Mixed Renter Household (family - only): `rent_burden` = (`RENT` * 12 * `family_size`/`n_hh`) / `FTOTINC` * 100

Mixed Renter Household (roommate - only):  `rent_burden` = ((`RENT` * 12) / `n_hh`) / `INCTOT` * 100


***range_burden***

The `range_burden` variable categorizes the percentage of `rent_burden` into `affordable` (30% or less), `burdened` (30–50%), `severely_burdened` (50–70%), and `extreme` (more than 70% but less than 100% ). 


***income_tier***

The `income_tier` variable categorizes income into `low_income` (bottom 30th percentile), `middle_income` (30th–80th percentile), and `upper_income` (80th–100th percentile), based on quantiles calculated separately by survey year within each household category. Individual-level groups use individual income, while household-level groups use household income.

