# For filtering the dataset according to users' input filter
# and visualise the dataset in the "collisions with pedestrian" tab

# Only return collisions with pedestrian involved
ddsb_ped_filtered_hk_collisions = reactive({
  filter(ddsb_filtered_hk_collisions(), collision_type_with_cycle == "Vehicle collision with Pedestrian")
})

# filtered hk_casualties with pedestrian involved only
ddsb_ped_filtered_hk_casualties = reactive({

  serial_no_filtered = unique(ddsb_ped_filtered_hk_collisions()[["serial_no"]])

  filter(hk_casualties, serial_no %in% serial_no_filtered)
})

# filtered hk_vehicles with pedestrian involved only
ddsb_ped_filtered_hk_vehicles = reactive({

  serial_no_filtered = unique(ddsb_ped_filtered_hk_collisions()[["serial_no"]])

  filter(hk_vehicles, serial_no %in% serial_no_filtered)
})

ped_grid_count = reactive({
  # Do not generate collision location map when "All Districts" is selected
  validate(
    need(input$ddsb_district_filter != "All Districts",
         "要查看車禍位置地圖，請於上面地區選項中選擇「全港」以外的地區。\nTo view the collision location map, please select districts other than \"All Districts\" in the district filter above"
         )
  )

  count_collisions_in_grid(ddsb_ped_filtered_hk_collisions())
})


# Outputs ----------------------------------

# Replace renderInfoBox with variables for value_box
output$ped_total_collision <- renderText({
  n_collision = nrow(ddsb_ped_filtered_hk_collisions())
  format(n_collision, big.mark=",")
})

output$ped_total_casualty <- renderText({
  n_casualty = nrow(ddsb_ped_filtered_hk_casualties())
  format(n_casualty, big.mark=",")
})

output$ped_serious_stat <- renderText({
  n_serious = nrow(filter(ddsb_ped_filtered_hk_casualties(), injury_degree == "Seriously Injured"))
  serious_per = round(n_serious / nrow(ddsb_ped_filtered_hk_casualties()) * 100, digits = 1)
  paste0(format(n_serious, big.mark=","), " (", serious_per, "%)")
})

output$ped_fatal_stat <- renderText({
  n_fatal = nrow(filter(ddsb_ped_filtered_hk_casualties(), injury_degree == "Killed"))
  fatal_per = round(n_fatal / nrow(ddsb_ped_filtered_hk_casualties()) * 100, digits = 1)
  paste0(format(n_fatal, big.mark=","), " (", fatal_per, "%)")
})


# Interactive heatmap
output$ddsb_ped_collision_heatmap = renderTmap({

  tm_shape(ped_grid_count()) +
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
output$ddsb_ped_ksi_plot = renderPlotly({

  # count by severity
  plot_data = count(ddsb_ped_filtered_hk_collisions(), severity, name = "count", na.rm = TRUE) %>%
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

# Vehicle Class plot
output$ddsb_ped_vehicle_class_plot = renderPlotly({

  # count by vehicle class
  plot_data = count(ddsb_ped_filtered_hk_vehicles(), vehicle_class, name = "count", na.rm = TRUE) %>%
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
output$ddsb_ped_vehicle_movement_plot = renderPlotly({

  # count by vehicle movement
  plot_data = count(ddsb_ped_filtered_hk_vehicles(), vehicle_movement, name = "count") %>%
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

# Pedestrian Action plot
output$ddsb_ped_ped_action_plot = renderPlotly({

  # count by pedestrian Action
  plot_data = ddsb_ped_filtered_hk_casualties() %>%
    filter(!is.na(ped_action)) %>%
    count(ped_action, name = "count") %>%
    left_join(PED_ACTION_TRANSLATE, by = c("ped_action" = "ped_action")) %>%
    # Merge both en and zh values, then reorder vehicle class in descending order
    mutate(ped_action_order = reorder(paste0(ped_action_chi, "\n", ped_action), count))


  plot_by_ped_action = ggplot(plot_data, aes(x = ped_action_order, y = count)) +
    geom_bar(stat = "identity", fill = CATEGORY_COLOR$casualties) +
    coord_flip() +
    theme_minimal() +
    theme(
      axis.title.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      legend.position = "none"
    )

  ggplotly(plot_by_ped_action)
})

# Road hierarchy plot
output$ddsb_ped_road_hierarchy_plot = renderPlotly({

  # count by pedestrian Action
  plot_data = ddsb_ped_filtered_hk_collisions() %>%
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
