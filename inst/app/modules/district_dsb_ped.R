# For filtering the dataset according to users' input filter
# and visualise the dataset in the "collisions with pedestrian" tab

# Only return collisions with pedestrian involved
ddsb_ped_filtered_hk_accidents = reactive({
  filter(ddsb_filtered_hk_accidents(), Type_of_Collision == "Vehicle collision with Pedestrian")
})

# filtered hk_casualties with pedestrian involved only
ddsb_ped_filtered_hk_casualties = reactive({

  serial_no_filtered = unique(ddsb_ped_filtered_hk_accidents()[["Serial_No_"]])

  filter(hk_casualties, Serial_No_ %in% serial_no_filtered)
})

# filtered hk_vehicles with pedestrian involved only
ddsb_ped_filtered_hk_vehicles = reactive({

  serial_no_filtered = unique(ddsb_ped_filtered_hk_accidents()[["Serial_No_"]])

  filter(hk_vehicles, Serial_No_ %in% serial_no_filtered)
})

ped_grid_count = reactive({
  count_collisions_in_grid(ddsb_ped_filtered_hk_accidents())
})


# Outputs ----------------------------------

output$box_ped_total_collision = renderValueBox({
  n_collision = nrow(ddsb_ped_filtered_hk_accidents())

  valueBox(
    value = format(n_collision, big.mark=","),
    subtitle = "Number of collisions in selection",
    icon = icon("car-crash"),
    color = "blue"
  )
})

output$box_ped_total_casualty = renderValueBox({
  n_casualty = nrow(ddsb_ped_filtered_hk_casualties())

  valueBox(
    value = format(n_casualty, big.mark=","),
    subtitle = "Number of casualties in selection",
    icon = icon("user-injured"),
    color = "blue"
  )
})

output$box_ped_serious_stat = renderValueBox({
  n_serious = nrow(filter(ddsb_ped_filtered_hk_casualties(), Degree_of_Injury == "Seriously Injured"))
  serious_per = round(n_serious / nrow(ddsb_ped_filtered_hk_casualties()) * 100, digits = 1)

  valueBox(
    value = paste0(n_serious, " (", serious_per, "%)"),
    subtitle = "Serious casualties / % of total",
    icon = icon("procedures"),
    color = "red"
  )
})

output$box_ped_fatal_stat = renderValueBox({
  n_fatal = nrow(filter(ddsb_ped_filtered_hk_casualties(), Degree_of_Injury == "Killed"))
  fatal_per = round(n_fatal / nrow(ddsb_ped_filtered_hk_casualties()) * 100, digits = 1)

  valueBox(
    value = paste0(n_fatal, " (", fatal_per, "%)"),
    subtitle = "Fatal casualties / % of total",
    # Change icon color manually
    # Default color from shinydashboard.css is rgba(0, 0, 0, 0.15);
    icon = tags$i(class = "fas fa-skull-crossbones", role = "presentation", style = "color: rgba(240, 240, 240, 0.15);"),
    color = "navy"
  )
})

# Interactive heatmap
output$ddsb_ped_collision_heatmap = renderTmap({

  tm_shape(ped_grid_count()) +
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
output$ddsb_ped_ksi_plot = renderPlotly({

  # count by severity
  plot_data = count(ddsb_ped_filtered_hk_accidents(), Severity, name = "count")

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
output$ddsb_ped_vehicle_class_plot = renderPlotly({

  # count by Vehicle_Class
  plot_data = count(ddsb_ped_filtered_hk_vehicles(), Vehicle_Class, name = "count") %>%
    # reorder vehicle class in descending order
    mutate(Vehicle_Class_order = reorder(Vehicle_Class, count))


  plot_by_vehicle_class = ggplot(plot_data, aes(x = Vehicle_Class_order, y = count)) +
    geom_bar(stat = "identity") +
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
output$ddsb_ped_vehicle_movement_plot = renderPlotly({

  # count by Vehicle_Class
  plot_data = count(ddsb_ped_filtered_hk_vehicles(), Main_vehicle, name = "count") %>%
    # reorder vehicle class in descending order
    mutate(Main_vehicle_order = reorder(Main_vehicle, count))


  plot_by_vehicle_movement = ggplot(plot_data, aes(x = Main_vehicle_order, y = count)) +
    geom_bar(stat = "identity") +
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

# Pedestrian Action plot
output$ddsb_ped_ped_action_plot = renderPlotly({

  # count by pedestrian Action
  plot_data = count(ddsb_ped_filtered_hk_casualties(), Ped_Action, name = "count") %>%
    # reorder the drawing order from largest category
    mutate(Ped_Action_order = reorder(Ped_Action, count))


  plot_by_ped_action = ggplot(plot_data, aes(x = Ped_Action_order, y = count)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    theme_minimal() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    ) +
    labs(
      x = "",
      title = "Pedestrian action at accident"
    )

  ggplotly(plot_by_ped_action)
})

# Road hierarchy plot
output$ddsb_ped_road_hierarchy_plot = renderPlotly({

  # count by pedestrian Action
  plot_data = count(ddsb_ped_filtered_hk_accidents(), Road_Hierarchy, name = "count") %>%
    # reorder the drawing order from largest category
    mutate(Road_Hierarchy_order = reorder(Road_Hierarchy, count))


  plot_by_road_hierarchy = ggplot(plot_data, aes(x = Road_Hierarchy_order, y = count)) +
    geom_bar(stat = "identity") +
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
