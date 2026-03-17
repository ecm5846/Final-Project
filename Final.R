rm(list = ls())
# Call Libraries ----------------------------------------------------------

library(stringr)
library(ggthemes)
library(tidyverse)
library(labeling)
library(dplyr)
library(readxl)
library(readr)
library(lubridate)
library(scales)
library(ggplot2)
library(gridExtra)
library(grid)
library(slider)
library(knitr)
library(plotly)

# Initial data import -----------------------------------------------------

# MD Data Import
delaney_data <- read_csv(  "Campaign Donations/MD/Delaney/schedule_a-2026-03-17T18_54_17.csv")
trone_data <- read_csv("Campaign Donations/MD/Trone/schedule_a-2026-03-17T18_57_57.csv")

# PA Data Import
thompson_data <- read_csv("Campaign Donations/PA/schedule_a-2026-03-17T18_59_04.csv")


# Initial Exploration -----------------------------------------------------

# Find distribution of finances across type of donor, compute proportion to the total
trone_fin_dist <- trone_data %>% 
  filter(entity_type_desc != "CANDIDATE") %>% # He gave himself 10 million dollars, filter it out
  group_by(entity_type_desc) %>% 
  summarise(total = sum(contribution_receipt_amount)) %>% 
  mutate(prop = total / sum(total)) %>% 
  arrange(desc(total))


ggplot(fin_dist, aes(x = "", y = prop, fill = entity_type_desc)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  
  geom_text(
    aes(label = percent(prop, accuracy = 0.1)),
    position = position_stack(vjust = 0.5),
    size = 4
  ) +
  
  labs(
    title = "Distribution of Contributions by Entity Type",
    fill = "Entity Type"
  ) +
  
  theme_void() +
  
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    legend.position = "right",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10)
  )
