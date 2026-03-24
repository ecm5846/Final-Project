rm(list = ls())
# Call Libraries ----------------------------------------------------------

library(tidyverse)
library(lubridate)
library(scales)
library(plotly)
library(stringdist)

# Initial data import -----------------------------------------------------

# MD Data Import
delaney_data <- read_csv("Campaign Donations/MD/Delaney/schedule_a-2026-03-17T18_54_17.csv")

trone_data <- read_csv("Campaign Donations/MD/Trone/schedule_a-2026-03-17T18_57_57.csv") %>% 
  mutate(
    committee_name = str_replace(committee_name, "DAVID TRONE.*", "DAVID TRONE FOR CONGRESS")
  )

# PA Data Import
thompson_data <- read_csv("Campaign Donations/PA/schedule_a-2026-03-17T18_59_04.csv")

# Combine all data sets
all_data <- rbind(delaney_data, trone_data, thompson_data)

# Cleaning and Standardizing -----------------------------------------------------
## Remove candidate contributions (loans etc...), reimbursements/refunds, and duplicate line items. 
df_filtered <- function(df) {
  df %>%
    filter(
      !entity_type_desc %in% c("CANDIDATE", "CAMPAIGN COMMITTEE", "POLITICAL PARTY COMMITTEE", "OTHER COMMITTEE"),
      contribution_receipt_amount > 0,
    ) %>% 
    distinct(transaction_id, .keep_all = TRUE)
}

## Find distribution of finances across type of donor, compute proportion to the total
summarize_finances <- function(df) {
  df_filtered(df) %>% # apply the filter first
    filter(report_year > 2020) %>% 
    group_by(entity_type_desc) %>%
    summarise(total = sum(contribution_receipt_amount, na.rm = TRUE), .groups = "drop") %>%
    mutate(prop = round((total / sum(total))*100, 2)) %>%
    arrange(desc(total))
}

## Find top n donors
summarize_donors <- function(df) {
  df_filtered(df) %>% 
    filter(report_year > 2020) %>% 
    group_by(contributor_name) %>% 
    summarise(total = sum(contribution_receipt_amount), .groups = "drop") %>% 
    slice_max(total, n = 10) %>% 
    arrange(desc(total))
}

## Financial Contribution by State
summarize_state <- function(df) {
  df_filtered(df) %>% 
    filter(report_year > 2020) %>% 
    group_by(contributor_state) %>% 
    summarise(total = sum(contribution_receipt_amount), .groups = "drop") %>% 
    slice_max(total, n = 5) %>% 
    arrange(desc(total))
}

## Financial Contribution by Year, all time
summarize_year <- function(df) {
  df_filtered(df) %>% 
    group_by(report_year) %>% 
    summarise(total = sum(contribution_receipt_amount), .groups = "drop") 
}

## Average distance by Contributor

# filter_city <- world.cities %>%
#   filter(country.etc == "USA") %>%
#   select(name, country.etc, lat, long) %>%
#   rename(City = name, Country = country.etc) %>% 
#   mutate(across(c(City, Country), toupper))
#   
# 
# latlongTable <- trone_data %>% 
#   mutate(contributor_city = toupper(contributor_city)) %>% 
#   left_join(
#     filter_city,
#     by = c("contributor_city" = "City")
#   )


# Exploration -------------------------------------------------------------
trone_fin_dist <- summarize_finances(trone_data) %>% mutate(candidate = "Trone")
delaney_fin_dist <- summarize_finances(delaney_data) %>% mutate(candidate = "Delaney")
thompson_fin_dist <- summarize_finances(thompson_data) %>% mutate(candidate = "Thompson")
all_fin_dist <- summarize_finances(all_data)

trone_donor_dist <- summarize_donors(trone_data) %>% mutate(candidate = "Trone")
delaney_donor_dist <- summarize_donors(delaney_data) %>% mutate(candidate = "Delaney")
thompson_donor_dist <- summarize_donors(thompson_data) %>% mutate(candidate = "Thompson")
all_donor_dist <- summarize_donors(all_data)

trone_state_dist <- summarize_state(trone_data) %>% mutate(candidate = "Trone")
delaney_state_dist <- summarize_state(delaney_data) %>% mutate(candidate = "Delaney")
thompson_state_dist <- summarize_state(thompson_data) %>% mutate(candidate = "Thompson")
all_state_dist <- summarize_state(all_data)

trone_year_dist <- summarize_year(trone_data) %>% mutate(candidate = "Trone")
delaney_year_dist <- summarize_year(delaney_data) %>% mutate(candidate = "Delaney")
thompson_year_dist <- summarize_year(thompson_data) %>% mutate(candidate = "Thompson")
all_year_dist <- summarize_year(all_data)

## Combine all data
all_donors <- bind_rows(trone_donor_dist, delaney_donor_dist, thompson_donor_dist)
all_dist <- bind_rows(trone_fin_dist, delaney_fin_dist, thompson_fin_dist)
all_state <- bind_rows(trone_state_dist, delaney_state_dist, thompson_state_dist)
all_year <- bind_rows(trone_year_dist, delaney_year_dist, thompson_year_dist)

