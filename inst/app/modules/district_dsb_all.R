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
