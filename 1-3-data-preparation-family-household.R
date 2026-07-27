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





