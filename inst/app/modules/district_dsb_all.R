# For filtering the dataset according to users' input filter
# and visualise the dataset in the "all collisions" tab

# Return filtered hk_accidents dataframe according to users' selected inputs
ddsb_filtered_hk_accidents = reactive({
  # filter by users' selected district
  hk_accidents_filtered = filter(hk_accidents, District_Council_District == input$ddsb_district_filter)

  # filter by users' selected time range
  hk_accidents_filtered = filter(hk_accidents_filtered, Year >= input$ddsb_year_filter[1] & Year <= input$ddsb_year_filter[2])

  # remove slightly injured collisions if user select "KSI only" option
  if (input$ddsb_ksi_filter == "Killed or Seriously Injuries only") {
    hk_accidents_filtered = filter(hk_accidents_filtered, Severity != "Slight")
  }

  # Show only collisions with valid lng/lat
  hk_accidents_filtered = hk_accidents_filtered %>%
    filter(!is.na(Grid_E) & !is.na(Grid_N)) %>%
    st_as_sf(coords = c("Grid_E", "Grid_N"), crs = 2326, remove = FALSE)

  print(nrow(hk_accidents_filtered))

  hk_accidents_filtered

})

# filtered hk_casualties
ddsb_filtered_hk_casualties = reactive({

  # vector of Serial No. in selected range
  serial_no_filtered = unique(ddsb_filtered_hk_accidents()[["Serial_No_"]])

  filter(hk_casualties, Serial_No_ %in% serial_no_filtered)
})

# filtered hk_vehicles
ddsb_filtered_hk_vehicles = reactive({

  # vector of Serial No. in selected range
  serial_no_filtered = unique(ddsb_filtered_hk_accidents()[["Serial_No_"]])

  filter(hk_vehicles, Serial_No_ %in% serial_no_filtered)
})

all_grid_count = reactive({
  count_collisions_in_grid(ddsb_filtered_hk_accidents())
})


# Outputs ----------------------------------

output$box_all_total_collision = renderInfoBox({
  n_collision = nrow(ddsb_filtered_hk_accidents())

  infoBox(
    title = "",
    value = format(n_collision, big.mark=","),
    subtitle = "Number of collisions in selection",
    icon = icon("car-crash"),
    color = "black"
  )
})

output$box_all_total_casualty = renderInfoBox({
  n_casualty = nrow(ddsb_filtered_hk_casualties())

  infoBox(
    title = "",
    value = format(n_casualty, big.mark=","),
    subtitle = "Number of casualties in selection",
    icon = icon("user-injured"),
    color = "black"
  )
})

output$box_all_serious_stat = renderInfoBox({
  n_serious = nrow(filter(ddsb_filtered_hk_casualties(), Degree_of_Injury == "Seriously Injured"))
  serious_per = round(n_serious / nrow(ddsb_filtered_hk_casualties()) * 100, digits = 1)

  infoBox(
    title = "",
    value = paste0(n_serious, " (", serious_per, "%)"),
    subtitle = "Serious casualties / % of total",
    icon = icon("procedures"),
    color = "orange"
  )
})

output$box_all_fatal_stat = renderInfoBox({
  n_fatal = nrow(filter(ddsb_filtered_hk_casualties(), Degree_of_Injury == "Killed"))
  fatal_per = round(n_fatal / nrow(ddsb_filtered_hk_casualties()) * 100, digits = 1)

  infoBox(
    title = "",
    subtitle = "Fatal casualties / % of total",
    value = paste0(n_fatal, " (", fatal_per, "%)"),
    icon = icon("skull-crossbones"),
    color = "red"
  )
})

# Interactive heatmap
output$ddsb_all_collision_heatmap = renderTmap({

  tm_shape(all_grid_count()) +
    tm_fill(
      col = "n_colli",
      palette = "Purples",
      n = 10,
      style = "cont",
      title = "Number of collisions",
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
  plot_data = count(ddsb_filtered_hk_accidents(), Severity, name = "count", na.rm = TRUE)

  plot_by_severity = ggplot(plot_data, aes(x = Severity, y = count, fill = Severity)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    scale_fill_manual(values = SEVERITY_COLOR) +
    theme_minimal() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    ) +
    labs(
      x = "",
      title = "Collisions by Severity"
    )

  ggplotly(plot_by_severity)
})

# Collision by year plot
output$ddsb_all_year_plot = renderPlotly({

  selected_district_data = filter(hk_accidents, District_Council_District == input$ddsb_district_filter)

  year_min = input$ddsb_year_filter[1]
  year_max = input$ddsb_year_filter[2]

  plot_data = count(ddsb_filtered_hk_accidents(), Year, name = "count", na.rm = TRUE)

  collision_year_trend_plot = ggplot(plot_data, aes(x = Year, y = count)) +
    # ggplotly does not support `ymin = -Inf, ymax = Inf`
    annotate("rect", xmin = year_min, xmax = year_max, ymin = 0, ymax = max(plot_data$count), alpha = .2, fill = "red") +
    geom_line() +
    theme_minimal() +
    theme(
      panel.grid.major.x = element_blank()
    ) +
    scale_y_continuous(limits = c(0, NA)) +
    labs(
      x = "Year",
      title = "Trend of collision in selected district"
    )

  out_plot = ggplotly(collision_year_trend_plot)

  # Disable tooltip of the annotation geom
  # https://stackoverflow.com/questions/45801389/disable-hover-information-for-a-specific-layer-geom-of-plotly
  out_plot$x$data[[1]]$hoverinfo <- "none"

  out_plot

})

# Collision type plot
output$ddsb_all_collision_type_plot = renderPlotly({

  # count by pedestrian Action
  plot_data = ddsb_filtered_hk_accidents() %>%
    count(Type_of_Collision_with_cycle, name = "count") %>%
    # reorder the drawing order from largest category
    mutate(Collision_Type_order = reorder(Type_of_Collision_with_cycle, count))

  plot_by_collision_type = ggplot(plot_data, aes(x = Collision_Type_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$accidents) +
    coord_flip() +
    theme_minimal() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none",
      plot.title.position = 'plot'
    ) +
    labs(
      x = "",
      title = "Collision type"
    )

  ggplotly(plot_by_collision_type)
})

# Vehicle Class plot
output$ddsb_all_vehicle_class_plot = renderPlotly({

  # count by Vehicle_Class
  plot_data = count(ddsb_filtered_hk_vehicles(), Vehicle_Class, name = "count", na.rm = TRUE) %>%
    # reorder vehicle class in descending order
    mutate(Vehicle_Class_order = reorder(Vehicle_Class, count))


  plot_by_vehicle_class = ggplot(plot_data, aes(x = Vehicle_Class_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$vehicles) +
    coord_flip() +
    theme_minimal() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    ) +
    labs(
      x = "",
      title = "Number of vehicles involved"
    )

  ggplotly(plot_by_vehicle_class)
})



# Road hierarchy plot
output$ddsb_all_road_hierarchy_plot = renderPlotly({

  # count by pedestrian Action
  plot_data = ddsb_filtered_hk_accidents() %>%
    filter(!is.na(Road_Hierarchy)) %>%
    count(Road_Hierarchy, name = "count") %>%
    # reorder the drawing order from largest category
    mutate(Road_Hierarchy_order = reorder(Road_Hierarchy, count))


  plot_by_road_hierarchy = ggplot(plot_data, aes(x = Road_Hierarchy_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$accidents) +
    coord_flip() +
    theme_minimal() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    ) +
    labs(
      x = "",
      title = "Hierarchy of the road where collision happened"
    )

  ggplotly(plot_by_road_hierarchy)
})
