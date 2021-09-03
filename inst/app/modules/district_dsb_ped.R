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
