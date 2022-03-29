# Analysis script for the feature integration theory experiment

# 0. Packages --------------------------------------------------------------
library(psych)
library(ggplot2)
library(tidyr)

library(aida)
library(brms) 
library(stringr)
library(dplyr)
library(tidyverse)
library(pwr)

# 1. Import --------------------------------------------------------------

# import csv
trial_frame <- read.csv('../../data/02_main/results_main.csv')

# cast variables
trial_frame$size <- as.numeric(trial_frame$display_size)
factor_variables <- c("submission_id", "condition", "display_size", "expected", "response", "target", "target_color")
trial_frame[factor_variables] <- lapply(trial_frame[factor_variables], factor)

# convert time from ms to minutes
trial_frame$experiment_duration <- trial_frame$experiment_duration/60000

# filter outliers
trial_frame <- subset(trial_frame, response_time < 3000 & response_time > 200)
trial_frame <- subset(trial_frame, display_size != 1)

# participants frame
trial_frame$age[is.na(trial_frame$age)]<-NaN
pf_valid <- aggregate(. ~ submission_id,
                      trial_frame[, c('submission_id', 'age', 'gender', 'blockorder', 'education', 'experiment_duration')], 
                      function(x){return(x[1])})
pf_valid <- merge(pf_valid, aggregate(trial_number ~ submission_id, data = trial_frame, FUN = length), by='submission_id')

# clean up
rm(factor_variables)


# 2. Descriptive -------------------------------------------------------------

# age
summary(as.numeric(pf_valid$age))

# duration
summary(as.numeric(pf_valid$experiment_duration))

# education
table(pf_valid$education)

# gender
table(pf_valid$gender)

# blockorder
table(pf_valid$blockorder)



# 3. Analysis Response Times ---------------------------------------------

# filter incorrect trials
tf_all <- subset(trial_frame, expected == response)
tf <- tf_all

# ---- descriptive ---
# overall
describe(response_time ~ display_size, data=tf)
hist(tf$response_time, breaks = 100)

# plots
data <- aggregate(response_time ~ size + expected + condition, data=tf_color, mean)
ggplot(data = data, 
       mapping = aes(y = response_time, x=size, group=interaction(expected,condition), color=interaction(expected,condition) )) + 
  geom_point() + 
  geom_line()


# ---- regression model ---
# bayesian
fit_RT <- brm(response_time ~  expected:condition + size:expected:condition -1, 
              data=tf, 
              family = gaussian())
summary(fit_RT)
#save(fit_RT, file='fit_RT.RData')

# Hypothesis 1.1:
hypothesis(fit_RT, "expectedpositive:conditionconjunction:size > 0", class = "b")
hypothesis(fit_RT, "expectednegative:conditionconjunction:size > 0", class = "b")

# Hypothesis 1.2:
hypothesis(fit_RT, "expectednegative:conditionconjunction:size > expectedpositive:conditionconjunction:size", class = "b")

# Hypothesis 2.1:
hypothesis(fit_RT, "expectedpositive:conditionfeature:size = 0", class = "b")

# Hypothesis 2.2:
hypothesis(fit_RT, "expectednegative:conditionfeature:size > 0", class = "b")


# ---- comparison for RT of size 1 ---
# Hypothesis 3:
hist(subset(tf, size == 1)$response_time, breaks = 25)
t.test(response_time ~ condition,  subset(tf, size == 1), var.equal = TRUE)


# ---- follow-up analysis ---
tf_plus1 <- subset(tf_all, display_size != 1)
  
fit_RT_plus1 <- brm(response_time ~  expected:condition + size:expected:condition -1, 
              data=tf_plus1, 
              family = gaussian())
summary(fit_RT_plus1)




# ---- follow-up feature ---
tf_feature_positive <- subset(tf_all, condition == 'feature' & response == 'positive')
tf_feature_positive$feature_condition = 'color'
tf_feature_positive[tf_feature_positive$target == 'S',]$feature_condition = 'shape'
tf_feature_positive$feature_condition <- factor(tf_feature_positive$feature_condition)

fit_RT_feature_positive <- brm(response_time ~  feature_condition + feature_condition:size -1, 
               data=tf_feature_positive, 
               family = gaussian())
summary(fit_RT_feature_positive)

# plots
data <- aggregate(response_time ~ feature_condition + size, data=tf_feature_positive, mean)
ggplot(data = data, 
       mapping = aes(y = response_time, x=size, group=feature_condition, color=feature_condition )) + 
  geom_point() + 
  geom_line()



# 4. Analysis Errors ------------------------------------------------------

# subset of dependent variables
tf <- trial_frame[, c('submission_id', 'condition', 'size', 'expected', 'response')]

# metrics
tf$fp <- (tf$expected == 'negative' & tf$response == 'postive')
tf$fn <- (tf$expected == 'positive' & tf$response == 'negative')
tf$error <- (tf$expected != tf$response)

# descriptive
prop.table(table(tf$fn, tf$condition), margin = 2)
prop.table(table(tf$fp, tf$condition), margin = 2)

# per participant
aggregate(. ~ submission_id, 
          tf[, c('submission_id', 'fn', 'fp')],
          mean)

# per display size
aggregate(. ~ size, 
          tf[, c('size', 'fn', 'fp')],
          mean)

# plots
data <- aggregate(error ~ size + expected + condition, data=tf, mean)
ggplot(data = data, 
       mapping = aes(y = error, x=size, group=interaction(expected,condition), color=interaction(expected,condition) )) + 
  geom_point() + 
  geom_line()


# apply linear model
fit_error <- glm(error ~ expected:condition + size:expected:condition -1, data=tf, family="binomial")

# Hypothesis 4:
summary(fit_error)
