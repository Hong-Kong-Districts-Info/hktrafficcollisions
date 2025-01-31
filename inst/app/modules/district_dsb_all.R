# For filtering the dataset according to users' input filter
# and visualise the dataset in the "all collisions" tab

# filtered hk_casualties
ddsb_filtered_hk_casualties = reactive({

  # vector of Serial No. in selected range
  serial_no_filtered = unique(ddsb_filtered_hk_collisions()[["serial_no"]])

  filter(hk_casualties, serial_no %in% serial_no_filtered)
})

# filtered hk_vehicles
ddsb_filtered_hk_vehicles = reactive({

  # vector of Serial No. in selected range
  serial_no_filtered = unique(ddsb_filtered_hk_collisions()[["serial_no"]])

  filter(hk_vehicles, serial_no %in% serial_no_filtered)
})

all_grid_count = reactive({
  # Do not generate collision location map when "All Districts" is selected
  validate(
    need(input$ddsb_district_filter != "All Districts",
         "要查看車禍位置地圖，請於上面地區選項中選擇「全港」以外的地區。\nTo view the collision location map, please select districts other than \"All Districts\" in the district filter above"
    )
  )

  count_collisions_in_grid(ddsb_filtered_hk_collisions())
})


# Outputs ----------------------------------

output$box_all_total_collision = renderInfoBox({
  n_collision = nrow(ddsb_filtered_hk_collisions())

  infoBox(
    title = "",
    value = format(n_collision, big.mark=","),
    subtitle = i18n$t("Total number of collisions"),
    icon = icon("car-crash"),
    color = "black"
  )
})

output$box_all_total_casualty = renderInfoBox({
  n_casualty = nrow(ddsb_filtered_hk_casualties())

  infoBox(
    title = "",
    value = format(n_casualty, big.mark=","),
    subtitle = i18n$t("Total number of casualties"),
    icon = icon("user-injured"),
    color = "black"
  )
})

output$box_all_serious_stat = renderInfoBox({
  n_serious = nrow(filter(ddsb_filtered_hk_casualties(), injury_degree == "Seriously Injured"))
  serious_per = round(n_serious / nrow(ddsb_filtered_hk_casualties()) * 100, digits = 1)

  infoBox(
    title = "",
    value = paste0(n_serious, " (", serious_per, "%)"),
    subtitle = i18n$t("Serious casualties (% of total)"),
    icon = icon("procedures"),
    color = "orange"
  )
})

output$box_all_fatal_stat = renderInfoBox({
  n_fatal = nrow(filter(ddsb_filtered_hk_casualties(), injury_degree == "Killed"))
  fatal_per = round(n_fatal / nrow(ddsb_filtered_hk_casualties()) * 100, digits = 1)

  infoBox(
    title = "",
    subtitle = i18n$t("Fatal casualties (% of total)"),
    value = paste0(n_fatal, " (", fatal_per, "%)"),
    icon = icon("skull-crossbones"),
    color = "red"
  )
})

# Interactive heatmap
output$ddsb_all_collision_heatmap = renderTmap({

  tm_shape(all_grid_count()) +
    tm_fill(
      group = i18n$t("Number of collisions"),
      col = "n_colli",
      palette = "Purples",
      n = 10,
      style = "cont",
      title = i18n$t("Number of collisions"),
      id = "n_colli",
      showNA = FALSE,
      alpha = 0.8,
      # disable popups
      popup.vars = FALSE,
    ) +
    tm_borders(col = "#232323", lwd = 0.7)

})

# Collision number by severity
output$ddsb_all_ksi_plot = renderPlotly({

  # count by severity
  plot_data = count(ddsb_filtered_hk_collisions(), severity, name = "count", na.rm = TRUE) %>%
    left_join(COLLISION_SEVERITY_TRANSLATE, by = "severity") %>%
    # Force order of the categorical axis
    # Factor in reversed order since last element in factor is plotted on top in ggplot
    mutate(severity_text = factor(paste0(severity_chi, "\n", severity), c("致命\nFatal", "嚴重\nSerious", "輕微\nSlight")))

  plot_by_severity = ggplot(plot_data, aes(x = severity_text, y = count, fill = severity)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    scale_fill_manual(values = SEVERITY_COLOR) +
    theme_minimal() +
    theme(
      axis.title.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    )

  ggplotly(plot_by_severity)
})

# Collision by year plot
output$ddsb_all_year_plot = renderPlotly({

  plot_data = count(ddsb_filtered_hk_collisions(), year, name = "count", na.rm = TRUE)

  collision_year_trend_plot = ggplot(plot_data, aes(x = year, y = count)) +
    geom_line() +
    theme_minimal() +
    theme(
      panel.grid.major.x = element_blank()
    ) +
    scale_y_continuous(limits = c(0, NA)) +
    labs(x = "Year")

  ggplotly(collision_year_trend_plot)

})

# Collision type plot
output$ddsb_all_collision_type_plot = renderPlotly({

  # count by pedestrian Action
  plot_data = ddsb_filtered_hk_collisions() %>%
    count(collision_type_with_cycle, name = "count") %>%
    left_join(COLLISION_TYPE_TRANSLATE, by = c("collision_type_with_cycle" = "collision_type_with_cycle")) %>%
    # Merge both en and zh values, then reorder vehicle class in descending order
    mutate(collision_type_with_cycle_order = reorder(paste0(collision_type_with_cycle_chi, "\n", collision_type_with_cycle), count))


  plot_by_collision_type = ggplot(plot_data, aes(x = collision_type_with_cycle_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$collisions) +
    coord_flip() +
    theme_minimal() +
    theme(
      axis.title.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    )

  ggplotly(plot_by_collision_type)
})


# Vehicle Class plot
output$ddsb_all_vehicle_class_plot = renderPlotly({

  # count by Vehicle_Class
  plot_data = count(ddsb_filtered_hk_vehicles(), vehicle_class, name = "count", na.rm = TRUE) %>%
    left_join(VEHICLE_CLASS_TRANSLATE, by = c("vehicle_class" = "vehicle_class")) %>%
    # Merge both en and zh values, then reorder vehicle class in descending order
    mutate(vehicle_class_order = reorder(paste0(vehicle_class_chi, "\n", vehicle_class), count))

  plot_by_vehicle_class = ggplot(plot_data, aes(x = vehicle_class_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$vehicles) +
    coord_flip() +
    theme_minimal() +
    theme(
      axis.title.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    )

  ggplotly(plot_by_vehicle_class)
})



# Road hierarchy plot
output$ddsb_all_road_hierarchy_plot = renderPlotly({

  # count by pedestrian Action
  plot_data = ddsb_filtered_hk_collisions() %>%
    filter(!is.na(road_hierarchy)) %>%
    count(road_hierarchy, name = "count") %>%
    left_join(ROAD_HIERARCHY_TRANSLATE, by = c("road_hierarchy" = "road_hierarchy")) %>%
    # Merge both en and zh values, then reorder vehicle class in descending order
    mutate(road_hierarchy_order = reorder(paste0(road_hierarchy_chi, "\n", road_hierarchy), count))


  plot_by_road_hierarchy = ggplot(plot_data, aes(x = road_hierarchy_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$collisions) +
    coord_flip() +
    theme_minimal() +
    theme(
      axis.title.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    )

  ggplotly(plot_by_road_hierarchy)
})
