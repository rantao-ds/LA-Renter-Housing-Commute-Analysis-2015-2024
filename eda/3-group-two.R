Part 1: pre-eda dataset adjustments

# creating income-tier categories within each ACS 5-year sample and analytical group
group_two_eda <- group_two_eda %>%
  group_by(year) %>%
  mutate(
    income_tier_g2 = case_when(
      household_income <= quantile(household_income, 0.30) ~ "low_income",
      household_income <= quantile(household_income, 0.80) ~ "middle_income",
      TRUE ~ "upper_income"
    )
  ) %>%
  ungroup()

## verify
group_two_eda %>%
  group_by(income_tier_g2) %>%
  summarise(n = n()) %>%
  mutate(pct = n/sum(n)*100) %>%
  arrange(income_tier_g2)


# saving the dataset
saveRDS(group_two_eda, "data/group_two_eda_ready.rds")


Part 2: group two eda
