# Load Packages -----------------------------------------------------------
library(sf)
library(terra)
library(dplyr)
library(tmap)
library(ggspatial)
library(ggplot2)
library(maps)
library(leaflet)
library(prettymapr)
# Campaign Contribution by Entity Type ------------------------------------
ggplot(all_dist) + 
  aes(x = entity_type_desc, y = total, fill = candidate) +
  geom_col(position = "dodge", stat = "identity") +
  
  geom_text(
    aes(label = scales::comma(total)),
    position = position_dodge(width = 0.9),
    vjust = -0.3,
    size = 3
  ) +
  
  theme(
    panel.grid.minor = element_blank(),
    plot.margin = margin(6, 8, 6, 8),
    axis.text.y = element_text(angle = 40, hjust = 1, vjust = 1),
    legend.position = "bottom"
  ) +
  
  scale_y_continuous(labels = dollar) +
  
  labs(
    title = "Contribution Totals by Entity Type",
    x = NULL,
    y = "Total Contributions"
  )

# Campaign Contribution by State ------------------------------------
# https://r.geocompx.org/adv-map

ggplot(all_state) + 
  aes(x = candidate, y = total, fill = contributor_state) +
  geom_bar(position = "stack", stat = "identity") +
  
  # geom_text(
  #   aes(label = scales::comma(total)),
  #   position = position_dodge(width = 0.9),
  #   vjust = -0.3,
  #   size = 3
  # ) +
  
  theme(
    panel.grid.minor = element_blank(),
    plot.margin = margin(6, 8, 6, 8),
    axis.text.y = element_text(angle = 40, hjust = 1, vjust = 1),
    legend.position = "bottom"
  ) +
  
  scale_y_continuous(labels = dollar) +
  
  labs(
    title = "Contribution Totals by State",
    x = NULL,
    y = "Total Contributions"
  )


# State Contribution Map [WIP] ----------------------------------------------
## https://forum.posit.co/t/how-to-make-markers-have-different-colors-based-on-specific-variable-in-data-frame-using-leaflet-map/186922/3

max_contributor <- lat_long_tbl %>% 
  filter(contributor_name != "ACTBLUE") %>% 
  group_by(committee_name, contributor_name) %>% 
  summarise(
    sum_val = sum(contribution_receipt_amount),
    Latitude = mean(Latitude, na.rm = TRUE),
    Longitude = mean(Longitude, na.rm = TRUE),
    contributor_state = first(na.omit(contributor_state)),
    contributor_city = first(na.omit(contributor_city)),
    .groups = "drop"
  ) %>% 
  group_by(committee_name) %>% 
  slice_max(sum_val, n = 5) %>% 
  ungroup()

DonationMap <-
  leaflet(lat_long_tbl) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~Longitude,
    lat = ~Latitude,
    radius = 0.5,
    color = ~case_when(
      committee_name == "DAVID TRONE FOR CONGRESS" ~ "blue",
      committee_name == "APRIL MCCLAIN DELANEY FOR CONGRESS" ~ "red"
    )
  ) %>%
  addMarkers(
    data = max_contributor,
    lng = ~Longitude,
    lat = ~Latitude,
    popup = ~paste0(
      "<b>TOP CONTRIBUTOR</b><br>",
      "Contributor: ", contributor_name, "<br>",
      "Contributor State: ", contributor_city, ", ", contributor_state, "<br>",
      "Recipient : ", committee_name, "<br>",
      "Total: $", comma(sum_val)
    )
  ) %>%
  setView(-98.55, 39.80, zoom = 4)
DonationMap