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

# DonationMap <-
#   leaflet(lat_long_tbl) %>%
#   addTiles() %>%
#   addCircleMarkers(radius = 0.5, color = "red") %>%
#   addMarkers(lng = -77.00, lat = 38.88, popup = "Delaney & Trone HQ") %>% 
#   setView(-98.55, 39.80, zoom = 4) # middle of the US
# DonationMap

DonationMap <-
  leaflet(lat_long_tbl) %>%
  addTiles() %>%
  addCircleMarkers(
    radius = 0.5,
    color = ~case_when(
      committee_name == "DAVID TRONE FOR CONGRESS" ~ "blue",
      committee_name == "APRIL MCCLAIN DELANEY FOR CONGRESS" ~ "red"
    )
  ) %>%
  addMarkers(lng = -77.00, lat = 38.88, popup = "Delaney & Trone HQ") %>% 
  setView(-98.55, 39.80, zoom = 4)

DonationMap

# Candidate Earnings by Year ----------------------------------------------

## Identify maximum donation value
max_callouts <- all_year %>% 
  group_by(candidate) %>% 
  slice_max(total, n = 1, with_ties = FALSE)
max_callouts

## Build base line plot
base_plot <- 
  ggplot(all_year) +
  aes(
    x = report_year,
    y = total,
    colour = candidate,
    group = candidate
  ) +
  geom_line() +
  ggtitle(label = "Financial Contribution by Year", subtitle = "All Time") + 
  theme_bw()

## Add call out values to max points
max_values <- base_plot +
  geom_segment(
  data = max_callouts,
  aes(
    x = report_year - 5,
    y = total,
    xend = report_year - 0.5,
    yend = total - 5000
  )
) +
  geom_point(
    data = max_callouts,
    size = 3
  ) 
max_values
    
  