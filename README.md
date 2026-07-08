# LA-Renter-Affordability-Commute-Analysis-5Yr-ACS-2019-2024
Analysis of the trade-off between housing affordability and commute time in Los Angeles County across two 5-year ACS periods (2019 & 2024) using R.

## Why This Project
As a renter living in LA, the trade-off between housing affordability and commute time is a real and often difficult decision, given the high rent and heavy traffic during rush hour. As an international student in LA, I faced this trade-off directly: live close to school to minimize commute time but pay higher rent (even with a roommate), or live farther away for more affordable rent but face commutes of up to two hours. Early on, I prioritized a shorter commute and was willing to share housing. Later, my priorities shifted toward privacy and affordability over commute time, as I only needed to attend school two to three times a week. For workers with less flexible schedules, this trade-off can be even more difficult, especially those working full-time or more than three days a week. Therefore, this project attempts to understand how Los Angeles renters from different households handle this trade-off, using the 2019 and 2024 5-year ACS estimates. As a secondary analysis, I also explore how the rise of remote work following COVID-19 may have shifted this pattern.


## Data
The data was retrieved from IPUMS USA, selecting samples from the ACS 5-Year datasets for **2015–2019** and **2020–2024**, restricted to **Los Angeles County, California**. 

The following variables were selected and processed for the analysis:

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

### The data is divided into four groups:

**Single Renter Household** 
A single-person household in which the person is a stable worker living alone. After the wrangling, 21,974 observations remain for analysis.

**Roommate Renter Household** 
A multi-person household in which the head is a stable worker and all other household members are non-family, with at least one roommate also being a stable worker. After the wrangling, 9,229 observations remain for analysis.

**Family Renter Household** 
A multi-person household in which the head is a stable worker and all other household members share a family-based relationship. After the wrangling, 85,848 observations remain for analysis. 

**Mixed Renter Household** 
A multi-person household in which the head is a stable worker, living with family members who share a family-based relationship with the head (not required to be workers), and at least one non-family roommate who is also a stable worker. Following data wrangling, 3,454 observations remain for analysis.


### The criteria for renter household and unit structure:

- The ownership of the dwelling (tenure) is rented, with cash rent.

- The unit structure must be a physical housing unit: a 1-family house (detached or attached) or a multi-family building with 2 or more units.

- For multi-person households, only two-to-five-person households were retained, as these represent the majority within that ACS 5-year sample (82.4% in ACS 2019, 83.3% in ACS 2024).


### The criteria of a stable worker:

A person who is 1) aged 24–64, 2) currently at work, 3) working between 20 and 80 hours per week, and 4) earning an annual income greater than or equal to the annual minimum wage in Los Angeles County for that year.


### The additional variables added for analysis:

***person_id***

The `person_id` variable uniquely identifies each person by combining the ACS year, household serial number, and person number within that household (e.g., `2019_342924_1`).

***type_hrwk*** 

The `type_hrwk` variable categorizes hours worked per week into `part_time` (20–34 hours/week), `full_time` (35–40 hours/week), or `over_time` (more than 40 hours/week).

***wft***

The `wft` variable identifies whether the work is remote (`TRUE`).


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

The `roommate_workers` variable identify the number of stabling working roommates in a mixed household.


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

The `range_burden` variable categorizes rent_burden percentages into four tiers: affordable (30% or less), burdened (30% to 50%), severely_burdened (50% to 70%), and extreme (over 70% but under 100%).


### Analytical Framework & Groupings

To facilitate exploratory data analysis (EDA) and modeling, the four original household types were combined into three distinct analytical groups.

**Group_One**

Group One represents an individual-level analysis focusing on nonfamily living arrangements. This group combines individuals from single renter households, roommate renter households, and roommates living in mixed renter households. Following the data-cleaning and merging process, Group One retains a sample of 32,604 observations for descriptive and predictive analysis.


**Group_Two**

Group Two represents a household-level analysis focusing on family living arrangements. This group combines individuals from family renter households and families living in mixed renter households. Following the data-cleaning and merging process, Group Two retains a sample of 87,901 observations for descriptive and predictive analysis.


**Group_Three**

Group Three is an additional group focusing exclusively on work-from-home (WFH) individuals across all households. Following the data-cleaning and merging process, Group Three retains a sample of 13,979 observations for descriptive analysis.
