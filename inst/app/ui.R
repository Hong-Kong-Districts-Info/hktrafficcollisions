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

    # add custom css style for the data filter panel
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),

    tabItems(

      # Menu item: Collision Location Map --------------------------------------

      tabItem(
        tabName = "tab_collision_location_map",

        fluidRow(
          box(
            width = 12,
            leafletOutput(outputId = "main_map", height = 800),

            absolutePanel(
              id = "controls", class = "panel panel-default", fixed = TRUE,
              draggable = TRUE, top = 100, left = "auto", right = 50, bottom = "auto",
              width = 330, height = "auto",

              h2("Filter Panel"),

              p("Number of rows: ", textOutput("nrow_filtered", inline = TRUE)),

              dateRangeInput(
                inputId = "date_filter", label = "Date range:",
                start = "2016-05-01",
                end   = "2016-06-30",
                format = "d MM yyyy"
              ),

              sliderInput(
                inputId = "n_causality_filter", label = "No. of casualties",
                min = min(hk_accidents$No__of_Casualties_Injured),
                max = max(hk_accidents$No__of_Casualties_Injured),
                value = range(hk_accidents$No__of_Casualties_Injured),
                step = 1
              ),

              pickerInput(
                inputId = "collision_type_filter", label = "Collision Type",
                choices = unique(hk_accidents$Type_of_Collision),
                selected = unique(hk_accidents$Type_of_Collision),
                multiple = TRUE,
                options = list(
                  `actions-box` = TRUE,
                  `deselect-all-text` = "Unselect All",
                  `select-all-text` = "Select All",
                  `none-selected-text` = "Select Collision type(s)...",
                  `selected-text-format` = "count",
                  `count-selected-text` = "{0} collison types choosed (on a total of {1})"
                ),
                choicesOpt = NULL,
                width = NULL,
                inline = FALSE
              ),

              pickerInput(
                inputId = "vehicle_class_filter", label = "Vehicle classes involved in the collision",
                choices = unique(hk_vehicles$Vehicle_Class),
                selected = unique(hk_vehicles$Vehicle_Class),
                multiple = TRUE,
                options = list(
                  `actions-box` = TRUE,
                  `deselect-all-text` = "Unselect All",
                  `select-all-text` = "Select All",
                  `none-selected-text` = "Select vehicle class(es)...",
                  `selected-text-format` = "count",
                  `count-selected-text` = "{0} vehicle classes choosed (on a total of {1})"
                ),
                choicesOpt = NULL,
                width = NULL,
                inline = FALSE
              ),

              p("NOTE: Multiple selections mean the accident includes ANY of the selected classes (instead of includes ALL of the selected classes)."),

              pickerInput(
                inputId = "severity_filter", label = "Accident Severity",
                choices = unique(hk_accidents$Severity),
                selected = unique(hk_accidents$Severity),
                multiple = TRUE,
                options = list(
                  `actions-box` = TRUE,
                  `deselect-all-text` = "Unselect All",
                  `select-all-text` = "Select All",
                  `none-selected-text` = "Select Severity type(s)...",
                  `selected-text-format` = "count",
                  `count-selected-text` = "{0} severity types choosed (on a total of {1})"
                ),
                choicesOpt = NULL,
                width = NULL,
                inline = FALSE
              ),

              # Multiple UI choices available for this filter
              # TODO: select between `checkboxGroupInput` or `checkboxGroupButtons` as UI of this filter
              checkboxGroupButtons(
                inputId = "pedestrian_involved_filter", label = "Pedestrian Involved in the accident?",
                choices = list("Yes" = TRUE, "No" = FALSE),
                selected = list(TRUE, FALSE),
                justified = TRUE, status = "primary"
              )
            )
          )
        ),

        fluidRow(
          box(
            width = 4,
            title = "Location Filter",
            "Insert location filter here"
          )
        ),
        fluidRow(
          plotlyOutput(outputId = "plotly_testvisual"),
          box(
            width = 4,
            title = "Stats & Info",
            "Insert data here"
          )
        )
      ),

      # Menu item: Dashboard ---------------------------------------------------

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
        )
      ),

      # Menu item: Dashboard ---------------------------------------------------

      tabItem(
        tabName = "tab_hotspots_and_worst_roads",
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
            title = "Hotspot Map",
            "Insert hotspot map here"
          ),
          box(width = 6,
              title = "Hotspot Junction Rank List",
              "Insert hotspot junction rank list here"
          )
        ),

        fluidRow(
          box(
            width = 6,
            title = "Hot Zone Map",
            "Insert hot zone map here"
          ),
          box(width = 6,
              title = "Hot Road Sections Rank List",
              "Insert hot road sections rank list here"
          )
        ),

        fluidRow(
          box(
            width = 6,
            title = "KSI Collision Per km Map",
            "Insert ksi collision per km map here"
          ),
          box(width = 6,
              title = "Worst Road (KSI Collision/ km)",
              "Insert worst road rank list here"
          )
        )
      ),

      # Menu item: Key Facts ---------------------------------------------------

      tabItem(
        tabName = "tab_key_facts",
        fluidRow(
          box(
            width = 12,
            title = "Key Facts about Hong Kong Traffic Injury Collisions"
          ),
          box(
            width = 12,
            title = "Concept Explainer",
            HTML("- Definition of each casualty severity
                 <br>
                 - Why emphasises KSI Collision?
                 <br>
                 - ...")
          )
        )
      ),

      # Menu item: Data Download -----------------------------------------------

      tabItem(
        tabName = "tab_data_download",
          box(
            width = 12,
            title = "Data Source",
            "Download Url"
          )
      ),

      # Menu item: Project Info ------------------------------------------------

      tabItem(
        tabName = "tab_project_info",
        box(
          width = 12,
          title = "About Us",
        ),
        box(
          width = 12,
          title = "What this is about",
        ),
        box(
          width = 12,
          title = "How to use this database?",
        ),
        box(
          width = 12,
          title = "Reference",
        ),
        box(
          width = 12,
          title = "Useful Urls",
        ),
        box(
          width = 12,
          title = "Caveats",
        )
      ) # tabItem
    ) # tabItems
  ) # dashboardBody
) # dashboardPage
