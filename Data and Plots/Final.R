rm(list = ls()) 
# Call Libraries ----------------------------------------------------------

library(tidyverse)
library(lubridate)
library(scales)
library(plotly)
library(stringdist)
library(dcData)
library(here)

# Initial data import -----------------------------------------------------

# MD Data Import
delaney_data <- read_csv(
  here("Campaign Donations", "MD", "Delaney", "schedule_a-2026-03-17T18_54_17.csv")
)


trone_data_raw <- read_csv(
  here("Campaign Donations", "MD", "Trone", "schedule_a-2026-03-17T18_57_57.csv")
)
trone_data <- trone_data_raw %>% 
  mutate(
    committee_name = str_replace(committee_name, "DAVID TRONE.*", "DAVID TRONE FOR CONGRESS")
  )

# Combine all data sets
all_data <- rbind(delaney_data, trone_data) %>% 
  select(committee_id, committee_name, report_year, transaction_id, 
         file_number, entity_type, entity_type_desc, unused_contbr_id, 
         contributor_name, recipient_committee_designation, contributor_first_name, 
         contributor_middle_name, contributor_last_name, contributor_suffix, 
         contributor_street_1, contributor_street_2, contributor_city, 
         contributor_state, contributor_zip, contributor_employer, contributor_occupation, 
         contributor_id, is_individual, receipt_type_desc, memo_text, 
         contribution_receipt_date, contribution_receipt_amount, contributor_aggregate_ytd, 
         candidate_name, candidate_first_name, candidate_last_name, candidate_middle_name, 
         candidate_office_state, candidate_office_state_full, candidate_office_district, 
         conduit_committee_id, donor_committee_name, fec_election_year, two_year_transaction_period)


# Cleaning and Standardizing -----------------------------------------------------
## Remove candidate contributions (loans etc...), reimbursements/refunds, and duplicate line items. 
## https://r4ds.hadley.nz/functions.html
df_filtered <- function(df) {
  df %>%
    filter(
      !entity_type_desc %in% c("CANDIDATE", "CAMPAIGN COMMITTEE", 
                               "POLITICAL PARTY COMMITTEE", "OTHER COMMITTEE"),
      contribution_receipt_amount > 0,
      report_year >= 2020,
      contributor_name != "ACTBLUE") # Lines for PAC and accompanying line for associated individual donation
}



## Find distribution of finances across type of donor, compute proportion to the total
summarize_finances <- function(df) {
  df_filtered(df) %>% # apply the filter first
    group_by(entity_type_desc) %>%
    summarise(total = sum(contribution_receipt_amount, na.rm = TRUE), .groups = "drop") %>%
    mutate(prop = round((total / sum(total))*100, 2)) %>%
    arrange(desc(total))
}

## Find top n donors
summarize_donors <- function(df) {
  df_filtered(df) %>% 
    group_by(contributor_name) %>% 
    summarise(total = sum(contribution_receipt_amount), .groups = "drop") %>% 
    slice_max(total, n = 10) %>% 
    arrange(desc(total))
}

## Financial Contribution by State
summarize_state <- function(df) {
  df_filtered(df) %>% 
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
# Clean all data ZIP codes and select only necessary variables
MD_map_data <- df_filtered(all_data) %>% 
  mutate(
    contributor_zip = str_sub(contributor_zip, 1, 5),
    contributor_zip = str_pad(contributor_zip, 5, pad = "0")) %>% 
  select(
    committee_id, committee_name, report_year, entity_type, entity_type_desc,
    contributor_name, contributor_city, contributor_state, contributor_zip,
    contributor_id, is_individual, contribution_receipt_amount) %>% 
  group_by(committee_name, contributor_name) %>% 
  mutate(total = sum(contribution_receipt_amount, na.rm = TRUE)) %>% 
  ungroup()

lat_long_tbl <- MD_map_data %>% 
  left_join(
    ZipGeography %>% select(ZIP, Latitude, Longitude),
    by = c("contributor_zip" = "ZIP")
  ) %>% 
  filter(!is.na(Latitude)) # Remove around 100 lines where lat/long data isn't available.

# Exploration -------------------------------------------------------------
trone_fin_dist <- summarize_finances(trone_data) %>% mutate(candidate = "Trone")
delaney_fin_dist <- summarize_finances(delaney_data) %>% mutate(candidate = "Delaney")
all_fin_dist <- summarize_finances(all_data)

trone_donor_dist <- summarize_donors(trone_data) %>% mutate(candidate = "Trone")
delaney_donor_dist <- summarize_donors(delaney_data) %>% mutate(candidate = "Delaney")
all_donor_dist <- summarize_donors(all_data)

trone_state_dist <- summarize_state(trone_data) %>% mutate(candidate = "Trone")
delaney_state_dist <- summarize_state(delaney_data) %>% mutate(candidate = "Delaney")
all_state_dist <- summarize_state(all_data)

trone_year_dist <- summarize_year(trone_data) %>% mutate(candidate = "Trone")
delaney_year_dist <- summarize_year(delaney_data) %>% mutate(candidate = "Delaney")
all_year_dist <- summarize_year(all_data)

## Combine all data
all_donors <- bind_rows(trone_donor_dist, delaney_donor_dist)
all_dist <- bind_rows(trone_fin_dist, delaney_fin_dist)
all_state <- bind_rows(trone_state_dist, delaney_state_dist)
all_year <- bind_rows(trone_year_dist, delaney_year_dist)

# Clarification -------------------------------------------------------------

check <- trone_data %>% 
  filter(entity_type_desc == "CANDIDATE") 
