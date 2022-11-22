# Fundamental reactive functions and UI for the district dashboard

# Translation terms

VEHICLE_CLASS_TRANSLATE = data.frame(
  Vehicle_Class = c(
    "Private car", "Public franchised bus", "Taxi", "Motorcycle", "Light goods vehicle",
    "Bicycle", "Heavy goods vehicle", "Medium goods vehicle", "Tram", "Public light bus",
    "Others (incl. unknown)", "Public non-franchised bus", "Light rail vehicle"),
  Vehicle_Class_chi = c(
    "私家車", "公共專營巴士", "的士", "電單車", "輕型貨車",
    "單車", "重型貨車", "中型貨車", "電車", "公共小巴",
    "其他（包括類別不詳車輛）", "公共非專營巴士", "輕鐵車輛"
  )
)


# UI to be rendered

output$dsb_filter_ui = renderUI({
  selectInput(
    inputId = "ddsb_district_filter", label = i18n$t("District"),
    choices = stats::setNames(
      DISTRICT_ABBR,
      lapply(DISTRICT_FULL_NAME, function(x) i18n$t(x))
    ),
    selected = "CW"
  )
})

output$ksi_filter_ui = renderUI({
  selectInput(
    inputId = "ddsb_ksi_filter", label = i18n$t("Collision severity"),
    choices = setNames(
      c("all", "ksi_only"),
      c(i18n$t("All Severities"), i18n$t("Killed or Seriously Injuries only"))
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
