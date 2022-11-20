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
