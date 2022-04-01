# Plot script for the feature integration theory experiment

# 0. Packages --------------------------------------------------------------
library(psych)
library(ggplot2)
library(tidyr)
library(tidyverse)

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

# 2. Line plot all conditions -------------------------------------------------------------

# subset
tf <- subset(trial_frame, expected == response)

data <- aggregate(response_time ~ size + expected + condition, data=tf, mean)
ggplot(data = data, 
       mapping = aes(y = response_time, x=size, group=interaction(expected,condition),
                     color=condition, linetype=expected)) + 
  geom_point() + 
  geom_line() +
  xlab("Display Size") +
  ylab("Response Time (ms)") + 
  scale_color_manual(values=c("#3977AF", "#EF8536")) + 
  labs(linetype ='Response', color='Condition') + 
  guides(linetype = guide_legend(reverse=TRUE))


# 3. Line plot all conditions and subgroups -------------------------------------------------------------

# subset
tf <- subset(trial_frame, expected == response)
tf$feature_cond <- ''
tf[tf$target == 'S',]$feature_cond <- 'shape'
tf[tf$target_color == 'blue',]$feature_cond <- 'color'

data <- aggregate(response_time ~ size + expected + condition + feature_cond, data=tf, mean)
size <- 15
p <- ggplot(data = data, 
       mapping = aes(y = response_time, x=size, group=interaction(expected,condition,feature_cond),
                     color=condition, linetype=expected, shape=feature_cond)) + 
  geom_point(size=2.5) + 
  geom_line(size=1.25) +
  xlab("Display Size") +
  ylim(c(750, 1750)) +
  ylab("Response Time (ms)") + 
  scale_color_manual(values=c("#3977AF", "#EF8536")) + 
  labs(linetype ='Response', color='Condition', shape='Feature') + 
  guides(shape = guide_legend(reverse=TRUE)) + 
  guides(linetype = guide_legend(order = 2), col = guide_legend(order = 1)) +
  theme(text = element_text(size=size)) + 
  scale_x_continuous(breaks = c(1,5,15,30))
plot(p)

pdf(file='plots/lineplot_subgroup.pdf', width=8, height=4)
plot(p)
dev.off()

