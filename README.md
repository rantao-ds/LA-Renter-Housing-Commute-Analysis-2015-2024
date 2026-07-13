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


<img width="1500" alt="transit_performance_dashboard" src="https://github.com/user-attachments/assets/7a218b57-c7f2-45a7-87e2-cd732d12ba5e" />

Unsurprisingly, the majority of renters commute by private auto (77.2%), and more than 70% of renters commute by private auto across all household groups. Notably, a sizable share of renters work from home (11.7%), while very small portions commute by public transit or active transit, at 5.9% and 3.7% respectively. Overall, this commute pattern is highly consistent with LA's car-oriented urban landscape.


<img width="1000"  alt="transit_hh_performance_dashboard" src="https://github.com/user-attachments/assets/5a9e9403-4679-4530-9ba5-08d09a4f54c7" />

Overall, the average commute time stays around 30 minutes across all household groups, ranging from 29.5 to 31.3 minutes. However, rent burden varies across different household groups: single households have the highest mean rent burden (33.3%), followed by family households (28.2%), roommate households (24.1%), and mixed households (21%). This suggests that renters generally expect and manage a commute of around 30 minutes regardless of household type, while rent burden still varies by household structure, reinforcing the "privacy tax" pattern seen earlier.

The trade-off by transit mode looks completely different from the trade-off by household type. While mean rent burden stays around 30% across all transit modes, public transit renters have the highest average rent burden and commute time, at 31.4% and 49.6 minutes, respectively. This clearly indicates that public transit renters are less able to manage this trade-off. By contrast, active transit renters average 30.4% rent burden with the shortest mean commute time of 16 minutes, suggesting they prioritize proximity, likely choosing to live close to work. Private auto and other transit renters manage the trade-off well, with rent burden and commute time both staying around 30% and 30 minutes, respectively.



### Group One (Nonfamily)

<img width="1000" alt="independent_share_pie" src="https://github.com/user-attachments/assets/59b0ad49-ee0f-4186-9b6e-221beba20ddc" />

In group one, the majority of renters come from single households at 65.8%, which again confirms that renters in Los Angeles County prioritize privacy. Additionally, a sizable portion of renters are from roommate-only households at 29.4%, and very few come from mixed households at 4.7%, indicating that renters who share space to reduce their rent burden are less likely to share that space with family.


<img width="1000" alt="nonfamily_housing_dashboard" src="https://github.com/user-attachments/assets/e7868352-cac3-4d4b-9d67-535945928cbe" />

In group one, 87.9% of renters have less than 50% rent burden. Among all household types, mixed households have the highest share of renters with less than 50% rent burden (98%) and the lowest share with more than 50% rent burden (around 2%). For roommate-only households, 94.5% have less than 50% rent burden, while 5.5% have more than 50%. For single households, 84.2% have less than 50% rent burden, but a sizable 15.7% experience more than 50% rent burden.


<img width="1000" alt="rent_burden_socioeconomic_profiles" src="https://github.com/user-attachments/assets/98c7f329-0f0c-43a9-bcb5-6b9e9ae8e3ec" />

All age groups share a similar proportion across the range of rent burden in group one: about 12%–13% from ages 55–64, about 16% from ages 45–54, roughly 22%–25% from ages 35–44, and approximately 45–50% from ages 24–34.

However, the income tier reflects the true financial difficulties for those with low income. At the affordable level, more than 80% of renters come from upper- and middle-income groups, and only 14.5% are low-income. At the burdened level, middle- and upper-income renters still occupy about half, while the low-income group rises to 43.2%. At both the severely burdened and extreme levels, the upper-income group drops to near zero, and low-income renters expand from 78.2% to 94.5%.


<img width="1000" alt="rent_burden_racial_ethnic_profile" src="https://github.com/user-attachments/assets/7072c7e5-5afd-4fb1-a003-dba3f01517d8" />

Similar to age group, racial and ethnic groups also share a similar proportion across the range of rent burden in group one: about 39.1–42.5% Non-Hispanic White, approximately 26.6–28.9% Hispanic/Latino, roughly 10.8–14.9% Black/African American, about 10.9–15.3% Asian, roughly 4.5–5.3% Other/Multi-racial, and Native American renters at near zero across all rent burden levels.


<img width="1500" alt="transit_performance_dashboard" src="https://github.com/user-attachments/assets/53143cb1-dfec-43ab-970c-b03348543d86" />


In group one, the overall transit distribution is pretty similar across all household types: the majority of renters commute by private auto at 72.2%, a sizable portion work from home at 15.2%, and very few commute by public transit, active transit, or other transit methods. This pattern is consistent across all household groups. However, it is interesting to note that roommate renters living in mixed households are less likely to work from home compared with other household groups.


<img width="1000" alt="transit_mode_income_profile_high_contrast_green" src="https://github.com/user-attachments/assets/11c4c7c2-58ec-45f7-9588-fefd5bfd8ff7" />

In group one, renters using active and other transit have a very similar share across all income tiers. However, the low-income group is more likely to use public transit (57%) compared with private auto (29.9%) and work from home (18.9%). For middle- and upper-income renters, these two income tiers are the primary users of private auto and are very likely to work from home.


<img width="1500" alt="nonfamily_transit_hh_performance_dashboard" src="https://github.com/user-attachments/assets/e51d9e6a-1ce8-4390-867b-ebab2ae8c4b3" />

Again, the "privacy tax" adds to rent burden as mean commute time is controlled within 30 minutes, with single households having the highest rent burden at 33.3%, followed by roommate households at 24.1%, and mixed households at 17.8%. This pattern remains consistent within transit groups and household types. When mean commute time is controlled within a specific range for each transit mode, rent burden decreases from the highest (single households) to the lowest (mixed households). However, it is worth noting that single households commuting by public transit are the most difficult group, as these renters face a double burden: extra rent burden from the "privacy tax" and the longest commute time across all transit and household groups. Renters living in mixed households who use active transit, on the other hand, are very likely to experience the lightest burden in this trade-off, with the least rent burden and commute time across all household and transit groups.


<img width="1500" alt="carpool_rent_burden_by_hh" src="https://github.com/user-attachments/assets/5a0168c5-11d7-4e32-8b3a-11bd6ccb6109" />

Another interesting lens to look at the non-family group is carpool status, as carpooling may be another way to reduce rent burden, especially for the single household, non-sharing group. For roommate-only and mixed households, carpool status shows no major change in rent burden when comparing the drives-alone and carpool groups. However, single households flip this assumption that carpooling may reduce rent burden. Instead, affordable renters in the drives-alone group have a higher proportion at 54.7%, compared with 40.3% in the carpool group. As rent burden increases, the carpool group has a higher proportion than the drives-alone group, in the burdened (39.1% vs. 30.2%), severely burdened (14.7% vs. 10.4%), and extreme (5.9% vs. 4.6%) categories. Overall, carpool status shows no significant improvement in reducing rent burden across all household types.


### Group Two (Family)

<img width="1000" alt="family_housing_dashboard" src="https://github.com/user-attachments/assets/56274dd9-07fe-4de4-9fd7-4005bdc69a8c" />

Overall, the majority of group two renters come from family households (97.7%), and very few come from mixed households (2.3%). The "privacy tax" also applies to group two, where mixed households have a comparatively higher proportion in the affordable category. Across the more burdened categories (burdened, severely burdened, and extreme), family households have a slightly higher proportion.

<img width="1000" alt="family_rent_burden_socioeconomic_profiles" src="https://github.com/user-attachments/assets/46883e5d-9809-41b1-a18e-20e083b47139" />

In group two, renters near retirement (55–64) stay fairly stable across all categories, ranging narrowly from 11.9% to 13.4%. For rent burden under 50% (affordable and burdened), young professionals (24–34) have a slightly higher proportion than mid- and late-career professionals (35–44 and 45–54). For rent burden over 50% (severely burdened and extreme), the proportion of young professionals decreases while mid- and late-career professionals increase, with young and mid-career professionals ending up with a similar share in the more burdened categories. 

In terms of income tier, the low-income group shows a very significant shift across the four rent burden categories. In the affordable category, low-income renters represent only 10.1%, then increase to 62.1% in the burdened category. In both severely burdened and extreme categories, low-income renters dominate, at 92.7% and 99.1% respectively. In contrast, almost all upper-income renters fall under the affordable category and drop to nearly zero in the more burdened categories. Meanwhile, middle-income renters also significantly decline at high burden levels, dropping to just 7.3% in the severely burdened category and to nearly zero in extreme.


<img width="1000" alt="family_rent_burden_racial_ethnic_profile" src="https://github.com/user-attachments/assets/c758ac4f-5e53-4766-80c8-485eaa915968" />


Overall, more than half of renters are Hispanic/Latino across all rent burden categories, with a slight increase in proportion as burden grows, from 51.3% at affordable to 60.7% at extreme. In contrast, White (Non-Hispanic) renters make up a sizeable share but decrease as burden increases, from 24.3% at affordable to 16.2% at extreme. Black/African American, Asian, and Other/Multi-racial renters represent comparatively smaller proportions and stay fairly stable across the four rent burden categories.


<img width="1000" alt="family_mixed_worker_profile_dashboard" src="https://github.com/user-attachments/assets/d62870ba-48aa-4e25-b068-bfd44eb22c7c" />


In family-based households, the number of stable workers in a family may impact rent burden, especially for families with children under the age of 18. 

Overall, multiple earners without children have the least rent burden, sharing the largest proportion of the affordable category in both family (54.1%) and mixed (71.8%) households, with that share decreasing as burden level increases. 

In contrast, single earners with children have the highest rent burden, and this share significantly increases as burden level grows. It is interesting to note that the shares for less than 50% rent burden are pretty similar for both family and mixed households, while mixed households have a higher share for over 50% rent burden, indicating that mixed households with a single earner and children are more likely to face financial difficulties than family households.

For multiple earners with children, family and mixed households show a completely different pattern. In family households, the share slightly decreases as rent burden increases. In mixed households, however, a sizable proportion centers on burdened (18.5%) and severely burdened (15.6%), with comparatively smaller shares in affordable and extreme categories.

Similarly, for single earners without children, the share in family households increases as rent burden increases, while in mixed households, a sizable share falls under burdened (20.2%) and extreme (22%) categories, with comparatively smaller shares in affordable and severely burdened categories.

This indicates that single earners face tremendous financial difficulties, especially those with children, with mixed households showing an even higher share in the extreme burden category than family households.

<img width="1000" alt="family_transit_mode_income_profile" src="https://github.com/user-attachments/assets/5366edf7-bb7c-4008-a911-07e4ce2187a2" />

Similarly, the majority of renters in group two commute by private auto, with a sizable portion working from home. Even though very few commute by public transit, it is the primary alternative transit mode compared with active and other transit. This pattern is consistent across all household types in group two.


<img width="1000" alt="family_transit_performance_dashboard" src="https://github.com/user-attachments/assets/9d7450c5-b773-4055-825e-0c54840814ad" />

Among private auto, active, and other transit modes, the income tier distribution closely mirrors the original 30/50/20 split: ranging from 30.6% to 37.1% for low-income, 45.7% to 51.1% for middle-income, and 16.3% to 18.3% for upper-income.

For public transit in group two, low-income renters significantly increase to 48.6%, becoming the largest share within public transit, though closely followed by middle-income at 43.0%, while upper-income renters drop to just 8.5%. In contrast, upper-income renters in WFH increase to 35.2%, while low-income renters drop to 17.2%.

Overall, middle-income renters stay very stable across all transit modes, while public transit and WFH show the most divergence, with low-income concentrated in public transit and upper-income concentrated in WFH.


<img width="1000" alt="family_transit_performance_dashboard copy" src="https://github.com/user-attachments/assets/e3d96930-d076-41b2-9183-e8940b934ca2" />

Overall, both family-based household types share a similar trade-off between rent burden and commute time. Rent burden stays within a similar level across all transit modes, while commute time varies, with active transit being the shortest and public transit being the longest. Private auto and other transit show a good balance on this trade-off.

Additionally, mixed households have slightly less mean commute time and rent burden across all transit modes. While the average rent burden ranges from 27.9% to 31.7% in family households, mixed households' mean burden ranges from 23.4% to 25.5%. Among all transit modes, the mean commute time in mixed households is 1–5 minutes shorter than in family households.


<img width="1000" alt="family_mixed_tradeoff_dashboard_wk_child" src="https://github.com/user-attachments/assets/630d3074-ab12-4c62-86a4-c460d28238cf" />

From the lens of household working structure, this trade-off shows that family households have no clear advantage in managing rent burden, while average commute time stays similar across all household groups and working structures. In family households, rent burden increases as the number of earners decreases, and is also strongly associated with having children. In mixed households, single earners with children face the highest burden and multiple earners with no children face the least, while multiple earners with children and single earners without children show similar shares.

Overall, single earners consistently face the greatest financial strain, especially when children are involved, and this holds true across both family and mixed households.


### Group Three (WFH)


<img width="1000" alt="wfh_population_trends_10yr" src="https://github.com/user-attachments/assets/9050a938-b8b0-444a-9e1d-71c0f69e79c0" />


<img width="1000" alt="wfh_dashboard" src="https://github.com/user-attachments/assets/23d200eb-0903-4a3a-9594-3e9bb85fd614" />


<img width="1000" alt="wfh_rent_burden_trends_corrected" src="https://github.com/user-attachments/assets/c7faa34c-7ee2-49cc-98a9-f2bc57e60637" />


<img width="1000" alt="wfh_housing_burden_dashboard" src="https://github.com/user-attachments/assets/0013eb6d-26b1-4cd7-bb28-49045807eb86" />

