Part 1: initial cleaning

# checking the composition of household structure 
mh_mx <- mh_mx %>%
group_by(YEAR, SERIAL) %>%
mutate(
  has_head = sum(RELATED == 101), 
  has_roommate = sum(RELATED %in% c(1115, 1260)),
  has_relatives = sum(RELATED %in% c(201, 301, 302, 303, 401, 501, 601, 701, 801, 901, 1001, 1114, 1242))) %>%
     ungroup()

mh_mx <- mh_mx %>% 
  mutate(
    check = (has_head == 1 & has_roommate >= 1 & has_relatives>=1)
  )

table(mh_mx$check)

# creating a varaible to calculate the family member's pooled income in mixed households
## checking the summary of INCTOT & removing the no value code
summary(mh_mx$INCTOT)
mh_mx <- mh_mx %>%
  mutate(
         INCTOT = ifelse(INCTOT %in% c(9999998, 9999999), 0, INCTOT)
     )

### reculating and creating FTOTINC variable 
mh_mx <- mh_mx %>%
  group_by(YEAR, SERIAL) %>%
  mutate(
    FTOTINC_clean = sum(INCTOT[RELATED %in% c(101, 201, 301, 302, 303, 401, 501, 601, 701, 801, 901, 1001, 1114, 1242)], na.rm = TRUE)
  ) %>%
  ungroup()

#### dropping the FTOTINC less than zero and trimming the FTOTINC with 1.5% from top and bottom tier and only retaining 97% of sampling by MULTYEAR

mh_mx <- mh_mx %>%
  filter(FTOTINC_clean > 0) %>%
  group_by(MULTYEAR) %>%
  filter(
    FTOTINC_clean >= quantile(FTOTINC_clean, 0.015, na.rm = TRUE) &
    FTOTINC_clean <= quantile(FTOTINC_clean, 0.985, na.rm = TRUE)
  ) %>%
  ungroup()

summary(mh_mx$FTOTINC_clean)

# applying the target sample criteria
mh_mx <- mh_mx %>%
filter(OWNERSHP == 2 & OWNERSHPD == 22) %>%
filter(EMPSTAT == 1 & EMPSTATD %in% c(10, 14)) %>%
filter(AGE >= 24, AGE < 65) %>%
filter(between(UNITSSTR,3,10)) %>%
filter(between(UHRSWORK, 20,80)) 


# creating a new variable to label the type of work
mh_mx <- mh_mx %>%
 mutate(
 type_hrwrk = case_when(
 between(UHRSWORK,20,34) ~ "part_time",
 between(UHRSWORK, 35, 40) ~ "full_time",
 UHRSWORK > 40 ~ "over_time")
 )


# checking the TRANWORK and does all the trantime less than zero are wfh
mh_mx %>%
     filter(TRANTIME == 0) %>%
     group_by(TRANWORK) %>%
     count()

##  creating a varible to label wfh_status(TRUE/FALSE)
mh_mx <- mh_mx %>%
     mutate(
         wfh = if_else(TRANWORK == 80, "TRUE", "FALSE")
     )

table(mh_mx$type_hrwrk,mh_mx$wfh)

# removing the unneeded variables
mh_mx <- mh_mx %>%
 select(-SAMPLE, -STATEFIP, -COUNTYFIP, -OWNERSHP, -OWNERSHPD, -EMPSTAT, -EMPSTATD)

# saving the initial cleaned dataset 
saveRDS(mh_mx, "data/mh_mx_initial_clean.rds")

Part 2: income and rent burden

# setting the minimum wage threadhold and filtering out below the minimum wage
mh_mx <- mh_mx %>%
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
     mutate(below_minwage = INCTOT < min_wage_threshold) 


# dropping the unqualified roommate wokers 
 mh_mx <- mh_mx %>%
     filter(!(RELATED %in% c(1115, 1260) & INCTOT < min_wage_threshold))


# creating a new varible for rent_burnden and retaining the rent_burden less than 100%
mh_mx <- mh_mx %>%
  mutate(family_size = has_head + has_relatives) %>%
  mutate(
    rent_burden = case_when(
      RELATED %in% c(1115, 1260) ~ 
        round(((RENT * 12) / n_hh) / INCTOT * 100, 2),
      TRUE ~ 
        round(((RENT * 12) * (family_size / n_hh)) / FTOTINC_clean * 100, 2)
    )
  ) %>%
  filter(rent_burden <= 100)


# creating a new varibale for the range of rent_burden 
mh_mx  <- mh_mx  %>%
  mutate(
    range_burden = case_when(
      rent_burden <= 30.00 ~ "affordable",
      rent_burden <= 50.00 ~ "burdened",
      rent_burden <= 70.00 ~ "severely_burdened",
      TRUE                 ~ "extreme"  # This catches everything else (> 70.00)
    )
  )

# creating one variable to a labled roommate/family and one variaible to add n_worker
mh_mx <- mh_mx %>%
  mutate(
    lv_status = case_when(
      RELATED %in% c(1115, 1260) ~ "RM", 
      TRUE                       ~ "FM" 
    )
  ) %>%
  group_by(YEAR, SERIAL) %>%
  mutate(n_workers = n()) %>%
  ungroup()

# creating two variable to check the number of family and roommate workers
## family_workers + roommate_workers should equal n_workers
mh_mx <- mh_mx %>%
  group_by(YEAR, SERIAL) %>%
  mutate(
    family_workers = sum(!RELATED %in% c(1115, 1260)),
    roommate_workers = sum(RELATED %in% c(1115, 1260))
  ) %>%
  ungroup()

## verification 
mh_mx %>%
  mutate(check = family_workers + roommate_workers == n_workers) %>%
  summarise(all_match = all(check))

### checking the burden by household structure 
mh_mx %>%
           filter(lv_status == "FM" & has_dependent_children == "TRUE") %>%
               distinct(YEAR, SERIAL, family_size, family_workers,range_burden) %>% 
               group_by(family_size,family_workers) %>%
               count(range_burden) %>%
               mutate(pct = n/sum(n)*100) %>%
 print(n = Inf, width = Inf)

# creating a variable "income_tier" to segmentate three tire 30(low_income) - 50(middle_income) - 20(upper_income) by ACS 5-year
mh_mx <- mh_mx %>%
  group_by(YEAR) %>%
  mutate(
    p30_rm = quantile(INCTOT[RELATED %in% c(1115, 1260)], 0.30, na.rm = TRUE),
    p80_rm = quantile(INCTOT[RELATED %in% c(1115, 1260)], 0.80, na.rm = TRUE), 
    p30_fam = quantile(FTOTINC_clean[!RELATED %in% c(1115, 1260)], 0.30, na.rm = TRUE),
    p80_fam = quantile(FTOTINC_clean[!RELATED %in% c(1115, 1260)], 0.80, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  mutate(
    income_tier = case_when(
      RELATED %in% c(1115, 1260) & INCTOT <= p30_rm ~ "low_income",
      RELATED %in% c(1115, 1260) & INCTOT <= p80_rm ~ "middle_income",
      RELATED %in% c(1115, 1260)                     ~ "upper_income",
      FTOTINC_clean <= p30_fam ~ "low_income",
      FTOTINC_clean <= p80_fam ~ "middle_income",
      TRUE                     ~ "upper_income"
    )
  )

## verifying
mh_mx %>%
  group_by(lv_status, income_tier) %>%
  summarise(n = n()) %>%
  group_by(lv_status) %>%
  mutate(pct = n/sum(n)*100) %>%
  arrange(lv_status, income_tier)


# saving the cleaned dataset 
saveRDS(mh_mx, "data/mh_mx_final_cleaned.rds")


Part 3: relabling the character
# UNITSSTR
mh_mx <- mh_mx %>%
  mutate(
    UNITSSTR = case_when(
      UNITSSTR == 3  ~ "1_fh_detached",
      UNITSSTR == 4  ~ "1_fh_attached",
      UNITSSTR == 5  ~ "2_fb",
      UNITSSTR == 6  ~ "3-4_fb",
      UNITSSTR == 7  ~ "5-9_fb",
      UNITSSTR == 8  ~ "10-19_fb",
      UNITSSTR == 9  ~ "20-49_fb",
      UNITSSTR == 10 ~ "50_plus_fb"
    ),
      UNITSSTR = factor(UNITSSTR, levels = c(
      "1_fh_detached", "1_fh_attached", "2_fb", "3-4_fb", 
      "5-9_fb", "10-19_fb", "20-49_fb", "50_plus_fb"
    ))
  )

#BEDROOMS
mh_mx <- mh_mx %>%
  mutate(
    BEDROOMS = case_when(
      BEDROOMS == 1 ~ "no_bedrooms" ,
      BEDROOMS == 2 ~ "1_bedrooms",
      BEDROOMS == 3 ~ "2_bedrooms",
      BEDROOMS == 4 ~ "3_bedrooms",
      BEDROOMS == 5 ~ "4_bedrooms",
      BEDROOMS == 6 ~ "5_bedrooms",
      BEDROOMS == 8 ~ "7_bedrooms"
    ),
      BEDROOMS = factor(BEDROOMS, levels = c(
      "no_bedrooms", "1_bedrooms", "2_bedrooms", "3_bedrooms", 
      "4_bedrooms", "5_bedrooms", "7_bedrooms"
    ))
  )

#VEHICLES
mh_mx <- mh_mx %>%
  mutate(VEHICLES = case_when(
    VEHICLES == 9 ~ "no_available", 
    TRUE ~ as.character(VEHICLES)   
  ))

#RELATED
mh_mx <- mh_mx %>%
  mutate(
    RELATED = case_when(
      RELATED == 101 ~ "head",
      RELATED == 201 ~ "spouse",
      RELATED == 301 ~ "child",
      RELATED == 303 ~ "stepchild",
      RELATED == 401 ~ "child_in_law",
      RELATED == 501 ~ "parent",
      RELATED == 601 ~ "parent_in_law",
      RELATED == 701 ~ "sibling",
      RELATED == 801 ~ "sibling_in_law",
      RELATED == 1001 ~ "other_relatives",
      RELATED == 1114 ~ "unmarried_partner",
      RELATED == 1115 ~ "housemate",
      RELATED == 1260 ~ "other_non_relatives"
    ),
    RELATED = factor(RELATED, levels = c(
      "head", "spouse", "child", "stepchild", "child_in_law", "parent", 
      "parent_in_law", "sibling", "sibling_in_law", "other_relatives", 
      "unmarried_partner", "housemate", "other_non_relatives"
    ))
  )

#SEX
mh_mx <- mh_mx %>%
mutate(SEX = case_when(
  SEX == 1 ~ "male",
  SEX == 2 ~ "female"),
SEX = factor(SEX, levels = c("male", "female"))
)

#RACE
mh_mx <- mh_mx %>%
  mutate(
    RACE = case_when(
      RACE == 1 ~ "white", 
      RACE == 2 ~ "black_african_american",
      RACE == 3 ~ "american_indian_alaska_native",
      RACE == 4 ~ "chinese",
      RACE == 5 ~ "japanese",
      RACE == 6 ~ "other_asian_pacific_islander",
      RACE == 7 ~ "other_race",
      RACE == 8 ~ "two_major_races",
      RACE == 9 ~ "three_plus_major_races"
    ),
    
    RACE = factor(RACE, levels = c(
      "white", "black_african_american", "american_indian_alaska_native",
      "chinese", "japanese", "other_asian_pacific_islander", 
      "other_race", "two_major_races", "three_plus_major_races"
    ))
  )

#HISPAN
mh_mx <- mh_mx %>%
  mutate(
    HISPAN = case_when(
      HISPAN == 0 ~ "not_hispanic",
      HISPAN == 1 ~ "mexican",
      HISPAN == 2 ~ "puerto_rican",
      HISPAN == 3 ~ "cuban",
      HISPAN == 4 ~ "other_hispanic"
    ),
    HISPAN = factor(HISPAN, levels = c(
      "not_hispanic", "mexican", "puerto_rican", "cuban", "other_hispanic"
    ))
  )

#EDUCD
mh_mx <- mh_mx %>%
  mutate(
    EDUCD = case_when(
      EDUCD %in% c(2, 12, 14, 15, 16, 17, 22, 23, 25, 26, 30, 40, 50, 61) ~ "less_than_hs",
      EDUCD %in% c(63, 64) ~ "hs_or_ged",
      EDUCD %in% c(65, 71, 81) ~ "some_college_associate",
      EDUCD == 101 ~ "bachelors",
      EDUCD %in% c(114, 115, 116) ~ "advanced_degree"
    ),
    EDUCD = factor(EDUCD, levels = c(
     "less_than_hs", "hs_or_ged", "some_college_associate", "bachelors", "advanced_degree"
    ))
  )

#TRANWORK
mh_mx <- mh_mx %>%
  mutate(
    TRANWORK = case_when(
      TRANWORK == 10 ~ "auto_truck_van",
      TRANWORK == 20 ~ "motorcycle",
      TRANWORK == 31 ~ "bus",
      TRANWORK == 34 ~ "light_rail_streetcar",
      TRANWORK == 36 ~ "subway_elevated",
      TRANWORK == 37 ~ "commuter_train",
      TRANWORK == 38 ~ "taxi_ride_hail",
      TRANWORK == 39 ~ "ferryboat",
      TRANWORK == 50 ~ "bicycle",
      TRANWORK == 60 ~ "walked",
      TRANWORK == 70 ~ "other",
      TRANWORK == 80 ~ "wfh"
    ),
      TRANWORK= factor(TRANWORK, levels = c(
      "auto_truck_van", "motorcycle", "bus", "light_rail_streetcar", 
      "subway_elevated", "commuter_train", "taxi_ride_hail", "ferryboat", 
      "bicycle", "walked", "other", "wfh"
    ))
  )

# creating a new variable to label the trans_mode into four groups
mh_mx <- mh_mx %>% 
mutate(
    transit_group = case_when(
       transit_mode %in% c("auto_truck_van", "motorcycle") ~ "private_auto",
       transit_mode %in% c("bus", "subway_elevated", "commuter_train", "light_rail_streetcar", "ferryboat") ~ "public_transit",
       transit_mode %in% c("walked", "bicycle") ~ "active_transit",
       transit_mode == "wfh" ~ "wfh",
       transit_mode %in% c("taxi_ride_hail", "other") ~ "other_transit"
    )
  )


#CARPOOL
mh_mx <- mh_mx %>%
  mutate(
    CARPOOL = case_when(
      CARPOOL == 0 ~ "not_applicable",
      CARPOOL == 1 ~ "drives_alone",
      CARPOOL == 2 ~ "carpools"
    ),
    CARPOOL = factor(CARPOOL, levels = c(
     "not_applicable", "drives_alone", "carpools"
    ))
  )

# double checking structure of household 
mh_mx <- mh_mx %>%
      group_by(year, serial) %>%
          mutate(
         surving_head = sum(relationship == "head")) %>% 
      ungroup()

table(mh_mx$surving_head)

table(mh_mx$surving_head, mh_mx$surviving_roommates)

# removing the no stable working head household 
mh_mx <- mh_mx %>%
filter(!surving_head == 0)

# veryfing if every household has one stable working head PLUS one stable working roommate
mh_mx <- mh_mx %>% 
 group_by(year, serial) %>%
  mutate(
    check = (surving_head == 1 & surviving_roommates >= 1)
  )

table(mh_mx$check)

table(mh_mx$surving_head, mh_mx$surviving_roommates)

# removing the no stable working head household 
mh_mx <- mh_mx %>%
filter(!surving_head == 0)

# veryfing if every household has one stable working head PLUS one stable working roommate
mh_mx <- mh_mx %>% 
 group_by(year, serial) %>%
  mutate(
    check = (surving_head == 1 & surviving_roommates >= 1)
  )

table(mh_mx$check)

table(mh_mx$surving_head, mh_mx$surviving_roommates)


# re-calculating family_worker and roommate_worker
mh_mx <- mh_mx %>%
     group_by(year, serial) %>%
     mutate(
         family_workers = sum(!relationship %in% c("housemate", "other_non_relatives")),
         roommate_workers = sum(relationship %in% c("housemate", "other_non_relatives"))
     ) %>%
     ungroup()


# creating a variable to mark if the househld with "single_earner" or "multiple_earners"
mh_mx <- mh_mx %>%
  mutate(
    worker_type = case_when(
      lv_status == "FM" & family_workers == 1 ~ "single_earner",
      lv_status == "FM" & family_workers > 1  ~ "multiple_earners",
      lv_status == "RM"                       ~ "roommate"
    )
  )

## veryfing
table(mh_mx$worker_type)

# creating new variable to label of group of household   
mh_mx <- mh_mx %>% 
mutate(hh_group = "mixed")

# saving the dataset
saveRDS(mh_mx, "data/mh_mx_eda_ready_final.rds")

