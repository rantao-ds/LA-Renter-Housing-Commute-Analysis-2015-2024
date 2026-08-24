# Rethinking the Housing–Commute Trade-Off: LA Renter Analysis (ACS 2019–2024)
An analysis of how stable working renters in Los Angeles County experience the housing–commute trade-off through affordability, commuting patterns, household structure, and work-from-home trends using the 2019 and 2024 ACS 5-year estimates with R.

## Why This Project
As a renter living in Los Angeles, the trade-off between housing affordability and commute time is a real and often difficult decision, given high housing costs and heavy rush-hour traffic. During my time as an international student in LA, I experienced this trade-off directly: living closer to school meant shorter commute times but higher rent, even when sharing housing, while living farther away provided more affordable options but could require commutes of up to two hours. Early in my time in LA, I prioritized a shorter commute and accepted shared housing. Later, as my schedule became more flexible and I only needed to attend school two to three times per week, my priorities shifted toward privacy and affordability over proximity.

For workers with less flexible schedules, this trade-off can be even more challenging, particularly for working full-time or commuting multiple days per week. Therefore, this project examines how Los Angeles renters across different household types navigate the relationship between housing affordability and commute time using the 2019 and 2024 5-year ACS estimates. As a secondary analysis, this project also explores whether the rise of remote work following COVID-19 has changed this relationship.

## Data

The data were retrieved from IPUMS USA using the ACS 5-Year datasets for **2015–2019** and **2020–2024**, restricted to **Los Angeles County, California**. 

**Data Source Citation:**
> Steven Ruggles, Sarah Flood, Matthew Sobek, Daniel Backman, Grace Cooper, Julia A. Rivera Drew, Stephanie Richards, Renae Rodgers, Jonathan Schroeder, and Kari C.W. Williams. IPUMS USA: Version 16.0 [dataset]. Minneapolis, MN: IPUMS, 2025. https://doi.org/10.18128/D010.V16.0

Raw ACS/IPUMS data files are not included in this repository and can be obtained by registering through IPUMS USA and downloading the corresponding ACS 5-year samples. For detailed information on variable selection and definitions, please refer to the [Variable Selection Details](variable-selection-details.md) page.


### Renter Household & Unit Structure Criteria

* The household tenure must be renter-occupied with cash rent.
* The housing structure must be a residential unit: a 1-family house (detached or attached) or a multi-family building with 2 or more units.
* For multi-person households, only households with 2–5 persons were retained, representing the majority of selected ACS samples (82.4% in ACS 2019 and 83.3% in ACS 2024).

### Stable Worker Definition

A stable worker is defined as a person who meets all of the following criteria:

1. Aged 24–64,
2. Currently employed and at work,
3. Usually working 20–80 hours per week, and
4. Earning annual income greater than or equal to the California minimum wage threshold for the corresponding ACS survey year, calculated using the published hourly minimum wage and the minimum weekly hour benchmark for each working-hour category.
   > **Note:** The minimum income threshold was calculated separately for each ACS survey year using California's published hourly minimum wage rate ([U.S. DOL Minimum Wage History](https://www.dol.gov/agencies/whd/state/minimum-wage/history)). The annual threshold varies by working-hour category, using 20 hours/week as the benchmark for part-time workers and 35 hours/week as the benchmark for both full-time and overtime workers.


### Renter Household Classifications

**Single Renter Household** 
A single-person household in which the person is a stable worker living alone. Following data wrangling, 21,974 observations remain for analysis.

**Roommate Renter Household** 
A multi-person household in which the head is a stable worker and all other household members are non-family roommates. Following data wrangling, 9,229 observations remain for analysis.

**Family Renter Household** 
A multi-person household in which the head is a stable worker and all other household members share a family-based relationship. Following data wrangling, 85,848 observations remain for analysis. 

**Mixed Renter Household** 
A multi-person household in which the head is a stable worker, living with both family members who share a family-based relationship with the head (not required to be workers) and at least one non-family roommate who is also a stable worker. Following data wrangling, 3,454 observations remain for analysis.


### Analytical Framework & Groupings

To facilitate exploratory data analysis (EDA) and modeling, the four original household types were combined into three distinct analytical groups.

  > **Note:** Mixed renter households contribute observations to the analytical groups depending on the individual's household role: family members are included in Group Two, while stable working roommates are included in Group One.


**Group One**

Group One represents an individual-level analytical framework focusing on nonfamily living arrangements. This group combines individuals from single renter households, roommate renter households, and roommates living in mixed renter households. Following the data wrangling and merging process, Group One retains a sample of 32,604 observations for descriptive and predictive analysis.


**Group Two**

Group Two represents a household-level analytical framework focusing on family living arrangements. This group combines individuals from family renter households and families living in mixed renter households. Following the data wrangling and merging process, Group Two retains a sample of 87,901 observations for descriptive and predictive analysis.



**Group Three**

Group Three is an additional group focusing exclusively on work-from-home (WFH) individuals across all households. Following the data wrangling and merging process, Group Three retains a sample of 13,979 observations for descriptive analysis.


## Exploratory Data Analysis (EDA)
The primary goal of the EDA is to understand how different analytical groups handle this trade-off by comparing rent burden and commute time across different household structures within the same analytical group.

### At a Glance

<img width="600" alt="overall_prop_type_household" src="https://github.com/user-attachments/assets/83b897ad-87dd-4faa-840d-3121c48685a4" />

Overall, family households are the most common renter household type in Los Angeles County, representing 69.7% of all renter households. In contrast, mixed households, another family-based household structure, represent only 3%, indicating that the majority of family-based households do not often take on an additional roommate to share the space. When it comes to living with a roommate versus living alone, more renters choose to live alone in a single household (18.8%) than with a roommate (8.4%). This overall distribution suggests that renters in Los Angeles County tend to prioritize privacy.

<img width="850" alt="housing_burden_dashboard" src="https://github.com/user-attachments/assets/fd3b9f90-16d0-4c68-b497-f629d2eeccb1" />

Overall, the majority of renters in Los Angeles County meet the gold standard of the 30% rent burden rule (65.4%), while almost a quarter (23.8%) have a rent burden between 30% and 50%. This indicates that 89.2% of renters have a rent burden below 50%. Meanwhile, 7.5% are severely burdened and 3.2% face extreme rent burden, suggesting that these groups continue to experience financial strain. The weighted mean rent burden also remained relatively stable, decreasing slightly from 28.6% in the 2019 ACS 5-year sample to 28.1% in the 2024 sample.

Out of all the household groups in Los Angeles County, single households carry the highest rent burden, with only 53.6% of renters considered affordable. The remaining household groups manage rent burden more comfortably, especially mixed households, where 82.3% of renters are considered affordable. In terms of renters experiencing over 50% rent burden, mixed and roommate households are less likely to face financial difficulties, at 4% and 5.5%, respectively. For family and single households, the non-sharing households, a sizable portion of renters are likely to face this burden, at 10.3% and 15.7%, respectively. This pattern suggests a "privacy tax" on rent burden, where renters who prioritize privacy over shared living tend to pay for it through higher financial strain.


<img width="800" alt="boxplot_rent_by_household_perweigth" src="https://github.com/user-attachments/assets/75a9fe32-8617-4def-a4d6-c605d7750c34" />

The boxplot shows that non-sharing households (single & family) have rent distributions that are less spread out and more stable compared to space-sharing households (roommate & mixed). While single and family households have similar medians and rent distributions (box sizes), the main difference is in the outliers: single household outliers stay between $4,000 and $5,000, while family household outliers extend beyond $5,000.

Roommate-only households show the most instability and spread in rent distribution, with the highest median rent (around $2,150) and upper whisker ($4,500). Their outliers especially reach beyond the graph's $5,000 limit. Even though mixed households have a similar box size and spread, their median rent and upper whisker are comparatively lower. Their outliers are sparse but still extend beyond the $5,000 limit.


<img width="850" alt="transit_performance_dashboard" src="https://github.com/user-attachments/assets/7a218b57-c7f2-45a7-87e2-cd732d12ba5e" />

As expected, the majority of renters commute by private auto (77.2%), and more than 70% of renters commute by private auto across all household groups. Notably, a sizable share of renters work from home (11.7%), while very small portions commute by public transit or active transit, at 5.9% and 3.7% respectively. Overall, this commute pattern is highly consistent with LA's car-oriented urban landscape.


<img width="850"  alt="transit_hh_performance_dashboard" src="https://github.com/user-attachments/assets/5a9e9403-4679-4530-9ba5-08d09a4f54c7" />

Overall, the average commute time stays around 30 minutes across all household groups, ranging from 29.5 to 31.3 minutes. However, rent burden varies across different household groups: single households have the highest mean rent burden (33.3%), followed by family households (28.2%), roommate households (24.1%), and mixed households (21%). This suggests that renters generally expect and manage a commute of around 30 minutes regardless of household type, while rent burden still varies by household structure, reinforcing the "privacy tax" pattern seen earlier.

The trade-off by transit mode looks completely different from the trade-off by household type. While mean rent burden stays around 30% across all transit modes, public transit renters have the highest average rent burden and commute time, at 31.4% and 49.6 minutes, respectively. This clearly indicates that public transit renters are less able to manage this trade-off. By contrast, active transit renters average 30.4% rent burden with the shortest mean commute time of 16 minutes, suggesting they prioritize proximity, likely choosing to live close to work. Private auto and other transit renters manage the trade-off well, with rent burden and commute time both staying around 30% and 30 minutes, respectively.



### Group One (Nonfamily)

<img width="600" alt="independent_share_pie" src="https://github.com/user-attachments/assets/59b0ad49-ee0f-4186-9b6e-221beba20ddc" />

Group One focuses on the trade-off at the individual level. The majority of renters in this group come from single-person households (65.8%), while a sizable portion come from roommate-only households (29.4%). Very few renters come from mixed households (4.7%).

<img width="850" alt="nonfamily_housing_dashboard" src="https://github.com/user-attachments/assets/e7868352-cac3-4d4b-9d67-535945928cbe" />

Overall, 87.9% of renters in Group One have a rent burden of less than 50%. Among all household types, space-sharing households (roommate & mixed) have a comparatively higher share of renters with less than 50% rent burden and a lower share with more than 50% rent burden than non-sharing households (single). 

Additionally, the weighted mean rent burden remained nearly unchanged between the 2019 and 2024 ACS 5-year samples, increasing slightly from 29.4% to 30.0%. This stability was consistent across household types: mixed households increased from 17.7% to 18.1%, roommate households from 24.0% to 24.1%, while single households decreased slightly from 33.2% to 32.9%.


<img width="850" alt="rent_burden_socioeconomic_profiles" src="https://github.com/user-attachments/assets/98c7f329-0f0c-43a9-bcb5-6b9e9ae8e3ec" />

Regarding the socioeconomic profile, all age groups show a similar distribution across rent burden levels in Group One. Renters aged 24–34 represent the largest share across all burden categories (approximately 45–50%), while the share of renters decreases with age. However, income tier reflects the true financial difficulties faced by low-income renters. At the affordable level, more than 80% of renters come from upper- and middle-income groups, while only 14.5% are low-income. At the burdened level, middle- and upper-income renters still account for about half of renters, while the share of low-income renters rises to 43.2%. At both the severely burdened and extreme levels, the share of upper-income renters drops to near zero, while low-income renters increase from 78.2% to 94.5%.

<img width="600" alt="rent_burden_racial_ethnic_profile" src="https://github.com/user-attachments/assets/7072c7e5-5afd-4fb1-a003-dba3f01517d8" />

Similar to age, racial and ethnic groups also show a similar distribution across all rent burden categories in Group One. Non-Hispanic White renters represent the largest proportion (39.1–42.5%), followed by Hispanic/Latino renters (26.6–28.9%). Black/African American and Asian renters account for similar shares, ranging from 10.8–14.9% and 10.9–15.3%, respectively. Other/multi-racial renters represent a smaller share (4.5–5.3%), while Native American renters account for a near-zero share across all rent burden levels.


<img width="850" alt="transit_performance_dashboard" src="https://github.com/user-attachments/assets/53143cb1-dfec-43ab-970c-b03348543d86" />

Similar to the overall transit distribution, private auto represents the largest share of transit modes, as expected. Interestingly, roommate renters living in mixed households are less likely to work from home compared with other household types.


<img width="650" alt="transit_mode_income_profile_high_contrast_green" src="https://github.com/user-attachments/assets/11c4c7c2-58ec-45f7-9588-fefd5bfd8ff7" />

Across all transit modes, the low-income group accounts for the largest share of public transit users (57%) but the smallest share of renters who work from home (18.9%). In contrast, middle-income renters account for the largest share of those who work from home (52.5%), followed by upper-income renters (28.6%).


<img width="850" alt="nonfamily_transit_hh_performance_dashboard" src="https://github.com/user-attachments/assets/e51d9e6a-1ce8-4390-867b-ebab2ae8c4b3" />

Again, the "privacy tax" contributes to higher rent burden, as mean commute times remain similar across household types. Single households experience the highest rent burden (33.3%), followed by roommate (24.1%) and mixed households (17.8%). This pattern is also consistent within each transit mode, where household types have comparable mean commute times but rent burden continues to decrease from single to roommate to mixed households. Notably, single households commuting by public transit face the greatest trade-off, experiencing both the highest rent burden and the longest commute time. In contrast, mixed households using active transit experience the lightest trade-off, with the lowest rent burden and the shortest commute time.




### Group Two (Family)

<img width="850" alt="family_housing_dashboard" src="https://github.com/user-attachments/assets/56274dd9-07fe-4de4-9fd7-4005bdc69a8c" />

Overall, the majority of Group Two renters come from family households (97.7%), with only 2.3% from mixed households. Mixed households have a slightly higher proportion in the affordable category, while family households have higher proportions in the burdened, severely burdened, and extreme categories.

Additionally, the weighted mean rent burden in Group Two decreased from 28.3% in 2019 to 27.4% in 2024. This decline occurred across both household types, falling from 28.4% to 27.5% among family households and from 24.5% to 22.6% among mixed households.

<img width="850" alt="family_rent_burden_socioeconomic_profiles" src="https://github.com/user-attachments/assets/46883e5d-9809-41b1-a18e-20e083b47139" />

For socioeconomic profile, renters near retirement (55–64) remain a relatively small proportion across all categories (11.9%–13.4%). The proportions of renters aged 35–44 and 45–54 increase slightly as rent burden rises. In contrast, renters aged 24–34 represent the largest share in the affordable category, but their proportion decreases as rent burden increases.

In terms of income tier, low-income renters show the largest shift across rent burden categories, representing only 10.1% of affordable renters but dominating the severely burdened (92.7%) and extreme (99.1%) categories. In contrast, upper-income renters are concentrated almost entirely in the affordable category, while middle-income renters also decline sharply as rent burden increases.

<img width="600" alt="family_rent_burden_racial_ethnic_profile" src="https://github.com/user-attachments/assets/c758ac4f-5e53-4766-80c8-485eaa915968" />

Overall, Hispanic/Latino renters represent the majority across all rent burden categories, increasing slightly from 51.3% in the affordable category to 60.7% in the extreme category. In contrast, Non-Hispanic White renters decrease from 24.3% to 16.2% as burden increases, while Black/African American, Asian, and Other/Multi-racial renters remain relatively stable with smaller shares.

<img width="850" alt="family_mixed_worker_profile_dashboard" src="https://github.com/user-attachments/assets/d62870ba-48aa-4e25-b068-bfd44eb22c7c" />

In family-based households, the number of earners and number of children strongly influence rent burden. Multiple earners without children have the lowest burden, representing the largest share of affordable renters in both family (54.1%) and mixed households (71.8%). In contrast, single earners with children experience the highest burden, with their share increasing substantially as burden levels rise. Mixed households with single earners and children show even greater financial strain, particularly in the extreme burden category. Overall, households with more earners tend to have lower rent burden, while households supporting children with a single income face the greatest affordability challenges.


<img width="850" alt="family_transit_performance_dashboard" src="https://github.com/user-attachments/assets/9d7450c5-b773-4055-825e-0c54840814ad" />

Similarly, most Group Two renters commute by private auto, with a sizable share working from home. Although public transit represents a small share, it remains the primary alternative mode compared with active and other transit. This pattern is consistent across all household types.


<img width="650" alt="family_transit_mode_income_profile" src="https://github.com/user-attachments/assets/5366edf7-bb7c-4008-a911-07e4ce2187a2" />


Across private auto, active, and other transit modes, income distribution remains close to the overall 30/50/20 pattern, with low-income renters ranging from 30.6% to 37.1%, middle-income renters from 45.7% to 51.1%, and upper-income renters from 16.3% to 18.3%. Public transit shows a different pattern, with a higher concentration of low-income renters (48.6%) and fewer upper-income renters (8.5%). In contrast, WFH renters have a higher share of upper-income renters (35.2%) and a lower share of low-income renters (17.2%). Overall, middle-income renters remain relatively stable across modes, while public transit and WFH show the clearest income differences.



<img width="850" alt="family_transit_performance_dashboard copy" src="https://github.com/user-attachments/assets/e3d96930-d076-41b2-9183-e8940b934ca2" />

Overall, family and mixed households show a similar rent burden–commute pattern across transit modes. Rent burden remains relatively stable across modes, while commute time varies more substantially, with active transit showing the shortest and public transit the longest commute times. Private auto and other transit show a more balanced trade-off, with relatively similar rent burdens and commute times compared with the larger differences observed in active and public transit. Additionally, mixed households show slightly lower average rent burden and commute time across all transit modes, with mean rent burden ranging from 23.4% to 25.5%, compared with 27.9% to 31.7% for family households.

<img width="850" alt="family_mixed_tradeoff_dashboard_wk_child" src="https://github.com/user-attachments/assets/630d3074-ab12-4c62-86a4-c460d28238cf" />

From the household working structure perspective, commute time remains relatively stable across family households, while rent burden increases as the number of earners decreases and households have more children. Mixed households show a similar rent burden pattern, although multiple earners with children and single earners without children have comparable burden levels. Commute time in mixed households varies slightly more, with households with children generally showing slightly longer commute times than those without. Overall, both family and mixed households show a clear relationship between household resources and rent burden: households with multiple earners and no children have the lowest burden, while single-earner households with children face the highest burden.


### Group Three (WFH)


<img width="800" alt="wfh_population_trends_10yr" src="https://github.com/user-attachments/assets/9050a938-b8b0-444a-9e1d-71c0f69e79c0" />

The last group is an additional analysis focusing only on renters who work from home (WFH). All four household groups experienced a significant increase in the number of WFH renters starting in 2020, continuing to increase or remaining stable through 2021 and 2022 before declining slightly in 2023 due to the return-to-office trend.

<img width="850" alt="wfh_dashboard" src="https://github.com/user-attachments/assets/23d200eb-0903-4a3a-9594-3e9bb85fd614" />

Overall, most WFH renters come from non-sharing households, with 61.3% living in family households and 27.0% in single households. In contrast, roommate-only and mixed households account for only 9.5% and 2.2% of WFH renters, respectively.

Interestingly, the share of WFH renters living in family households decreased by 3% after COVID-19, while the roommate-only share declined by 0.5%. In contrast, the shares of single and mixed households increased by 3.3% and 0.2%, respectively.

<img width="800" alt="wfh_rent_burden_trends_corrected" src="https://github.com/user-attachments/assets/c7faa34c-7ee2-49cc-98a9-f2bc57e60637" />

Overall, the average rent burden remained below 50% for all household types throughout the 10-year period, with single households consistently experiencing the highest burden and mixed households the lowest. Rent burden generally declined after COVID-19 across all household types. Family households exhibited the most stable trend, roommate households became more stable after COVID-19, single households experienced a sharp decline in 2020 followed by a gradual increase, and mixed households generally declined before stabilizing during the pandemic.


<img width="850" alt="wfh_housing_burden_dashboard" src="https://github.com/user-attachments/assets/0013eb6d-26b1-4cd7-bb28-49045807eb86" />

Overall, 90.8% of WFH renters have less than 50% rent burden, with the majority in the affordable category. Again, single households have the lowest share of affordable and burdened renters (less than 50% rent burden) but the highest share of severely burdened and extreme renters (over 50%) among all household groups. This suggests that even with the flexibility to relocate and reduce housing costs, the "privacy tax" persists for single-household renters.


## Modeling

While the EDA describes patterns in the rent–commute trade-off, the goal of the modeling section is to test and predict these patterns more formally. To remain consistent with the EDA, the modeling is conducted separately for Group One and Group Two. This project uses two models:

**K-Means Clustering** – Groups renters into distinct clusters based on income, rent burden, commute time, work hours, and age to identify whether natural renter profiles emerge from the data.

**Logistic Regression** – Predicts which renters are most likely to experience both high rent burden and long commute times simultaneously, using the 30/30 rule (>30% rent burden and >30-minute commute) as the threshold, and identifies the key demographic and transit characteristics associated with this outcome.

### K-Means Clustering

#### GROUP ONE 

<img width="1000" alt="K-MEAN(G1)" src="https://github.com/user-attachments/assets/08e6ce7e-d9cc-4a29-8bc8-3a977d713b79" />

In Group One (non-family households), which includes single households, roommate-only households, and roommate renters in mixed households, renters are grouped into five clusters (k = 5). As these renters are responsible for the trade-off at the individual level, the clustering variables focus on individual-level income, rent burden, commute time, work hours, and age rather than household-level measures.


**Cluster 1** groups renters with the highest income ($302,559) and the lowest rent burden (10.5%) among the five clusters. Renters in this cluster are in their mid-career, with an average age of 41.4, working full-time. It is interesting to note that the average commute time is not the lowest of the five clusters, even though they have the lowest burden and the financial ability to move to housing closer to work. This indicates that commute time may not be the primary concern for this cluster, as they simply expect to spend about 20 to 30 minutes commuting, and the factors driving their housing choices may extend beyond the trade-off, such as housing quality, neighborhood characteristics, or personal preference.


**Cluster 2** groups the youngest full-time renters (31.5) with the lowest combination of rent burden (23.9%) and commute time (24 min). This cluster has the largest sample size of the five clusters. Despite being the youngest group, their income is the second highest among all clusters, possibly suggesting that they work in high-paying industries for their age, such as technology. The large sample size and favorable outcomes suggest that this represents a common pattern among younger full-time renters, who are able to maintain a commute of around 30 minutes while keeping rent burden relatively low.


**Cluster 3** groups renters with the highest rent burden (58.3%) and lowest income ($32,908), and has the third-largest sample size of the five clusters. Renters in this cluster are in their early- to mid-career stages, earning close to minimum wage, with the lowest average weekly work hours (35.1) among all clusters, indicating that the group likely includes a mix of part-time and full-time workers. It is also interesting to note that average commute time falls at around 26.5 minutes, even with the highest rent burden. The relatively short commute despite the highest rent burden suggests that proximity to work may be prioritized over reducing housing costs, even under financial strain.


**Cluster 4** groups the oldest full-time renters (52.9), with a typical commute time (25.3 min) and moderate rent burden (25.4%). This cluster has the second-largest sample size, and renters are in their late-career to pre-retirement stage, earning a moderate income ($69,191) for their age. Similar to Cluster 2, this cluster manages the trade-off well despite only moderate income. As an older renter group, this cluster may benefit from greater housing stability or established living arrangements that help maintain a manageable rent burden.


**Cluster 5** has the smallest sample size of the five clusters, with the longest average commute time (72.9 minutes) and a moderate rent burden (26.3%). Renters in this cluster are full-time workers in their young-to-mid career, earning a moderate income ($65,381). Even though it represents the smallest cluster, this pattern is common in Los Angeles: living farther from work, likely more than 30 miles away, to keep rent more affordable. This cluster illustrates renters trading commute time directly for affordability, the opposite of the pattern observed in Cluster 3.


Overall, non-family households exhibit two types of trade-off. The first (Clusters 1 through 4) keeps commute time around 25 minutes, with rent burden varying mainly by income: the higher the income, the lower the rent burden. Therefore, the trade-off in these clusters appears to shift: it is less about commute time versus rent burden and more about income determining how much rent renters can afford within a fixed commute radius. The second trade-off, and the main focus of this study, is Cluster 5: renters accepting a much longer commute to keep rent burden lower and maintain financial stability.


<img width="800"  alt="png_nonfamily_renter_bubble_chart_high_legibility-1" src="https://github.com/user-attachments/assets/b85d6e4e-14cf-4856-949a-e5ce4bdab606" />

The scatterplot shows Cluster 1 (red, highest income) and Cluster 3 (green, lowest income) positioned at opposite corners, highlighting the strong relationship between income and rent burden. Clusters 2, 4, and 5 overlap densely in the middle-to-left side of the chart (the lower-to-moderate income zone), although a few outliers from Cluster 5 (purple) and Cluster 4 (yellow) extend toward the high-burden area, suggesting that some renters in these clusters still experience financial constraints. With bubble size representing commute time, most bubbles remain within the 30-minute range, with only Cluster 5 (purple) showing noticeably larger bubbles. This indicates that the trade-off for most non-family renters is primarily driven by income and rent burden, while Cluster 5 represents the only group experiencing the classic rent–commute trade-off.


#### GROUP TWO

<img width="1000" alt="k-mean(g2)" src="https://github.com/user-attachments/assets/21c0a1a8-82e5-43b4-bded-d18898eb2660" />


In Group Two (family households), which includes family-only households and family renters in mixed households, renters are grouped into six clusters (k = 6), reflecting the additional household-level variables, such as family size, number of family workers, and number of children, that shape this group's trade-off.



**Cluster 1** groups family-based renters with the highest household income ($218,361) and lowest rent burden (14.3%). Renters in this cluster are full-time workers in their mid-career, with an average family size of 2.51 and 1.93 earners, and few children (0.3 on average). It is interesting to note that this cluster closely matches the pattern of Cluster 1 in Group One, as they also maintain a typical commute time of 31.5 minutes despite high income and greater financial flexibility in housing choice. This suggests that housing choices in this cluster may be shaped by factors beyond the rent–commute trade-off, such as neighborhood characteristics, housing quality, or maintaining manageable commute times for household members.



**Cluster 2** groups family-based renters with the largest family size (4.39) and highest average number of children (2.03) among the six clusters, and has the third-largest sample size. While this cluster has an average of only 1.73 earners and a household income of $83,141, representing relatively limited financial resources given the large family size, the combination of moderate rent burden (27.5%) and commute time (31.3 min) suggests that this group manages the trade-off relatively well. At the same time, the large family size and limited number of earners suggest that this group may still face financial constraints despite managing the rent–commute trade-off relatively well.


**Cluster 3** groups family-based renters with a higher average household income ($124,722) and an average family size of 4.14. This cluster has the highest average number of earners (3.16) among the six clusters and and has few children (0.24 on average), suggesting strong financial capacity supported by multiple working adults. In terms of the trade-off, with a typical commute time of 30.6 minutes, the average rent burden in this cluster is only 18.6%. This represents a financially stable household group. However, despite having multiple earners and few children, the commute time suggests that this cluster does not prioritize minimizing commute time, similar to the pattern observed in Cluster 1


**Cluster 4** groups family-based renters with the lowest household income ($33,997) and fewest average earners (1.32) among the six clusters, while supporting a larger family size of 3.12. As expected, this cluster also has the highest rent burden (62.3%) among the six clusters, while maintaining a typical commute time of 30.5 minutes. This cluster has an average of 1.01 children, suggesting that many households include children. The combination of low income and limited earners indicates significant financial pressure for supporting a larger family. Compared with Cluster 2, which has a higher household income, this cluster experiences greater financial difficulty. Despite the high rent burden, these households still maintain commute times within the 30-minute range, suggesting that the challenge is primarily related to affordability rather than commuting distance.


**Cluster 5** groups family-based renters with the third-highest household income ($91,002) and the largest sample size among the six clusters. This cluster represents a typical dual-earner household, with an average family size of 2.39, 1.86 earners, and few children (0.22 on average). It is also interesting to note that renters in this cluster are the youngest, with an average age of 31.5 years. This cluster manages the trade-off well, with a rent burden around 25% and a commute time of 31.2 minutes. Overall, this cluster reflects a young, dual-income household that maintains financial stability early in their careers.


**Cluster 6** groups family-based renters representing the second-largest sample size and the oldest renters (52.7 years old) among the six clusters. In this cluster, household income ($81,381) is moderate among all clusters, with an average of 1.66 earners supporting a family size of 2.69. This cluster may represent older family households with fewer dependent children, potentially reflecting a later life stage. With a rent burden of 26.1% and a commute time of 31.8 minutes, this cluster manages the trade-off well, similar to Cluster 5.


Overall, all clusters maintain commute times around 30 minutes despite substantial differences in rent burden driven by household structure. The number of dependent children and earners has a significant impact on rent burden, consistent with the patterns identified in the EDA. Therefore, the trade-off in family-based households appears to shift: rather than balancing commute time against rent burden, families are more likely balancing housing affordability within a 30-minute commute range with their household structure and financial capacity.



<img width="800" alt="family_renter_bubble_chart_high_legibility-1" src="https://github.com/user-attachments/assets/614f1ff4-2690-4178-b338-506974b5d3d1" />

Just like non-family households, family clusters show the same core pattern: rent burden is strongly associated with income rather than commute time. Cluster 4 (yellow, lowest income) and Cluster 1 (red, highest income) sit at opposite ends of the chart. However, unlike non-family renters, the remaining clusters (2, 3, 5, and 6) overlap densely across the middle and right side of the chart, with many households positioned in the higher-income range. This rightward shift reflects the difference between individual and household income, as non-family renters primarily rely on individual earnings, while family households reflect pooled household resources. Despite this shift, a few outlier bubbles from Cluster 2 extend toward the Cluster 4 area, suggesting that some family households still experience financial constraints. Unlike non-family households, most bubble sizes across all six clusters remain within the 30-to-60-minute range, with relatively few large bubbles appearing across clusters. This further reinforces that the trade-off for family households is more closely related to income and rent burden than commute time.


### GLM(binomical)


#### GROUP ONE 

<img width="390" alt="glm(g1)" src="https://github.com/user-attachments/assets/8f51d6aa-caca-4263-9a80-93fa2fdbdd7a" />

To analyze the socioeconomic factors associated with renters falling into the dual-burden (30/30) threshold, a logistic regression model was fitted using upper-income, single households, private auto, and Non-Hispanic White renters as baseline categories. All predictors are statistically significant, with most showing strong significance (p < 0.001). The exception is nh_native (p = 0.012), which remains significant at the 0.05 level.

**Income Tier**: 
Income tier shows the strongest association with dual-burden status. Compared to upper-income renters, middle-income renters are 13.4 times more likely to fall into the dual-burden threshold, while low-income renters are 43.5 times more likely. This reinforces that income is the dominant predictor of dual-burden status among non-family renters.

**Household Structure**: 
Compared to single households, roommate households are 69% less likely (OR = 0.31) and mixed households are 89% less likely (OR = 0.11) to fall into the dual-burden threshold. This statistically supports the "privacy tax" finding from the EDA: sharing space is strongly associated with a lower likelihood of falling into dual-burden status.

**Transit Mode**: 
Compared to private auto commuters, public transit renters are 2.57 times more likely to fall into dual-burden status, consistent with the EDA finding that public transit renters face the toughest trade-off. Active transit renters, on the other hand, are 77% less likely (OR = 0.23) to fall into dual-burden status, which may reflect shorter commute distances and greater proximity to work.

**Age and Weekly Hours**: 
Both age and weekly hours worked show small but statistically significant negative associations with dual-burden status (OR = 0.99 for both), suggesting that older renters and those working more hours are slightly less likely to fall into dual-burden status. These effects are relatively small compared with income and household type, indicating that age and work intensity play a more limited role in explaining dual-burden outcomes among non-family renters.


**Race / Ethnicity**: 
Compared to Non-Hispanic White renters, most racial and ethnic groups have lower odds of falling into dual-burden status. Hispanic (OR = 0.70), nh_asian (OR = 0.72), nh_black (OR = 0.87), and nh_other (OR = 0.93) renters are all less likely to fall into the dual-burden threshold. In contrast, nh_native renters show higher odds (OR = 1.22), although this result should be interpreted cautiously given the smaller representation of this group in the dataset. Overall, race and ethnicity show smaller differences compared with the much stronger effects of income, household structure, and transit mode.

<img width="600" alt="model_performance(g1)" src="https://github.com/user-attachments/assets/8cf924e0-3b1f-4d40-9612-0f919b19a329" />

The classification threshold was set at 12%, closely matching the observed prevalence of dual-burden renters (11.8%) in the data, rather than using the default 50% threshold. Under this threshold, the model correctly identifies about 7 out of 10 renters who are actually in dual-burden status (sensitivity: 72.3%), with an overall accuracy of 68.5% and a balanced accuracy of 70.1%. Overall, the model demonstrates a reasonable ability to identify renters likely to fall into the dual-burden threshold.

<img width="500" alt="nonfamily_glm_roc_curve-1" src="https://github.com/user-attachments/assets/5ca7a8aa-b24f-44ee-96f5-5c86f89179d8" />

<img width="500" alt="nonfamily_glm_weighted_roc_curve-1" src="https://github.com/user-attachments/assets/b0b5b211-970b-43ed-8f37-f792f8366eed" />

The ROC curve shows an AUC of 0.78, indicating that the model has good ability to distinguish between renters who fall into the dual-burden threshold and those who do not. The weighted ROC curve, accounting for population weights (PERWT), shows a slightly lower but comparable AUC of 0.77, suggesting that model performance remains consistent when generalized to the broader Los Angeles renter population.


#### GROUP TWO


<img width="410" alt="glm(g2)" src="https://github.com/user-attachments/assets/c17211c9-4dd7-4cd8-894d-f28d7a4663eb" />

To analyze the socioeconomic and household characteristics associated with family-based renters falling into the dual-burden (30/30) threshold, a logistic regression model was fitted using upper-income, family households, private auto, and Non-Hispanic White renters as baseline categories. Compared with Group One, the model includes three additional household-level variables: number of dependent children, family size, and number of family workers (earners), reflecting the role of household structure in shaping affordability outcomes. All variables are statistically significant, with most showing strong significance (p < 0.001), except nh_other (p = 0.064), which does not reach the 0.05 significance level.


**Income Tier**: 
Income tier remains the strongest predictor of dual-burden status in Group Two. Compared with upper-income households, middle-income households are 29.2 times more likely to fall into the dual-burden threshold, while low-income households are 136 times more likely. The much larger odds ratios compared with Group One suggest that income constraints become even more critical when renters are responsible for supporting a household, highlighting the additional financial pressure associated with family-based housing needs.

**Household Structure**: 
Unlike Group One, where sharing space reduced dual-burden risk, mixed households in Group Two are 1.64 times more likely than family households to fall into the dual-burden threshold. This supports the EDA finding that adding a roommate does not necessarily reduce financial strain for family-based households.

**Transit Mode**: 
The transit mode pattern is consistent with Group One. Compared with private auto commuters, public transit renters are 2.57 times more likely to fall into dual-burden status, while active transit renters are 77% less likely (OR = 0.23). This suggests that transit mode influences dual-burden risk in a similar way across both household groups.

**Age and Weekly Hours**: 
Both age and weekly hours show OR = 1.00, indicating that these factors have minimal practical influence on dual-burden status among family households, even though they are statistically significant.

**Race / Ethnicity**: 
Similar to Group One, most racial and ethnic groups show lower odds of falling into dual-burden status compared with Non-Hispanic White renters. The exceptions are nh_native renters (OR = 1.51), who show higher odds, and nh_other renters (OR = 1.03), which is not statistically significant (p = 0.064).

**Household-Level Variables (new in group two)**: 
Each additional dependent child increases the odds of dual-burden status by 8% (OR = 1.08), while each additional family member increases the odds by 2% (OR = 1.02). In contrast, each additional family worker reduces the odds by 29% (OR = 0.71), showing that additional earners provide a significant reduction in dual-burden risk for family households.


<img width="600" alt="model_performance(g2)" src="https://github.com/user-attachments/assets/42e46c79-b454-44de-94c9-f05a578d18ac" />


The classification threshold was set at 10%, closely matching the actual prevalence of dual-burden family households (10.2%) in the data, rather than using the default 50% threshold. The model correctly identifies about 7 out of 10 family households actually in dual-burden status (sensitivity: 74.5%), with an overall accuracy of 72.4% and a balanced accuracy of 73.4%. Overall, the Group Two model performs slightly better than Group One, likely reflecting the additional household-level variables that capture more of the financial complexity among family households.


<img width="500" alt="family_glm_roc_curve-1" src="https://github.com/user-attachments/assets/9da64081-54af-4253-9687-dce9f5ca9674" />

<img width="500" alt="family_glm_weighted_roc_curve-1" src="https://github.com/user-attachments/assets/32cd6727-975c-4c78-953d-34be47489c5e" />

The ROC curve shows an AUC of 0.80, indicating that the model has good ability to distinguish between family renters who fall into the dual-burden threshold and those who do not. The weighted ROC curve, accounting for population weights (PERWT), shows a very similar AUC of 0.79, suggesting that the model's performance remains consistent when generalized to the broader Los Angeles family renter population. Overall, the Group Two model performs slightly better than Group One (AUC: 0.80 vs. 0.78), likely reflecting the added predictive value of household-level variables.

## Conclusion

Overall, this project shows that the classic trade-off between housing affordability and commute time operates differently in Los Angeles County. Rather than renters consistently exchanging lower rent for longer commutes, many stable working renters appear to accept traffic and maintain commute times within a relatively consistent range. Instead, income and household structure are the primary factors shaping where renters can afford to live and how much of their income is allocated toward housing. This pattern is closely tied to Los Angeles County’s car-dependent urban form, where job centers are spread across the region and private vehicles remain the dominant commuting option. This trade-off may look very different in cities such as Boston or New York, where stronger public transit networks and more walkable urban environments provide more diverse commuting choices and may create a stronger relationship between housing location, commute time, and rent burden.

As this trade-off shifts in Los Angeles County, some renter groups show unexpectedly low rent burden despite limited income, likely reflecting factors such as housing assistance programs or long-term housing stability. However, these benefits are often limited by strict eligibility requirements, Area Median Income (AMI) thresholds, and changing rental market conditions. As rents continue to rise and neighborhoods experience gentrification, even households receiving assistance may still face significant affordability challenges when the gap between subsidized costs and actual market rents increases. Meanwhile, this project focuses only on stable working renters; other low-income workers outside this population may experience even greater difficulty balancing housing costs and commuting needs.


Having lived in Los Angeles for a decade, I have personally witnessed the continued increase in housing costs over time. For many renters who want to maintain a reasonable commute, higher rent burden becomes an unavoidable consequence. While Los Angeles has continued investing in public transit improvements, its polycentric urban structure, with employment centers distributed across the county rather than concentrated in a single downtown core, makes it difficult for transit alone to replace car dependency. Therefore, expanding affordable housing, maintaining housing stability, and strengthening assistance programs remain critical strategies for reducing financial pressure among low-income renters in Los Angeles County.



