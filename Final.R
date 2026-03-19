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


# Cleaning and Standardizing -----------------------------------------------------

# Standard functions to reduce repetition
## Remove candidate contributions (loans etc...), reimbursements/refunds, and duplicate line items. 

df_filtered <- function(df) {
  df %>%
    filter(
      !entity_type_desc %in% c("CANDIDATE", "CAMPAIGN COMMITTEE", "POLITICAL PARTY COMMITTEE", "OTHER COMMITTEE"),
      contribution_receipt_amount > 0,
      is.na(contributor_name) | contributor_name == "" | contributor_name != "NOTE: ABOVE CONTRIBUTION EARMARKED THROUGH THIS ORGANIZATION.",
      report_year > 2020
    )
  }

## Find distribution of finances across type of donor, compute proportion to the total
  summarize_finances <- function(df) {
    df_filtered(df) %>%   # apply the filter first
      group_by(entity_type_desc) %>%
      summarise(total = sum(contribution_receipt_amount, na.rm = TRUE), .groups = "drop") %>%
      mutate(prop = round((total / sum(total))*100, 2)) %>%
      arrange(desc(total))
  }

## Find top 5 donors
summarrize_donors <- function(df) {
  df_filtered(df) %>% 
    group_by(contributor_name) %>% 
    summarise(total = sum(contribution_receipt_amount), .groups = "drop") %>% 
    slice_max(total, n = 10) %>% 
    arrange(desc(total))
}

## Financial Contribution by State
summarrize_state <- function(df) {
  df_filtered(df) %>% 
    group_by(contributor_state) %>% 
    summarise(total = sum(contribution_receipt_amount), .groups = "drop") %>% 
    slice_max(total, n = 5) %>% 
    arrange(desc(total))
}
# Exploration -------------------------------------------------------------

trone_fin_dist <- summarize_finances(trone_data) %>% mutate(candidate = "Trone")
delaney_fin_dist <- summarize_finances(delaney_data) %>% mutate(candidate = "Delaney")
thompson_fin_dist <- summarize_finances(thompson_data) %>% mutate(candidate = "Thompson")

trone_donor_dist <- summarrize_donors(trone_data) %>% mutate(candidate = "Trone")
delaney_donor_dist <- summarrize_donors(delaney_data) %>% mutate(candidate = "Delaney")
thompson_donor_dist <- summarrize_donors(thompson_data) %>% mutate(candidate = "Thompson")

trone_state_dist <- summarize_state(trone_data) %>% mutate(candidate = "Trone")
delaney_state_dist <- summarize_state(delaney_data) %>% mutate(candidate = "Delaney")
thompson_state_dist <- summarize_state(thompson_data) %>% mutate(candidate = "Thompson")

## Combine all data
all_donors <- bind_rows(trone_donor_dist, delaney_donor_dist, thompson_donor_dist)
all_dist <- bind_rows(trone_fin_dist, delaney_fin_dist, thompson_fin_dist)
all_state <- bind_rows(trone_state_dist, delaney_state_dist, thompson_state_dist)
