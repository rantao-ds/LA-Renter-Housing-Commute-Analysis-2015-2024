Group 1 
# preparing the dataset for group one clustering
group1_clustering <- group_one_eda %>%
  filter(wfh == FALSE) %>%
  select(individual_income, rent_burden, commute_time, hours_worked, age, perwt) %>%
  na.omit() 

# scaling the variables without scaling PERWT
scaled_g1 <- group1_clustering %>%
  select(-perwt) %>%
  scale()

# running K-means with 5 clusters
set.seed(123)
kout_g1 <- kmeans(scaled_g1,centers = 5, nstart = 25)

# adding PERWT for weighted cluster profiling
group1_clustering$cluster <- factor(kout_g1$cluster)

group1_clustering_profiles <- group1_clustering %>%
  group_by(cluster) %>%
  summarise(
    avg_income  = weighted.mean(individual_income, perwt),
    avg_burden  = weighted.mean(rent_burden, perwt),
    avg_commute = weighted.mean(commute_time, perwt),
    avg_hours   = weighted.mean(hours_worked, perwt),
    avg_age     = weighted.mean(age, perwt),
    sample_size = n(),                  
    pop_est     = sum(perwt),                 
    .groups = "drop"
  )

print(group1_clustering_profiles)

# preparing the dataset with a 2,000 observation random sample
set.seed(123) 
plot_sample_g1 <- group1_clustering %>%
  sample_n(2000) 

# defining cluster colors
high_contrast_colors <- c(
  "1" = "#EF4444",  
  "2" = "#3B82F6",  
  "3" = "#10B981",  
  "4" = "#F59E0B",  
  "5" = "#8B5CF6"   
)

# plot 
bubble_plot_g1 <- ggplot(plot_sample_g1, aes(x = individual_income, y = rent_burden, color = cluster)) +
  geom_point(aes(size = commute_time), alpha = 0.4) +
  scale_x_log10(
    labels = scales::label_comma(),
    breaks = c(10000, 20000, 50000, 100000, 200000, 500000, 1000000)
  ) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  scale_size_continuous(
    range = c(0.4, 4.0), 
    breaks = c(30, 60, 90), 
    name = "Commute Time (mins)"
  ) +
  scale_color_manual(
    values = high_contrast_colors,
    labels = c(
      "1" = "Cluster 1",
      "2" = "Cluster 2",
      "3" = "Cluster 3",
      "4" = "Cluster 4",
      "5" = "Cluster 5"
    ),
    name = "Renter Profile Cluster"
  ) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "LA Renter Profiles: Nonfamily Households",
    subtitle = "Income vs. Rent Burden & Commute Time (Log-Bubble Chart)",
    x = "Individual Income ($ - Log Scale)",
    y = "Rent Burden (%)",
    caption = "Note: Plotted using a representative random sample of 2,000 physical nonfamily commuters. Income is scaled using personal weights (PERWT). WFH excluded. Larger bubbles indicate longer commute times."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 15, hjust = 0.5, margin = margin(t = 15, b = 5)),
    plot.subtitle = element_text(size = 11, color = "gray30", hjust = 0.5, margin = margin(b = 15)),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E5E5E5", linewidth = 0.5),
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.title = element_text(face = "bold", size = 9),
    legend.text = element_text(size = 8),
    plot.caption = element_text(hjust = 1, size = 8, color = "gray50", margin = margin(t = 15)),
    plot.caption.position = "plot"
  ) +
  guides(
    color = guide_legend(nrow = 1, title.position = "top", title.hjust = 0.5, order = 2),
    size = guide_legend(nrow = 1, title.position = "top", title.hjust = 0.5, order = 1)
  )

bubble_plot_g1

# saving the plot 
ggsave("output/nonfamily_renter_bubble_chart_high_legibility.pdf",
       plot = bubble_plot_g1,
       width = 15, height = 10, 
       bg = "white")


Group 2
# preparing the dataset for group two clustering                     
group2_clustering_expanded <- group_two_eda %>%
  filter(wfh == FALSE) %>% 
  mutate(
  family_size_clean = ifelse(is.na(family_size), n_hh, family_size),
  family_workers_clean = ifelse(is.na(family_workers), n_workers, family_workers)
  ) %>%
  select(household_income, rent_burden, commute_time, hours_worked, age, 
         family_workers = family_workers_clean, 
         family_size = family_size_clean, 
         num_dependent_children, 
         perwt) %>%  
  na.omit()                    

# scaling the variables without scaling PERWT
scaled_vars_g2 <- group2_clustering_expanded %>%
  select(-perwt) %>%
  scale()

# running K-means with 6 clusters        
set.seed(123) 
kmeans_g2_expanded <- kmeans(scaled_vars_g2, centers = 6, nstart = 25)

# adding PERWT for weighted cluster profiling                     
group2_clustering_expanded$cluster <- factor(kmeans_g2_expanded$cluster)

group2_clustering_profiles_g2 <- group2_clustering_expanded %>%
  group_by(cluster) %>%
  summarise(
    avg_income      = weighted.mean(household_income, perwt),
    avg_burden      = weighted.mean(rent_burden, perwt),
    avg_commute     = weighted.mean(commute_time, perwt),
    avg_hours       = weighted.mean(hours_worked, perwt),
    avg_age         = weighted.mean(age, perwt),
    avg_fam_workers = weighted.mean(family_workers, perwt),
    avg_fam_size    = weighted.mean(family_size, perwt),
    avg_children    = weighted.mean(num_dependent_children, perwt),    
    sample_size     = n(),                         
    pop_est         = sum(perwt),                  
    .groups = "drop"
  )

print(group2_clustering_profiles_g2, n = Inf, width = Inf)

# preparing the dataset with a 2,000 observation random sample
set.seed(123)            
plot_sample_g2 <- group2_clustering_expanded %>%
  sample_n(2000)

                     
# defining cluster colors
high_contrast_colors <- c(
  "1" = "#EF4444",  
  "2" = "#3B82F6",  
  "3" = "#10B981",  
  "4" = "#F59E0B",  
  "5" = "#8B5CF6",  
  "6" = "#64748B"   
)

# plot
bubble_plot_g2 <- ggplot(plot_sample_g2, aes(x = household_income, y = rent_burden, color = cluster)) +
  geom_point(aes(size = commute_time), alpha = 0.4) +
  scale_x_log10(
    labels = scales::label_comma(),
    breaks = c(10000, 20000, 50000, 100000, 200000, 500000, 1000000)
  ) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  scale_size_continuous(
    range = c(0.4, 4.0), 
    breaks = c(30, 60, 90), 
    name = "Commute Time (mins)"
  ) +
  scale_color_manual(
    values = high_contrast_colors,
    labels = c(
      "1" = "Cluster 1",
      "2" = "Cluster 2",
      "3" = "Cluster 3",
      "4" = "Cluster 4",
      "5" = "Cluster 5",
      "6" = "Cluster 6"
    ),
    name = "Renter Profile Cluster"
  ) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "LA Renter Profiles: Family Households",
    subtitle = "Income vs. Rent Burden & Commute Time (Log-Bubble Chart)",
    x = "Household Income ($ - Log Scale)",
    y = "Rent Burden (%)",
    caption = "Note: Plotted using a representative random sample of 2,000 physical family commuters. Income is scaled using personal weights (PERWT). WFH excluded. Larger bubbles indicate longer commute times."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 15, hjust = 0.5, margin = margin(t = 15, b = 5)),
    plot.subtitle = element_text(size = 11, color = "gray30", hjust = 0.5, margin = margin(b = 15)),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E5E5E5", linewidth = 0.5),
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.title = element_text(face = "bold", size = 9),
    legend.text = element_text(size = 8),
    plot.caption = element_text(hjust = 1, size = 8, color = "gray50", margin = margin(t = 15)),
    plot.caption.position = "plot"
  ) +
  guides(
    color = guide_legend(nrow = 1, title.position = "top", title.hjust = 0.5, order = 2),
    size = guide_legend(nrow = 1, title.position = "top", title.hjust = 0.5, order = 1)
  )

bubble_plot_g2

# saving the plot
ggsave("output/family_renter_bubble_chart_high_legibility.pdf",
       plot = bubble_plot_g2,
       width = 15, height = 10, 
       bg = "white")                  
                     
