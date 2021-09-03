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
