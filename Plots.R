
# Load Packages -----------------------------------------------------------
library(sf)
library(terra)
library(dplyr)
library(tmap)    # for static and interactive maps
library(leaflet) # for interactive maps
library(ggplot2) # tidyverse data visualization package
library(usmap)
# Campaign Contribution by Entity Type ------------------------------------
ggplot(all_dist) + 
  aes(x = entity_type_desc, y = total, fill = candidate) +
  geom_col(position = "dodge") +
  
  geom_text(
    aes(label = scales::comma(total)),
    position = position_dodge(width = 0.9),
    vjust = -0.3,
    size = 3
  ) +
  
  theme(
    panel.grid.minor = element_blank(),
    plot.margin = margin(6, 8, 6, 8),
    # axis.text.x = element_text(angle = 40, hjust = 1, vjust = 1),
    legend.position = "bottom"
  ) +
  
  labs(
    title = "Contribution Totals by Entity Type",
    x = NULL,
    y = "Total Contributions"
  )

# Campaign Contribution by State ------------------------------------
# https://r.geocompx.org/adv-map

ggplot(all_state) + 
  aes(x = candidate, y = total, fill = state) +
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
plot_usmap(
  data = all_state,
  values = "total",
  include = unique(all_state$state),
  color = "red"
) + 
  scale_fill_continuous(
    low = "white",
    high = "red",
    name = "Contribution Amount",
    labels = scales::dollar
  ) + 
  labs(title = "Northeastern United States") +
  theme(legend.position = "right")

plot_usmap(data = all_state, values = "total", color = "red") + 
  scale_fill_continuous(name = "Contribution Amount", labels = scales::comma) + 
  theme(legend.position = "right")
