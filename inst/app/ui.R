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

              airDatepickerInput("start_month",
                                 label = "From",
                                 value = "2016-05-01",
                                 min = as.Date(min(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                                 max = as.Date(max(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                                 view = "months",
                                 minView = "months",
                                 dateFormat = "MM yyyy"
              ),

              airDatepickerInput("end_month",
                                 label = "To",
                                 value = "2016-06-01",
                                 min = as.Date(min(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                                 max = as.Date(max(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                                 view = "months",
                                 minView = "months",
                                 dateFormat = "MM yyyy"
              ),

              checkboxGroupButtons(
                inputId = "severity_filter", label = "Collision severity",
                choices = c(`Fatal <i style="color:#230B4C;" class="fas fa-skull-crossbones"></i>` = "Fatal",
                            `Serious <i style="color:#C03A51;"class="fas fa-procedures"></i>` = "Serious",
                            `Slight <i style="color:#F1701E;" class="fas fa-user-injured"></i>` = "Slight"),
                selected = unique(hk_accidents$Severity),
                direction = "vertical",
                justified = TRUE,
                checkIcon = list(yes = icon("ok", lib = "glyphicon"))
              ),

              collapsibleAwesomeCheckboxGroupInput(
                inputId = "collision_type_filter", label = "Collision type",
                i = 3,
                # reverse alphabetical order
                choices = sort(unique(hk_accidents$Type_of_Collision_with_cycle), decreasing = TRUE),
                selected = unique(hk_accidents$Type_of_Collision_with_cycle)
              ),

              collapsibleAwesomeCheckboxGroupInput(
                inputId = "vehicle_class_filter", label = "Vehicle classes involved in the collision",
                i = 2,
                choices = unique(hk_vehicles$Vehicle_Class),
                selected = unique(hk_vehicles$Vehicle_Class)
              ),

              br(),

              p("Total number of collisions: ", textOutput("nrow_filtered", inline = TRUE),
                style = "font-size: 20px;text-align:center;"),
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

        # Filters
        fluidRow(
          box(
            width = 4,
            title = "Area Filter",
            selectInput(
              inputId = "ddsb_district_filter", label = "Select District",
              choices = unique(hk_accidents$District_Council_District)
            )
          ),
          box(
            width = 4,
            title = "Year Filter",
            sliderInput(
              inputId =  "ddsb_year_filter", label = "Select time period:",
              min = 2014, max = 2019,
              value = c(2015, 2019),
              # Remove thousands separator
              sep = ""
            )
          ),
          box(
            width = 4,
            title = "All/ KSI Filter",
            selectInput(
              inputId = "ddsb_ksi_filter", label = "Select collision severity category",
              choices = c("All", "Killed or Seriously Injuries only")
            )
          )
        ),

        tabBox(
          width = 12,

          # Use tabsetPanel to observe which tab user is currently opening
          # https://stackoverflow.com/questions/23243454/how-to-use-tabpanel-as-input-in-r-shiny
          tabsetPanel(
            id = "dashboard_collision_category",

            # All Vehicle Collision tab
            tabPanel(
              value = "all_vehicle_collision",
              title = "All Vehicle Collision",

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
                infoBoxOutput(width = 3, outputId = "box_ped_total_collision"),
                infoBoxOutput(width = 3, outputId = "box_ped_total_casualty"),
                infoBoxOutput(width = 3, outputId = "box_ped_serious_stat"),
                infoBoxOutput(width = 3, outputId = "box_ped_fatal_stat")
              ),

              fluidRow(
                box(
                  width = 6,
                  title = "Collision Map",
                  tmapOutput(outputId = "ddsb_ped_collision_heatmap")
                ),
                box(width = 6,
                    title = "KSI Stats",
                    plotlyOutput(outputId = "ddsb_ped_ksi_plot")
                )
              ),

              fluidRow(
                box(
                  width = 6,
                  title = "Vehicle Class Stats",
                  plotlyOutput(outputId = "ddsb_ped_vehicle_class_plot")
                ),
                box(
                  width = 6,
                  title = "Vehicle Movement Stats",
                  plotlyOutput(outputId = "ddsb_ped_vehicle_movement_plot")
                )
              ),

              fluidRow(
                box(
                  width = 6,
                  title = "Pedestrian Action Stats",
                  plotlyOutput(outputId = "ddsb_ped_ped_action_plot")
                ),
                box(
                  width = 6,
                  title = "Junction and Road Stats",
                  plotlyOutput(outputId = "ddsb_ped_road_hierarchy_plot")
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
                infoBoxOutput(width = 3, outputId = "box_cyc_total_collision"),
                infoBoxOutput(width = 3, outputId = "box_cyc_total_casualty"),
                infoBoxOutput(width = 3, outputId = "box_cyc_serious_stat"),
                infoBoxOutput(width = 3, outputId = "box_cyc_fatal_stat")
              ),

              fluidRow(
                box(
                  width = 6,
                  title = "Collision Map",
                  tmapOutput(outputId = "ddsb_cyc_collision_heatmap")
                ),
                box(width = 6,
                    title = "KSI Stats",
                    plotlyOutput(outputId = "ddsb_cyc_ksi_plot")
                )
              ),

              fluidRow(
                box(
                  width = 6,
                  title = "Vehicle Class Stats",
                  plotlyOutput(outputId = "ddsb_cyc_vehicle_class_plot")
                ),
                box(
                  width = 6,
                  title = "Vehicle Movement Stats",
                  plotlyOutput(outputId = "ddsb_cyc_vehicle_movement_plot")
                )
              ),

              fluidRow(
                box(
                  width = 6,
                  title = "Cyclist Action Stats",
                  "Insert cyclist action stats here"
                ),
                box(
                  width = 6,
                  title = "Road Stats",
                  plotlyOutput(outputId = "ddsb_cyc_road_hierarchy_plot")
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
