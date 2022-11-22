# Fundamental reactive functions and UI for the district dashboard

# Translation terms

COLLISION_SEVERITY_TRANSLATE = data.frame(
  Severity = c("Slight", "Serious", "Fatal"),
  Severity_chi = c("輕微", "嚴重", "致命")
)

COLLISION_TYPE_TRANSLATE = data.frame(
  Collision_Type = c(
    "Vehicle collision with Vehicle", "Vehicle collision with Pedestrian", "Vehicle collision with Pedal Cycle",
    "Vehicle collision with Object", "Vehicle collision with Nothing", "Pedal Cycle collision with Pedestrian",
    "Pedal Cycle collision with Pedal Cycle", "Pedal Cycle collision with Object", "Pedal Cycle collision with Nothing"
  ),
  Collision_Type_chi = c(
    "車撞車", "車撞行人", "車撞單車",
    "車撞物", "車輛沒有碰撞", "單車撞行人",
    "單車撞單車", "單車撞物", "單車沒有碰撞"
  )
)

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

# Unique Main_vehicle values extracted from hk_vehicles
# TODO: Unify the capitalisation rules
VEHICLE_MOVEMENT_TRANSLATE = data.frame(
  Main_vehicle = c(
    "Going straight ahead (with priority)", "Changing lanes or merging", "Overtaking on off-side",
    "Overtaking on near-side", "Going Straight Ahead (against priority)", "Making right turn", "Making left turn",
    "Making U turn", "Slowing or stopping", "Stopped in traffic", "Starting in traffic", "Leaving parking place",
    "Parked", "Reversing", "Driverless moving vehicle", "Ran off road", "Other", "Unknown"
  ),
  Main_vehicle_chi = c(
    "向前駛 （優先）", "轉換行車線", "從外線超車",
    "從內線超車", "向前駛（無優先）", "右轉", "左轉",
    "掉頭", "慢駛或停車", "因前路受阻而停車", "跟隨前面交通開車", "駛離泊車位",
    "停泊車", "倒車", "移動中而無人駕駛", "衝出馬路", "其他", "行駛情況不詳"
  )
)

PED_ACTION_TRANSLATE = data.frame(
  Ped_Action = c(
    "Walking - back to traffic", "Walking - facing traffic", "Standing", "Boarding vehicle",
    "Alighting from vehicle", "Falling or jumping from vehicle", "Working at a vehicle", "Other working",
    "Playing", "Crossing from near-side", "Crossing from off-side", "Not known"
  ),
  Ped_Action_chi = c(
    "步行 ─ 背向車流", "步行 ─ 面向車流", "站立", "正在登車",
    "正在下車", "從車上跌下或跳下", "在修車中", "其他工作",
    "在玩耍中", "從車左邊橫過馬路", "從車右邊橫過馬路", "資料不詳"
  )
)

ROAD_HIERARCHY_TRANSLATE = data.frame(
  Road_Hierarchy = c("Expressway", "Main Road", "Secondary Road", "Other Minor Road"),
  Road_Hierarchy_chi = c("快速公路", "主要道路", "次要道路（內街／支路）", "小路（鄉村道路／行人徑）")
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
