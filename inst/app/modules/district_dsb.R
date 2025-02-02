# Fundamental reactive functions and UI for the district dashboard

# Translation terms

COLLISION_SEVERITY_TRANSLATE = data.frame(
  severity = c("Slight", "Serious", "Fatal"),
  severity_chi = c("輕微", "嚴重", "致命")
)

COLLISION_TYPE_TRANSLATE = data.frame(
  collision_type_with_cycle = c(
    "Vehicle collision with Vehicle", "Vehicle collision with Pedestrian", "Vehicle collision with Pedal Cycle",
    "Vehicle collision with Object", "Vehicle collision with Nothing", "Pedal Cycle collision with Pedestrian",
    "Pedal Cycle collision with Pedal Cycle", "Pedal Cycle collision with Object", "Pedal Cycle collision with Nothing",
    "Unknown vehicle collision type"
  ),
  collision_type_with_cycle_chi = c(
    "車撞車", "車撞行人", "車撞單車",
    "車撞物", "車輛沒有碰撞", "單車撞行人",
    "單車撞單車", "單車撞物", "單車沒有碰撞",
    "類別不明"
  )
)

VEHICLE_CLASS_TRANSLATE = data.frame(
  vehicle_class = c(
    "Private car", "Public franchised bus", "Taxi", "Motorcycle", "Light goods vehicle",
    "Bicycle", "Heavy goods vehicle", "Medium goods vehicle", "Tram", "Public light bus",
    "Others (incl. unknown)", "Public non-franchised bus", "Light rail vehicle"),
  vehicle_class_chi = c(
    "私家車", "公共專營巴士", "的士", "電單車", "輕型貨車",
    "單車", "重型貨車", "中型貨車", "電車", "公共小巴",
    "其他（包括類別不詳車輛）", "公共非專營巴士", "輕鐵車輛"
  )
)

# Unique vehicle movement values extracted from hk_vehicles
VEHICLE_MOVEMENT_TRANSLATE = data.frame(
  vehicle_movement = c(
    "Going straight ahead (with priority)", "Changing lanes or merging", "Overtaking on off-side",
    "Overtaking on near-side", "Going Straight Ahead (against priority)", "Making right turn", "Making left turn",
    "Making U turn", "Slowing or stopping", "Stopped in traffic", "Starting in traffic", "Leaving parking place",
    "Parked", "Reversing", "Driverless moving vehicle", "Ran off road", "Other", "Unknown"
  ),
  vehicle_movement_chi = c(
    "向前駛 （優先）", "轉換行車線", "從外線超車",
    "從內線超車", "向前駛（無優先）", "右轉", "左轉",
    "掉頭", "慢駛或停車", "因前路受阻而停車", "跟隨前面交通開車", "駛離泊車位",
    "停泊車", "倒車", "移動中而無人駕駛", "衝出馬路", "其他", "行駛情況不詳"
  )
)

PED_ACTION_TRANSLATE = data.frame(
  ped_action = c(
    "Walking - back to traffic", "Walking - facing traffic", "Standing", "Boarding vehicle",
    "Alighting from vehicle", "Falling or jumping from vehicle", "Working at a vehicle", "Other working",
    "Playing", "Crossing from near-side", "Crossing from off-side", "Not known"
  ),
  ped_action_chi = c(
    "步行 ─ 背向車流", "步行 ─ 面向車流", "站立", "正在登車",
    "正在下車", "從車上跌下或跳下", "在修車中", "其他工作",
    "在玩耍中", "從車左邊橫過馬路", "從車右邊橫過馬路", "資料不詳"
  )
)

ROAD_HIERARCHY_TRANSLATE = data.frame(
  road_hierarchy = c("Expressway", "Main Road", "Secondary Road", "Other Minor Road", "Cycle Track/Others"),
  road_hierarchy_chi = c("快速公路", "主要道路", "次要道路（內街／支路）", "小路（鄉村道路／行人徑）", "單車徑/其他")
)


# UI to be rendered

output$dsb_filter_ui = renderUI({
  selectInput(
    inputId = "ddsb_district_filter", label = i18n$t("District"),
    choices = stats::setNames(
      c("All Districts", DISTRICT_ABBR),
      lapply(c("All Districts", DISTRICT_FULL_NAME), function(x) i18n$t(x))
    ),
    selected = "All Districts"
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


# Return filtered hk_collisions dataframe according to users' selected inputs
ddsb_filtered_hk_collisions = reactive({

  # Ensure KSI filter values are initialised before filtering data
  req(
    input$ddsb_ksi_filter
  )

  # Avoid displaying red errors messages when filter values are not set correctly
  # https://shiny.posit.co/r/articles/improve/validation/
  validate(
    need(!is.null(input$ddsb_district_filter), "Please select a district"),
    need(!is.null(input$ddsb_year_filter), "Please select a year period"),
    need(!is.null(input$ddsb_ksi_filter), "Please select a KSI category")
  )

  # filter by users' selected time range
  hk_collisions_filtered = filter(hk_collisions, year >= input$ddsb_year_filter[1] & year <= input$ddsb_year_filter[2])

  if (input$ddsb_district_filter != "All Districts") {
    hk_collisions_filtered = filter(hk_collisions_filtered, district == input$ddsb_district_filter)
  }

  # remove slightly injured collisions if user select "KSI only" option
  if (input$ddsb_ksi_filter == "ksi_only") {
    hk_collisions_filtered = filter(hk_collisions_filtered, severity != "Slight")
  }

  # Show only collisions with valid lng/lat
  hk_collisions_filtered = hk_collisions_filtered %>%
    filter(!is.na(easting) & !is.na(northing)) %>%
    st_as_sf(coords = c("easting", "northing"), crs = 2326, remove = FALSE)

  hk_collisions_filtered

})
