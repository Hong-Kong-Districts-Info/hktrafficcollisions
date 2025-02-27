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
  filter(ddsb_filtered_hk_collisions(), collision_type_with_cycle %in% COLLISION_TYPE_WITH_CYCLES)
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
    filter(collision_type_with_cycle == "Vehicle collision with Pedal Cycle") %>%
    pull(serial_no)

  # exclude cycle when counting vehicle class
  filter(hk_vehicles, serial_no %in% serial_no_filtered & vehicle_class != "Bicycle")
})


cyc_grid_count = reactive({
  # Do not generate collision location map when "All Districts" is selected
  validate(
    need(input$ddsb_district_filter != "All Districts",
         "要查看車禍位置地圖，請於上面地區選項中選擇「全港」以外的地區。\nTo view the collision location map, please select districts other than \"All Districts\" in the district filter above"
    )
  )

  count_collisions_in_grid(ddsb_cyc_filtered_hk_collisions())
})

# Outputs ----------------------------------

# Replace renderInfoBox with variables for value_box
cyc_total_collision <- reactive({
  n_collision = nrow(ddsb_cyc_filtered_hk_collisions())
  format(n_collision, big.mark=",")
})

cyc_total_casualty <- reactive({
  n_casualty = nrow(ddsb_cyc_filtered_hk_casualties())
  format(n_casualty, big.mark=",")
})

cyc_serious_stat <- reactive({
  n_serious = nrow(filter(ddsb_cyc_filtered_hk_casualties(), injury_degree == "Seriously Injured"))
  serious_per = round(n_serious / nrow(ddsb_cyc_filtered_hk_casualties()) * 100, digits = 1)
  paste0(format(n_serious, big.mark=","), " (", serious_per, "%)")
})

cyc_fatal_stat <- reactive({
  n_fatal = nrow(filter(ddsb_cyc_filtered_hk_casualties(), injury_degree == "Killed"))
  fatal_per = round(n_fatal / nrow(ddsb_cyc_filtered_hk_casualties()) * 100, digits = 1)
  paste0(format(n_fatal, big.mark=","), " (", fatal_per, "%)")
})

# Expose the reactive values to the server.R file
observe({
  cyc_total_collision <- cyc_total_collision()
  cyc_total_casualty <- cyc_total_casualty()
  cyc_serious_stat <- cyc_serious_stat()
  cyc_fatal_stat <- cyc_fatal_stat()
})

# Original infoBox code for reference (commented out)
# output$box_cyc_total_collision = renderInfoBox({
#   n_collision = nrow(ddsb_cyc_filtered_hk_collisions())
#
#   infoBox(
#     title = "",
#     value = format(n_collision, big.mark=","),
#     subtitle = i18n$t("Total number of collisions"),
#     icon = icon("car-crash"),
#     color = "black"
#   )
# })
#
# output$box_cyc_total_casualty = renderInfoBox({
#   n_casualty = nrow(ddsb_cyc_filtered_hk_casualties())
#
#   infoBox(
#     title = "",
#     value = format(n_casualty, big.mark=","),
#     subtitle = i18n$t("Total number of casualties"),
#     icon = icon("user-injured"),
#     color = "black"
#   )
# })
#
# output$box_cyc_serious_stat = renderInfoBox({
#   n_serious = nrow(filter(ddsb_cyc_filtered_hk_casualties(), injury_degree == "Seriously Injured"))
#   serious_per = round(n_serious / nrow(ddsb_cyc_filtered_hk_casualties()) * 100, digits = 1)
#
#   infoBox(
#     title = "",
#     value = paste0(format(n_serious, big.mark=","), " (", serious_per, "%)"),
#     subtitle = i18n$t("Serious casualties (% of total)"),
#     icon = icon("procedures"),
#     color = "orange"
#   )
# })
#
# output$box_cyc_fatal_stat = renderInfoBox({
#   n_fatal = nrow(filter(ddsb_cyc_filtered_hk_casualties(), injury_degree == "Killed"))
#   fatal_per = round(n_fatal / nrow(ddsb_cyc_filtered_hk_casualties()) * 100, digits = 1)
#
#   infoBox(
#     title = "",
#     value = paste0(format(n_fatal, big.mark=","), " (", fatal_per, "%)"),
#     subtitle = i18n$t("Fatal casualties (% of total)"),
#     icon = icon("skull-crossbones"),
#     color = "red"
#   )
# })

# Interactive heatmap
output$ddsb_cyc_collision_heatmap = renderTmap({

  tm_shape(cyc_grid_count()) +
    tm_polygons(
      fill = "n_colli",
      fill.scale = tm_scale(values = "matplotlib.purples"),
      fill_alpha = 0.8,
      fill.legend = tm_legend(title = i18n$t("Number of collisions")),

      group = i18n$t("Number of collisions"),
      popup.vars = c("Number of collisions" = "n_colli")
    )

})

# Collision number by severity
output$ddsb_cyc_ksi_plot = renderPlotly({

  # count by severity
  plot_data = count(ddsb_cyc_filtered_hk_collisions(), severity, name = "count", na.rm = TRUE) %>%
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

# Collision type plot
output$ddsb_cyc_collision_type_plot = renderPlotly({

  # count by pedestrian Action
  plot_data = ddsb_cyc_filtered_hk_collisions() %>%
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
output$ddsb_cyc_vehicle_class_plot = renderPlotly({

  # count by Vehicle_Class
  plot_data = count(ddsb_cyc_filtered_hk_vehicles_wo_cycle(), vehicle_class, name = "count", na.rm = TRUE) %>%
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

# Vehicle movement plot
output$ddsb_cyc_vehicle_movement_plot = renderPlotly({

  # count by vehicle movement
  plot_data = count(ddsb_cyc_filtered_hk_vehicles_wo_cycle(), vehicle_movement, name = "count", na.rm = TRUE) %>%
    left_join(VEHICLE_MOVEMENT_TRANSLATE, by = c("vehicle_movement" = "vehicle_movement")) %>%
    # Merge both en and zh values, then reorder vehicle movement in descending order
    mutate(vehicle_movement_order = reorder(paste0(vehicle_movement_chi, " ", vehicle_movement), count))

  plot_by_vehicle_movement = ggplot(plot_data, aes(x = vehicle_movement_order, y = count)) +
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
    filter(vehicle_class == "Bicycle") %>%
    count(vehicle_movement, name = "count") %>%
    left_join(VEHICLE_MOVEMENT_TRANSLATE, by = c("vehicle_movement" = "vehicle_movement")) %>%
    # Merge both en and zh values, then reorder vehicle movement in descending order
    mutate(vehicle_movement_order = reorder(paste0(vehicle_movement_chi, " ", vehicle_movement), count))

  plot_by_vehicle_movement = ggplot(plot_data, aes(x = vehicle_movement_order, y = count)) +
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
    mutate(road_hierarchy = ifelse(is.na(road_hierarchy), "Cycle Track/Others", road_hierarchy)) %>%
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
