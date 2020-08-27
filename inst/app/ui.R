# ---- #
# ui.R #
# ---- #
# DESC: Script should be relatively short and straightforward.
#       All that happens here is setting out where things go.
#       There are no calculations.

ui <- dashboardPage(

  # Title and Skin
  title = "Traffic Collisions",
  skin = "yellow",

  # Header
  header = dashboardHeader(
    title = "HK: Traffic Collisions",

    tags$li(a(
      href = "https://hong-kong-districts-info.github.io/",
      icon(name = "globe-asia"),
      title = "Website"
    ),
    class = "dropdown"
    ),
    tags$li(a(
      href = "https://github.com/Hong-Kong-Districts-Info/hktrafficcollisions",
      icon("github"),
      title = "GitHub"
    ),
    class = "dropdown"
    ),
    tags$li(a(
      href = "mailto: hkdistricts.info@gmail.com",
      icon("envelope"),
      title = "Email us"
    ),
    class = "dropdown"
    ),
    tags$li(a(
      href = "https://hkdistricts-info.shinyapps.io/trafficcollisions/",
      img(src = "logo.png", title = "Back to Home", height = "46px"),
      style = "padding-top:2px; padding-bottom:2px;"
    ),
    class = "dropdown"
    )
  ),

  # Sidebar
  sidebar = dashboardSidebar(
    sidebarMenu(
      id = "menu",

      # Collision Location Map
      menuItem(
        text = "Collision Location Map",
        icon = icon(name = "map"),
        tabName = "tab_collision_location_map"
      ),

      # Dashboard
      menuItem(
        text = "Dashboard",
        icon = icon(name = "tachometer-alt"),
        tabName = "tab_dashboard"
      ),

      # Hotspots and Worst Roads
      menuItem(
        text = "Hotspots and Worst Roads",
        icon = icon(name = "exclamation-triangle"),
        tabName = "tab_hotspots_and_worst_roads"
      ),

      # Key Facts
      menuItem(
        text = "Key Facts",
        icon = icon(name = "file-alt"),
        tabName = "tab_key_facts"
      ),

      # Data Download
      menuItem(
        text = "Data Download",
        icon = icon(name = "file-download"),
        tabName = "tab_data_download"
      ),

      # Project Info
      menuItem(
        text = "Project Info",
        icon = icon(name = "info"),
        tabName = "tab_project_info"
      )

    ) # sidebarMenu
  ), # dashboardSidebar

  # Body
  body = dashboardBody(
    tabItems(

      # Tab: Collision Location Map --------------------------------------------

      tabItem(
        tabName = "tab_collision_location_map",
        fluidRow(
          box(
            width = 4,
            title = "Location Filter",
            "Insert location filter here"
          )
        ),
        fluidRow(
          box(
            width = 8,
            title = "Map",
            "Insert map here"
          ),
          box(
            width = 4,
            title = "Stats & Info",
            "Insert data here"
          )
        )
      ),

      # Tab: Dashboard ---------------------------------------------------------

      tabItem(
        tabName = "tab_dashboard",
        tabBox(
          width = 12,

          # All Vehicle Collision tab
          tabPanel(
            value = "all_vehicle_collision",
            title = "All Vehicle Collision",

            fluidRow(
              box(
                width = 4,
                title = "Area Filter",
                "Insert area filter here"
              ),
              box(
                width = 4,
                title = "Year Filter",
                "Insert year filter here"
              ),
              box(
                width = 4,
                title = "All/ KSI Filter",
                "Insert all/ksi filter here"
              )
            ),

            fluidRow(
              box(
                  width = 6,
                  title = "Collision Map",
                  "Insert collison map here"
              ),
              box(width = 6,
                  title = "KSI Stats",
                  "Insert ksi stats here"
              )
            ),

            fluidRow(
              box(
                width = 4,
                title = "Vehicle Class vs Casualty Role Graph",
                "Insert vehicle class vs casualty role graph here"
              ),
              box(
                width = 4,
                title = "Junction and Road Stats",
                "Insert junction and role stats here"
              ),
              box(
                width = 4,
                title = "Collision Year Line Graph",
                "Insert collision year line graph here"
              )
            ),

            fluidRow(
              box(width = 6,
                  title = "Contributory Factors Stats",
                  "Insert contributory factors stats here"
              ),
              box(width = 6,
                  title = "Accidents by Road Length Stats",
                  "Insert accidents by road length stats here"
              )
            )
          ),

          # Vehicle w/ Peds tab
          tabPanel(
            value = "vehicle_with_pedestrians",
            title = "Vehicle w/ Peds",

            fluidRow(
              box(
                width = 4,
                title = "Area Filter",
                "Insert area filter here"
              ),
              box(
                width = 4,
                title = "Year Filter",
                "Insert year filter here"
              ),
              box(
                width = 4,
                title = "All/ KSI Filter",
                "Insert all/ksi filter here"
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = "Collision Map",
                "Insert collison map here"
              ),
              box(width = 6,
                  title = "KSI Stats",
                  "Insert ksi stats here"
              )
            ),

            fluidRow(
              box(
                width = 3,
                title = "Vehicle Class Stats",
                "Insert vehicle class stats here"
              ),
              box(
                width = 3,
                title = "Vehicle Movement Stats",
                "Insert vehicle movement stats here"
              ),
              box(
                width = 3,
                title = "Pedestrian Action Stats",
                "Insert padestrian action stats here"
              ),
              box(
                width = 3,
                title = "Junction and Road Stats",
                "Insert junction and road stats here"
              )
            ),

            fluidRow(
              box(width = 12,
                  title = "Contributory Factors Stats",
                  "Insert contributory factors stats here"
              )
            )
          ),

          # Vehicle w/ Cycles tab
          tabPanel(
            value = "vehicle_with_bicycles",
            title = "Vehicle w/ Cycles",

            fluidRow(
              box(
                width = 4,
                title = "Area Filter",
                "Insert area filter here"
              ),
              box(
                width = 4,
                title = "Year Filter",
                "Insert year filter here"
              ),
              box(
                width = 4,
                title = "All/ KSI Filter",
                "Insert all/ksi filter here"
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = "Collision Map",
                "Insert collison map here"
              ),
              box(width = 6,
                  title = "KSI Stats",
                  "Insert ksi stats here"
              )
            ),

            fluidRow(
              box(
                width = 3,
                title = "Vehicle Class Stats",
                "Insert vehicle class stats here"
              ),
              box(
                width = 3,
                title = "Vehicle Movement Stats",
                "Insert vehicle movement stats here"
              ),
              box(
                width = 3,
                title = "Cyclist Action Stats",
                "Insert cyclist action stats here"
              ),
              box(
                width = 3,
                title = "Road Stats",
                "Insert road stats here"
              )
            ),

            fluidRow(
              box(width = 12,
                  title = "Contributory Factors Stats",
                  "Insert contributory factors stats here"
              )
            )
          )

        ) # tabBox
      ) # tabItem
    ) # tabItems
  ) # dashboardBody
) # dashboardPage
