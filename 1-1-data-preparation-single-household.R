Part 1 : initial cleaning 

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

# removing unnesseary variables
sh <- sh %>%
 select(-SAMPLE, -STATEFIP, -COUNTYFIP, -OWNERSHP, -OWNERSHPD, -EMPSTAT, -EMPSTATD)

drop_sh <- c("n_hh", "hh_type", "CPI99", "income_check", "income_check2","min_wage_threshold","below_minwage" )

sh <- sh %>%
select(-all_of(drop_sh))

saveRDS(sh, "data/sh_final_cleaned.rds")

Part 2 : 
