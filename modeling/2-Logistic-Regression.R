Group One 
# set the baseline as 30% of rent burden and 30 minutes of commute time
## 1 = Failed Trade-off (High Rent AND Long Commute)
## 0 = Managed Trade-off (Got cheap rent, OR got a short commute, OR got both)
glm_g1 <- group_one_eda %>%
filter(wfh == FALSE) %>%
mutate(tradeoff_failed = ifelse(rent_burden > 30 & commute_time > 30, 1, 0))

# preparing variables for the Group One GLM
## setting factor reference levels
glm_g1 <- glm_g1 %>%
  mutate(
    income_tier_g1 = factor(income_tier_g1, 
                            levels = c("upper_income", "middle_income", "low_income")),
    hh_group = factor(hh_group, 
                      levels = c("single", "roommate", "mixed")),
    transit_group = factor(transit_group, 
                           levels = c("private_auto", "public_transit", "active_transit", "other_transit")),

    race_ethnicity = factor(race_ethnicity, 
                            levels = c("nh_white", "hispanic", "nh_black", "nh_asian", "nh_other", "nh_native"))
  )


# saving the dataset for modeling 
saveRDS(glm_g1, "data/glm_g1_modeling_ready.rds")

# running the modeling 
glm_g1_modeling <- glm(tradeoff_failed ~ hours_worked + age + income_tier_g1 + hh_group + transit_group + race_ethnicity,
                       data = glm_g1,
                       family = "binomial",
                       weights = perwt)

# saving the model 
saveRDS(glm_g1_modeling, "data/glm_g1_model.rds")

# checking the resluts 
summary(glm_g1_modeling)
exp(glm_g1_modeling$coef)

# predicting probability for each observation
pred_prob <- predict(glm_g1_modeling, type = "response")

#running confusion matrix:
pred_class <- ifelse(pred_prob > 0.12, 1, 0)
glm_g1$tradeoff_failed <-  factor(glm_g1$tradeoff_failed, levels = c(1, 0))

library(caret)
confusionMatrix(factor(pred_class), glm_g1$tradeoff_failed)

# calculating ROC & AUC
library(pROC)
roc_obj_glm_g1 <- roc(glm_g1$tradeoff_failed,  pred_prob)
auc(roc_obj_glm_g1)

# plotting ROC curve
roc_df <- data.frame(
  Sensitivity = roc_obj_glm_g1$sensitivities,
  Specificity = roc_obj_glm_g1$specificities)

ggplot_roc <- ggplot(roc_df, aes(x = 1 - Specificity, y = Sensitivity)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray60", linewidth = 0.8) +
  geom_line(color = "#1D4ED8", linewidth = 1.5) + 
  scale_x_continuous(labels = percent_format(), limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "ROC Curve: Nonfamily Households GLM",
    subtitle = paste("Model Predictive Performance (AUC =", round(auc(roc_obj_glm_g1), 4), ")"),
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)",
    caption = "Note: WFH excluded."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 15, hjust = 0.5, margin = margin(t = 15, b = 5)),
    plot.subtitle = element_text(size = 11, color = "gray30", hjust = 0.5, margin = margin(b = 15)),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E5E5E5", linewidth = 0.5),
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)),
    plot.caption.position = "plot"
  )

ggplot_roc

# saving the plot
ggsave("output/nonfamily_glm_roc_curve.pdf",
       plot = ggplot_roc,
       width = 11, height = 7,
       bg = "white")

# weighted ROC 
## generating predicted probabilities
pred_prob <- predict(glm_g1_modeling, type = "response")

## extracting prediction vectors
weights <- glm_g1$perwt
actual <- as.numeric(as.character(glm_g1$tradeoff_failed))

## generating weighted ROC coordinates
library(WeightedROC)
weighted_roc_g1 <- WeightedROC(
  guess = pred_prob, 
  label = actual, 
  weight = weights)

## calculating the weighted AUC (0.77453)
weighted_auc_g1 <- WeightedAUC(weighted_roc_g1)

### plotting the weighted ROC curve
ggplot_weighted_roc_g1 <- ggplot(weighted_roc_g1, aes(x = FPR, y = TPR)) + 
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray60", linewidth = 0.8) +
  geom_line(color = "#1D4ED8", linewidth = 1.5) + 
  scale_x_continuous(labels = percent_format(), limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "Weighted ROC Curve: Nonfamily Households GLM",
    subtitle = paste("Population Performance (Weighted AUC =", round(weighted_auc_g1, 5), ")"),
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)",
    caption = "Note: Estimates and coordinates are weighted using personal weights (PERWT). WFH excluded."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 15, hjust = 0.5, margin = margin(t = 15, b = 5)),
    plot.subtitle = element_text(size = 11, color = "gray30", hjust = 0.5, margin = margin(b = 15)),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E5E5E5", linewidth = 0.5),
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)),
    plot.caption.position = "plot"
  )

ggplot_weighted_roc_g1

#### saving the plot
ggsave("output/nonfamily_glm_weighted_roc_curve.pdf",
       plot = ggplot_weighted_roc_g1,
       width = 11, height = 7,
       bg = "white")



Group Two
# set the baseline as 30% of rent burden and 30 minutes of commute time
## 1 = Failed Trade-off (High Rent AND Long Commute)
## 0 = Managed Trade-off (Got cheap rent, OR got a short commute, OR got both)
glm_g2 <- group_two_eda %>%
filter(wfh == FALSE) %>%
mutate(tradeoff_failed = ifelse(rent_burden > 30 & commute_time > 30, 1, 0)) 

# preparing variables for the Group Two GLM
## cleaning household variables and setting factor reference levels
glm_g2 <- glm_g2 %>%
  mutate(
    family_size_clean = ifelse(is.na(family_size), n_hh, family_size),
    family_workers_clean = ifelse(is.na(family_workers), n_workers, family_workers),
    income_tier_g2 = factor(income_tier_g2, 
                            levels = c("upper_income", "middle_income", "low_income")),
    hh_group = factor(hh_group, 
                      levels = c("family", "mixed")),
    transit_group = factor(transit_group, 
                           levels = c("private_auto", "public_transit", "active_transit", "other_transit")),
    race_ethnicity = factor(race_ethnicity, 
                            levels = c("nh_white", "hispanic", "nh_black", "nh_asian", "nh_other", "nh_native"))
  ) 

# saving the dataset for modeling 
saveRDS(glm_g2, "data/glm_g2_modeling_ready.rds")

# running the modeling 
glm_g2_modeling <- glm(tradeoff_failed ~ hours_worked + age + income_tier_g2 + hh_group + transit_group + race_ethnicity + num_dependent_children + family_size_clean + family_workers_clean,
                       data = glm_g2,
                       family = "binomial",
                       weights = perwt)

# saving the model
saveRDS(glm_g2_modeling, "data/glm_g2_model.rds")

# checking the resluts 
summary(glm_g2_modeling)
exp(glm_g2_modeling$coef)

# predicting probability for each observation
pred_prob <- predict(glm_g2_modeling, type = "response")
 
# running confusion matrix:
library(caret)
pred_class <- ifelse(pred_prob > 0.10, 1, 0)
glm_g2$tradeoff_failed <-  factor(glm_g2$tradeoff_failed, levels = c(1, 0))
confusionMatrix(factor(pred_class), glm_g2$tradeoff_failed)

# calculating ROC & AUC
library(pROC)
roc_obj_glm_g2 <- roc(glm_g2$tradeoff_failed,  pred_prob)
auc(roc_obj_glm_g2)

# plotting ROC curve
roc_df_g2 <- data.frame(
  Sensitivity = roc_obj_glm_g2$sensitivities,
  Specificity = roc_obj_glm_g2$specificities)

ggplot_roc_g2 <- ggplot(roc_df_g2, aes(x = 1 - Specificity, y = Sensitivity)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray60", linewidth = 0.8) +
  geom_line(color = "#1D4ED8", linewidth = 1.5) + 
  scale_x_continuous(labels = percent_format(), limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "ROC Curve: Family Households GLM",
    subtitle = paste("Model Predictive Performance (AUC =", round(auc(roc_obj_glm_g2), 4), ")"),
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)",
    caption = "Note: WFH excluded."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 15, hjust = 0.5, margin = margin(t = 15, b = 5)),
    plot.subtitle = element_text(size = 11, color = "gray30", hjust = 0.5, margin = margin(b = 15)),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E5E5E5", linewidth = 0.5),
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)),
    plot.caption.position = "plot"
  )

ggplot_roc_g2

# saving the plot
ggsave("plots/family_glm_roc_curve.pdf",
       plot = ggplot_roc_g2,
       width = 11, height = 7,
       bg = "white")

# weighted ROC 
## generating predicted probabilities
pred_prob <- predict(glm_g2_modeling, type = "response")

## extracting prediction vectors
actual    <- as.numeric(as.character(glm_g2$tradeoff_failed)) 
weights   <- glm_g2$perwt

## generating weighted ROC coordinates
library(WeightedROC)
weighted_roc <- WeightedROC(
  guess = pred_prob, 
  label = actual, 
  weight = weights
)

## calculating the weighted AUC (0.79251)
weighted_auc <- WeightedAUC(weighted_roc)

### plotting the weighted ROC curve
ggplot_weighted_roc <- ggplot(weighted_roc, aes(x = FPR, y = TPR)) + 
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray60", linewidth = 0.8) +
  geom_line(color = "#1D4ED8", linewidth = 1.5) + 
  scale_x_continuous(labels = percent_format(), limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
  scale_y_continuous(labels = percent_format(), limits = c(0, 1), breaks = seq(0, 1, by = 0.2)) +
  theme_minimal(base_family = "sans") +
  labs(
    title = "Weighted ROC Curve: Family Households GLM",
    subtitle = paste("Population Performance (Weighted AUC =", round(weighted_auc, 5), ")"),
    x = "False Positive Rate (1 - Specificity)",
    y = "True Positive Rate (Sensitivity)",
    caption = "Note: Estimates and coordinates are weighted using personal weights (PERWT). WFH excluded."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 15, hjust = 0.5, margin = margin(t = 15, b = 5)),
    plot.subtitle = element_text(size = 11, color = "gray30", hjust = 0.5, margin = margin(b = 15)),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E5E5E5", linewidth = 0.5),
    plot.caption = element_text(hjust = 1, size = 9, color = "gray50", margin = margin(t = 15)),
    plot.caption.position = "plot"
  )

ggplot_weighted_roc

#### saving the plot
ggsave("output/family_glm_weighted_roc_curve.pdf",
       plot = ggplot_weighted_roc,
       width = 11, height = 7,
       bg = "white")







