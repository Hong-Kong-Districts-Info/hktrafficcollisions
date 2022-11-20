# Fundamental reactive functions and UI for the district dashboard

output$dsb_filter_ui = renderUI({
  selectInput(
    inputId = "ddsb_district_filter", label = "Select District",
    choices = stats::setNames(
      DISTRICT_ABBR,
      lapply(DISTRICT_FULL_NAME, function(x) i18n$t(x))
    ),
    selected = "CW"
  )
})

output$ksi_filter_ui = renderUI({
  selectInput(
    inputId = "ddsb_ksi_filter", label = "Select collision severity category",
    choices = setNames(
      c("all", "ksi_only"),
      c("All", "Killed or Seriously Injuries only")
      ),
    selected = "all"
  )
})


# Return filtered hk_accidents dataframe according to users' selected inputs
ddsb_filtered_hk_accidents = reactive({
  # filter by users' selected district
  # FIXME: Temp workaround to fix non-initialised value when district filter renders in server side
  ddsb_district_filter = if (is.null(input$ddsb_district_filter)) "CW" else input$ddsb_district_filter
  hk_accidents_filtered = filter(hk_accidents, District_Council_District == ddsb_district_filter)

  # filter by users' selected time range
  hk_accidents_filtered = filter(hk_accidents_filtered, Year >= input$ddsb_year_filter[1] & Year <= input$ddsb_year_filter[2])

  # remove slightly injured collisions if user select "KSI only" option
  # FIXME: Temp workaround to fix non-initialised value when KSI filter renders in server side
  ddsb_ksi_filter = if (is.null(input$ddsb_ksi_filter)) "all" else input$ddsb_ksi_filter

  if (ddsb_ksi_filter == "ksi_only") {
    hk_accidents_filtered = filter(hk_accidents_filtered, Severity != "Slight")
  }

  # Show only collisions with valid lng/lat
  hk_accidents_filtered = hk_accidents_filtered %>%
    filter(!is.na(Grid_E) & !is.na(Grid_N)) %>%
    st_as_sf(coords = c("Grid_E", "Grid_N"), crs = 2326, remove = FALSE)

  print(nrow(hk_accidents_filtered))

  hk_accidents_filtered

})
