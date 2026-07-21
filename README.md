# LA-Renter-Affordability-Commute-Analysis-5Yr-ACS-2019-2024
Analysis of the trade-off between housing affordability and commute time in Los Angeles County across two 5-year ACS periods (2019 & 2024) using R.

## Why This Project
As a renter living in LA, the trade-off between housing affordability and commute time is a real and often difficult decision, given the high rent and heavy traffic during rush hour. As an international student in LA, I faced this trade-off directly: live close to school to minimize commute time but pay higher rent (even with a roommate), or live farther away for more affordable rent but face commutes of up to two hours. Early on, I prioritized a shorter commute and was willing to share housing. Later, my priorities shifted toward privacy and affordability over commute time, as I only needed to attend school two to three times a week. For workers with less flexible schedules, this trade-off can be even more difficult, especially those working full-time or more than three days a week. Therefore, this project attempts to understand how Los Angeles renters from different households handle this trade-off, using the 2019 and 2024 5-year ACS estimates. As a secondary analysis, I also explore how the rise of remote work following COVID-19 may have shifted this pattern.


## Data

The data retrieved from IPUMS USA, with samples selected from the ACS 5-Year datasets for **2015–2019** and **2020–2024**, restricted to **Los Angeles County, California**. For detailed information on variable selection and additional variables, please refer to the [Variable Selection Details](variable-selection-details.md) page.

### Renter Household & Unit Structure Criteria:

* The ownership of the dwelling (tenure) is rented, with cash rent.
* The unit structure must be a physical housing unit: a 1-family house (detached or attached) or a multi-family building with 2 or more units.
* For multi-person households, only two-to-five-person households were retained, as these represent the majority within that ACS 5-year sample (82.4% in ACS 2019, 83.3% in ACS 2024).

### Stable Worker Criteria:

A person who is:
1. Aged 24–64,
2. Currently at work,
3. Working between 20 and 80 hours per week, and
4. Earning an annual income greater than or equal to the annual minimum wage in California for that year ([U.S. DOL Minimum Wage History](https://www.dol.gov/agencies/whd/state/minimum-wage/history)). 

### Renter Household Classifications

**Single Renter Household** 
A single-person household in which the person is a stable worker living alone. Following data wrangling, 21,974 observations remain for analysis.

**Roommate Renter Household** 
A multi-person household in which the head is a stable worker and all other household members are non-family roommates. Following data wrangling, 9,229 observations remain for analysis.

**Family Renter Household** 
A multi-person household in which the head is a stable worker and all other household members share a family-based relationship. Following data wrangling, 85,848 observations remain for analysis. 

**Mixed Renter Household** 
A multi-person household in which the head is a stable worker, living with family members who share a family-based relationship with the head (not required to be workers), and at least one non-family roommate who is also a stable worker. Following data wrangling, 3,454 observations remain for analysis.


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

<img width="600" alt="overall_prop_type_household" src="https://github.com/user-attachments/assets/83b897ad-87dd-4faa-840d-3121c48685a4" />

Overall, family households are the most common renter household type in Los Angeles County, representing 69.7% of all renter households. In contrast, mixed households, another family-based household structure, represent only 3%, indicating that the majority of family-based households do not often take on an additional roommate to share the space. When it comes to living with a roommate versus living alone, more renters choose to live alone in a single household (18.8%) than with a roommate (8.4%). This overall distribution suggests that renters in Los Angeles County tend to prioritize privacy.

<img width="850" alt="housing_burden_dashboard" src="https://github.com/user-attachments/assets/fd3b9f90-16d0-4c68-b497-f629d2eeccb1" />


Overall, the majority of renters in Los Angeles County meet the gold standard of the 30% rent burden rule (65.4%), and almost a quarter of renters (23.8%) have a rent burden between 30% and 50%. This indicates that 89.2% of renters in Los Angeles County have a rent burden of less than 50%. Meanwhile, 7.5% of renters are severely burdened and 3.2% face extreme rent burden, suggesting that these groups are still struggling financially. 

Out of all the household groups in Los Angeles County, single households carry the highest rent burden, with only 53.6% of renters considered affordable. The remaining household groups manage rent burden more comfortably, especially mixed households, where 82.3% of renters are considered affordable. In terms of renters experiencing over 50% rent burden, mixed and roommate households are less likely to face financial difficulties, at 4% and 5.5%, respectively. For family and single households, the non-sharing households, a sizable portion of renters are likely to face this burden, at 10.3% and 15.7%, respectively. This pattern suggests a "privacy tax" on rent burden, where renters who prioritize privacy over shared living tend to pay for it through higher financial strain.


<img width="800" alt="boxplot_rent_by_household_perweigth" src="https://github.com/user-attachments/assets/75a9fe32-8617-4def-a4d6-c605d7750c34" />

The boxplot shows that non-sharing households have rent distributions that are less spread out and more stable compared to space-sharing households. While single and family households have similar medians and rent distributions (box sizes), the main difference is in the outliers: single household outliers stay between $4,000 and $5,000, while family household outliers extend beyond $5,000.

Roommate-only households show the most instability and spread in rent distribution, with the highest median rent (around $2,150) and upper whisker ($4,500). Their outliers especially reach beyond the graph's $5,000 limit. Even though mixed households have a similar box size and spread, their median rent and upper whisker are comparatively lower. Their outliers are sparse but still extend beyond the $5,000 limit.


<img width="850" alt="transit_performance_dashboard" src="https://github.com/user-attachments/assets/7a218b57-c7f2-45a7-87e2-cd732d12ba5e" />

Unsurprisingly, the majority of renters commute by private auto (77.2%), and more than 70% of renters commute by private auto across all household groups. Notably, a sizable share of renters work from home (11.7%), while very small portions commute by public transit or active transit, at 5.9% and 3.7% respectively. Overall, this commute pattern is highly consistent with LA's car-oriented urban landscape.


<img width="850"  alt="transit_hh_performance_dashboard" src="https://github.com/user-attachments/assets/5a9e9403-4679-4530-9ba5-08d09a4f54c7" />

Overall, the average commute time stays around 30 minutes across all household groups, ranging from 29.5 to 31.3 minutes. However, rent burden varies across different household groups: single households have the highest mean rent burden (33.3%), followed by family households (28.2%), roommate households (24.1%), and mixed households (21%). This suggests that renters generally expect and manage a commute of around 30 minutes regardless of household type, while rent burden still varies by household structure, reinforcing the "privacy tax" pattern seen earlier.

The trade-off by transit mode looks completely different from the trade-off by household type. While mean rent burden stays around 30% across all transit modes, public transit renters have the highest average rent burden and commute time, at 31.4% and 49.6 minutes, respectively. This clearly indicates that public transit renters are less able to manage this trade-off. By contrast, active transit renters average 30.4% rent burden with the shortest mean commute time of 16 minutes, suggesting they prioritize proximity, likely choosing to live close to work. Private auto and other transit renters manage the trade-off well, with rent burden and commute time both staying around 30% and 30 minutes, respectively.



### Group One (Nonfamily)

<img width="600" alt="independent_share_pie" src="https://github.com/user-attachments/assets/59b0ad49-ee0f-4186-9b6e-221beba20ddc" />

In group one, the majority of renters come from single households at 65.8%, which again confirms that renters in Los Angeles County prioritize privacy. Additionally, a sizable portion of renters are from roommate-only households at 29.4%, and very few come from mixed households at 4.7%, indicating that renters who share space to reduce their rent burden are less likely to share that space with family.


<img width="850" alt="nonfamily_housing_dashboard" src="https://github.com/user-attachments/assets/e7868352-cac3-4d4b-9d67-535945928cbe" />

In group one, 87.9% of renters have less than 50% rent burden. Among all household types, mixed households have the highest share of renters with less than 50% rent burden (98%) and the lowest share with more than 50% rent burden (around 2%). For roommate-only households, 94.5% have less than 50% rent burden, while 5.5% have more than 50%. For single households, 84.2% have less than 50% rent burden, but a sizable 15.7% experience more than 50% rent burden.


<img width="850" alt="rent_burden_socioeconomic_profiles" src="https://github.com/user-attachments/assets/98c7f329-0f0c-43a9-bcb5-6b9e9ae8e3ec" />

All age groups share a similar proportion across the range of rent burden in group one: about 12%–13% from ages 55–64, about 16% from ages 45–54, roughly 22%–25% from ages 35–44, and approximately 45–50% from ages 24–34.

However, the income tier reflects the true financial difficulties for those with low income. At the affordable level, more than 80% of renters come from upper- and middle-income groups, and only 14.5% are low-income. At the burdened level, middle- and upper-income renters still occupy about half, while the low-income group rises to 43.2%. At both the severely burdened and extreme levels, the upper-income group drops to near zero, and low-income renters expand from 78.2% to 94.5%.


<img width="600" alt="rent_burden_racial_ethnic_profile" src="https://github.com/user-attachments/assets/7072c7e5-5afd-4fb1-a003-dba3f01517d8" />

Similar to age group, racial and ethnic groups also share a similar proportion across the range of rent burden in group one: about 39.1–42.5% Non-Hispanic White, approximately 26.6–28.9% Hispanic/Latino, roughly 10.8–14.9% Black/African American, about 10.9–15.3% Asian, roughly 4.5–5.3% Other/Multi-racial, and Native American renters at near zero across all rent burden levels.


<img width="850" alt="transit_performance_dashboard" src="https://github.com/user-attachments/assets/53143cb1-dfec-43ab-970c-b03348543d86" />


In group one, the overall transit distribution is pretty similar across all household types: the majority of renters commute by private auto at 72.2%, a sizable portion work from home at 15.2%, and very few commute by public transit, active transit, or other transit methods. This pattern is consistent across all household groups. However, it is interesting to note that roommate renters living in mixed households are less likely to work from home compared with other household groups.


<img width="650" alt="transit_mode_income_profile_high_contrast_green" src="https://github.com/user-attachments/assets/11c4c7c2-58ec-45f7-9588-fefd5bfd8ff7" />

In group one, active transit and other transit show the most balanced income distribution across all three tiers. However, the low-income group is more likely to use public transit (57%) compared with private auto (29.9%) and work from home (18.9%). For middle- and upper-income renters, these two income tiers are the primary users of private auto and are very likely to work from home.


<img width="850" alt="nonfamily_transit_hh_performance_dashboard" src="https://github.com/user-attachments/assets/e51d9e6a-1ce8-4390-867b-ebab2ae8c4b3" />

Again, the "privacy tax" adds to rent burden as mean commute time is controlled within 30 minutes, with single households having the highest rent burden at 33.3%, followed by roommate households at 24.1%, and mixed households at 17.8%. This pattern remains consistent within transit groups and household types. When mean commute time is controlled within a specific range for each transit mode, rent burden decreases from the highest (single households) to the lowest (mixed households). However, it is worth noting that single households commuting by public transit are the most difficult group, as these renters face a double burden: extra rent burden from the "privacy tax" and the longest commute time across all transit and household groups. Renters living in mixed households who use active transit, on the other hand, are very likely to experience the lightest burden in this trade-off, with the least rent burden and commute time across all household and transit groups.


<img width="850" alt="carpool_rent_burden_by_hh" src="https://github.com/user-attachments/assets/5a0168c5-11d7-4e32-8b3a-11bd6ccb6109" />

Another interesting lens to look at the non-family group is carpool status, as carpooling may be another way to reduce rent burden, especially for the single household, non-sharing group. For roommate-only and mixed households, carpool status shows no major change in rent burden when comparing the drives-alone and carpool groups. However, single households flip this assumption that carpooling may reduce rent burden. Instead, affordable renters in the drives-alone group have a higher proportion at 54.7%, compared with 40.3% in the carpool group. Across the more burdened categories, the carpool group consistently shows a higher proportion than the drives-alone group: burdened (39.1% vs. 30.2%), severely burdened (14.7% vs. 10.4%), and extreme (5.9% vs. 4.6%). Overall, carpool status shows no significant improvement in reducing rent burden across all household types.


### Group Two (Family)

<img width="850" alt="family_housing_dashboard" src="https://github.com/user-attachments/assets/56274dd9-07fe-4de4-9fd7-4005bdc69a8c" />

Overall, the majority of group two renters come from family households (97.7%), and very few come from mixed households (2.3%). The "privacy tax" also applies to group two, where mixed households have a comparatively higher proportion in the affordable category. Across the more burdened categories (burdened, severely burdened, and extreme), family households have a slightly higher proportion.

<img width="850" alt="family_rent_burden_socioeconomic_profiles" src="https://github.com/user-attachments/assets/46883e5d-9809-41b1-a18e-20e083b47139" />

In group two, renters near retirement (55–64) stay fairly stable across all categories, ranging narrowly from 11.9% to 13.4%. For rent burden under 50% (affordable and burdened), young professionals (24–34) have a slightly higher proportion than mid- and late-career professionals (35–44 and 45–54). For rent burden over 50% (severely burdened and extreme), the proportion of young professionals decreases while mid- and late-career professionals increase, with young and mid-career professionals ending up with a similar share in the more burdened categories. 

In terms of income tier, the low-income group shows a very significant shift across the four rent burden categories. In the affordable category, low-income renters represent only 10.1%, then increase to 62.1% in the burdened category. In both severely burdened and extreme categories, low-income renters dominate, at 92.7% and 99.1% respectively. In contrast, almost all upper-income renters fall under the affordable category and drop to nearly zero in the more burdened categories. Meanwhile, middle-income renters also significantly decline at high burden levels, dropping to just 7.3% in the severely burdened category and to nearly zero in extreme.


<img width="600" alt="family_rent_burden_racial_ethnic_profile" src="https://github.com/user-attachments/assets/c758ac4f-5e53-4766-80c8-485eaa915968" />


Overall, more than half of renters are Hispanic/Latino across all rent burden categories, with a slight increase in proportion as burden grows, from 51.3% at affordable to 60.7% at extreme. In contrast, White (Non-Hispanic) renters make up a sizeable share but decrease as burden increases, from 24.3% at affordable to 16.2% at extreme. Black/African American, Asian, and Other/Multi-racial renters represent comparatively smaller proportions and stay fairly stable across the four rent burden categories.


<img width="850" alt="family_mixed_worker_profile_dashboard" src="https://github.com/user-attachments/assets/d62870ba-48aa-4e25-b068-bfd44eb22c7c" />


In family-based households, the number of stable workers in a family may impact rent burden, especially for families with children under the age of 18. 

Overall, multiple earners without children have the least rent burden, sharing the largest proportion of the affordable category in both family (54.1%) and mixed (71.8%) households, with that share decreasing as burden level increases. 

In contrast, single earners with children have the highest rent burden, and this share significantly increases as burden level grows. It is interesting to note that the shares for less than 50% rent burden are pretty similar for both family and mixed households, while mixed households have a higher share for over 50% rent burden, indicating that mixed households with a single earner and children are more likely to face financial difficulties than family households.

For multiple earners with children, family and mixed households show a completely different pattern. In family households, the share slightly decreases as rent burden increases. In mixed households, however, a sizable proportion centers on burdened (18.5%) and severely burdened (15.6%), with comparatively smaller shares in affordable and extreme categories.

Similarly, for single earners without children, the share in family households increases as rent burden increases, while in mixed households, a sizable share falls under burdened (20.2%) and extreme (22%) categories, with comparatively smaller shares in affordable and severely burdened categories.

This indicates that single earners face tremendous financial difficulties, especially those with children, with mixed households showing an even higher share in the extreme burden category than family households.

<img width="650" alt="family_transit_mode_income_profile" src="https://github.com/user-attachments/assets/5366edf7-bb7c-4008-a911-07e4ce2187a2" />

Among private auto, active, and other transit modes, the income tier distribution closely mirrors the original 30/50/20 split: ranging from 30.6% to 37.1% for low-income, 45.7% to 51.1% for middle-income, and 16.3% to 18.3% for upper-income.

For public transit in group two, low-income renters significantly increase to 48.6%, becoming the largest share within public transit, though closely followed by middle-income at 43.0%, while upper-income renters drop to just 8.5%. In contrast, upper-income renters in WFH increase to 35.2%, while low-income renters drop to 17.2%.

Overall, middle-income renters stay very stable across all transit modes, while public transit and WFH show the most divergence, with low-income concentrated in public transit and upper-income concentrated in WFH.


<img width="850" alt="family_transit_performance_dashboard" src="https://github.com/user-attachments/assets/9d7450c5-b773-4055-825e-0c54840814ad" />

Similarly, the majority of renters in group two commute by private auto, with a sizable portion working from home. Even though very few commute by public transit, it is the primary alternative transit mode compared with active and other transit. This pattern is consistent across all household types in group two.


<img width="850" alt="family_transit_performance_dashboard copy" src="https://github.com/user-attachments/assets/e3d96930-d076-41b2-9183-e8940b934ca2" />

Overall, both family-based household types share a similar trade-off between rent burden and commute time. Rent burden stays within a similar level across all transit modes, while commute time varies, with active transit being the shortest and public transit being the longest. Private auto and other transit show a good balance on this trade-off.

Additionally, mixed households have slightly less mean commute time and rent burden across all transit modes. While the average rent burden ranges from 27.9% to 31.7% in family households, mixed households' mean burden ranges from 23.4% to 25.5%. Among all transit modes, the mean commute time in mixed households is 1–5 minutes shorter than in family households.


<img width="850" alt="family_mixed_tradeoff_dashboard_wk_child" src="https://github.com/user-attachments/assets/630d3074-ab12-4c62-86a4-c460d28238cf" />

From the lens of household working structure, this trade-off shows that family households have no clear advantage in managing rent burden, while average commute time stays similar across all household groups and working structures. In family households, rent burden increases as the number of earners decreases, and is also strongly associated with having children. In mixed households, single earners with children face the highest burden and multiple earners with no children face the least, while multiple earners with children and single earners without children show similar shares.

Overall, single earners consistently face the greatest financial strain, especially when children are involved, and this holds true across both family and mixed households.


### Group Three (WFH)


<img width="800" alt="wfh_population_trends_10yr" src="https://github.com/user-attachments/assets/9050a938-b8b0-444a-9e1d-71c0f69e79c0" />

The last group is an additional analysis looking only at WFH renters. All four household groups experience a significant growth of the number of WFH renters starting in 2020, keep increasing or staying stable through 2021 and 2022, then slightly decrease by 2023 due to the trend of back to office.

<img width="850" alt="wfh_dashboard" src="https://github.com/user-attachments/assets/23d200eb-0903-4a3a-9594-3e9bb85fd614" />

Overall, the majority of WFH renters come from non-sharing households: 61.3% from family and 27% from single household. For space-sharing households, it is less likely to have WFH renters in both roommate and mixed households, 9.5% and 2.2% respectively.

It is interesting to note that the family household share of all WFH renters actually decreased by 3% before and after COVID-19. Similarly, the roommate household share also decreased by 0.5%. In contrast, the share for single and mixed households increased by 3.3% and 0.2%, respectively.


<img width="800" alt="wfh_rent_burden_trends_corrected" src="https://github.com/user-attachments/assets/c7faa34c-7ee2-49cc-98a9-f2bc57e60637" />

Overall, the average rent burden for all households stayed under 50% over the 10-year period, with single households having the highest burden and mixed households having the least. Also, the average rent burden for all households in the post-COVID period is lower than before COVID.

Out of the four household groups, family households show the most stable pattern, with steady increases and decreases that stay within the range of roughly 24% to 32%. The rent burden in the post-COVID period is significantly lower than before COVID.

For single households, the average rent burden slightly decreases from 40% in 2015 to about 34% in 2018, with a minor increase in 2019. A sharp decrease happened during COVID-19 in 2020, and the burden has been steadily increasing since. Similar to family households, the rent burden in the post-COVID period is significantly lower than before COVID.

For roommate households, the average rent burden was quite unstable before COVID, moving up and down from year to year with no clear direction. Since COVID-19 in 2020, the burden has been more stable, with a slight decrease. Overall, the rent burden in the post-COVID period is slightly lower than before COVID.

For mixed households, the average rent burden peaks in 2016 and keeps moving down until COVID-19 in 2020, then stays stable between 2020 and 2022. After a sharp decrease in 2023, the average rent burden goes back to a higher level in 2024. Overall, the rent burden in the post-COVID period is slightly lower than before COVID.



<img width="850" alt="wfh_housing_burden_dashboard" src="https://github.com/user-attachments/assets/0013eb6d-26b1-4cd7-bb28-49045807eb86" />

Overall, 90.8% of WFH renters have less than 50% rent burden, with the majority falling in the affordable category. Single households, again, have the lowest share in both the affordable and burdened categories (less than 50%) but the highest share in both severely burdened and extreme categories (over 50%) compared with the rest of the household groups. This indicates that even though single household renters have the flexibility to relocate anywhere to lower their rent, the "privacy tax" still persists.




## Modeling

While the EDA describes patterns in the rent-commute trade-off, the goal of the modeling section is to test and predict them more formally. To stay consistent with the EDA, the modeling process is applied separately to group one and group two. This project uses two models:

**K-Means Clustering** – groups renters into distinct types based on income, rent burden, commute time, work hours, and age, to see if natural renter "profiles" emerge from the data.

**Logistic Regression** – predicts which renters are most likely to face both high rent burdens and long commutes simultaneously, using the "30/30 rule" (>30% rent burden and >30-minute commute) as the threshold, and identifies which demographic and transit factors matter most.

### K-Means Clustering

#### GROUP ONE 

<img width="1000" alt="K-MEAN(G1)" src="https://github.com/user-attachments/assets/08e6ce7e-d9cc-4a29-8bc8-3a977d713b79" />

In group one (non-family households), which includes single, roommate-only, and roommate renters in mixed households, renters are grouped into five clusters (k = 5). As these renters are responsible for the trade-off at the individual level, the clustering variables focus on individual-level income, rent burden, commute time, work hours, and age, rather than household-level measures.


**Cluster 1** groups renters with the highest income ($302,559) and the lowest rent burden (10.5%) of the five clusters. Renters in this cluster are in their mid-career, with an average age of 41.4, working full-time. It is interesting to note that the average commute time is not the lowest of the five clusters, even though they have the lowest burden and the financial ability to move to housing closer to work. This indicates that commute time may not be the main concern for this cluster, as they simply expect to be on the road for about 20 to 30 minutes, and the factors driving their choices may go beyond the trade-off, such as housing quality, neighborhood, or personal preference.


**Cluster 2** groups the youngest full-time renters (31.5) with the lowest combination of rent burden (23.9%) and commute time (24 min). This cluster has the largest sample size of the five clusters. Despite being the youngest group, their income is the second highest among all clusters, possibly suggesting they work in high-paying fields for their age, such as tech. However, this cluster is more likely to face the trade-off, as their income is more moderate ($72,343), but they still manage it well relative to the other clusters.


**Cluster 3** groups renters with the highest rent burden (58.3%) and lowest income ($32,908), and has the third-largest sample size of the five clusters. Renters in this cluster are in their young-to-mid career, earning close to minimum wage, with the lowest average weekly hours (35.1) among all clusters, indicating the group likely includes a mix of part-time and full-time workers. It is also interesting to note that average commute time falls at around 26.5 minutes, even with the highest rent burden. The preference for commute time indicates that housing location or proximity to work may matter more to this cluster than lowering their rent burden, despite financial strain.


**Cluster 4** groups the oldest full-time renters (52.9), with a typical commute time (25.3 min) and moderate rent burden (25.4%). This cluster has the second-largest sample size, and renters in this cluster are in their late-career to pre-retirement stage, earning a moderate income ($69,191) for their age. Similar to Cluster 2, this cluster manages the trade-off well, but they are likely benefiting from lower rent as long-term renters, possibly protected by rent control or having secured a lease years ago before prices rose. This suggests that renter tenure may play a role in easing this trade-off. 


**Cluster 5** has the smallest sample size of the five clusters, with the longest average commute time (72.9 minutes) and a moderate rent burden (26.3%). Renters in this cluster are full-time workers in their young-to-mid career, earning a moderate income ($65,381). Even though it represents a small portion of group one renters, this is a very typical pattern in Los Angeles: living farther away from work, likely over 30 miles, to keep rent more affordable. This shows the cluster trading commute time directly for affordability, the opposite of the pattern seen in Cluster 3.


Overall, non-family households show two types of trade-off. The first (Clusters 1 through 4) keeps commute time around 25 minutes, with rent burden varying mainly by income: the higher the income, the lower the rent burden. Therefore, the trade-off in these clusters likely flips: it's less about commute time versus rent burden, and more about income determining how much rent someone can afford within that fixed commute radius. The second trade-off, and the main focus of this study, is Cluster 5: renters accepting a much longer commute to keep rent burden lower and maintain financial stability.

It's also worth noting that Cluster 4 suggests renter tenure may play a role separate from income. Despite only moderate income, older renters in this cluster maintain a manageable rent burden, likely benefiting from long-term leases or rent-controlled units rather than income alone.



<img width="800"  alt="png_nonfamily_renter_bubble_chart_high_legibility-1" src="https://github.com/user-attachments/assets/b85d6e4e-14cf-4856-949a-e5ce4bdab606" />

The scatterplot shows Cluster 1 (red, highest income) and Cluster 3 (green, lowest income) sitting at opposite corners, indicating that higher income is strongly tied to a lower rent burden. Clusters 2, 4, and 5 overlap densely in the middle-to-left side of the chart (the lower-to-moderate income zone), but a few outliers from Cluster 5 (purple) and Cluster 4 (yellow) fall even deeper into the high-burden corner, suggesting some renters in these clusters still face financial constraints. With bubble size representing commute time, most bubbles stay within the 30-minute range, with only Cluster 5 (purple) showing noticeably larger bubbles. This indicates that the trade-off is more about income versus rent burden for most nonfamily renters, with Cluster 5 being the only cluster that actually experiences the classic rent-commute trade-off.


#### GROUP TWO

<img width="1000" alt="k-mean(g2)" src="https://github.com/user-attachments/assets/21c0a1a8-82e5-43b4-bded-d18898eb2660" />

In group two (family households), which includes family-only households and family renters in mixed households, renters are grouped into six clusters (k = 6), reflecting the additional household-level variables, such as family size, number of family workers, and number of children, that shape this group's trade-off.

**Cluster 1** groups family-based renters with the highest household income ($218,361) and lowest rent burden (14.3%). Renters in this cluster are full-time workers in their mid-career, with an average family size of 2.51 and 1.93 earners, and are unlikely to have children. It is interesting to note that this cluster closely matches the pattern of Cluster 1 in group one, as they also have a typical commute time of 31.5 minutes, even with high income and the ability to move wherever they like. This suggests housing choice in this cluster may be shaped by factors like neighborhood or housing quality, or by keeping each earner's commute to around 30 minutes.


**Cluster 2** groups family-based renters with the largest family size (4.39) and highest number of children (2.03) of the six clusters, and has the third-largest sample size. While this cluster has an average of only 1.73 earners and a household income of $83,141, which is considered relatively low on a per-capita basis given the large family size, the trade-off between rent burden (27.5%) and commute time (31.3 min) indicates this cluster is managing it well. However, households in this cluster may benefit from housing subsidy programs, but are still likely to face financial constraints.


**Cluster 3** groups family-based renters with a higher average household income ($124,722) and an average family size of 4.14. This cluster has the highest average number of earners (3.16) of the six clusters and is very unlikely to have children, suggesting strong financial capacity from multiple working adults. In terms of the trade-off, with a typical commute time of 30.6 minutes, the average rent burden in this cluster is only 18.6%. This is a well-earning household with strong financial ability to ease rent burden. However, commute time suggests that even with multiple earners and no children to accommodate, this cluster still doesn't optimize for a shorter commute, similar to the pattern seen in Cluster 1.


**Cluster 4** groups family-based renters with the lowest household income ($33,997) and average number of earners (1.32) of the six clusters, supporting a larger family size of 3.12. As expected, this cluster also has the largest rent burden (62.3%) of the six clusters, while maintaining a typical commute time of 30.5 minutes. This household is likely to have one child, and the income of $33,997 suggests that the sole earner in the household may only just clear the minimum wage threshold needed to support a family of three with one child. This indicates greater financial difficulty than Cluster 2, which has a higher household income. This cluster is likely supported by housing subsidies, but still faces a large rent burden. Even so, they still manage to keep commute time within 30 minutes.


**Cluster 5** groups family-based renters with the second-highest household income ($91,002), and is the largest sample size of the six clusters. The household in this cluster is a very typical two-working-couple family, with an average family size of 2.39 and 1.86 earners, and very unlikely to have children. It is also interesting to note that renters in this cluster are the youngest, at 31.5 years old. This cluster manages the trade-off well, with a rent burden around 25% and a commute time of 31.2 minutes. Overall, this cluster reflects a young, dual-income household prioritizing financial stability early in their careers.


**Cluster 6** groups family-based renters representing the second-largest sample size and the oldest renters (52.7 years old) of the six clusters. In this cluster, the household income of $81,381 is moderate among all clusters, with an average of 1.66 earners supporting a family of 2.69. This cluster likely represents older renter couples in the empty-nest stage, whose children have grown up, established their own families, and moved out. With a rent burden of 26.1% and a commute time of 31.8 minutes, this cluster manages the trade-off well, similar to Cluster 5. 


Overall, it is interesting to note that all clusters keep commute time around 30 minutes, despite different rent burdens depending on household structure. The number of dependent children and earners has a profound impact on rent burden, which was also discussed in the EDA. Therefore, the trade-off in family-based households likely flips: since average commute time stays around 30 minutes across all clusters, the trade-off is more likely about finding housing within that 30-minute commute that can support the family's structure and income, rather than about commute time versus rent burden.


<img width="800" alt="family_renter_bubble_chart_high_legibility-1" src="https://github.com/user-attachments/assets/614f1ff4-2690-4178-b338-506974b5d3d1" />

Just like nonfamily households, the family clusters show the same core pattern: rent burden is driven almost entirely by income rather than commute time. Cluster 4 (yellow, lowest income) and Cluster 1 (red, highest income) sit at opposite ends of the chart. However, unlike nonfamily renters, the remaining clusters (2, 3, 5, and 6) overlap densely across the middle and right side of the chart, pushing heavily into the high-income zone. This rightward shift is because nonfamily renters solely rely on their individual incomes, whereas family households reflect pooled household incomes. Despite the rightward shift, a few outlier bubbles from Cluster 2 fall into the Cluster 4 zone, suggesting some households are still likely to face financial constraints. Unlike nonfamily households, most bubble sizes across all six clusters stay within the 30-to-60-minute range, with very few large bubbles mixed into each cluster. This further reinforces that the trade-off is more about income versus rent burden than commute time for family households.


### GLM(binomical)


#### GROUP ONE 

<img width="390" alt="glm(g1)" src="https://github.com/user-attachments/assets/8f51d6aa-caca-4263-9a80-93fa2fdbdd7a" />

To analyze the socioeconomic conditions under which renters are likely to fall into the dual-burden (30/30) threshold, a logistic regression was fitted with baselines of upper-income, single household, private auto, and Non-Hispanic White. The model reveals that all variables are highly statistically significant (p < 0.001), with the exception of nh_native (p = 0.012), which is still statistically significant at the 0.05 level.

**Income Tier**: 
Income tier has the strongest effect on dual-burden status. Compared to upper-income renters, middle-income renters are 13.4 times more likely to fall into the dual-burden threshold, while low-income renters are 43.5 times more likely. This confirms that income is the most dominant predictor of falling into the 30/30 dual-burden.

**Household Structure**: 
Compared to single households, roommate households are 69% less likely (OR = 0.31) and mixed households are 89% less likely (OR = 0.11) to fall into the dual-burden threshold. This statistically confirms the "privacy tax" finding from the EDA: sharing space significantly reduces the risk of falling into dual-burden status.

**Transit Mode**: 
Compared to private auto commuters, public transit renters are 2.57 times more likely to fall into dual-burden status, consistent with the EDA finding that public transit renters face the toughest trade-off. Active transit renters, on the other hand, are 77% less likely (OR = 0.23), reflecting their shorter commutes and proximity to work.

**Age and Weekly Hours**: 
Both age and weekly hours worked show small but statistically significant negative effects (OR = 0.99 for both), suggesting that older renters and those working more hours are slightly less likely to fall into dual-burden status, possibly reflecting more stable employment and earnings over time.

**Race / Ethnicity**: 
Compared to Non-Hispanic White renters, all racial and ethnic groups except nh_native show lower odds of falling into dual-burden status. Hispanic (OR = 0.70), nh_asian (OR = 0.72), nh_black (OR = 0.87), and nh_other (OR = 0.93) renters are all less likely than Non-Hispanic White renters to fall into dual-burden status. Notably, nh_native renters are 22% more likely (OR = 1.22), though this should be interpreted with caution given the small sample size of this group in the data.


<img width="600" alt="model_performance(g1)" src="https://github.com/user-attachments/assets/8cf924e0-3b1f-4d40-9612-0f919b19a329" />

The classification threshold was set at 12%, matching the actual prevalence of dual-burden renters (11.8%) in the data, rather than using the default 50% threshold. The model correctly identifies about 7 out of 10 renters actually in dual-burden status (sensitivity: 72.3%), with an overall accuracy of 68.5% and a balanced accuracy of 70.1%. Overall, the model performs well in identifying renters at risk of falling into the dual-burden threshold.


<img width="500" alt="nonfamily_glm_roc_curve-1" src="https://github.com/user-attachments/assets/5ca7a8aa-b24f-44ee-96f5-5c86f89179d8" />

<img width="500" alt="nonfamily_glm_weighted_roc_curve-1" src="https://github.com/user-attachments/assets/b0b5b211-970b-43ed-8f37-f792f8366eed" />

The ROC curve shows an AUC of 0.78, indicating the model performs well in correctly classifying dual-burden renters. The weighted ROC curve, accounting for population weights (PERWT), shows a slightly lower but still strong AUC of 0.77, suggesting the model's performance remains consistent when generalized to the broader LA renter population.


#### GROUP TWO


<img width="410" alt="glm(g2)" src="https://github.com/user-attachments/assets/c17211c9-4dd7-4cd8-894d-f28d7a4663eb" />

To analyze the socioeconomic conditions under which family-based renters are likely to fall into the dual-burden (30/30) threshold, a logistic regression was fitted with baselines of upper-income, family household, private auto, and Non-Hispanic White. The model also includes three additional continuous household-level variables not present in group one: number of dependent children, family size, and number of family workers (earners). All variables are highly statistically significant (p < 0.001), with the exception of nh_other (p = 0.064), which does not reach statistical significance at the 0.05 level.


**Income Tier**: 
Income tier remains the strongest predictor in group two as well. Compared to upper-income households, middle-income households are 29.2 times more likely to fall into dual-burden status, while low-income households are 136 times more likely. This is a much stronger effect than group one, reflecting the compounding financial pressure of supporting a family on a low income.


**Household Structure**: 
Unlike group one where sharing space reduced dual-burden risk, mixed households in group two are 1.64 times more likely than family households to fall into dual-burden status. This statistically confirms the EDA finding that adding a roommate does not necessarily relieve financial strain for family-based households.


**Transit Mode**: 
The transit mode pattern is identical to group one: public transit renters are 2.57 times more likely to fall into dual-burden status compared to private auto, while active transit renters are 77% less likely (OR = 0.23), consistent across both groups.


**Age and Weekly Hours**: 
Both age and weekly hours show OR = 1.00, meaning they have essentially no practical effect on dual-burden status in family households, even though they are statistically significant.


**Race / Ethnicity**: 
Similar to group one, most racial and ethnic groups show lower odds than Non-Hispanic White renters, except nh_native (OR = 1.51, 51% more likely) and nh_other (OR = 1.03, not statistically significant at p = 0.064).


**Household-Level Variables (new in group two)**: 
Each additional dependent child increases the odds of dual-burden status by 8% (OR = 1.08), and each additional family member increases it by 2% (OR = 1.02). On the other hand, each additional family worker reduces the odds by 29% (OR = 0.71), confirming that more earners in the household significantly lowers the risk of falling into dual-burden status.


<img width="600" alt="model_performance(g2)" src="https://github.com/user-attachments/assets/42e46c79-b454-44de-94c9-f05a578d18ac" />


The classification threshold was set at 10%, matching the actual prevalence of dual-burden family households (10.2%) in the data, rather than using the default 50% threshold. The model correctly identifies about 7 out of 10 family households actually in dual-burden status (sensitivity: 74.5%), with an overall accuracy of 72.4% and a balanced accuracy of 73.4%. Overall, the group two model performs slightly better than group one, likely reflecting the additional household-level variables capturing more of the financial complexity in family households.



<img width="500" alt="family_glm_roc_curve-1" src="https://github.com/user-attachments/assets/9da64081-54af-4253-9687-dce9f5ca9674" />

<img width="500" alt="family_glm_weighted_roc_curve-1" src="https://github.com/user-attachments/assets/32cd6727-975c-4c78-953d-34be47489c5e" />

The ROC curve shows an AUC of 0.80, indicating the model performs well in correctly classifying dual-burden family households. The weighted ROC curve, accounting for population weights (PERWT), shows a very similar AUC of 0.79, suggesting the model's performance remains consistent when generalized to the broader LA family renter population. Overall, the group two model performs slightly better than group one (0.80 vs. 0.78), likely reflecting the added predictive power of the household-level variables.



## Conclusion

Overall, this project confirms that the classic trade-off between housing affordability and commute time flips in Los Angeles County, as stable working renters largely accept the traffic and manage it within a reasonable time frame. Instead, income and household structure are the key factors shaping where renters can afford to live and how much of their income goes toward housing. This is largely due to Los Angeles County being car-dependent with limited availability of a reliable alternative public transit system. This trade-off may tell a completely different story in cities like Boston or New York, which have better public transit systems with higher ridership and are also more pedestrian and bike-friendly, where varied commute options and patterns may show a stronger and more classic association between rent burden and commute time.

As this trade-off flips in Los Angeles County, it is also interesting to note that certain low-income and older renter households show an unexpectedly low rent burden, likely benefiting from housing subsidy programs such as Section 8 or long-term tenureship. However, these benefits come with extremely restricted qualifications, also impacted by Area Median Income (AMI) thresholds and rental market rates. With gentrification and rising rents, low-income households may still face significant rent burden even with subsidies, as renters are still required to pay the difference between the subsidy and the actual rent, particularly those with specific socioeconomic conditions that are likely to fall into the dual-burden (30/30) threshold, as discussed earlier. Meanwhile, this project only focuses on stable working renters, while a large population, particularly undocumented immigrants, works below the minimum income threshold and is likely to experience this trade-off at its worst.

Having lived in Los Angeles for a decade, I have truly witnessed the ongoing rent increases over the years. For renters who wish to maintain a reasonable commute, rent burden becomes an inevitable consequence. While Los Angeles has been improving its public transit system, its polycentric urban structure, with job centers spread across the county rather than concentrated in one hub, makes it unrealistic to fully replace car dependency with public transit alone. Therefore, rent control and housing subsidy programs remain critical tools for easing the financial pressure on low-income renters in Los Angeles County.







