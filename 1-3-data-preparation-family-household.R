Part 1: initial cleaning
# double checking composition of family structure
mh_fm <- mh_fm %>%
group_by(YEAR, SERIAL) %>%
mutate(
  has_head = sum(RELATED == 101), has_roommate = sum(RELATED %in% c(1115, 1260)),
    has_relatives = sum(RELATED %in% c(201, 301, 302, 303, 401, 501, 601, 701, 801, 901, 1001, 1114, 1242))) %>%
     ungroup()

table(mh_fm$has_roommate)
table(mh_fm$has_head,mh_fm$has_relatives)


# filtering the target sampling characters and verifing the filtering
mh_fm <- mh_fm %>%
filter(OWNERSHP == 2 & OWNERSHPD == 22) %>%
filter(EMPSTAT == 1 & EMPSTATD %in% c(10, 14)) %>%
filter(AGE >= 24, AGE < 65) %>%
filter(between(UNITSSTR,3,10)) %>%
filter(between(UHRSWORK, 20,80)) 

# creating a new variable to label the type of work
mh_fm <- mh_fm %>%
 mutate(
 type_hrwrk = case_when(
 between(UHRSWORK,20,34) ~ "part_time",
 between(UHRSWORK, 35, 40) ~ "full_time",
 UHRSWORK > 40 ~ "over_time")
 )

# checking the TRANWORK and if all the trantime less than zero are wfh
table(mh_fm$TRANWORK)
mh_fm %>%
     filter(TRANTIME == 0) %>%
     group_by(TRANWORK) %>%
     count()

##  creating a varible to label wfh_status(TRUE/FALSE)
mh_fm <- mh_fm %>%
     mutate(
         wfh = if_else(TRANWORK == 80, "TRUE", "FALSE")
     )

# removing uneeded varaibles
mh_fm <- mh_fm %>%
 select(-SAMPLE, -STATEFIP, -COUNTYFIP, -OWNERSHP, -OWNERSHPD, -EMPSTAT, -EMPSTATD)

# saving the initial clean dataset 
saveRDS(mh_fm, "data/mh_fm_initial_clean.rds")

Part 2: income and rent burden
# checking the summary of HHINCOME
summary(mh_fm$HHINCOME) 

## removing the 1.5% top and bottom tier of HHINCOME and retaining 97% of sampling
mh_fm <- mh_fm %>%
  group_by(MULTYEAR) %>%
  filter(
    HHINCOME >= quantile(HHINCOME, 0.015) &
    HHINCOME <= quantile(HHINCOME, 0.985)
  ) %>%
  ungroup()

### checking the summary of filtering
summary(mh_fm$HHINCOME)


# checking the summary of rent
summary(mh_fm$RENT)

## removing the 1.5% top and bottom tier of RENT and retaining 97% of sampling
mh_fm <- mh_fm %>%
  group_by(MULTYEAR) %>%
  filter(
    RENT >= quantile(RENT, 0.015) &
    RENT <= quantile(RENT, 0.985)
  ) %>%
  ungroup()


### cheking the summary of filtering
summary(mh_fm$RENT)

# double checking the composition of hh structure and dropping the one wihout head 
mh_fm <- mh_fm %>%
     group_by(YEAR, SERIAL) %>%
     mutate(after_has_head = sum(RELATED == 101)) %>%
     ungroup()

## verifying
table(mh_fm$after_has_head)


### removing the household without the head
mh_fm <- mh_fm %>%
filter(after_has_head == 1)


# creating a new varible for rent_burnden and retaining the rent_burden less than 100%
mh_fm <- mh_fm %>%
  mutate(rent_burden = round((RENT * 12) / HHINCOME * 100, 2)) %>%
  filter(rent_burden <= 100)


# creating a new varibale for the range of rent_burden 
mh_fm  <- mh_fm  %>%
  mutate(
    range_burden = case_when(
      rent_burden <= 30.00 ~ "affordable",
      rent_burden <= 50.00 ~ "burdened",
      rent_burden <= 70.00 ~ "severely_burdened",
      TRUE                 ~ "extreme"  # This catches everything else (> 70.00)
    )
  )

## checking the rent burden
table(mh_fm$range_burden)

## adding n_worker and checking rent burden again
mh_fm <- mh_fm %>%
     group_by(YEAR, SERIAL) %>%
     mutate(n_workers = n()) %>%
     ungroup()

mh_fm %>%
     distinct(YEAR, SERIAL, n_hh, n_workers, range_burden, has_dependent_children) %>%
     group_by(has_dependent_children, n_hh, n_workers) %>%
     count(range_burden) %>%
     mutate(pct = n/sum(n)*100) %>%
     arrange(has_dependent_children, n_hh, n_workers) %>%
     print(n=Inf, width=Inf)


# saving the dataset 
saveRDS(mh_fm, "data/mh_fm_final_cleaned.rds")

Part 3: relabeling character 

#UNITSSTR

mh_fm <- mh_fm %>%
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
mh_fm <- mh_fm %>%
  mutate(
    BEDROOMS = case_when(
      BEDROOMS == 1 ~ "no_bedrooms" ,
      BEDROOMS == 2 ~ "1_bedrooms",
      BEDROOMS == 3 ~ "2_bedrooms",
      BEDROOMS == 4 ~ "3_bedrooms",
      BEDROOMS == 5 ~ "4_bedrooms",
      BEDROOMS == 6 ~ "5_bedrooms",
      BEDROOMS == 7 ~ "6_bedrooms",
      BEDROOMS == 8 ~ "7_bedrooms"
    ),
    BEDROOMS = factor(BEDROOMS, levels = c(
      "no_bedrooms", "1_bedrooms", "2_bedrooms", "3_bedrooms", 
      "4_bedrooms", "5_bedrooms", "6_bedrooms","7_bedrooms"
    ))
  )

#VEHICLES
mh_fm <- mh_fm %>%
  mutate(VEHICLES = case_when(
    VEHICLES == 9 ~ "no_available", 
    TRUE ~ as.character(VEHICLES)   
  ))

#RELATED
mh_fm <- mh_fm %>%
  mutate(
    RELATED = case_when(
      RELATED == 101 ~ "head",
      RELATED == 201 ~ "spouse",
      RELATED == 301 ~ "child",
      RELATED == 302 ~ "adopted_child",
      RELATED == 303 ~ "stepchild",
      RELATED == 401 ~ "child_in_law",
      RELATED == 501 ~ "parent",
      RELATED == 601 ~ "parent_in_law",
      RELATED == 701 ~ "sibling",
      RELATED == 801 ~ "sibling_in_law",
      RELATED == 901 ~ "grandchild",
      RELATED == 1001 ~ "other_relatives",
      RELATED == 1114 ~ "unmarried_partner"
    ),
    RELATED = factor(RELATED, levels = c(
      "head", "spouse", "child", "adopted_child", "stepchild", "child_in_law",
      "parent", "parent_in_law", "sibling", "sibling_in_law", "grandchild", 
      "other_relatives", "unmarried_partner"
    ))
  )

#SEX
mh_fm <- mh_fm %>%
mutate(SEX = case_when(
  SEX == 1 ~ "male",
  SEX == 2 ~ "female"),
SEX = factor(SEX, levels = c("male", "female"))
)

#RACE
mh_fm <- mh_fm %>%
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
mh_fm <- mh_fm %>%
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
mh_fm <- mh_fm %>%
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

#tranwork
mh_fm <- mh_fm %>%
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
mh_fm <- mh_fm %>%
mutate(
    transit_group = case_when(
       transit_mode %in% c("auto_truck_van", "motorcycle") ~ "private_auto",
       transit_mode %in% c("bus", "subway_elevated", "commuter_train", "light_rail_streetcar", "ferryboat") ~ "public_transit",
       transit_mode %in% c("walked", "bicycle") ~ "active_transit",
       transit_mode == "wfh" ~ "wfh",
       transit_mode %in% c("taxi_ride_hail", "other") ~ "other_transit"
    )
  )


#carpool
mh_fm <- mh_fm %>%
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

# creating a new variable to label the housheold with single or multiple earners
mh_fm <- mh_fm %>%
      mutate(
          worker_type = case_when(
              n_workers == 1 ~ "single_earner",
              n_workers > 1 ~ "multiple_earners"))


# creating new variable to label of group of household 
mh_fm <- mh_fm %>%
 mutate(hh_group = "family")

# saving the dataset
saveRDS(mh_fm, "data/mh_fm_eda_ready_final.rds")



