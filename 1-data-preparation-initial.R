Part 1: Initial Cleaning 
# loading the dataset

# filtering the dataset for LA county
la_acs <- data %>%
filter(COUNTYFIP == 37)

# grouping the data according to the household structure 
la_acs <- la_acs %>%
group_by(YEAR, SERIAL) %>%
  mutate(
    n_hh = n(),
    hh_type = if_else(n_hh == 1, "single_hh", "multi_hh"),
    person_id = paste(YEAR, SERIAL, PERNUM, sep = "_")
  ) %>%
  ungroup() 

## verifying single_hh all have n_hh == 1
la_acs %>%
     filter(hh_type == "single_hh") %>%
     summarise(
         min_nhh = min(n_hh),
         max_nhh = max(n_hh)
     )


## verifying multi_hh all have n_hh >= 2
la_acs %>%
     filter(hh_type == "multi_hh") %>%
     summarise(
         min_nhh = min(n_hh),
         max_nhh = max(n_hh)
     )


# creating two datasets 
sh <- la_acs %>%
  filter(hh_type == "single_hh")

mh <- la_acs %>%
  filter(hh_type == "multi_hh")


# saving the datasets
saveRDS(sh, "data/sh_raw.rds")
saveRDS(mh, "data/mh_raw.rds")

Part 2: Initial Cleaning for multi-household

# creating a new variable to calculating sum of INCTOT for ONLY family-type members
mh_raw <- mh_raw %>%
  group_by(YEAR, SERIAL) %>%
  mutate(
    custom_FTOTINC = sum(INCTOT[RELATED %in% c(101, 201, 301, 302, 303, 401, 501, 601, 701, 801, 901, 1001, 1114, 1242)], na.rm = TRUE)
  ) %>%
  ungroup()

# creating a new variable to flag family with children and count the number if it is true
mh_raw <- mh_raw %>%
  group_by(YEAR, SERIAL) %>%
  mutate(
    # TRUE if the house has ANY minor child, stepchild, grandchild, or foster child
    has_dependent_children = any(RELATED %in% c(301, 302, 303, 401, 901, 1242) & AGE < 18),
    
    # Optional: Count EXACTLY how many kids there are to measure financial burden
    num_dependent_children = sum(RELATED %in% c(301, 302, 303, 401, 901, 1242) & AGE < 18)
  ) %>%
  ungroup()


# creating a new variable to flag couple family 
mh_raw <- mh_raw %>%
  group_by(YEAR, SERIAL) %>%
  mutate(
    # Flag if the household contains a spouse or unmarried partner
    has_partner = any(RELATED %in% c(201, 1114))
  ) %>%
  ungroup()

# checking the pct of household size  
mh %>%
     group_by(YEAR) %>%
     count(n_hh) %>%
     mutate(pct = n/sum(n)*100) %>%
     print(n = Inf, width = Inf)

## filtering to household sieze (2-5) and verifying 
mh_raw <- mh_raw %>%
 filter(between(n_hh,2,5))

table(mh_raw$n_hh)

mh_raw %>%
     group_by(YEAR) %>%
     count(n_hh) %>%
     mutate(pct = n/sum(n)*100)

# checking the distribution of RELATED   
table(mh_raw$RELATED)

# spliting the dataset into three household group: fm/rm/mx
# Define categories with the th
family_codes <- c(201, 301, 302, 303, 401, 501, 601, 701, 801, 901, 1001, 1114, 1242)
roommate_codes <- c(1115, 1260)

## 1. fm-only dataset (Has Family, NO Roommates)
fm_serial <- mh_raw %>%
  group_by(YEAR, SERIAL) %>%
  filter(
    any(RELATED == 101) & 
    any(RELATED %in% family_codes) & 
    !any(RELATED %in% roommate_codes) # Strictly FORBID roommates
  ) %>%
  distinct(YEAR, SERIAL) %>%
  ungroup()

mh_fm <- mh_raw %>% inner_join(fm_serial, by = c("YEAR", "SERIAL"))


## 2. roommate-only dataset (Has Roommates, NO Family)
rm_serial <- mh_raw %>%
  group_by(YEAR, SERIAL) %>%
  filter(
    any(RELATED == 101) & 
    any(RELATED %in% roommate_codes) & 
    !any(RELATED %in% family_codes) # Strictly FORBID family members
  ) %>%
  distinct(YEAR, SERIAL) %>%
  ungroup()

mh_rm <- mh_raw %>% inner_join(rm_serial, by = c("YEAR", "SERIAL"))


## 3. mixed dataset (Has BOTH Family AND Roommates)
mx_serial <- mh_raw %>%
  group_by(YEAR, SERIAL) %>%
  filter(
    any(RELATED == 101) & 
    any(RELATED %in% family_codes) & 
    any(RELATED %in% roommate_codes) # Explicitly REQUIRE both
  ) %>%
  distinct(YEAR, SERIAL) %>%
  ungroup()

mh_mx <- mh_raw %>% inner_join(mx_serial, by = c("YEAR", "SERIAL"))


### verification
total_hh <- n_distinct(mh_raw %>% select(YEAR, SERIAL))
(nrow(fm_serial) + nrow(rm_serial) + nrow(sh_serial) + nrow(mx_serial)) == total_hh 

#### saving the vector and dataset 
saveRDS(fm_serial, "data/fm_serial.rds")
saveRDS(rm_serial, "data/rm_serial.rds")
saveRDS(mx_serial, "data/mx_serial.rds")
saveRDS(mh_fm, "data/mh_fm_raw.rds")
saveRDS(mh_rm, "data/mh_rm_raw.rds")
saveRDS(mh_mx, "data/mh_mx_raw.rds")


saveRDS(mh_raw, "data/mh_cleaned.rds")


Part 3 : cleaning for single household
# filtering the target sampling characters and verifing the filtering
sh <- sh %>%
filter(OWNERSHP == 2 & OWNERSHPD == 22) %>%
filter(EMPSTAT == 1 & EMPSTATD %in% c(10, 14)) %>%
filter(AGE >= 24, AGE < 65) %>%
filter(between(UNITSSTR,3,10)) %>%
filter(between(UHRSWORK, 20,80)) 

table(sh$OWNERSHP,sh$OWNERSHPD)
table(sh$EMPSTAT,sh$EMPSTATD)
range(sh$AGE)
table(sh$UNITSSTR)
range(sh$UHRSWORK)

# creating a new variable to label the type of work and verifying
sh <- sh %>%
 mutate(
 type_hrwrk = case_when(
 between(UHRSWORK,20,34) ~ "part_time",
 between(UHRSWORK, 35, 40) ~ "full_time",
 UHRSWORK > 40 ~ "over_time")
 )

# checking the TRANWORK and verify all the trantime less than zero are wfh
table(sh$TRANWORK)
range(sh$TRANTIME)

sh %>%
     filter(TRANTIME == 0) %>%
     group_by(TRANWORK) %>%
     count()

##  creating a varible to label wfh_status(TRUE/FALSE)
sh <- sh %>%
     mutate(
         wfh = if_else(TRANWORK == 80, "TRUE", "FALSE")
     )

table(sh$wfh)
table(sh$type_hrwrk,sh$wfh)


# seting the minimum wage threadhold and filtering out below the minimum wage
sh <- sh %>%
  mutate(min_wage_threshold = case_when(
    # 2015
    MULTYEAR == 2015 & type_hrwrk == "part_time" ~ 9360,
    MULTYEAR == 2015 & type_hrwrk %in% c("full_time", "over_time") ~ 16380,
    # 2016
    MULTYEAR == 2016 & type_hrwrk == "part_time" ~ 10400,
    MULTYEAR == 2016 & type_hrwrk %in% c("full_time", "over_time") ~ 18200,
    # 2017
    MULTYEAR == 2017 & type_hrwrk == "part_time" ~ 10400,
    MULTYEAR == 2017 & type_hrwrk %in% c("full_time", "over_time") ~ 18200,
    # 2018
    MULTYEAR == 2018 & type_hrwrk == "part_time" ~ 11440,
    MULTYEAR == 2018 & type_hrwrk %in% c("full_time", "over_time") ~ 20020,
    # 2019
    MULTYEAR == 2019 & type_hrwrk == "part_time" ~ 12480,
    MULTYEAR == 2019 & type_hrwrk %in% c("full_time", "over_time") ~ 21840,
    # 2020
    MULTYEAR == 2020 & type_hrwrk == "part_time" ~ 12480,
    MULTYEAR == 2020 & type_hrwrk %in% c("full_time", "over_time") ~ 21840,
    # 2021
    MULTYEAR == 2021 & type_hrwrk == "part_time" ~ 13520,
    MULTYEAR == 2021 & type_hrwrk %in% c("full_time", "over_time") ~ 23660,
    # 2022
    MULTYEAR == 2022 & type_hrwrk == "part_time" ~ 14560,
    MULTYEAR == 2022 & type_hrwrk %in% c("full_time", "over_time") ~ 25480,
    # 2023
    MULTYEAR == 2023 & type_hrwrk == "part_time" ~ 16120,
    MULTYEAR == 2023 & type_hrwrk %in% c("full_time", "over_time") ~ 28210,
    # 2024
    MULTYEAR == 2024 & type_hrwrk == "part_time" ~ 16640,
    MULTYEAR == 2024 & type_hrwrk %in% c("full_time", "over_time") ~ 29120
  )) %>%
  mutate(below_minwage = HHINCOME < min_wage_threshold) %>%
  filter(!below_minwage)

# checking the summary of HHINCOME
summary(sh$HHINCOME)


# checking summary of RENT by each year 
sh %>%
 group_by(MULTYEAR) %>%
 summarise(
 across(
 RENT,list(mean = mean, max = max, min = min, median = median),
 na.rm = TRUE)
 )

# removing the 1% top and bottom tier of RENT as no specific benchmark 
sh <- sh %>%
  group_by(MULTYEAR) %>%
  filter(
    RENT >= quantile(RENT, 0.015) &
    RENT <= quantile(RENT, 0.985)
  ) %>%
  ungroup()

# checking the summary of rent each year after trimmed
sh %>%
 group_by(MULTYEAR) %>%
 summarise(
 across(
 RENT,list(mean = mean, max = max, min = min, median = median),
 na.rm = TRUE)
 )

# creating a new varible for rent_burnden and retaining the rent_burden euqal or less than 100%
sh <- sh %>%
  mutate(rent_burden = round((RENT * 12) / HHINCOME * 100, 2)) %>%
  filter(rent_burden <= 100)


# creating a new varibale for the range of rent_burden 
sh <- sh %>%
  mutate(
    range_burden = case_when(
      rent_burden <= 30.00 ~ "affordable",
      rent_burden <= 50.00 ~ "burdened",
      rent_burden <= 70.00 ~ "severely_burdened",
      TRUE                 ~ "extreme"  
    )
  )

# verifying
summary(sh$rent_burden)
sh %>%
      count(range_burden) %>%
      mutate(pct = n/sum(n)*100)

# creating a variable "income_tier" to segmentate three tire 30(low_income) - 50(middle_income) - 20(upper_income)
sh <- sh %>%
  group_by(YEAR) %>%
  mutate(income_tier = case_when(
    HHINCOME <= quantile(HHINCOME, 0.30) ~ "low_income",
    HHINCOME <= quantile(HHINCOME, 0.80) ~ "middle_income",
    TRUE ~ "upper_income"
  )) %>%
  ungroup()

#verifying
sh %>%
     group_by(income_tier) %>%
     summarise(
         n = n(),
         pct = n()/nrow(sh)*100,
         min_HHINCOME = min(HHINCOME),
         max_HHINCOME = max(HHINCOME),
         median_HHINCOME = median(HHINCOME)
     ) %>%
     arrange(income_tier)
