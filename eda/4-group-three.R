# chart 1 (Work-from-Home(WFH) Population Trends Over 10 years)
## calculating 
wfh_pop_hh_trends <- group_three_eda %>%
  filter(wfh == TRUE) %>%
  group_by(multyear, hh_group) %>%
  summarise(
    wfh_pop = sum(perwt, na.rm = TRUE),
    .groups = "drop"
  )

### preparation 
plot_data <- wfh_pop_hh_trends %>%
  mutate(
    hh_group = factor(hh_group, 
                      levels = c("family", "single", "roommate", "mixed"),
                      labels = c("Family", "Single", "Roommate", "Mixed"))
  )

### defining the color palette
trend_colors <- c(
  "Family"   = "#003580",  
  "Single"   = "#aa1b63",  
  "Roommate" = "#0099CC",  
  "Mixed"    = "#66C2E8"   
)

### plot
pop_plot <- ggplot(plot_data, aes(x = multyear, y = wfh_pop, color = hh_group, group = hh_group)) +
  theme_minimal(base_family = "sans") +
  geom_vline(xintercept = 2020, linetype = "dotted", color = "gray50", linewidth = 0.8) +
  COVID-19 text annotation (positioned cleanly in the gap at y = 22,000)
  annotate("text", x = 2020.1, y = 22000, label = "COVID-19", 
           color = "gray40", size = 3.5, hjust = 0, fontface = "plain") +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_x_continuous(breaks = 2015:2024, limits = c(2015, 2024)) +
  scale_y_continuous(
    labels = scales::label_comma(),
    limits = c(0, 36000),
    breaks = seq(0, 35000, by = 5000)
  ) +
  scale_color_manual(values = trend_colors) +
  labs(
    title = "Work-from-Home (WFH) Population Trends Over 10 Years",
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    x = "Year",
    y = "Estimated WFH Population",
    color = "Household Type",
    caption = "Note: Estimates are weighted using personal weights (PERWT)."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 16, color = "black", hjust = 0, margin = margin(t = 15, b = 5)),
    plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0, margin = margin(b = 20)),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E5E5E5", linewidth = 0.5),
    axis.title.x = element_text(size = 11, color = "gray30", margin = margin(t = 10)),
    axis.title.y = element_text(size = 11, color = "gray30", margin = margin(r = 10)),
    axis.text.x = element_text(face = "bold", size = 11, color = "black"),
    axis.text.y = element_text(size = 10, color = "gray40"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 11, color = "black"),
    legend.text = element_text(size = 10, color = "gray20"),
    legend.key = element_blank(),
    legend.margin = margin(t = 10, b = 10),
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)),
    plot.caption.position = "plot"
  )

pop_plot

# saving the plot
ggsave("plots/wfh_population_trends_10yr.png",
       plot = pop_plot,
       width = 14, height = 8, dpi = 300,
       bg = "white")


# chart 2 (Work-from-Home(WFH) & Living Arrangement Distribution)
## calculating
wfh_trend <- group_three_eda %>%
 count(hh_group, wt = perwt) %>%           
     mutate(prop = n / sum(n))

wfh_trend_acs <- group_three_eda %>%
group_by(year) %>%
 count(hh_group, wt = perwt) %>%           
     mutate(prop = n / sum(n))

### preparing for both plot1 & plot2
prop_clean_donut <- wfh_trend %>%
  mutate(hh_group = factor(hh_group, 
                           levels = c("family", "roommate", "mixed", "single"),
                           labels = c("Family-Only (Multi-Person)", "Roommate-Only (Multi-Person)", "Mixed (Multi-Person)", "Single Household"))) %>%
  arrange(desc(hh_group)) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2),
    label_x = ifelse(prop < 0.05, 2.70, 2.0),
    label_color = ifelse(prop < 0.05, "gray30", "white")
  )

prop_inside_donut  <- prop_clean_donut %>% filter(prop >= 0.05) 

prop_outside_donut <- prop_clean_donut %>% filter(prop < 0.05)  

prop_outside_donut <- prop_outside_donut %>%
  mutate(
    label_hjust = 0.5 
  )


plot_data_bar <- wfh_trend_acs %>%
  mutate(
    year = factor(year, 
                  levels = c(2019, 2024), 
                  labels = c("ACS 2019 (2015-2019)", "ACS 2024 (2020-2024)")),
        hh_group = factor(hh_group, 
                      levels = c("family", "roommate", "mixed", "single"),
                      labels = c("Family-Only (Multi-Person)", "Roommate-Only (Multi-Person)", "Mixed (Multi-Person)", "Single Household"))
  )

### plot1
plot1 <- ggplot(prop_clean_donut, aes(x = 2, y = prop, fill = hh_group)) +
  geom_bar(stat = "identity", color = "white", linewidth = 1.0) +
  coord_polar(theta = "y", start = 0) +
  geom_segment(
    data = prop_outside_donut,
    aes(x = 2.1, xend = 2.5, y = label_y, yend = label_y),
    color = "gray50",
    linewidth = 0.8,
    inherit.aes = FALSE
  ) +
  geom_text(
    data = prop_inside_donut,
    aes(x = 2.0, y = label_y, label = percent(prop, accuracy = 0.1)),
    color = "white", 
    fontface = "bold", 
    size = 4.0
  ) +
  geom_text(
    data = prop_outside_donut,
    aes(x = 2.70, y = label_y, label = percent(prop, accuracy = 0.1)),
    color = "gray30", 
    fontface = "bold", 
    size = 4.5,
    hjust = 0.5,        
    inherit.aes = FALSE
  ) +  
  scale_fill_manual(values = hh_colors) +
  xlim(0.7, 3.0) + 
  theme_void() +
  labs(title = "Overall WFH Household Share", 
       fill = "Household Group") +
  guides(fill = guide_legend(nrow = 2, title.position = "top", title.hjust = 0.5)) +
  theme(
    aspect.ratio = 1, 
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(t = 10, b = -20)), 
    legend.position = "bottom", 
    legend.title = element_text(face = "bold", size = 10), 
    legend.text = element_text(size = 9),              
    legend.key.size = unit(1.1, "lines"),                 
    legend.margin = margin(t = -10, r = 0, b = 10, l = 0) 
  )

### plot2
plot2 <- ggplot(plot_data_bar, aes(x = year, y = prop, fill = hh_group)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7, alpha = 0.9) +
  geom_text(
    aes(label = percent(prop, accuracy = 0.1)),
    position = position_dodge(width = 0.8),
    vjust = -0.5, 
    fontface = "bold",
    size = 2.8 
  ) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 0.85)) + 
  scale_fill_manual(values = hh_colors) +
  theme_minimal() +
  labs(
    title = "Before & Post COVID-19", 
    x = NULL,
    y = "Proportion (%)",
    fill = "Household Group"
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
final_wfh_dashboard <- plot1 + plot2 + 
  plot_layout(widths = c(1, 1)) + 
  plot_annotation(
    title = "Work-from-Home (WFH) & Living Arrangement Distribution", 
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)", 
    caption = "Note: Estimates are weighted using personal weights (PERWT).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10)),
      plot.caption.position = "plot" 
    )
  )

final_wfh_dashboard

### saving the plot
ggsave("plots/wfh_dashboard.png",
       plot = final_wfh_dashboard,
       width = 16, height = 9, dpi = 300,
       bg = "white")


# chart 3 (Work-from-Home(WFH) Rent Burden Trends Over 10 Years)
## calculating 
wfh_burden_hh_trends <- group_three_eda %>%
  # 1. Filter safely
  filter(wfh == TRUE) %>%
  group_by(multyear, hh_group) %>%
  summarise(
    avg_rent_burden = weighted.mean(rent_burden, perwt, na.rm = TRUE),
    .groups = "drop"
  )

### preparation
plot_data <- wfh_burden_hh_trends %>%
  mutate(
    hh_group = factor(hh_group, 
                      levels = c("family", "single", "roommate", "mixed"),
                      labels = c("Family", "Single", "Roommate", "Mixed"))
  )

### defining the color palette
trend_colors <- c(
  "Family"   = "#003580",  
  "Single"   = "#aa1b63",  
  "Roommate" = "#0099CC",  
  "Mixed"    = "#66C2E8"   
)


### plot
trend_plot <- ggplot(plot_data, aes(x = multyear, y = avg_rent_burden, color = hh_group, group = hh_group)) +
  theme_minimal(base_family = "sans") +
  geom_vline(xintercept = 2020, linetype = "dotted", color = "gray50", linewidth = 0.8) +
  annotate("text", x = 2020.1, y = 17, label = "COVID-19", 
           color = "gray40", size = 3.5, hjust = 0, fontface = "plain") +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_x_continuous(breaks = 2015:2024, limits = c(2015, 2024)) +
  scale_y_continuous(
    labels = function(x) paste0(x, "%"),
    limits = c(12, 42),
    breaks = seq(15, 40, by = 5)
  ) +
  scale_color_manual(values = trend_colors) +
  labs(
    title = "Work-from-Home (WFH) Rent Burden Trends Over 10 Years (by Household Type)",
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    x = "Year",
    y = "Mean Rent Burden (%)",
    color = "Household Type",
    caption = "Note: Population estimates and rent burden averages are weighted by person weight (PERWT)."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 16, color = "black", hjust = 0, margin = margin(t = 15, b = 5)),
    plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0, margin = margin(b = 20)),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E5E5E5", linewidth = 0.5),
    axis.title.x = element_text(size = 11, color = "gray30", margin = margin(t = 10)),
    axis.title.y = element_text(size = 11, color = "gray30", margin = margin(r = 10)),
    axis.text.x = element_text(face = "bold", size = 11, color = "black"),
    axis.text.y = element_text(size = 10, color = "gray40"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 11, color = "black"),
    legend.text = element_text(size = 10, color = "gray20"),
    legend.key = element_blank(),
    legend.margin = margin(t = 10, b = 10),
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)),
    plot.caption.position = "plot"
  )

trend_plot

### saving the plot
ggsave("plots/wfh_rent_burden_trends_corrected.png",
       plot = trend_plot,
       width = 14, height = 8, dpi = 300,
       bg = "white")


# chart 4 (Work-from-Home(WFH) Housing Affordability & Living Arrangement Distribution)
## calculating
overall_wfh_burden <- group_three_eda %>%
group_by(range_burden) %>%
     summarise(
         n = n(),
         n_weighted = sum(perwt, na.rm = TRUE)
     ) %>%
     mutate(prop = n_weighted/sum(n_weighted)) %>%
     arrange(desc(prop))

wfh_burden_hh <- group_three_eda %>%
filter(wfh == TRUE) %>%
  group_by(hh_group, range_burden) %>%
  summarise(
    n_weighted = sum(perwt, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(hh_group) %>%
  mutate(prop = n_weighted/sum(n_weighted)) %>%
  ungroup()

### preparing for both plot1 & plot2
overall_wfh_burden <- full_final %>%
  filter(wfh == TRUE | wfh == "TRUE") %>% 
  group_by(range_burden) %>%
  summarise(
    n = n(),
    n_weighted = sum(perwt, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(prop = n_weighted / sum(n_weighted)) %>%
  arrange(desc(prop))

wfh_burden_hh <- full_final %>%
  filter(wfh == TRUE | wfh == "TRUE") %>% 
  group_by(hh_group, range_burden) %>%
  summarise(
    n_weighted = sum(perwt, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(hh_group) %>%
  mutate(prop = n_weighted / sum(n_weighted)) %>%
  ungroup()

prop_clean_donut <- overall_wfh_burden %>%
  arrange(desc(range_burden)) %>%
  mutate(
    cumsum_prop = cumsum(prop),
    label_y = cumsum_prop - (prop / 2)
  )
extreme_data_g1 <- prop_clean_donut %>%
  filter(range_burden == "extreme")


plot_data_bar <- wfh_burden_hh %>%
  mutate(
    hh_group = factor(hh_group, 
                      levels = c("family", "roommate", "mixed", "single"),
                      labels = c("Family", "Roommate", "Mixed", "Single")),
    range_burden = factor(range_burden, 
                          levels = c("affordable", "burdened", "severely_burdened", "extreme"))
  )

### defining the color palette
burden_colors <- c(
  "affordable"        = "#2D6A4F",  
  "burdened"          = "#F4A261",  
  "severely_burdened" = "#E76F51",  
  "extreme"           = "#8B1A1A"   
)

### plot1
plot1 <- ggplot(prop_clean_donut, aes(x = 2, y = prop, fill = range_burden)) +
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
    aes(x = 2.1, xend = 2.5, y = label_y, yend = label_y),
    color = "gray50",
    linewidth = 0.8,
    inherit.aes = FALSE 
  ) +
  geom_text(
    data = extreme_data_g1,
    aes(x = 2.65, y = label_y, label = scales::percent(prop, accuracy = 0.1)),
    color = "gray30", 
    fontface = "bold", 
    size = 4.5,
    hjust = 0.5,         
    inherit.aes = FALSE
  ) +
  scale_fill_manual(
    values = burden_colors,
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
  labs(title = "Overall WFH Rent Burden Distribution", 
       fill = "Rent Burden Category") +
  guides(fill = guide_legend(
    nrow = 2, 
    byrow = FALSE,             
    title.position = "top", 
    title.hjust = 0.5
  )) +
  theme(
    aspect.ratio = 1, 
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 10, b = -20)), 
    legend.position = "bottom", 
    legend.title = element_text(face = "bold", size = 12), 
    legend.text = element_text(size = 11),              
    legend.key.size = unit(1.1, "lines"),                 
    legend.margin = margin(t = -10, r = 0, b = 10, l = 0) 
  )

### plot2
plot2 <- ggplot(plot_data_bar, aes(x = hh_group, y = prop, fill = range_burden)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7, alpha = 0.9) +
  geom_text(
    aes(label = ifelse(prop >= 0.015, percent(prop, accuracy = 0.1), "")), 
    position = position_dodge(width = 0.8),
    vjust = -0.5, 
    fontface = "bold",
    size = 3.0
  ) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 0.90)) + 
  scale_fill_manual(
    values = burden_colors,
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
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(t = 10, b = -10)), 
    axis.text.x = element_text(face = "bold", size = 11, color = "black"),
    axis.text.y = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "none" 
  )

### merging plot1 & plot2 side by side 
final_wfh_burden_dashboard <- plot1 + plot2 + 
  plot_layout(widths = c(1, 1)) + 
  plot_annotation(
    title = "Work-from-Home (WFH) Housing Affordability & Living Arrangement Distribution", 
    subtitle = "Stable Working Renter Commuters | Los Angeles County (Pooled 5-Year ACS, 2019 & 2024)",
    caption = "Note: Estimates are weighted using personal weights (PERWT).",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(t = 20, b = 2)),
      plot.subtitle = element_text(size = 12, color = "gray30", hjust = 0.5, margin = margin(b = 20)),
      plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 10)),
      plot.caption.position = "plot"
    )
  )

final_wfh_burden_dashboard

### saving the plot 
ggsave("plots/wfh_housing_burden_dashboard.png",
       plot = final_wfh_burden_dashboard,
       width = 16, height = 8, dpi = 300,
       bg = "white")
