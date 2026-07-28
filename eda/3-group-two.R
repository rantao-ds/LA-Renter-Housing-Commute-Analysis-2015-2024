Part 1: pre-eda dataset adjustments

# creating income-tier categories within each ACS 5-year sample for group two
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

# chart 1 (Distribution of Family-Based Households)
## calculating 
pct_fm_mx <- group_two_eda %>%
 count(hh_group, wt = perwt) %>%           
     mutate(prop = n / sum(n))

burden_fm_mx <- group_two_eda %>%
  filter(wfh == FALSE) %>%
  group_by(hh_group, range_burden) %>%
  summarise(
    n_weighted = sum(perwt, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(hh_group) %>%
  mutate(prop = n_weighted/sum(n_weighted)) %>%
  ungroup()

## preparing for both plot1 & plot2
prop_clean_g2 <- pct_fm_mx %>%
  mutate(hh_group = factor(hh_group, 
                           levels = c("family", "mixed"),
                           labels = c("Family (Multi-Person)", "Mixed (Multi-Person)"))) %>%
  arrange(desc(hh_group)) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2),
    label_x = ifelse(prop < 0.05, 2.65, 2.0),
    label_color = ifelse(prop < 0.05, "gray30", "white")
  )

prop_inside_g2  <- prop_clean_g2 %>% filter(prop >= 0.05) 

prop_outside_g2 <- prop_clean_g2 %>% filter(prop < 0.05) 

prop_outside_g2 <- prop_outside_g2 %>%
  mutate(
    label_hjust = 0.5 
  )

plot_data_rb_g2 <- burden_fm_mx %>%
  mutate(
    hh_group = factor(hh_group, 
                      levels = c("family", "mixed"),
                      labels = c("Family (Multi-Person)", "Mixed (Multi-Person)")),
    range_burden = factor(range_burden, 
                          levels = c("affordable", "burdened", "severely_burdened", "extreme"),
                          labels = c("Affordable (<30%)", "Burdened (30-50%)", 
                                     "Severely Burdened (50-70%)", "Extreme (70-100%)"))
  )

### defining the color 
donut_colors_g2 <- c(
  "Family (Multi-Person)" = "#003580",  
  "Mixed (Multi-Person)"  = "#66C2E8"   
)


### plot1
plot1 <- ggplot(prop_clean_g2, aes(x = 2, y = prop, fill = hh_group)) +
  geom_bar(stat = "identity", color = "white", linewidth = 1.5) +
  coord_polar(theta = "y", start = 0) +
  geom_text(
    aes(label = ifelse(prop >= 0.05,
                       scales::percent(prop, accuracy = 0.1),
                       "")),
    position = position_stack(vjust = 0.5), 
    color = "white",
    size = 4.5,
    fontface = "bold"
  ) +
  geom_segment(
    data = prop_outside_g2,
    aes(x = 2.1, xend = 2.5, y = label_y, yend = label_y),
    color = "gray50",
    linewidth = 0.8,
    inherit.aes = FALSE 
  ) +
  geom_text(
    data = prop_outside_g2,
    aes(x = 2.65, y = label_y, label = scales::percent(prop, accuracy = 0.1)),
    color = "gray30", 
    fontface = "bold", 
    size = 4.5,
    hjust = 0.5,       
    inherit.aes = FALSE
  ) +
  scale_fill_manual(
    values = donut_colors_g2,
    name = "Living Arrangement"
  ) +
  xlim(0.3, 3.0) + 
  theme_void() +
  labs(
    title = "Overall Family-Bound Share", 
    fill = "Living Arrangement"
  ) +
  guides(fill = guide_legend(nrow = 1, title.position = "top", title.hjust = 0.5)) +
  theme(
    aspect.ratio = 1, 
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 10, b = -20)), 
    legend.title = element_text(face = "bold", size = 12), 
    legend.text = element_text(size = 11),              
    legend.key.size = unit(1.1, "lines"),                 
    legend.margin = margin(t = -10, r = 0, b = 10, l = 0) 
  )


### plot2
p_rent_burden_by_hh_g2 <- ggplot(plot_data_rb_g2, aes(x = range_burden, y = prop, fill = hh_group)) + 
  geom_col(position = position_dodge(width = 0.8), width = 0.7, alpha = 0.9) +
  geom_text(
    aes(label = percent(prop, accuracy = 0.1)), 
    position = position_dodge(width = 0.8),
    vjust = -0.5, 
    fontface = "bold",
    size = 3.0
  ) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 0.90)) + 
  scale_fill_manual(
    values = donut_colors_g2, 
    name = "Living Arrangement"
  ) +
  theme_minimal() +
  labs(
    title = "Rent Burden by Household Type", 
    x = "Rent Burden Category",               
    y = "Proportion (%)",
    fill = "Living Arrangement"
  ) +
  theme(
    aspect.ratio = 1, 
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 10, b = 15)), 
    axis.text.x = element_text(face = "bold", size = 9, color = "black"), 
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none" 
  )

### merging plot1 & plot2 side by side
final_g2_housing_dashboard <- plot1 + p_rent_burden_by_hh_g2 + 
  plot_layout(widths = c(1, 1)) + 
  plot_annotation(
    title = "Distribution of Family-Based Households", 
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Estimates are weighted using personal weights (PERWT).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10)) 
    )
  )

# Display the dashboard
final_g2_housing_dashboard

# saving the plot
ggsave("plots/family_housing_dashboard.png",
       plot = final_g2_housing_dashboard,
       width = 20, height = 10, dpi = 300,
       bg = "white")


# chart 2 (Socioeconomic Profiles of Rent Burden Categories: Family Households)
## calculating 
burden_range_age_g2 <- group_two_eda %>%
 group_by(range_burden) %>%
 count(age_group, wt = perwt) %>%           
     mutate(prop = n / sum(n))

burden_range_income_g2 <- group_two_eda %>%
 group_by(range_burden) %>%
 count(income_tier_g2, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### preparing both plot1 & plot2
plot_data_age <- burden_range_age_g2 %>%
  ungroup() %>% 
  mutate(
    range_burden = factor(range_burden, 
                          levels = c("affordable", "burdened", "severely_burdened", "extreme"),
                          labels = c("Affordable\n(<30%)", "Burdened\n(30-50%)", "Severely Burdened\n(50-70%)", "Extreme\n(70-100%)"))
  ) %>%
  arrange(range_burden, desc(age_group)) %>%
  group_by(range_burden) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2) 
  ) %>%
  ungroup()

plot_data_income <- burden_range_income_g2 %>%
  ungroup() %>% 
  complete(range_burden, income_tier_g2, fill = list(n = 0, prop = 0)) %>%
  mutate(
    range_burden = factor(range_burden, 
                          levels = c("affordable", "burdened", "severely_burdened", "extreme"),
                          labels = c("Affordable\n(<30%)", "Burdened\n(30-50%)", "Severely Burdened\n(50-70%)", "Extreme\n(70-100%)")),
    income_tier_g2 = factor(income_tier_g2,
                            levels = c("low_income", "middle_income", "upper_income"),
                            labels = c("Low-Income", "Middle-Income", "Upper-Income"))
  ) %>%
  arrange(range_burden, desc(income_tier_g2)) %>%
  group_by(range_burden) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2) 
  ) %>%
  ungroup()


### defining color palettes
age_colors <- c(
  "24-34" = "#0F172A",  
  "35-44" = "#334155",  
  "45-54" = "#64748B",  
  "55-64" = "#94A3B8"   
)

income_colors <- c(
  "Low-Income"    = "#4C0519",  
  "Middle-Income" = "#881337",  
  "Upper-Income"  = "#BE123C"   
)

### plot1
plot1 <- ggplot(plot_data_age, aes(x = range_burden, y = prop, fill = age_group)) +
  geom_col(color = "white", linewidth = 0.6, width = 0.65) +
  geom_text(
    aes(
      y = label_y, 
      label = percent(prop, accuracy = 0.1)
    ),
    color = "white",
    fontface = "bold",
    size = 3.5
  ) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1.0)) +
  scale_fill_manual(values = age_colors) +
  theme_minimal() +
  labs(
    title = "Age Group Composition",
    x = NULL,
    y = "Proportion (%)",
    fill = "Age Cohort"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5, margin = margin(t = 10, b = 10)),
    axis.text.x = element_text(face = "bold", size = 10, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 10),
    legend.text = element_text(size = 9)
  )

### plot2
plot2 <- ggplot(plot_data_income, aes(x = range_burden, y = prop, fill = income_tier_g2)) +
  geom_col(color = "white", linewidth = 0.6, width = 0.65) +
  geom_text(
    aes(
      y = label_y,
      label = ifelse(prop >= 0.01, percent(prop, accuracy = 0.1), "")
    ),
    color = "white",
    fontface = "bold",
    size = 3.5
  ) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1.0)) +
  scale_fill_manual(values = income_colors) +
  theme_minimal() +
  labs(
    title = "Income Tier Composition",
    x = NULL,
    y = "Proportion (%)",
    fill = "Income Tier"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5, margin = margin(t = 10, b = 10)),
    axis.text.x = element_text(face = "bold", size = 10, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 10),
    legend.text = element_text(size = 9)
  )

### merging plot1 & plot2 side by side 
final_profile_dashboard <- plot1 + plot2 + 
  plot_layout(widths = c(1, 1)) + 
  plot_annotation(
    title = "Socioeconomic Profiles of Rent Burden Categories: Family Households",
    subtitle = "Stable Working Family Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Estimates are weighted using personal weights (PERWT). Income tiers are calculated as relative percentiles (30:50:20) within each respective 5-year ACS period (pooled 2019 or 2024).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)),
      plot.caption.position = "plot"
    )
  )

final_profile_dashboard

### saving the plot
ggsave("plots/family_rent_burden_socioeconomic_profiles.png",
       plot = final_profile_dashboard,
       width = 14, height = 8, dpi = 300,
       bg = "white")


# chart 3 (Racial and Ethnic Profiles of Rent Burden Categories: Family Households)
## calculating
burden_range_ethnicity_g2 <- group_two_eda %>%
 group_by(range_burden) %>%
 count(race_ethnicity, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### preparation
plot_data_race_eth <- burden_range_ethnicity_g2 %>%
  ungroup() %>% 
  complete(range_burden, race_ethnicity, fill = list(n = 0, prop = 0)) %>%
  mutate(
    range_burden = factor(range_burden, 
                          levels = c("affordable", "burdened", "severely_burdened", "extreme"),
                          labels = c("Affordable\n(<30%)", "Burdened\n(30-50%)", "Severely Burdened\n(50-70%)", "Extreme\n(70-100%)")),
    race_ethnicity = factor(race_ethnicity,
                            levels = c("nh_white", "hispanic", "nh_black", "nh_asian", "nh_other", "nh_native"),
                            labels = c("White (Non-Hispanic)", "Hispanic / Latino", "Black / African American", "Asian", "Other / Multi-racial", "Native American"))
  ) %>%
  arrange(range_burden, desc(race_ethnicity)) %>%
  group_by(range_burden) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2) 
  ) %>%
  ungroup()

### defining the color palettes
race_eth_colors <- c(
  "White (Non-Hispanic)"     = "#1E0B36",  
  "Hispanic / Latino"        = "#3B0764",  
  "Black / African American" = "#5B21B6",  
  "Asian"                    = "#7C3AED",  
  "Other / Multi-racial"     = "#A78BFA",  
  "Native American"          = "#DDD6FE"   

### plot
single_race_eth_plot_g2 <- ggplot(plot_data_race_eth, aes(x = range_burden, y = prop, fill = race_ethnicity)) +
  geom_col(color = "white", linewidth = 0.6, width = 0.6) +
  geom_text(
    aes(
      y = label_y,
      label = ifelse(prop >= 0.01, percent(prop, accuracy = 0.1), "")
    ),
    color = "white",
    fontface = "bold",
    size = 3.8
  ) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1.0)) +
  scale_fill_manual(values = race_eth_colors) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "Racial and Ethnic Profiles of Rent Burden Categories: Family Households",
    subtitle = "Stable Working Family Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    x = NULL,
    y = "Proportion (%)",
    fill = "Race / Ethnicity",
    caption = "Note: Estimates are weighted using personal weights (PERWT)."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 20, b = 2)),
    plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
    axis.text.x = element_text(face = "bold", size = 10, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 10),
    legend.text = element_text(size = 9),
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)),
    plot.caption.position = "plot"
  )

single_race_eth_plot_g2

# saving the plot
ggsave("plots/family_rent_burden_racial_ethnic_profile.png",
       plot = single_race_eth_plot_g2,
       width = 13, height = 10, dpi = 300,
       bg = "white")


# chart 4 (Household Composition & Worker Profile: Family-Based Households)
## calculating 
burden_wk_child_fm <- group_two_eda %>% 
     filter(hh_group == "family") %>%
     group_by(range_burden, has_dependent_children, worker_type) %>%
     summarise(
        n_weighted = sum(perwt, na.rm = TRUE),
           .groups = "drop"
          ) %>%
          group_by(range_burden) %>%
          mutate(prop = n_weighted/sum(n_weighted)) %>%
          ungroup() %>%
 print(n = Inf, width = Inf)

burden_wk_child_mx <- group_two_eda %>% 
     filter(hh_group == "mixed") %>%
     group_by(range_burden, has_dependent_children, worker_type) %>%
     summarise(
        n_weighted = sum(perwt, na.rm = TRUE),
           .groups = "drop"
          ) %>%
          group_by(range_burden) %>%
          mutate(prop = n_weighted/sum(n_weighted)) %>%
          ungroup() %>%
  print(n = Inf, width = Inf)

### preparing for both plot1 & plot2
combined_raw_data <- group_two_eda %>% 
  filter(hh_group %in% c("family", "mixed")) %>%
  group_by(hh_group, range_burden, has_dependent_children, worker_type) %>%
  summarise(
    n_weighted = sum(perwt, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(hh_group, range_burden) %>%
  mutate(prop = n_weighted / sum(n_weighted)) %>%
  ungroup()

plot_data_clean <- combined_raw_data %>%
  mutate(
    working_profile = case_when(
      has_dependent_children == TRUE  & worker_type == "single_earner"     ~ "Single Earner, with Children",
      has_dependent_children == FALSE & worker_type == "single_earner"     ~ "Single Earner, no Children",
      has_dependent_children == TRUE  & worker_type == "multiple_earners"  ~ "Multiple Earners, with Children",
      has_dependent_children == FALSE & worker_type == "multiple_earners"  ~ "Multiple Earners, no Children"
    ),
    working_profile = factor(working_profile,
                             levels = c("Single Earner, with Children", 
                                        "Single Earner, no Children", 
                                        "Multiple Earners, with Children", 
                                        "Multiple Earners, no Children")),
    range_burden = factor(range_burden, 
                          levels = c("affordable", "burdened", "severely_burdened", "extreme"),
                          labels = c("Affordable\n(<30%)", "Burdened\n(30-50%)", "Severely Burdened\n(50-70%)", "Extreme\n(70-100%)"))
  ) %>%
  complete(hh_group, range_burden, working_profile, fill = list(n_weighted = 0, prop = 0)) %>%
  arrange(hh_group, range_burden, desc(working_profile)) %>%
  group_by(hh_group, range_burden) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2) 
  ) %>%
  ungroup()

family_profile_data <- plot_data_clean %>% filter(hh_group == "family")
mixed_profile_data  <- plot_data_clean %>% filter(hh_group == "mixed")

### defining the color palettes
profile_colors <- c(
  "Single Earner, with Children"    = "#172554",  
  "Single Earner, no Children"      = "#1D4ED8",  
  "Multiple Earners, with Children" = "#3B82F6",  
  "Multiple Earners, no Children"   = "#93C5FD"   
)

text_colors <- c(
  "Single Earner, with Children"    = "white",
  "Single Earner, no Children"      = "white",
  "Multiple Earners, with Children" = "white",
  "Multiple Earners, no Children"   = "#172554"  
)

### plot1
plot1 <- ggplot(family_profile_data, aes(x = range_burden, y = prop, fill = working_profile)) +
  geom_col(color = "white", linewidth = 0.6, width = 0.65) + 
  geom_text(
    aes(
      y = label_y,
      label = ifelse(prop >= 0.01, percent(prop, accuracy = 0.1), ""),
      color = working_profile
    ),
    fontface = "bold",
    size = 3.5
  ) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1.0)) +
  scale_fill_manual(values = profile_colors) +
  scale_color_manual(values = text_colors) +
  guides(color = "none") +
  theme_minimal(base_family = "sans") +
  labs(title = "Family Households (Multi-Person)", fill = "Household Working Profile") +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 10, b = 10)),
    axis.text.x = element_text(face = "bold", size = 10, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none" 
  )

  # plot2
  plot2 <- ggplot(mixed_profile_data, aes(x = range_burden, y = prop, fill = working_profile)) +
  geom_col(color = "white", linewidth = 0.6, width = 0.65) +  
  geom_text(
    aes(
      y = label_y,
      label = ifelse(prop >= 0.01, percent(prop, accuracy = 0.1), ""),
      color = working_profile
    ),
    fontface = "bold",
    size = 3.5
  ) +  
  scale_y_continuous(labels = percent_format(), limits = c(0, 1.0)) +
  scale_fill_manual(values = profile_colors) +
  scale_color_manual(values = text_colors) +
  guides(color = "none") +
  theme_minimal(base_family = "sans") +
  labs(title = "Mixed Households (Multi-Person)", fill = "Household Working Profile") +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 10, b = 10)),
    axis.text.x = element_text(face = "bold", size = 10, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none" 
  )

  ### merging plot1 & plot2 side by side
  final_profile_dashboard <- (plot1 + plot2) + 
  plot_layout(widths = c(1, 1), guides = "collect") & 
  theme(
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 11),
    legend.text = element_text(size = 10),
    legend.key.size = unit(1.1, "lines"),
    legend.margin = margin(t = -10, r = 0, b = 10, l = 0)
  )

final_profile_dashboard <- final_profile_dashboard + 
  plot_annotation(
    title = "Household Composition & Worker Profile: Family-Based Households", 
    subtitle = "Stable Working Family Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Population-weighted estimates (PERWT). Family workers only (roommates excluded).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10)) 
    )
  )

final_profile_dashboard

# saving the plot
ggsave("plots/family_mixed_worker_profile_dashboard.png",
       plot = final_profile_dashboard,
       width = 14, height = 8, dpi = 300,
       bg = "white")

# chart 5 (Income Tier Composition of Transit Modes: Family Households)
## calculating
transit_income_g2 <- group_two_eda %>%
     group_by(transit_group) %>%
     count(income_tier_g2, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### preparation
plot_data_transit_inc <- transit_income_g2 %>%
  ungroup() %>% 
  complete(transit_group, income_tier_g2, fill = list(n = 0, prop = 0)) %>%
  mutate(
    transit_group = factor(transit_group, 
                           levels = c("private_auto", "public_transit", "active_transit", "other_transit", "wfh"),
                           labels = c("Private Auto", "Public Transit", "Active Transit", "Other", "WFH")),
    income_tier_g2 = factor(income_tier_g2,
                            levels = c("low_income", "middle_income", "upper_income"),
                            labels = c("Low-Income", "Middle-Income", "Upper-Income"))
  ) %>%
  arrange(transit_group, desc(income_tier_g2)) %>%
  group_by(transit_group) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2) 
  ) %>%
  ungroup()
  
### defining the gradient color
income_colors <- c(
  "Low-Income"    = "#0F2519",  
  "Middle-Income" = "#2B5738",  
  "Upper-Income"  = "#598F6C"   
)

### plot
transit_income_plot_g2 <- ggplot(plot_data_transit_inc, aes(x = transit_group, y = prop, fill = income_tier_g2)) +
  geom_col(color = "white", linewidth = 0.6, width = 0.6) +
  geom_text(
    aes(
      y = label_y,
      label = percent(prop, accuracy = 0.1)
    ),
    color = "white",
    fontface = "bold",
    size = 4.0
  ) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1.0)) +
  scale_fill_manual(values = income_colors) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "Income Tier Composition of Transit Modes: Family Households",
    subtitle = "Stable Working Family Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    x = NULL,
    y = "Proportion (%)",
    fill = "Income Tier",
    caption = "Note: Estimates are weighted using personal weights (PERWT). Income tiers are calculated as relative percentiles (30:50:20) within each respective 5-year ACS period (pooled 2019 or 2024)."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 20, b = 2)),
    plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
    axis.text.x = element_text(face = "bold", size = 11, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 10),
    legend.text = element_text(size = 9),
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)),
    plot.caption.position = "plot"
  )

transit_income_plot_g2

# saving the plot
ggsave("plots/family_transit_mode_income_profile.png",
       plot = transit_income_plot_g2,
       width = 11, height = 7, dpi = 300,
       bg = "white")

# chart 6 (Overall Transit Distribution and Commuter Profile: Family-Based Households)
## calculating
prop_group2_trans <- group_two_eda %>%
  count(transit_group, wt = perwt) %>%           
  mutate(prop = n / sum(n))

prop_group2_trans_hh <- group_two_eda %>%
     group_by(hh_group) %>%                 
     count(transit_group, wt = perwt) %>%           
     mutate(prop = n / sum(n))

## preparing for both plot1 & plot2
prop_clean <- prop_group2_trans %>%
  mutate(transit_group = factor(transit_group, 
                                levels = c("private_auto", "public_transit", "active_transit", "other_transit", "wfh"),
                                labels = c("Private Auto", "Public Transit", "Active Transit", "Other", "WFH"))) %>%
  arrange(desc(transit_group)) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2),
    label_x = ifelse(prop < 0.05, 2.65, 2.0),
    label_color = ifelse(prop < 0.05, "gray30", "white")
  )

prop_inside  <- prop_clean %>% filter(prop >= 0.05) 
  
prop_outside <- prop_clean %>% filter(prop < 0.05)  

prop_outside <- prop_outside %>%
  mutate(
    label_hjust = 0.5 
  )

  
plot_data_b <- prop_group2_trans_hh %>%
  mutate(
    transit_group = factor(transit_group, 
                           levels = c("private_auto", "public_transit", "active_transit", "other_transit", "wfh"),
                           labels = c("Private Auto", "Public Transit", "Active Transit", "Other", "WFH")),
    hh_group = factor(hh_group, 
                      levels = c("family", "mixed"),
                      labels = c("Family (Multi-Person)", "Mixed (Multi-Person)"))
  )


### defining the color palette
transit_colors <- c(
  "Private Auto"   = "#5199eb",  
  "Public Transit" = "#bd2f2f",  
  "Active Transit" = "#539c75",  
  "Other"          = "#d7bc6b",  
  "WFH"            = "#624696"   
)


### plot1
plot1 <- ggplot(prop_clean, aes(x = 2, y = prop, fill = transit_group)) +
  geom_bar(stat = "identity", color = "white", linewidth = 1.0) +
  coord_polar(theta = "y", start = 0) +
  geom_segment(
    data = prop_outside,
    aes(x = 2.1, xend = 2.5, y = label_y, yend = label_y),
    color = "gray50",
    linewidth = 0.8,
    inherit.aes = FALSE 
  ) +
  geom_text(
    data = prop_inside,
    aes(x = 2.0, y = label_y, label = percent(prop, accuracy = 0.1)),
    color = "white", 
    fontface = "bold", 
    size = 4.0
  ) +
  geom_text(
    data = prop_outside,
    aes(x = 2.65, y = label_y, label = percent(prop, accuracy = 0.1), hjust = label_hjust),
    color = "gray30", 
    fontface = "bold", 
    size = 4.0,
    inherit.aes = FALSE
  ) +
  scale_fill_manual(values = transit_colors) +
  xlim(0.7, 3.0) + 
  theme_void() +
  labs(title = "Overall Transit Mode Share", 
       fill = "Transit Mode") +
  guides(fill = guide_legend(nrow = 2, title.position = "top", title.hjust = 0.5)) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(t = 10, b = -20)),
    legend.position = "bottom", 
    legend.title = element_text(face = "bold", size = 10), 
    legend.text = element_text(size = 9),              
    legend.key.size = unit(1.1, "lines"),                 
    legend.margin = margin(t = -10, r = 0, b = 10, l = 0) 
  )

### plot2
plot2 <- ggplot(plot_data_b, aes(x = hh_group, y = prop, fill = transit_group)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7, alpha = 0.9) +
  geom_text(
    aes(label = percent(prop, accuracy = 0.1)),
    position = position_dodge(width = 0.8),
    vjust = -0.5, 
    fontface = "bold",
    size = 2.8 
  ) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 0.90)) + 
  scale_fill_manual(values = transit_colors) +
  theme_minimal() +
  labs(
    title = "Commuter Profile", 
    x = NULL,
    y = "Proportion (%)",
    fill = "Transit Mode"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(t = 10, b = -10)),
    axis.text.x = element_text(face = "bold", size = 11, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none"
  )

### merging plot1 & plot2 side by side
final_transit_dashboard <- plot1 + plot2 + 
  plot_layout(widths = c(1, 1)) + 
  plot_annotation(
    title = "Overall Transit Distribution and Commuter Profile: Family-Based Households",
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Estimates are weighted using personal weights (perwt).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 20, hjust = 0.5, margin = margin(t = 20, b = 2)), 
      plot.subtitle = element_text(size = 14, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10))
    )
  )

final_transit_dashboard

# saving the plot
ggsave("plots/family_transit_performance_dashboard.png",
       plot = final_transit_dashboard,
       width = 15, height = 8, dpi = 300,
       bg = "white")


# chart 7 (Commute Time and Rent Burden Profiles of Family Households)
## calculating
mean_commute_rent_group2 <- group_two_eda %>%
  filter(transit_group != "wfh") %>% 
  group_by(transit_group, hh_group) %>%
  summarize(
    mean_commute = round(weighted.mean(commute_time, perwt, na.rm = TRUE), 1), 
    mean_burden = round(weighted.mean(rent_burden, perwt, na.rm = TRUE), 1), 
    .groups = "drop"
  )

### preparation
plot_data_g2_performance <- mean_commute_rent_group2 %>%
  pivot_longer(
    cols = c(mean_commute, mean_burden), 
    names_to = "metric",
    values_to = "value"
  ) %>%
  mutate(
    metric = case_when(
      metric == "mean_commute" ~ "Mean Commute Time (mins)",
      metric == "mean_burden"  ~ "Mean Rent Burden (%)"
    ),
    label_text = ifelse(metric == "Mean Commute Time (mins)", 
                        paste0(value, " min"), 
                        paste0(value, "%")),
    transit_group = factor(transit_group,
                           levels = c("private_auto", "public_transit", "active_transit", "other_transit"),
                           labels = c("Private Auto", "Public Transit", "Active Transit", "Other")),
    hh_group = factor(hh_group, 
                      levels = c("family", "mixed"),
                      labels = c("Family", "Mixed"))
  )

### plot
p_performance_g2 <- ggplot(plot_data_g2_performance, aes(x = value, y = transit_group, fill = metric)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7, color = "white", linewidth = 0.3) +
  geom_text(
    aes(label = label_text),
    position = position_dodge(width = 0.8),
    hjust = -0.15, 
    fontface = "bold",
    size = 3.5
  ) +
  facet_wrap(~ hh_group) +
  scale_x_continuous(limits = c(0, 60)) + 
  scale_fill_manual(
    values = c(
      "Mean Commute Time (mins)" = "#23cbc3", 
      "Mean Rent Burden (%)"     = "#ef2326" 
    )
  ) +
  theme_minimal() +
  labs(
    title = "Commute Time and Rent Burden Profiles of Family Households",
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    x = "Value (Minutes or %)",
    y = NULL,
    fill = "Metric",
    caption = "Note: Estimates are weighted using personal weights (perwt). Work-from-home workers excluded."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 25, b = 5)),
    plot.subtitle = element_text(size = 14, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10)),
    strip.text = element_text(face = "bold", size = 13, color = "black"),
    strip.background = element_rect(fill = "gray95", color = "white"),
    axis.text.y = element_text(face = "bold", size = 11, color = "black"),
    axis.text.x = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),               
    panel.grid.major.x = element_line(color = "gray90"), 
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 11),
    legend.text = element_text(size = 10),
    plot.margin = margin(20, 20, 20, 20)
  )

p_performance_g2

# saving the plot 
ggsave("plots/family_transit_performance_dashboard.png", 
       plot = p_performance_g2, 
       width = 16, height = 8, dpi = 300,
       bg = "white")

# chart 8 (The Rent-Commute Trade-off: Family vs. Mixed Households)
## calculating
commute_fm_mx <- group_two_eda %>%
 filter(wfh == FALSE) %>%
 group_by(hh_group, worker_type, has_dependent_children) %>%
 summarise(
         mean_commute = weighted.mean(commute_time, perwt, na.rm = TRUE),
         mean_burden  = weighted.mean(rent_burden, perwt, na.rm = TRUE),
         n_weighted   = sum(perwt, na.rm = TRUE),
         .groups = "drop"
     )

### preparing for both plot1 & plot2
combined_commute <- group_two_eda %>%
  filter(wfh == FALSE | wfh == "FALSE") %>%
  filter(!is.na(worker_type)) %>%
  group_by(hh_group, worker_type, has_dependent_children) %>%
  dplyr::summarise(
    mean_commute = weighted.mean(commute_time, perwt, na.rm = TRUE),
    mean_burden  = weighted.mean(rent_burden, perwt, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    worker_profile = case_when(
      worker_type == "single_earner" & has_dependent_children == TRUE  ~ "Single Earner\nwith Children",
      worker_type == "single_earner" & has_dependent_children == FALSE ~ "Single Earner\nno Children",
      worker_type == "multiple_earners" & has_dependent_children == TRUE  ~ "Multiple Earners\nwith Children",
      worker_type == "multiple_earners" & has_dependent_children == FALSE ~ "Multiple Earners\nno Children"
    ),
    worker_profile = factor(worker_profile,
                            levels = c(
                              "Multiple Earners\nno Children",
                              "Multiple Earners\nwith Children",
                              "Single Earner\nno Children",
                              "Single Earner\nwith Children"
                            )),
    hh_label = case_when(
      hh_group == "family" ~ "Family",
      hh_group == "mixed"  ~ "Mixed"
    )
  )

### plot 1 
p_tradeoff_burden <- ggplot(combined_commute, 
                            aes(x = worker_profile, y = mean_burden, fill = hh_label)) +
  geom_bar(stat = "identity", 
           position = position_dodge(width = 0.8), 
           width = 0.70, 
           color = "white", 
           linewidth = 0.3) +
  geom_text(
    aes(label = paste0(round(mean_burden, 1), "%")),
    position = position_dodge(width = 0.8),
    vjust = -0.5,
    fontface = "bold", size = 3.5
  ) +
  scale_fill_manual(
    values = c(
      "Family" = "#003580", 
      "Mixed"  = "#66C2E8"  
    ),
    name = "Household Type"
  ) +
  scale_y_continuous(
    labels = function(y) paste0(y, "%"),
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
    title = "Average Rent Burden",
    x = "Household Working Profile",
    y = "Average Rent Burden",
    fill = "Household Type"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14, margin = margin(t = 10, b = 5), hjust = 0), 
    axis.text.x = element_text(face = "bold", size = 9, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

### plot2
p_tradeoff_commute <- ggplot(combined_commute, 
                             aes(x = worker_profile, y = mean_commute, fill = hh_label)) +
  geom_bar(stat = "identity", 
           position = position_dodge(width = 0.8), 
           width = 0.70, 
           color = "white", 
           linewidth = 0.3) +
  geom_text(
    aes(label = paste0(round(mean_commute, 1), " min")),
    position = position_dodge(width = 0.8),
    vjust = -0.5,
    fontface = "bold", size = 3.5
  ) +
  scale_fill_manual(
    values = c(
      "Family" = "#003580", 
      "Mixed"  = "#66C2E8"  
    ),
    name = "Household Type"
  ) +
  scale_y_continuous(
    labels = function(y) paste0(y, " min"),
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
    title = "Average Commute Time",
    x = "Household Working Profile",
    y = "Average Commute Time",
    fill = "Household Type"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14, margin = margin(t = 10, b = 5), hjust = 0), 
    axis.text.x = element_text(face = "bold", size = 9, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

### merging plot1 & plot2 side by side
p_combined_dashboard <- (p_tradeoff_burden | p_tradeoff_commute) + 
  plot_layout(guides = "collect") & 
  theme(
    legend.position = "bottom", 
    legend.title = element_text(face = "bold", size = 11),
    legend.text = element_text(size = 10),
    legend.margin = margin(t = 10, r = 0, b = 10, l = 0)
  )

p_final_dashboard <- p_combined_dashboard + 
  plot_annotation(
    title = "The Rent-Commute Trade-off: Family vs. Mixed Households",
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Population-weighted estimates (PERWT). WFH excluded.",
    theme = theme(
      plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 14, color = "gray30", margin = margin(t = 5, b = 5), hjust = 0.5), 
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)) 
    )
  )

p_final_dashboard

# saving the plot
ggsave("plots/family_mixed_tradeoff_dashboard.png",
       plot = p_final_dashboard,
       width = 16,
       height = 8,
       dpi = 300, bg = "white")

  
