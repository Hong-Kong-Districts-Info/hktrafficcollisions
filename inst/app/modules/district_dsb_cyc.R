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
