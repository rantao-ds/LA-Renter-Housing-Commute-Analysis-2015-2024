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



