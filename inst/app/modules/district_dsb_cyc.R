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
ddsb_cyc_filtered_hk_collisions = reactive({
  filter(ddsb_filtered_hk_collisions(), Type_of_Collision_with_cycle %in% COLLISION_TYPE_WITH_CYCLES)
})

# filtered hk_casualties with bicycles involved only
ddsb_cyc_filtered_hk_casualties = reactive({

  serial_no_filtered = unique(ddsb_cyc_filtered_hk_collisions()[["serial_no"]])

  filter(hk_casualties, serial_no %in% serial_no_filtered)
})

# filtered hk_vehicles with bicycles involved only
ddsb_cyc_filtered_hk_vehicles = reactive({

  serial_no_filtered = unique(ddsb_cyc_filtered_hk_collisions()[["serial_no"]])

  filter(hk_vehicles, serial_no %in% serial_no_filtered)
})

# Cycle-related vehicle collision, yet exclude cycle in vehicles
ddsb_cyc_filtered_hk_vehicles_wo_cycle = reactive({

  serial_no_filtered = ddsb_cyc_filtered_hk_collisions() %>%
    filter(Type_of_Collision_with_cycle == "Vehicle collision with Pedal Cycle") %>%
    pull(serial_no)

  # exclude cycle when counting vehicle class
  filter(hk_vehicles, serial_no %in% serial_no_filtered & Vehicle_Class != "Bicycle")
})


cyc_grid_count = reactive({
  count_collisions_in_grid(ddsb_cyc_filtered_hk_collisions())
})

# Outputs ----------------------------------

output$box_cyc_total_collision = renderInfoBox({
  n_collision = nrow(ddsb_cyc_filtered_hk_collisions())

  infoBox(
    title = "",
    value = format(n_collision, big.mark=","),
    subtitle = i18n$t("Total number of collisions"),
    icon = icon("car-crash"),
    color = "black"
  )
})

output$box_cyc_total_casualty = renderInfoBox({
  n_casualty = nrow(ddsb_cyc_filtered_hk_casualties())

  infoBox(
    title = "",
    value = format(n_casualty, big.mark=","),
    subtitle = i18n$t("Total number of casualties"),
    icon = icon("user-injured"),
    color = "black"
  )
})

output$box_cyc_serious_stat = renderInfoBox({
  n_serious = nrow(filter(ddsb_cyc_filtered_hk_casualties(), Degree_of_Injury == "Seriously Injured"))
  serious_per = round(n_serious / nrow(ddsb_cyc_filtered_hk_casualties()) * 100, digits = 1)

  infoBox(
    title = "",
    value = paste0(n_serious, " (", serious_per, "%)"),
    subtitle = i18n$t("Serious casualties (% of total)"),
    icon = icon("procedures"),
    color = "orange"
  )
})

output$box_cyc_fatal_stat = renderInfoBox({
  n_fatal = nrow(filter(ddsb_cyc_filtered_hk_casualties(), Degree_of_Injury == "Killed"))
  fatal_per = round(n_fatal / nrow(ddsb_cyc_filtered_hk_casualties()) * 100, digits = 1)

  infoBox(
    title = "",
    subtitle = i18n$t("Fatal casualties (% of total)"),
    value = paste0(n_fatal, " (", fatal_per, "%)"),
    icon = icon("skull-crossbones"),
    color = "red"
  )
})


# Interactive heatmap
output$ddsb_cyc_collision_heatmap = renderTmap({

  tm_shape(cyc_grid_count()) +
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
output$ddsb_cyc_ksi_plot = renderPlotly({

  # count by severity
  plot_data = count(ddsb_cyc_filtered_hk_collisions(), Severity, name = "count", na.rm = TRUE) %>%
    left_join(COLLISION_SEVERITY_TRANSLATE, by = "Severity") %>%
    # Force order of the categorical axis
    # Factor in reversed order since last element in factor is plotted on top in ggplot
    mutate(Severity_text = factor(paste0(Severity_chi, "\n", Severity), c("致命\nFatal", "嚴重\nSerious", "輕微\nSlight")))

  plot_by_severity = ggplot(plot_data, aes(x = Severity_text, y = count, fill = Severity)) +
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

# Collision type plot
output$ddsb_cyc_collision_type_plot = renderPlotly({

  # count by pedestrian Action
  plot_data = ddsb_cyc_filtered_hk_collisions() %>%
    count(Type_of_Collision_with_cycle, name = "count") %>%
    left_join(COLLISION_TYPE_TRANSLATE, by = c("Type_of_Collision_with_cycle" = "Collision_Type")) %>%
    # Merge both en and zh values, then reorder vehicle class in descending order
    mutate(Collision_Type_order = reorder(paste0(Collision_Type_chi, "\n", Type_of_Collision_with_cycle), count))

  plot_by_collision_type = ggplot(plot_data, aes(x = Collision_Type_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$accidents) +
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
output$ddsb_cyc_vehicle_class_plot = renderPlotly({

  # count by Vehicle_Class
  plot_data = count(ddsb_cyc_filtered_hk_vehicles_wo_cycle(), Vehicle_Class, name = "count", na.rm = TRUE) %>%
    left_join(VEHICLE_CLASS_TRANSLATE, by = c("Vehicle_Class" = "Vehicle_Class")) %>%
    # Merge both en and zh values, then reorder vehicle class in descending order
    mutate(Vehicle_Class_order = reorder(paste0(Vehicle_Class_chi, "\n", Vehicle_Class), count))

  plot_by_vehicle_class = ggplot(plot_data, aes(x = Vehicle_Class_order, y = count)) +
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

# Vehicle movement plot
output$ddsb_cyc_vehicle_movement_plot = renderPlotly({

  # count by vehicle movement
  plot_data = count(ddsb_cyc_filtered_hk_vehicles_wo_cycle(), Main_vehicle, name = "count", na.rm = TRUE) %>%
    left_join(VEHICLE_MOVEMENT_TRANSLATE, by = c("Main_vehicle" = "Main_vehicle")) %>%
    # Merge both en and zh values, then reorder vehicle movement in descending order
    mutate(Main_vehicle_order = reorder(paste0(Main_vehicle_chi, " ", Main_vehicle), count))

  plot_by_vehicle_movement = ggplot(plot_data, aes(x = Main_vehicle_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$vehicles) +
    coord_flip() +
    theme_minimal() +
    theme(
      axis.title.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    )

  ggplotly(plot_by_vehicle_movement)
})

# Cyclist action plot
output$ddsb_cyc_cyc_action_plot = renderPlotly({

  # As cyclist are deemed drivers of pedal cycle,
  # cyclist actions are referenced by vehicle movement in the hk_vehicles dataset
  plot_data = ddsb_cyc_filtered_hk_vehicles() %>%
    # only select vehicles that are pedal cycles
    filter(Pedal_cycle == "Pedal Cycle") %>%
    count(Main_vehicle, name = "count") %>%
    left_join(VEHICLE_MOVEMENT_TRANSLATE, by = c("Main_vehicle" = "Main_vehicle")) %>%
    # Merge both en and zh values, then reorder vehicle movement in descending order
    mutate(Main_vehicle_order = reorder(paste0(Main_vehicle_chi, " ", Main_vehicle), count))

  plot_by_vehicle_movement = ggplot(plot_data, aes(x = Main_vehicle_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$casualties) +
    coord_flip() +
    theme_minimal() +
    theme(
      axis.title.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    )

  ggplotly(plot_by_vehicle_movement)

})

# Road hierarchy plot
output$ddsb_cyc_road_hierarchy_plot = renderPlotly({

  # count by road hierarchy
  plot_data = ddsb_cyc_filtered_hk_collisions() %>%
    # For cycle-related collisions, Road_Hierarchy == -99 in original data (transformed in NA)
    # implies the collision happened in cycle track
    # Most cycle-related collisions with Road_Hierarchy of NA are actually happened in cycle tracks
    mutate(Road_Hierarchy = ifelse(is.na(Road_Hierarchy), "Cycle Track/Others", Road_Hierarchy)) %>%
    count(Road_Hierarchy, name = "count") %>%
    left_join(ROAD_HIERARCHY_TRANSLATE, by = c("Road_Hierarchy" = "Road_Hierarchy")) %>%
    # Merge both en and zh values, then reorder vehicle class in descending order
    mutate(Road_Hierarchy_order = reorder(paste0(Road_Hierarchy_chi, "\n", Road_Hierarchy), count))


  plot_by_road_hierarchy = ggplot(plot_data, aes(x = Road_Hierarchy_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$accidents) +
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
