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
delaney_data <- read_csv("Campaign Donations/MD/Delaney/schedule_a-2026-03-17T18_54_17.csv")
trone_data <- read_csv("Campaign Donations/MD/Trone/schedule_a-2026-03-17T18_57_57.csv")

# PA Data Import
thompson_data <- read_csv("Campaign Donations/PA/schedule_a-2026-03-17T18_59_04.csv")


# Initial Exploration -----------------------------------------------------

## Data Cleaning General Functions
df_filtered <- function(df) {
  df %>%
    filter(
      entity_type_desc != "CANDIDATE",
      contribution_receipt_amount > 0,
      is.na(contributor_name) | contributor_name == "" | contributor_name != "NOTE: ABOVE CONTRIBUTION EARMARKED THROUGH THIS ORGANIZATION."
    )
  }
# Find distribution of finances across type of donor, compute proportion to the total

## Summary function to reduce repetition
  summarize_finances <- function(df) {
    df_filtered(df) %>%   # apply the filter first
      group_by(entity_type_desc) %>%
      summarise(total = sum(contribution_receipt_amount, na.rm = TRUE), .groups = "drop") %>%
      mutate(prop = total / sum(total)) %>%
      arrange(desc(total))
  }

trone_fin_dist <- summarize_finances(trone_data)
delaney_fin_dist <- summarize_finances(delaney_data)
thompson_fin_dist <- summarize_finances(thompson_data)

## Find top 5 donors
summarrize_donors <- function(df) {
  df_filtered(df) %>% 
    group_by(contributor_name) %>% 
    summarise(total = sum(contribution_receipt_amount), .groups = "drop") %>% 
    slice_max(total, n = 10) %>% 
    arrange(desc(total))
}
trone_donor_dist <- summarrize_donors(trone_data)
delaney_donor_dist <- summarrize_donors(delaney_data)
thompson_donor_dist <- summarrize_donors(thompson_data)

all_donors <- bind_rows(trone_donor_dist, delaney_donor_dist, thompson_donor_dist)

