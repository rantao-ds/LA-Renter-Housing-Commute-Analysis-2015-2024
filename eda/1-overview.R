Part 1: pre-eda adjustments

# merging the datasets - full dataset with all the type of household
full_final <- bind_rows(mh_rm, mh_fm, mh_mx,sh)

table(full_final$hh_group)


# creating a variable to label four age groups
full_final <- full_final %>%
mutate(
    age_group = cut(
      age,
      breaks = c(24, 34, 44, 54, 64),
      labels = c("24-34", "35-44", "45-54", "55-64"),
      include.lowest = TRUE
    )
  )

## verify 
table(full_final$age_group)

# creating a variable to combine hispanic and race with new labeling
full_final <- full_final %>%
  mutate(
    race_ethnicity = case_when(
      hispanic != "not_hispanic" ~ "hispanic",
      hispanic == "not_hispanic" & race == "white" ~ "nh_white",
      hispanic == "not_hispanic" & race == "black_african_american" ~ "nh_black",
      hispanic == "not_hispanic" & race %in% c("chinese", "japanese",
                                                "other_asian_pacific_islander") ~ "nh_asian",
      hispanic == "not_hispanic" & race == "american_indian_alaska_native" ~ "nh_native",
      hispanic == "not_hispanic" & race %in% c("other_race",
                                                "two_major_races",
                                                "three_plus_major_races") ~ "nh_other"
    )
  )

## verify 
table(full_final$race_ethnicity)

## saving the dataset
saveRDS(full_final, "data/full_final_eda_ready.rds")

# spliting the full dataset into three groups 

## group 1 containing sh & mh_rm & mh_mx(lv_status == "RM")
mx_roommates <- mh_mx %>% 
filter(lv_status == "RM")

group_one_eda <- bind_rows(sh, mh_rm, mx_roommates)

### verify
table(group_one_eda$hh_group)

#### saving the dataset
saveRDS(group_one_eda, "data/group_one_eda_ready.rds")


## group 2 containing mh_fm & mh_mx(lv_status == "FM")
mx_families <- mh_mx %>% 
filter(lv_status == "FM")

group_two_eda <- bind_rows(mh_fm, mx_families)

### verify
table(group_two_eda$hh_group)

#### saving the dataset
saveRDS(group_two_eda, "data/group_two_eda_ready.rds")


## group 3 containing only wfh woker across all the household groups
group_three_eda <- full_final %>%
 filter(wfh == TRUE)

### verify
table(group_three_eda$wfh)

#### saving the dataset
saveRDS(group_three_eda, "data/group_three_eda_ready.rds")

Part 2: eda - overview

# chart 1 (Distribution of Household Types)
## caclulating 
prop_full_household <- full_final %>%
 count(hh_group, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### plot
library(ggplot2)
library(scales)

p_household_dist <- ggplot(prop_full_household, aes(x = 2, y = prop, fill = hh_group)) +
    geom_bar(stat = "identity", color = "white", linewidth = 1.5) +
    coord_polar(theta = "y", start = 0) +
    scale_fill_manual(
        values = c(
          "family"   = "#003580",  
          "single"   = "#aa1b63",  
          "roommate" = "#0099CC",  
          "mixed"    = "#66C2E8"  
        ),
        labels = c(
          "family"   = "Family-Only (Multi-Person)", 
          "single"   = "Single Household",
          "roommate" = "Roommate-Only (Multi-Person)", 
          "mixed"    = "Mixed (Multi-Person)"
        ),
        breaks = c("family", "single", "roommate", "mixed") 
    ) +
    geom_text(
        aes(label = scales::percent(prop, accuracy = 0.1)),
        position = position_stack(vjust = 0.5),
        color = "white",
        size = 5.5,
        fontface = "bold"
    ) +
    xlim(0.7, 2.5) +
    theme_void() +
    labs(
        title = "Distribution of Household Types",
        subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
        fill = "Household Group"
    ) +
    theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 18,
                                  margin = margin(t = 40, b = 2)),
        plot.subtitle = element_text(hjust = 0.5, size = 14, color = "gray30",
                                     margin = margin(b = 10)),
        legend.position = "right",
        legend.title = element_text(face = "bold", size = 12),
        legend.text = element_text(size = 11)
    )

p_household_dist

ggsave("plots/overall_prop_type_household.png",
       plot = p_household_dist,
       width = 11,
       height = 6,
       dpi = 300, bg = "white")


# chart 2 (Overall Housing Affordability & Living Arrangement Distribution)
## calculating
overall_rent_burden <- full_final %>%
     group_by(range_burden) %>%
     summarise(
         n = n(),
         n_weighted = sum(perwt, na.rm = TRUE)
     ) %>%
     mutate(prop = n_weighted/sum(n_weighted)) %>%
     arrange(desc(prop))

rent_burden_household <- full_final %>%
 group_by(hh_group) %>%                 
     count(range_burden, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### plot
library(dplyr)
library(ggplot2)
library(scales)
library(patchwork)

#### prepartion for both plot1 & plot2
overall_rent_burden <- overall_rent_burden %>%
  arrange(desc(range_burden)) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2)
  )

extreme_data <- overall_rent_burden %>%
  filter(range_burden == "extreme")

plot_data_rb <- rent_burden_household %>%
  mutate(
    hh_group = factor(hh_group, 
                      levels = c("family", "roommate", "mixed", "single"),
                      labels = c("Family", "Roommate", "Mixed", "Single")),
    range_burden = factor(range_burden, 
                          levels = c("affordable", "burdened", "severely_burdened", "extreme"))
  )

#### plot1 
p_overall_burden <- ggplot(overall_rent_burden,
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
    data = extreme_data,
    aes(x = 2.1, xend = 2.5, y = label_y, yend = label_y),
    color = "gray50",
    linewidth = 0.8,
    inherit.aes = FALSE 
  ) +
  geom_text(
    data = extreme_data,
    aes(x = 2.6, y = label_y, label = scales::percent(prop, accuracy = 0.1)),
    color = "gray30",
    fontface = "bold",
    size = 4.5,
    hjust = 0,          
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
    guides(fill = guide_legend(nrow = 2, title.position = "top", title.hjust = 0.5)) +
  xlim(0.3, 3.0) +
  theme_void() +
  labs(
    title = "Overall Rent Burden Distribution", 
    fill = "Rent Burden Category"
  ) +
  theme(
    aspect.ratio = 1, 
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(b = 20)),
    legend.position = "bottom", 
    legend.title = element_text(face = "bold", size = 12), 
    legend.text = element_text(size = 11),              
    legend.key.size = unit(1.1, "lines"),                 
    # Slight negative margin to hug it perfectly under the donut
    legend.margin = margin(t = -10, r = 0, b = 10, l = 0) 
  )

#### plot2
p_rent_burden_by_hh <- ggplot(plot_data_rb, aes(x = hh_group, y = prop, fill = range_burden)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7, alpha = 0.9) +
  
  geom_text(
    aes(label = percent(prop, accuracy = 0.1)),
    position = position_dodge(width = 0.8),
    vjust = -0.5, 
    fontface = "bold",
    size = 3.0
  ) +
  
  scale_y_continuous(labels = percent_format(), limits = c(0, 0.95)) + 
  
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
    title = "Rent Burden by Household Type", 
    x = NULL,
    y = "Proportion (%)",
    fill = "Rent Burden Category"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(b = 20)),
    axis.text.x = element_text(face = "bold", size = 11, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none"
  )

#### merging two plots side by sisde
final_housing_dashboard <- p_overall_burden + p_rent_burden_by_hh + 
  plot_annotation(
    title = "Overall Housing Affordability & Living Arrangement Distribution",
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Estimates are weighted using personal weights (PERWT).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10))
    )
  )

final_housing_dashboard

ggsave("plots/housing_burden_dashboard.png",
       plot = final_housing_dashboard,
       width = 14, height = 7, dpi = 300,
       bg = "white")


# chart 3 (Monthly Rent by Household Type (boxplot))

library(ggplot2)
library(scales)

full_final %>%
  mutate(hh_group = factor(hh_group,
                           levels = c("single", "roommate", "family", "mixed"),
                           labels = c("Single Household", "Roommate-Only (Multi-Person)", "Family-Only (Multi-Person)", "Mixed (Multi-Person)"))) %>%
  ggplot(aes(x = hh_group, y = rent, fill = hh_group, weight = perwt)) +
  geom_boxplot(width = 0.5, alpha = 0.7,
               outlier.colour = "gray50",
               outlier.alpha = 0.5, outlier.size = 1.5) +
  scale_fill_manual(values = c(
    "Single Household"             = "#aa1b63",  
    "Roommate-Only (Multi-Person)" = "#0099CC",  
    "Family-Only (Multi-Person)"   = "#003580",  
    "Mixed (Multi-Person)"         = "#66C2E8"   
  )) +
  scale_y_continuous(labels = scales::dollar_format()) +
  coord_cartesian(ylim = c(0, 5000)) +
  labs(title = "Monthly Rent by Household Type",
       subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
       caption = "Note: Population-weighted estimates (PERWT).",
       x = NULL,
       y = "Monthly Rent (USD)") +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 18,
                              margin = margin(t = 25, b = 5), hjust = 0),
    plot.subtitle = element_text(size = 14, color = "gray30",
                                 margin = margin(b = 20), hjust = 0),
    
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10)),
    axis.text.x = element_text(face = "bold", size = 12, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none" 
  )

  ggsave("plots/boxplot_rent_by_household_perweigth.png",
       width = 11,
       height = 6,
       dpi = 300,
       bg = "white")

# chart 4 (Overall Transit Distribution and Commuter Profile by Household Type)
## calculating 
prop_full_trans <- full_final %>%
  count(transit_group, wt = perwt) %>%           
  mutate(prop = n / sum(n))

prop_trans_household <- full_final %>%
     group_by(hh_group) %>%                 
     count(transit_group, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### plot

library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(patchwork)

#### define the color palette
transit_colors <- c(
  "Private Auto"   = "#5199eb",  
  "Public Transit" = "#bd2f2f",  
  "Active Transit" = "#539c75",  
  "Other"          = "#d7bc6b",  
  "WFH"            = "#624696"   
)

#### prepareing for both plot 1 & plot2
prop_clean <- prop_full_trans %>%
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


plot_data_b <- prop_trans_household %>%
  mutate(
    transit_group = factor(transit_group, 
                           levels = c("private_auto", "public_transit", "active_transit", "other_transit", "wfh"),
                           labels = c("Private Auto", "Public Transit", "Active Transit", "Other", "WFH")),
    hh_group = factor(hh_group, 
                      levels = c("family", "roommate", "mixed", "single"),
                      labels = c("Family", "Roommate", "Mixed", "Single"))
  )

#### plot 1 
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
  labs(
    title = "Overall Transit Mode Share", 
    fill = "Transit Mode"
  ) +
  guides(fill = guide_legend(nrow = 2, title.position = "top", title.hjust = 0.5)) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5, 
                              margin = margin(t = 10, b = -20)),
    legend.position = "bottom", 
    legend.title = element_text(face = "bold", size = 10), 
    legend.text = element_text(size = 9),              
    legend.key.size = unit(1.1, "lines"),                 
    legend.margin = margin(t = -10, r = 0, b = 10, l = 0) 
  )

#### plot 2
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
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5, 
                              margin = margin(t = 10, b = -10)),
    axis.text.x = element_text(face = "bold", size = 11, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none" 
  )

#### merging two plots side by sisde
final_transit_dashboard <- plot1 + plot2 + 
  plot_layout(widths = c(1, 1)) + 
  plot_annotation(
    title = "Overall Transit Distribution and Commuter Profile by Household Type", 
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    # Caption updated to show that WFH is now included
    caption = "Note: Estimates are weighted using personal weights (perwt).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 20, hjust = 0.5, margin = margin(t = 20, b = 2)), 
      plot.subtitle = element_text(size = 14, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10))
    )
  )

final_transit_dashboard

ggsave("plots/transit_performance_dashboard.png",
       plot = final_transit_dashboard,
       width = 16, height = 8, dpi = 300,
       bg = "white")


# chart 5 (Mean Commute Time & Rent Burden Profiles)
## calculating
prop_commute_rent_weighted <- full_final %>%
     filter(wfh == FALSE | wfh == "FALSE") %>%     
     group_by(hh_group) %>%
     summarise(
         mean_commute = round(weighted.mean(commute_time, perwt, na.rm = TRUE), 1),
         mean_rent_burden = round(weighted.mean(rent_burden, perwt, na.rm = TRUE), 1),
         n_commuters = n(),
         .groups = "drop"
              )

mean_commute_rent_trans <- full_final %>%
  filter(transit_group != "wfh") %>% 
  group_by(transit_group) %>%
  summarize(
    mean_commute = round(weighted.mean(commute_time, perwt, na.rm = TRUE), 1), 
    mean_burden = round(weighted.mean(rent_burden, perwt, na.rm = TRUE), 1), 
    .groups = "drop"
  )

### plot
#### define the color 
metric_colors <- c(
   "Mean Commute Time (mins)" = "#23cbc3", 
   "Mean Rent Burden (%)"     = "#ef2326" )

#### preparing for both plot 1 & plot 2
plot_data_hh <- prop_commute_rent_weighted %>%
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
                      levels = c("mixed", "roommate", "family", "single"),
                      labels = c("Mixed (Multi-Person)", 
                                 "Roommate-Only (Multi-Person)", 
                                 "Family-Only (Multi-Person)", 
                                 "Single Household"))
  )

plot_data_transit <- mean_commute_rent_trans %>%
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
                           labels = c("Private Auto", "Public Transit", "Active Transit", "Other"))
  )

#### plot 1 
plot1 <- ggplot(plot_data_hh, aes(x = value, y = hh_group, fill = metric)) +
  geom_col(width = 0.75, position = position_dodge(width = 0.75)) +
  geom_text(aes(label = label_text),
            position = position_dodge(width = 0.75),
            hjust = -0.15,
            fontface = "bold",
            size = 3.5) +
  scale_fill_manual(values = metric_colors) +
  scale_x_continuous(limits = c(0, 45)) + 
  theme_minimal() +
  labs(
    title = "By Household Type", # Subplot title
    x = "Value (Minutes or %)",
    y = NULL,
    fill = "Metric"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(b = 15)),
    axis.text.y = element_text(face = "bold", size = 11, color = "black"),
    axis.text.x = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

#### plot 2
plot2 <- ggplot(plot_data_transit, aes(x = value, y = transit_group, fill = metric)) +
  geom_col(width = 0.75, position = position_dodge(width = 0.75)) +
  
  # Adds exact formatted labels (e.g., '49.6 min')
  geom_text(aes(label = label_text),
            position = position_dodge(width = 0.75),
            hjust = -0.15,
            fontface = "bold",
            size = 3.5) +
  
  scale_fill_manual(values = metric_colors) +
  scale_x_continuous(limits = c(0, 60)) + 
  theme_minimal() +
  labs(
    title = "By Transit Mode", # Subplot title
    x = "Value (Minutes or %)",
    y = NULL,
    fill = "Metric"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(b = 15)),
    axis.text.y = element_text(face = "bold", size = 11, color = "black"),
    axis.text.x = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

#### merging two plots side by sisde
final_performance_dashboard <- plot1 + plot2 + 
  plot_layout(guides = "collect") & 
  theme(
    legend.position = "bottom",
    legend.title = element_blank(), 
    legend.text = element_text(size = 11)
  )

final_performance_dashboard <- final_performance_dashboard + 
  plot_annotation(
    title = "Mean Commute Time & Rent Burden Profiles",
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Population estimates, rent averages, and commute times are weighted using personal weights (PERWT). WFH excluded.",
    theme = theme(
      plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 14, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10))
    )
  )

final_performance_dashboard

ggsave("plots/transit_hh_performance_dashboard.png",
       plot = final_performance_dashboard,
       width = 14, height = 7, dpi = 300,
       bg = "white")
