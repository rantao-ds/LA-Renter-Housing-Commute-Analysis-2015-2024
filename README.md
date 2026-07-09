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


### Analytical Framework & Groupings

To facilitate exploratory data analysis (EDA) and modeling, the four original household types were combined into three distinct analytical groups.

**Group_One**

Group One represents an individual-level analysis focusing on nonfamily living arrangements. This group combines individuals from single renter households, roommate renter households, and roommates living in mixed renter households. Following the data wrangling and merging process, Group One retains a sample of 32,604 observations for descriptive and predictive analysis.


**Group_Two**

Group Two represents a household-level analysis focusing on family living arrangements. This group combines individuals from family renter households and families living in mixed renter households. Following the data wrangling and merging process, Group Two retains a sample of 87,901 observations for descriptive and predictive analysis.


**Group_Three**

Group Three is an additional group focusing exclusively on work-from-home (WFH) individuals across all households. Following the data wrangling and merging process, Group Three retains a sample of 13,979 observations for descriptive analysis.



## Exploratory Data Analysis (EDA)
The primary goal of the EDA is to understand how different analytical groups handle this trade-off by comparing rent burden and commute time across different household structures within the same analytical group.

### At a Glance

<img width="1000" alt="overall_prop_type_household" src="https://github.com/user-attachments/assets/83b897ad-87dd-4faa-840d-3121c48685a4" />

Overall, family households are the most common renter household type in Los Angeles County, representing 69.7% of all renter households. In contrast, mixed households, another family-based household structure, represent only 3%, indicating that the majority of family-based households do not often take on an additional roommate to share the space. When it comes to living with a roommate versus living alone, more renters choose to live alone in a single household (18.8%) than with a roommate (8.4%). This overall distribution suggests that renters in Los Angeles County tend to prioritize privacy.

<img width="1000" alt="housing_burden_dashboard" src="https://github.com/user-attachments/assets/fd3b9f90-16d0-4c68-b497-f629d2eeccb1" />


Overall, the majority of renters in Los Angeles County meet the gold standard of the 30% rent burden rule (65.4%), and almost a quarter of renters (23.8%) have a rent burden between 30% and 50%. This indicates that 89.2% of renters in Los Angeles County have a rent burden of less than 50%. Meanwhile, 7.5% of renters are severely burdened and 3.2% face extreme rent burden, suggesting that these groups are still struggling financially. 

Out of all the household groups in Los Angeles County, single households carry the highest rent burden, with only 53.6% of renters considered affordable. The remaining household groups manage rent burden more comfortably, especially mixed households, where 82.3% of renters are considered affordable. In terms of renters experiencing over 50% rent burden, mixed and roommate households are less likely to face financial difficulties, at 4% and 5.5%, respectively. For family and single households, the non-sharing households, a sizable portion of renters are likely to face this burden, at 10.3% and 15.7%, respectively. This pattern suggests a "privacy tax" on rent burden, where renters who prioritize privacy over shared living tend to pay for it through higher financial strain.


<img width="1000" alt="boxplot_rent_by_household_perweigth" src="https://github.com/user-attachments/assets/75a9fe32-8617-4def-a4d6-c605d7750c34" />

The boxplot shows that non-sharing households have rent distributions that are less spread out and more stable compared to space-sharing households. While single and family households have similar medians and rent distributions (box sizes), the main difference is in the outliers: single household outliers stay between $4,000 and $5,000, while family household outliers extend beyond $5,000.

Roommate-only households show the most instability and spread in rent distribution, with the highest median rent (around $2,150) and upper whisker ($4,500). Their outliers especially reach beyond the graph's $5,000 limit. Even though mixed households have a similar box size and spread, their median rent and upper whisker are comparatively lower. Their outliers are sparse but still extend beyond the $5,000 limit.


<img width="1000" alt="transit_performance_dashboard" src="https://github.com/user-attachments/assets/7a218b57-c7f2-45a7-87e2-cd732d12ba5e" />

Unsurprisingly, the majority of renters commute by private auto (77.2%), and more than 70% of renters commute by private auto across all household groups. Notably, a sizable share of renters work from home (11.7%), while very small portions commute by public transit or active transit, at 5.9% and 3.7% respectively. Overall, this commute pattern is highly consistent with LA's car-oriented urban landscape.


<img width="1000"  alt="transit_hh_performance_dashboard" src="https://github.com/user-attachments/assets/5a9e9403-4679-4530-9ba5-08d09a4f54c7" />

Overall, the average commute time stays around 30 minutes across all household groups, ranging from 29.5 to 31.3 minutes. However, rent burden varies across different household groups: single households have the highest mean rent burden (33.3%), followed by family households (28.2%), roommate households (24.1%), and mixed households (21%). This suggests that renters generally expect and manage a commute of around 30 minutes regardless of household type, while rent burden still varies by household structure, reinforcing the "privacy tax" pattern seen earlier.

The trade-off by transit mode looks completely different from the trade-off by household type. While mean rent burden stays around 30% across all transit modes, public transit renters have the highest average rent burden and commute time, at 31.4% and 49.6 minutes, respectively. This clearly indicates that public transit renters are less able to manage this trade-off. By contrast, active transit renters average 30.4% rent burden with the shortest mean commute time of 16 minutes, suggesting they prioritize proximity, likely choosing to live close to work. Private auto and other transit renters manage the trade-off well, with rent burden and commute time both staying around 30% and 30 minutes, respectively.



### Group One (nonfamily)
