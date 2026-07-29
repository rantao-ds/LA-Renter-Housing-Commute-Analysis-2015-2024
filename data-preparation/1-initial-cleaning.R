Part 1: Initial Cleaning 

# note: please download the dataset from IPUMS USA using the selected variables and ACS years (registration required), then update the file path accordingly.
# dataset: https://usa.ipums.org/usa/

library(tidyverse)

# loading the datasets
data <- read_csv("data/usa_0009.csv.gz")

# filtering the dataset to Los Angeles county
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
    has_dependent_children = any(RELATED %in% c(301, 302, 303, 401, 901, 1242) & AGE < 18),
    num_dependent_children = sum(RELATED %in% c(301, 302, 303, 401, 901, 1242) & AGE < 18)
  ) %>%
  ungroup()


# creating a new variable to flag couple family 
mh_raw <- mh_raw %>%
  group_by(YEAR, SERIAL) %>%
  mutate(
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
    !any(RELATED %in% roommate_codes) 
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
    !any(RELATED %in% family_codes) 
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
    any(RELATED %in% roommate_codes) 
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


#California minimum wage from 2015 - 2019 and 2020 - 2024
##2015 - 2019 
2015: $9.00/hour 
part-time = 9 * 20 * 52 = 9,360
full-time = 9 * 35 * 52 = 16,380
2016: $10.00/hour
part-time = 10 * 20 * 52 = 10,400
full-time = 10 * 35 * 52 = 18,200
2017: $10.00/hour
part-time = 10 * 20 * 52 = 10,400
full-time = 10 * 35 * 52 = 18,200
2018: $11.00/hour
part-time = 11 * 20 * 52 = 11,440
full-time = 11 * 35 * 52 = 20,020
2019: $12.00/hour
part-time = 12 * 20 * 52 = 12,480 
full-time = 12 * 35 * 52 = 21,840

##2020 - 2024
2020: $12.00/hour
part-time = 12 * 20 * 52 = 12,480 
full-time = 12 * 35 * 52 = 21,840
2021: $13.00/hour
part-time = 13 * 20 * 52 = 13,520
full-time = 13 * 35 * 52 = 23,660
2022: $14.00/hour
part-time = 14 * 20 * 52 = 14,560
full-time = 14 * 35 * 52 = 25,480
2023: $15.50/hour
part-time = 15.5 * 20 * 52 = 16,120
full-time = 15.5 * 35 * 52 = 28,210
2024: $16.00/hour
part-time = 16 * 20 * 52 = 16,640
full-time = 16 * 35 * 52 = 29,120
