Part 1: pre-eda dataset adjustments
# creating a variable to label income-tier by ACS 5-year within the group 
group_one_eda <- group_one_eda %>%
  group_by(year) %>%
  mutate(
    income_tier_g1 = case_when(
      individual_income <= quantile(individual_income, 0.30) ~ "low_income",
      individual_income <= quantile(individual_income, 0.80) ~ "middle_income",
      TRUE ~ "upper_income"
    )
  ) %>%
  ungroup()

## verify 
group_one_eda %>%
  group_by(income_tier_g1) %>%
  summarise(n = n()) %>%
  mutate(pct = n/sum(n)*100) %>%
  arrange(income_tier_g1)

# saving the dataset 
saveRDS(group_one_eda, "data/group_one_eda_ready.rds")

Part 2: group one eda

# chart 1 (Distribution of Nonfamily Households(Single and Roommate-based))
## calculating 
pct_sh_rm_mx <- group_one_eda %>%
hh_group, wt = perwt) %>%
mutate(prop = n / sum(n))

### preparation 
prop_clean <- pct_sh_rm_mx %>%
  mutate(hh_group = factor(hh_group, 
                           levels = c("single", "roommate", "mixed"),
                           labels = c("Single Household", "Roommate-Only Household", "Mixed (Roommates) Household"))) %>%
  arrange(desc(hh_group)) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2),
    label_x = ifelse(prop < 0.05, 2.65, 2.0),
    label_color = ifelse(prop < 0.05, "gray30", "white")
  )
prop_inside  <- prop_clean %>% filter(prop >= 0.05) 
prop_outside <- prop_clean %>% filter(prop < 0.05)  
prop_outside <- prop_outside %>%
  mutate(label_hjust = 0.5)

### plot
p_independent_share <- ggplot(prop_clean, aes(x = 2, y = prop, fill = hh_group)) +
  # Draw the donut
  geom_bar(stat = "identity", color = "white", linewidth = 1.5) +
  coord_polar(theta = "y", start = 0) +
    geom_segment(
    data = prop_outside,
    aes(x = 2.1, xend = 2.5, y = label_y, yend = label_y),
    color = "gray50",
    linewidth = 0.8,
    inherit.aes = FALSE # Prevent inheriting the main fill aesthetics
  ) +
  geom_text(
    data = prop_inside,
    aes(x = 2.0, y = label_y, label = percent(prop, accuracy = 0.1)),
    color = "white", 
    fontface = "bold", 
    size = 4.5
  ) +
    geom_text(
    data = prop_outside,
    aes(x = 2.65, y = label_y, label = percent(prop, accuracy = 0.1), hjust = label_hjust),
    color = "gray30", 
    fontface = "bold", 
    size = 4.5,
    inherit.aes = FALSE
  ) +
    scale_fill_manual(
    values = c(
      "Single Household" = "#aa1b63",  
      "Roommate-Only Household" = "#0099CC",  
      "Mixed (Roommates) Household"     = "#66C2E8"   
    )
  ) +
    xlim(0.3, 3.0) + 
  theme_void() +
 labs(
    title = "Distribution of Nonfamily Households (Single and Roommate-Based)",
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    fill = "Living Arrangement",
    caption = "Note: Estimates are weighted using personal weights (PERWT)."
  ) +
  guides(fill = guide_legend(nrow = 1, title.position = "top", title.hjust = 0.5)) +
  theme(
    aspect.ratio = 1, # Keeps the donut perfectly round on export
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 40, b = 2)),
    plot.subtitle = element_text(size = 14, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10)),
    plot.caption.position = "plot", 
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 12),
    legend.text = element_text(size = 11),
    legend.margin = margin(t = -10, r = 0, b = 10, l = 0)
  )

p_independent_share

### saving the plot
ggsave("plots/independent_share_pie.png", 
       plot = p_independent_share, 
       width = 13, height = 9, dpi = 300,
       bg = "white")

# chart 2 (Overall Rent Burden Distribution of Nonfamily Households)
## calculating 
overall_group1_burden <- group_one_eda %>%
group_by(range_burden) %>%
     summarise(
         n = n(),
         n_weighted = sum(perwt, na.rm = TRUE)
     ) %>%
     mutate(prop = n_weighted/sum(n_weighted)) %>%
     arrange(desc(prop))

group1_burden_by_group <- group_one_eda %>%
group_by(hh_group) %>%                 
     count(range_burden, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### plot1 
p_overall_burden_g1 <- ggplot(overall_group1_burden,
                            aes(x = 2, y = prop, fill = range_burden)) +
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
    data = extreme_data_g1,
    # Starts just inside the outer edge (2.1) and extends outside (2.5)
    aes(x = 2.1, xend = 2.5, y = label_y, yend = label_y),
    color = "gray50",
    linewidth = 0.8,
    inherit.aes = FALSE 
  ) +
  geom_text(
    data = extreme_data_g1,
    aes(x = 2.64, y = label_y, label = scales::percent(prop, accuracy = 0.1)),
    color = "gray30",
    fontface = "bold",
    size = 4.5,
    hjust = 0.5,        
    inherit.aes = FALSE
  ) +
  scale_fill_manual(
    values = c(
      "affordable"        = "#2D6A4F",
      "burdened"          = "#F4A261",
      "severely_burdened" = "#E76F51",
      "extreme"           = "#8B1A1A"
    ),
    labels = c(
      "affordable"        = "Affordable (<30%)",
      "burdened"          = "Burdened (30-50%)",
      "severely_burdened" = "Severely Burdened (50-70%)",
      "extreme"           = "Extreme (70-100%)"
    ),
    breaks = c("affordable", "burdened", "severely_burdened", "extreme")
  ) +
  xlim(0.3, 3.0) +
  theme_void() +
  labs(
    title = "Overall Rent Burden Distribution", 
    fill = "Rent Burden Category"
  ) +
  guides(fill = guide_legend(nrow = 2, title.position = "top", title.hjust = 0.5)) +
  theme(
    aspect.ratio = 1, # Keeps the donut perfectly round on export!
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 10, b = -20)), 
    legend.position = "bottom", 
    legend.title = element_text(face = "bold", size = 12), 
    legend.text = element_text(size = 11),              
    legend.key.size = unit(1.1, "lines"),                 
    legend.margin = margin(t = -10, r = 0, b = 10, l = 0) 
  )

### plot2
p_rent_burden_by_hh_g1 <- ggplot(plot_data_rb_g1, aes(x = hh_group, y = prop, fill = range_burden)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7, alpha = 0.9) +
  geom_text(
    aes(label = percent(prop, accuracy = 0.1)),
    position = position_dodge(width = 0.8),
    vjust = -0.5, 
    fontface = "bold",
    size = 3.0
  ) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1.05)) + 
    scale_fill_manual(
    values = c(
      "affordable"        = "#2D6A4F",
      "burdened"          = "#F4A261",
      "severely_burdened" = "#E76F51",
      "extreme"           = "#8B1A1A"
    ),
    labels = c(
      "affordable"        = "Affordable (<30%)",
      "burdened"          = "Burdened (30-50%)",
      "severely_burdened" = "Severely Burdened (50-70%)",
      "extreme"           = "Extreme (70-100%)"
    ),
    breaks = c("affordable", "burdened", "severely_burdened", "extreme")
  ) +
  theme_minimal() +
  labs(
    title = "Rent Burden by Living Arrangement", 
    x = NULL,
    y = "Proportion (%)",
    fill = "Rent Burden Category"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 10, b = -10)), 
    axis.text.x = element_text(face = "bold", size = 11, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none" 
  )

### merging two plots side by side
final_g1_housing_dashboard <- p_overall_burden_g1 + p_rent_burden_by_hh_g1 + 
  plot_annotation(
    title = "Overall Rent Burden Distribution of Nonfamily Households", 
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Estimates are weighted using personal weights (PERWT).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10))
    )
  )

final_g1_housing_dashboard

# saving the plot
ggsave("plots/nonfamily_housing_dashboard.png",
       plot = final_g1_housing_dashboard,
       width = 14, height = 7, dpi = 300,
       bg = "white")


# chart 3 (Socioeconomic Profiles of Rent Burden Categories: Nonfamily Households)
## calculating 
burden_range_age_g1 <- group_one_eda %>%
 group_by(range_burden) %>%
 count(age_group, wt = perwt) %>%           
     mutate(prop = n / sum(n))

 burden_range_income_g1 <- group_one_eda %>%
 group_by(range_burden) %>%
 count(income_tier_g1, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### preparing for both plot1 & plot2
plot_data_age <- burden_range_age_g1 %>%
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
    label_y = cumsum_prop - (prop / 2) # Manual mathematical midpoint
  ) %>%
  ungroup()

plot_data_income <- burden_range_income_g1 %>%
  ungroup() %>% 
  complete(range_burden, income_tier_g1, fill = list(n = 0, prop = 0)) %>%
  mutate(
    range_burden = factor(range_burden, 
                          levels = c("affordable", "burdened", "severely_burdened", "extreme"),
                          labels = c("Affordable\n(<30%)", "Burdened\n(30-50%)", "Severely Burdened\n(50-70%)", "Extreme\n(70-100%)")),
    income_tier_g1 = factor(income_tier_g1,
                            levels = c("low_income", "middle_income", "upper_income"),
                            labels = c("Low-Income", "Middle-Income", "Upper-Income"))
  ) %>%
  arrange(range_burden, desc(income_tier_g1)) %>%
  group_by(range_burden) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2) 
  ) %>%
  ungroup()

### defining the gradient color palettes
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

### plot 1
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
plot2 <- ggplot(plot_data_income, aes(x = range_burden, y = prop, fill = income_tier_g1)) +
  geom_col(color = "white", linewidth = 0.6, width = 0.65) +
  geom_text(
    aes(
      y = label_y,
      label = ifelse(prop > 0.01, percent(prop, accuracy = 0.1), "")
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
    title = "Socioeconomic Profiles of Rent Burden Categories: Nonfamily Households",
    subtitle = "Stable Working Nonfamily Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Estimates are weighted using personal weights (PERWT). Income tiers are calculated as relative percentiles (30:50:20) within each respective 5-year ACS period (pooled 2019 or 2024).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)),
      plot.caption.position = "plot"
    )
  )

final_profile_dashboard

# saving the plot
ggsave("plots/rent_burden_socioeconomic_profiles.png",
       plot = final_profile_dashboard,
       width = 14, height = 8, dpi = 300,
       bg = "white")


# chart 4 (Racial and Ethnic Profiles of Rent Burden Categories: Nonfamily Households)
## calculating
burden_range_ethnicity_g1 <- group_one_eda %>%
 group_by(range_burden) %>%
 count(race_ethnicity, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### preparation
plot_data_transit_inc <- transit_income_g1 %>%
  ungroup() %>% 
  complete(transit_group, income_tier_g1, fill = list(n = 0, prop = 0)) %>%
  mutate(
    transit_group = factor(transit_group, 
                           levels = c("private_auto", "public_transit", "active_transit", "other_transit", "wfh"),
                           labels = c("Private Auto", "Public Transit", "Active Transit", "Other", "WFH")),
    # Format and order the income tiers logically
    income_tier_g1 = factor(income_tier_g1,
                            levels = c("low_income", "middle_income", "upper_income"),
                            labels = c("Low-Income", "Middle-Income", "Upper-Income"))
  ) %>%
  arrange(transit_group, desc(income_tier_g1)) %>%
  group_by(transit_group) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2) 
  ) %>%
  ungroup()

### defining the gradient color palettes
income_colors <- c(
  "Low-Income"    = "#0F2519", 
  "Middle-Income" = "#2B5738", 
  "Upper-Income"  = "#598F6C"   
)

### plot
transit_income_plot_contrast_green <- ggplot(plot_data_transit_inc, aes(x = transit_group, y = prop, fill = income_tier_g1)) +
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
    title = "Income Tier Composition of Transit Modes: Nonfamily Households",
    subtitle = "Stable Working Nonfamily Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
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

transit_income_plot_contrast_green

### saving the plot
ggsave("plots/transit_mode_income_profile_high_contrast_green.png",
       plot = transit_income_plot_contrast_green,
       width = 11, height = 7, dpi = 300,
       bg = "white")


# chart 5 (Overall Transit Distribution and Commuter Profile: Nonfamily Households)
## calculating
prop_group1_trans <- group_one_eda %>%
  count(transit_group, wt = perwt) %>%           
  mutate(prop = n / sum(n))

prop_group1_trans_hh <- group_one_eda %>%
     group_by(hh_group) %>%                 
     count(transit_group, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### preparation for both plot1 & plot2
prop_clean <- prop_group1_trans %>%
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

plot_data_b <- prop_group1_trans_hh %>%
  mutate(
    transit_group = factor(transit_group, 
                           levels = c("private_auto", "public_transit", "active_transit", "other_transit", "wfh"),
                           labels = c("Private Auto", "Public Transit", "Active Transit", "Other", "WFH")),
    hh_group = factor(hh_group, 
                      levels = c("roommate", "mixed", "single"),
                      labels = c("Roommate-Only (Multi-Person)", "Mixed (Multi-Person)", "Single Household"))
  )

### defining color palette
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

### merging both plot1 & plot2 side by side
final_transit_dashboard <- plot1 + plot2 + 
  plot_layout(widths = c(1, 1)) + 
  plot_annotation(
    title = "Overall Transit Distribution and Commuter Profile: Nonfamily Households",
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Estimates are weighted using personal weights (perwt).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 20, hjust = 0.5, margin = margin(t = 20, b = 2)), 
      plot.subtitle = element_text(size = 14, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10))
    )
  )

final_transit_dashboard

### saving the plot
ggsave("plots/transit_performance_dashboard.png",
       plot = final_transit_dashboard,
       width = 16, height = 8, dpi = 300,
       bg = "white")


# chart 6 (Income Tier Composition of Transit Modes: Nonfamily Households)
## calculating 
transit_income_g1 <- group_one_eda %>%
     group_by(transit_group) %>%
     count(income_tier_g1, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### preparation
plot_data_transit_inc <- transit_income_g1 %>%
  ungroup() %>% 
  complete(transit_group, income_tier_g1, fill = list(n = 0, prop = 0)) %>%
  mutate(
    transit_group = factor(transit_group, 
                           levels = c("private_auto", "public_transit", "active_transit", "other_transit", "wfh"),
                           labels = c("Private Auto", "Public Transit", "Active Transit", "Other", "WFH")),
    income_tier_g1 = factor(income_tier_g1,
                            levels = c("low_income", "middle_income", "upper_income"),
                            labels = c("Low-Income", "Middle-Income", "Upper-Income"))
  ) %>%
  arrange(transit_group, desc(income_tier_g1)) %>%
  group_by(transit_group) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2) 
  ) %>%
  ungroup()

### defining color palette
income_colors <- c(
  "Low-Income"    = "#0F2519",  
  "Middle-Income" = "#2B5738",  
  "Upper-Income"  = "#598F6C"   
)
 
### plot 
transit_income_plot_contrast_green <- ggplot(plot_data_transit_inc, aes(x = transit_group, y = prop, fill = income_tier_g1)) +
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
    title = "Income Tier Composition of Transit Modes: Nonfamily Households",
    subtitle = "Stable Working Nonfamily Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
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

transit_income_plot_contrast_green

### saving the plot
ggsave("plots/transit_mode_income_profile_high_contrast_green.png",
       plot = transit_income_plot_contrast_green,
       width = 11, height = 7, dpi = 300,
       bg = "white")


# chart 7 (Mean Commute Time & Rent Burden Profiles for Nonfamily Households)
## calculating
prop_commute_rent_group1 <- group_one_eda %>%
     filter(wfh == FALSE | wfh == "FALSE") %>%     
     group_by(hh_group) %>%
     summarise(
         mean_commute = round(weighted.mean(commute_time, perwt, na.rm = TRUE), 1),
         mean_rent_burden = round(weighted.mean(rent_burden, perwt, na.rm = TRUE), 1),
         n_commuters = n(),
         .groups = "drop"
              )

mean_commute_rent_group1 <- group_one_eda %>%
  filter(transit_group != "wfh") %>% 
  group_by(transit_group,hh_group) %>%
  summarize(
    mean_commute = round(weighted.mean(commute_time, perwt, na.rm = TRUE), 1), 
    mean_burden = round(weighted.mean(rent_burden, perwt, na.rm = TRUE), 1), 
    .groups = "drop"
  )

 ### preparing for both plot1 & plot2
plot_data_hh <- prop_commute_rent_group1 %>%
  pivot_longer(
    cols = c(mean_commute, mean_rent_burden),
    names_to = "metric",
    values_to = "value"
  ) %>%
  mutate(
    metric = case_when(
      metric == "mean_commute"      ~ "Mean Commute Time (mins)",
      metric == "mean_rent_burden"  ~ "Mean Rent Burden (%)"
    ),
    label_text = ifelse(metric == "Mean Commute Time (mins)", 
                        paste0(value, " min"), 
                        paste0(value, "%")),
    hh_group = factor(hh_group,
                      levels = c("mixed", "roommate", "single"),
                      labels = c("Mixed (Multi-Person)", 
                                 "Roommate (Multi-Person)", 
                                 "Single Household"))
  )


plot_data_transit <- mean_commute_rent_group1 %>%
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
                      levels = c("single", "roommate", "mixed"),
                      labels = c("Single Household", "Roommate (Multi-Person)", "Mixed (Multi-Person)"))
  )

### defining the color 
metric_colors <- c(
   "Mean Commute Time (mins)" = "#23cbc3", 
   "Mean Rent Burden (%)"     = "#ef2326"  
)

### plot1
plot1 <- ggplot(plot_data_hh, aes(x = value, y = hh_group, fill = metric)) +
  geom_col(width = 0.75, position = position_dodge(width = 0.75)) +
  geom_text(aes(label = label_text),
            position = position_dodge(width = 0.75),
            hjust = -0.15,
            vjust = 0.5,      
            fontface = "bold",
            size = 3.2) +      
  scale_fill_manual(values = metric_colors) +
  scale_x_continuous(limits = c(0, 45)) + 
  theme_minimal() +
  labs(
    title = "By Household Type", 
    x = "Value (Minutes or %)",
    y = NULL,
    fill = "Metric"
  ) +
  theme(
    # Pulls the title down closer to the bars!
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 10, b = 15)),
    axis.text.y = element_text(face = "bold", size = 11, color = "black"),
    axis.text.x = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

### plot2
plot2 <- ggplot(plot_data_transit, aes(x = value, y = transit_group, fill = metric)) +
  geom_col(width = 0.75, position = position_dodge(width = 0.75)) +
  geom_text(aes(label = label_text),
            position = position_dodge(width = 0.75),
            hjust = -0.15,
            vjust = 0.5,       
            fontface = "bold",
            size = 3.2) +     
  scale_fill_manual(values = metric_colors) +
  scale_x_continuous(limits = c(0, 60)) + 
  facet_wrap(~ hh_group, ncol = 1) + 
  theme_minimal() +
  labs(
    title = "By Transit Mode & Household Type", 
    x = "Value (Minutes or %)",
    y = NULL,
    fill = "Metric"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 10, b = 15)),
    strip.text = element_text(face = "bold", size = 11, color = "black"),
    strip.background = element_rect(fill = "gray95", color = "white"),
    axis.text.y = element_text(face = "bold", size = 11, color = "black"),
    axis.text.x = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(color = "gray90")
  )

### meriging plot1 & plot2 side by side
final_performance_dashboard <- (plot1 + plot2) + 
  plot_layout(widths = c(1, 1.2), guides = "collect") & 
  theme(
    legend.position = "bottom",
    legend.title = element_blank(), 
    legend.text = element_text(size = 11)
  )

final_performance_dashboard <- final_performance_dashboard + 
  plot_annotation(
    title = "Mean Commute Time & Rent Burden Profiles for Nonfamily Households",
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Population estimates, rent averages, and commute times are weighted using personal weights (perwt). WFH excluded.",
    theme = theme(
      plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 14, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10))
    )
  )

final_performance_dashboard

# saving the plot
ggsave("plots/nonfamily_transit_hh_performance_dashboard.png", 
       plot = final_performance_dashboard, 
       width = 16, height = 8, dpi = 300,
       bg = "white")
