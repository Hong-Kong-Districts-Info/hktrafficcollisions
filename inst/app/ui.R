# ---- #
# ui.R #
# ---- #
# DESC: Script should be relatively short and straightforward.
#       All that happens here is setting out where things go.
#       There are no calculations.

ui <- dashboardPage(

  # Title and Skin
  title = "Hong Kong Traffic Injury Collision Database",
  skin = "yellow",

  # Header
  header = dashboardHeader(
    title = "Hong Kong Traffic Injury Collision Database",
    titleWidth = 400,

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
      href = "https://github.com/Hong-Kong-Districts-Info",
      img(src = "logo-bw.png", title = "Hong Kong Districts Info", height = "30px"),
      style = "padding:10px;"
    ),
    class = "dropdown"
    ),
    tags$li(a(
      href = "https://bit.ly/StreetresetHK",
      img(src = "street-reset-logo-bw.png", title = "Street Reset", height = "46px"),
      style = "padding:2px;"
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

      # Pedestrian collision hotzones
      menuItem(
        text = "Pedestrian collision hotzones",
        icon = icon(name = "exclamation-triangle"),
        tabName = "tab_pedestrian_collision_hotzones"
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

    # OpenGraph
    # `OPENGRAPH_PROPS` constant is defined in global.R

    tags$head(

      # Facebook OpenGraph tags
      tags$meta(property = "og:title", content = OPENGRAPH_PROPS[["title"]]),
      tags$meta(property = "og:type", content = "website"),
      tags$meta(property = "og:url", content = OPENGRAPH_PROPS[["url"]]),
      tags$meta(property = "og:image", content = OPENGRAPH_PROPS[["image"]]),
      tags$meta(property = "og:description", content = OPENGRAPH_PROPS[["description"]]),

      # Twitter summary cards
      tags$meta(name = "twitter:card", content = "summary"),
      tags$meta(name = "twitter:title", content = OPENGRAPH_PROPS[["title"]]),
      tags$meta(name = "twitter:description", content = OPENGRAPH_PROPS[["description"]]),
      tags$meta(name = "twitter:image", content = OPENGRAPH_PROPS[["image"]]),

    ),


    # add custom css style for the data filter panel
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
      includeScript("./modules/gomap.js")
    ),

    tabItems(

      # Menu item: Collision Location Map --------------------------------------

      tabItem(
        tabName = "tab_collision_location_map",

        fluidRow(
          box(
            width = 12,

            column(
              # mapframe panel
              width = 9,
              leafletOutput(outputId = "main_map", height = "100vh")
            ),

            column(
              # filter panel
              width = 3,
              id = "controls", class = "panel panel-default",

              h2("Filter Panel"),

              selectizeInput(
                inputId = "district_filter",
                label = "District(s):",
                choices = setNames(DISTRICT_ABBR, DISTRICT_FULL_NAME),
                selected = "KC",
                options = list(maxItems = 3, placeholder = 'Select districts (3 maximum)')
              ),

              airDatepickerInput("start_month",
                                 label = "From",
                                 value = "2016-05-01",
                                 min = as.Date(min(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                                 max = as.Date(max(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                                 view = "months",
                                 minView = "months",
                                 dateFormat = "MM yyyy",
                                 addon = "none"
              ),

              airDatepickerInput("end_month",
                                 label = "To",
                                 value = "2016-06-01",
                                 min = as.Date(min(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                                 max = as.Date(max(hk_accidents$Date_Time), tz = "Asia/Hong_Kong"),
                                 view = "months",
                                 minView = "months",
                                 dateFormat = "MM yyyy",
                                 addon = "none"
              ),

              checkboxGroupButtons(
                inputId = "severity_filter", label = "Collision severity",
                # TODO: use sprintf and global SEVERITY_COLOR constant for mapping icon color
                choices = c(
                  `<div style="display: flex;justify-content: center;align-items: center;"><span class="dot" style="height: 14px;width: 14px;background-color: #FF4039;border-radius: 50%;border: 1.5px solid #0d0d0d;"></span><span style="color:black;padding-left:10px;"> Fatal</span></div>` = "Fatal",
                  `<div style="display: flex;justify-content: center;align-items: center;"><span class="dot" style="height: 14px;width: 14px;background-color: #FFB43F;border-radius: 50%;border: 1.5px solid #0d0d0d;"></span><span style="color:black;padding-left:10px;"> Serious</span></div>` = "Serious",
                  `<div style="display: flex;justify-content: center;align-items: center;"><span class="dot" style="height: 14px;width: 14px;background-color: #FFE91D;border-radius: 50%;border: 1.5px solid #0d0d0d;"></span><span style="color:black;padding-left:10px;"> Slight</span></div>` = "Slight"
                ),
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
              choices = setNames(DISTRICT_ABBR, DISTRICT_FULL_NAME)
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

        # Use tabsetPanel to observe which tab user is currently opening
        # https://stackoverflow.com/questions/23243454/how-to-use-tabpanel-as-input-in-r-shiny
        tabsetPanel(
          id = "dashboard_collision_category",

          # All Vehicle Collision tab
          tabPanel(
            value = "all_vehicle_collision",
            title = "All Vehicle Collision",

            fluidRow(
              infoBoxOutput(width = 3, outputId = "box_all_total_collision"),
              infoBoxOutput(width = 3, outputId = "box_all_total_casualty"),
              infoBoxOutput(width = 3, outputId = "box_all_serious_stat"),
              infoBoxOutput(width = 3, outputId = "box_all_fatal_stat")
            ),

            fluidRow(
              box(
                  width = 6,
                  title = "Collision Map",
                  tmapOutput(outputId = "ddsb_all_collision_heatmap")
              ),
              box(width = 6,
                  title = "KSI Stats",
                  plotlyOutput(outputId = "ddsb_all_ksi_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = "Collision Year Line Graph",
                plotlyOutput(outputId = "ddsb_all_year_plot")
              ),
              box(
                width = 6,
                title = "Collision Type",
                plotlyOutput(outputId = "ddsb_all_collision_type_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = "Vehicle Class Stats",
                plotlyOutput(outputId = "ddsb_all_vehicle_class_plot")
              ),
              box(
                width = 6,
                title = "Junction and Road Stats",
                plotlyOutput(outputId = "ddsb_all_road_hierarchy_plot")
              )
            )
          ),

          # Vehicle w/ Peds tab
          tabPanel(
            value = "vehicle_with_pedestrians",
            title = "Pedestrian Collision",

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
            )
          ),

          # Vehicle w/ Cycles tab
          tabPanel(
            value = "vehicle_with_bicycles",
            title = "Cyclist Collision",

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
                title = "Collision Type",
                plotlyOutput(outputId = "ddsb_cyc_collision_type_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = "Vehicle Class Stats (Only include collisions which vehicle collied with pedal cycle)",
                plotlyOutput(outputId = "ddsb_cyc_vehicle_class_plot")
              ),
              box(
                width = 6,
                title = "Vehicle Movement Stats (Only include collisions which vehicle collied with pedal cycle)",
                plotlyOutput(outputId = "ddsb_cyc_vehicle_movement_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = "Cyclist Action Stats",
                plotlyOutput(outputId = "ddsb_cyc_cyc_action_plot")
              ),
              box(
                width = 6,
                title = "Road Stats",
                plotlyOutput(outputId = "ddsb_cyc_road_hierarchy_plot")
              )
            )
          )
        )
      ),

      # Menu item: Pedestrian collision hotzones -------------------------------

      tabItem(
        tabName = "tab_pedestrian_collision_hotzones",
        fluidRow(
          box(
            width = 12,
            title = "Pedestrian Collision Hot Zones",
            tmapOutput(outputId = "hotspots_map")
          )
        ),
        fluidRow(
          box(
            width = 12,
            title = "Hot Zones Table",
            dataTableOutput(outputId = "hotspots_table")

          )
        )
      ),

      # Menu item: Key Facts ---------------------------------------------------

      tabItem(
        tabName = "tab_key_facts",
        box(
          width = 12,
          title = "Key Facts about Hong Kong Traffic Injury Collisions",
          "TENTATIVE: infographics, summary and link to the full report"
        )
      ),

      # Menu item: Data Download -----------------------------------------------

      tabItem(
        tabName = "tab_data_download",
          box(
            width = 12,
            title = "Data Source",
            icon(name = "wrench"),
            "We are currently finding ways to host the data for download.",
            icon(name = "hammer"),
            hr(),
            p("If you are interested in getting the traffic collision data, please contact us."),
          )
      ),

      # Menu item: Project Info ------------------------------------------------

      tabItem(
        tabName = "tab_project_info",
        fluidRow(
          box(
            width = 12,
            includeMarkdown("desc/information.md")
          )
        ),

        fluidRow(
          box(
            width = 12,
            # Add icon inside heading
            # https://community.rstudio.com/t/how-to-add-an-icon-in-shinydashboard-box-title/20650
            title = span(icon("th-list"), "Glossary of Terms"),
            p("The following terms are used in this website."),
            dataTableOutput(outputId = "terminology_table")
          )
        ),

        fluidRow(
          box(
            width = 12,
            hr(),
            paste("Hong Kong Traffic Injury Collision Database ver.", get_last_modified_date(getwd())),
            br(),
            paste("hkdatasets ver.", utils::packageVersion("hkdatasets")),
          )
        )
      ) # tabItem
    ) # tabItems
  ) # dashboardBody
) # dashboardPage
