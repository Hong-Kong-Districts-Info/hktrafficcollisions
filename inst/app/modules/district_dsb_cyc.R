# For filtering the dataset according to users' input filter
# and visualise the dataset in the "collisions with bicycles" tab

COLLISION_TYPE_WITH_CYCLES = c(
  "Pedal Cycle collision with Nothing",
  "Pedal Cycle collision with Pedestrian",
  "Vehicle collision with Pedal Cycle",
  "Pedal Cycle collision with Object",
  "Pedal Cycle collision with Pedal Cycle"
  )

# Only return collisions with bicycles involved
ddsb_cyc_filtered_hk_accidents = reactive({
  filter(ddsb_filtered_hk_accidents(), Type_of_Collision_with_cycle %in% COLLISION_TYPE_WITH_CYCLES)
})

# filtered hk_casualties with bicycles involved only
ddsb_cyc_filtered_hk_casualties = reactive({

  serial_no_filtered = unique(ddsb_cyc_filtered_hk_accidents()[["Serial_No_"]])

  filter(hk_casualties, Serial_No_ %in% serial_no_filtered)
})

# filtered hk_vehicles with bicycles involved only
ddsb_cyc_filtered_hk_vehicles = reactive({

  serial_no_filtered = unique(ddsb_cyc_filtered_hk_accidents()[["Serial_No_"]])

  filter(hk_vehicles, Serial_No_ %in% serial_no_filtered)
})

cyc_grid_count = reactive({
  count_collisions_in_grid(ddsb_cyc_filtered_hk_accidents())
})

# Outputs ----------------------------------

output$box_cyc_total_collision = renderInfoBox({
  n_collision = nrow(ddsb_cyc_filtered_hk_accidents())

  infoBox(
    title = "",
    value = format(n_collision, big.mark=","),
    subtitle = "Number of collisions in selection",
    icon = icon("car-crash"),
    color = "blue"
  )
})

output$box_cyc_total_casualty = renderInfoBox({
  n_casualty = nrow(ddsb_cyc_filtered_hk_casualties())

  infoBox(
    title = "",
    value = format(n_casualty, big.mark=","),
    subtitle = "Number of casualties in selection",
    icon = icon("user-injured"),
    color = "blue"
  )
})

output$box_cyc_serious_stat = renderInfoBox({
  n_serious = nrow(filter(ddsb_cyc_filtered_hk_casualties(), Degree_of_Injury == "Seriously Injured"))
  serious_per = round(n_serious / nrow(ddsb_cyc_filtered_hk_casualties()) * 100, digits = 1)

  infoBox(
    title = "",
    value = paste0(n_serious, " (", serious_per, "%)"),
    subtitle = "Serious casualties / % of total",
    icon = icon("procedures"),
    color = "red"
  )
})

output$box_cyc_fatal_stat = renderInfoBox({
  n_fatal = nrow(filter(ddsb_cyc_filtered_hk_casualties(), Degree_of_Injury == "Killed"))
  fatal_per = round(n_fatal / nrow(ddsb_cyc_filtered_hk_casualties()) * 100, digits = 1)

  infoBox(
    title = "",
    subtitle = "Fatal casualties / % of total",
    value = paste0(n_fatal, " (", fatal_per, "%)"),
    icon = icon("skull-crossbones"),
    color = "navy"
  )
})


# Interactive heatmap
output$ddsb_cyc_collision_heatmap = renderTmap({

  tm_shape(cyc_grid_count()) +
    tm_fill(
      col = "n_colli",
      palette = "YlOrRd",
      n = 10,
      style = "cont",
      title = "Number of collisions",
      id = "n_colli",
      showNA = FALSE,
      alpha = 0.8,
      # disable popups
      popup.vars = FALSE,
    ) +
    tm_borders(col = "white", lwd = 0.7)

})

# Collision number by severity
output$ddsb_cyc_ksi_plot = renderPlotly({

  # count by severity
  plot_data = count(ddsb_cyc_filtered_hk_accidents(), Severity, name = "count", na.rm = TRUE)

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

# Vehicle Class plot
output$ddsb_cyc_vehicle_class_plot = renderPlotly({

  # count by Vehicle_Class
  plot_data = count(ddsb_cyc_filtered_hk_vehicles(), Vehicle_Class, name = "count", na.rm = TRUE) %>%
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

# Vehicle movement plot
output$ddsb_cyc_vehicle_movement_plot = renderPlotly({

  # count by Vehicle_Class
  plot_data = count(ddsb_cyc_filtered_hk_vehicles(), Main_vehicle, name = "count") %>%
    # reorder vehicle class in descending order
    mutate(Main_vehicle_order = reorder(Main_vehicle, count))


  plot_by_vehicle_movement = ggplot(plot_data, aes(x = Main_vehicle_order, y = count)) +
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
      title = "Vehicle movements at accident"
    )

  ggplotly(plot_by_vehicle_movement)
})
