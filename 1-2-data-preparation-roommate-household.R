Part 1 : initial cleaning 
# double checking composition of roommate structure
mh_rm <- mh_rm %>%
group_by(YEAR, SERIAL) %>%
mutate(
  has_head = sum(RELATED == 101), 
  has_roommate = sum(RELATED %in% c(1115, 1260)),
  has_relatives = sum(RELATED %in% c(201, 301, 302, 303, 401, 501, 601, 701, 801, 901, 1001, 1114, 1242))) %>%
     ungroup()

table(mh_rm$has_relatives)

table(mh_rm$has_head,mh_rm$has_roommate)

# filtering the target sampling characters and verifing the filtering
mh_rm <- mh_rm %>%
filter(OWNERSHP == 2 & OWNERSHPD == 22) %>%
filter(EMPSTAT == 1 & EMPSTATD %in% c(10, 14)) %>%
filter(AGE >= 24, AGE < 65) %>%
filter(between(UNITSSTR,3,10)) %>%
filter(between(UHRSWORK, 20,80)) 

# creating a new variable to label the type of work
mh_rm <- mh_rm %>%
 mutate(
 type_hrwrk = case_when(
 between(UHRSWORK,20,34) ~ "part_time",
 between(UHRSWORK, 35, 40) ~ "full_time",
 UHRSWORK > 40 ~ "over_time")
 )

# checking the TRANWORK and if all the trantime less than zero are wfh
table(mh_rm$TRANWORK)
range(mh_rm$TRANTIME)
mh_rm %>%
     filter(TRANTIME == 0) %>%
     group_by(TRANWORK) %>%
     count()

##  creating a varible to label wfh_status(TRUE/FALSE)
mh_rm <- mh_rm %>%
     mutate(
         wfh = if_else(TRANWORK == 80, "TRUE", "FALSE")
     )

##verifying
table(mh_rm$wfh)
table(mh_rm$type_hrwrk,mh_rm$wfh)

# removing unneeded variables
mh_rm <- mh_rm %>%
 select(-SAMPLE, -STATEFIP, -COUNTYFIP, -OWNERSHP, -OWNERSHPD, -EMPSTAT, -EMPSTATD)

saveRDS(mh_rm, "data/mh_rm_initial_clean.rds")

Part 2 : income & rent burden

# seting the minimum wage threadhold and filtering out below the minimum wage
mh_rm <- mh_rm %>%
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
  mutate(below_minwage = INCTOT < min_wage_threshold) %>%
  filter(!below_minwage)

# creating a variable to calculate the true number of qualified worker in each household
mh_rm <- mh_rm %>%
  group_by(YEAR, SERIAL) %>%
  mutate(n_workers = n()) %>%
  ungroup()

# checking summary of RENT by each year 
mh_rm %>%
 group_by(MULTYEAR) %>%
 summarise(
 across(
 RENT,list(mean = mean, max = max, min = min, median = median),
 na.rm = TRUE)
 )

# removing the 1.5% top and bottom tier of RENT  and retaining 97% of sampling
mh_rm <- mh_rm %>%
  group_by(MULTYEAR) %>%
  filter(
    RENT >= quantile(RENT, 0.015) &
    RENT <= quantile(RENT, 0.985)
  ) %>%
  ungroup()

# double checking the composition of hh structure and dropping the one wihout head 
mh_rm <- mh_rm %>%
     group_by(YEAR, SERIAL) %>%
     mutate(after_has_head = sum(RELATED == 101)) %>%
     ungroup()

# removing the household without the head
mh_rm <- mh_rm %>%
filter(after_has_head == 1)

# creating a new varible for rent_burnden and retaining the rent_burden less than 100%
mh_rm <- mh_rm %>%
     mutate(rent_burden = round(((RENT * 12)/n_hh) / INCTOT * 100, 2)) %>%
     filter(rent_burden <= 100)

# creating a new varibale for the range of rent_burden 
mh_rm  <- mh_rm  %>%
  mutate(
    range_burden = case_when(
      rent_burden <= 30.00 ~ "affordable",
      rent_burden <= 50.00 ~ "burdened",
      rent_burden <= 70.00 ~ "severely_burdened",
      TRUE                 ~ "extreme"  
    )
  )

# creating a variable "income_tier" to segmentate three tire 30(low_income) - 50(middle_income) - 20(upper_income)
mh_rm <- mh_rm %>%
  group_by(YEAR) %>%
  mutate(income_tier = case_when(
    INCTOT <= quantile(INCTOT, 0.30) ~ "low_income",
    INCTOT <= quantile(INCTOT, 0.80) ~ "middle_income",
    TRUE ~ "upper_income"
  )) %>%
  ungroup()

saveRDS(mh_rm, "data/mh_rm_final_cleaned.rds")


# part 3 relabeling character

# UNITSSTR
mh_rm <- mh_rm %>%
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
mh_rm <- mh_rm %>%
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
mh_rm <- mh_rm %>%
  mutate(VEHICLES = case_when(
    VEHICLES == 9 ~ "no_available", 
    TRUE ~ as.character(VEHICLES)   
  ))

#RELATED
mh_rm <- mh_rm %>%
mutate(RELATED = case_when(
  RELATED == 101 ~ "head",
  RELATED == 1115 ~ "housemate",
  RELATED == 1260 ~ "other_non_relatives"
),
RELATED = factor(RELATED, level = c("head","housemate", "other_non_relatives"))
)

#SEX
mh_rm <- mh_rm %>%
mutate(SEX = case_when(
  SEX == 1 ~ "male",
  SEX == 2 ~ "female"),
SEX = factor(SEX, levels = c("male", "female"))
)

#RACE
mh_rm <- mh_rm %>%
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
mh_rm <- mh_rm %>%
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
mh_rm <- mh_rm %>%
  mutate(
    EDUCD = case_when(
      EDUCD %in% c(2, 11, 12, 14, 15, 16, 17, 22, 23, 25, 26, 30, 40, 50, 61) ~ "less_than_hs",
      EDUCD %in% c(63, 64) ~ "hs_or_ged",
      EDUCD %in% c(65, 71, 81) ~ "some_college_associate",
      EDUCD == 101 ~ "bachelors",
      EDUCD %in% c(114, 115, 116) ~ "advanced_degree"
    ),
    EDUCD = factor(EDUCD, levels = c(
     "less_than_hs", "hs_or_ged", "some_college_associate", "bachelors", "advanced_degree"
    ))
  )

#carpool
mh_rm <- mh_rm %>%
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

#tranwork
mh_rm <- mh_rm %>%
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
mh_rm <- mh_rm %>% 
mutate(
    transit_group = case_when(
       transit_mode %in% c("auto_truck_van", "motorcycle") ~ "private_auto",
       transit_mode %in% c("bus", "subway_elevated", "commuter_train", "light_rail_streetcar", "ferryboat") ~ "public_transit",
       transit_mode %in% c("walked", "bicycle") ~ "active_transit",
       transit_mode == "wfh" ~ "wfh",
       transit_mode %in% c("taxi_ride_hail", "other") ~ "other_transit"
    )
  )

# creating a new variable to label the type of household 
mh_rm <- mh_rm %>% 
     mutate(hh_group = "roommate")

saveRDS(mh_rm, "data/mh_rm_eda_ready_final.rds")
