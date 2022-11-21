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
    title = i18n$t("Hong Kong Traffic Injury Collision Database"),
    titleWidth = 400,

    tags$li(class = "dropdown",
            div(
              radioGroupButtons(
                inputId = "selected_language",
                label = NULL,
                choices = setNames(i18n$get_languages(), c("EN", "中")),
                selected = "zh",
                status = "dark",
                size = "xs"
              )
            ),
            # Align vertically to center and add spacing to the icons below
            style = "margin-top: 12.5px;margin-right: 20px;"),

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
        text = i18n$t("Collision Location Map"),
        icon = icon(name = "map"),
        tabName = "tab_collision_location_map"
      ),

      # Dashboard
      menuItem(
        text = i18n$t("Dashboard"),
        icon = icon(name = "tachometer-alt"),
        tabName = "tab_dashboard"
      ),

      # Pedestrian collision hotzones
      menuItem(
        text = i18n$t("Pedestrian Collision Hotzones"),
        icon = icon(name = "exclamation-triangle"),
        tabName = "tab_pedestrian_collision_hotzones"
      ),

      # Key Facts
      menuItem(
        text = i18n$t("Key Facts"),
        icon = icon(name = "file-alt"),
        tabName = "tab_key_facts"
      ),

      # Project Info
      menuItem(
        text = i18n$t("Project Info"),
        icon = icon(name = "info"),
        tabName = "tab_project_info"
      ),

      # User Survey
      menuItem(
        text = i18n$t("User Survey"),
        icon = icon(name = "list"),
        tabName = "tab_user_survey"
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

    # Monitor the state of the UI for live language translations
    shiny.i18n::usei18n(i18n),

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

              h3(span(icon("filter")), " ", i18n$t("Filters")),

              p(
                i18n$t("Please use the data filters below to select the category of traffic collisions you would like to show on the map. The map will automatically update and show the collisions meeting the current filter settings."),
                # add spacing to the first widget
                style = "margin-bottom: 10px"
                ),

              div(
                actionButton("zoom_to_pts", label = i18n$t("Zoom to matched collisions"), icon = icon("search-plus")),
                style = "display: flex;justify-content: center;align-items: center;margin-bottom: 10px;"
                ),

              uiOutput("district_filter_ui"),

              uiOutput("month_range_ui"),

              uiOutput("severity_filter_ui"),

              uiOutput("collision_type_filter_ui"),

              uiOutput("vehicle_class_filter_ui"),

              br(),

              p(i18n$t("Number of collisions in current filter settings: "), textOutput("nrow_filtered", inline = TRUE),
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
            width = 12,
            title = span(icon("tachometer-alt"), i18n$t("District Dashboard")),

            h4(i18n$t("Select collisions to be summarised")),

            column(
              width = 4,
              uiOutput("dsb_filter_ui")
            ),

            column(
              width = 4,
              sliderInput(
                inputId =  "ddsb_year_filter", label = i18n$t("Year Range"),
                min = 2014, max = 2019,
                value = c(2015, 2019),
                # Remove thousands separator
                sep = ""
              )
            ),

            column(
              width = 4,
              uiOutput("ksi_filter_ui")
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
            title = i18n$t("All Vehicle Collision"),

            fluidRow(
              infoBoxOutput(width = 3, outputId = "box_all_total_collision"),
              infoBoxOutput(width = 3, outputId = "box_all_total_casualty"),
              infoBoxOutput(width = 3, outputId = "box_all_serious_stat"),
              infoBoxOutput(width = 3, outputId = "box_all_fatal_stat")
            ),

            fluidRow(
              box(
                  width = 6,
                  title = i18n$t("Collision location"),
                  tmapOutput(outputId = "ddsb_all_collision_heatmap")
              ),
              box(width = 6,
                  title = i18n$t("Collision severity"),
                  plotlyOutput(outputId = "ddsb_all_ksi_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = i18n$t("Collision trend"),
                plotlyOutput(outputId = "ddsb_all_year_plot")
              ),
              box(
                width = 6,
                title = i18n$t("Collision type"),
                plotlyOutput(outputId = "ddsb_all_collision_type_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = i18n$t("Vehicle classes involved"),
                plotlyOutput(outputId = "ddsb_all_vehicle_class_plot")
              ),
              box(
                width = 6,
                title = i18n$t("Road hierarchy"),
                plotlyOutput(outputId = "ddsb_all_road_hierarchy_plot")
              )
            )
          ),

          # Vehicle w/ Peds tab
          tabPanel(
            value = "vehicle_with_pedestrians",
            title = i18n$t("Pedestrian Collision"),

            fluidRow(
              infoBoxOutput(width = 3, outputId = "box_ped_total_collision"),
              infoBoxOutput(width = 3, outputId = "box_ped_total_casualty"),
              infoBoxOutput(width = 3, outputId = "box_ped_serious_stat"),
              infoBoxOutput(width = 3, outputId = "box_ped_fatal_stat")
            ),

            fluidRow(
              box(
                width = 6,
                title = i18n$t("Collision location"),
                tmapOutput(outputId = "ddsb_ped_collision_heatmap")
              ),
              box(width = 6,
                  title = i18n$t("Collision severity"),
                  plotlyOutput(outputId = "ddsb_ped_ksi_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = i18n$t("Vehicle classes involved"),
                plotlyOutput(outputId = "ddsb_ped_vehicle_class_plot")
              ),
              box(
                width = 6,
                title = i18n$t("Vehicle maneuver"),
                plotlyOutput(outputId = "ddsb_ped_vehicle_movement_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = i18n$t("Pedestrian action"),
                plotlyOutput(outputId = "ddsb_ped_ped_action_plot")
              ),
              box(
                width = 6,
                title = i18n$t("Road hierarchy"),
                plotlyOutput(outputId = "ddsb_ped_road_hierarchy_plot")
              )
            )
          ),

          # Vehicle w/ Cycles tab
          tabPanel(
            value = "vehicle_with_bicycles",
            title = i18n$t("Cyclist Collision"),

            fluidRow(
              infoBoxOutput(width = 3, outputId = "box_cyc_total_collision"),
              infoBoxOutput(width = 3, outputId = "box_cyc_total_casualty"),
              infoBoxOutput(width = 3, outputId = "box_cyc_serious_stat"),
              infoBoxOutput(width = 3, outputId = "box_cyc_fatal_stat")
            ),

            fluidRow(
              box(
                width = 6,
                title = i18n$t("Collision location"),
                tmapOutput(outputId = "ddsb_cyc_collision_heatmap")
              ),
              box(width = 6,
                  title = i18n$t("Collision severity"),
                  plotlyOutput(outputId = "ddsb_cyc_ksi_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = i18n$t("Collision type"),
                plotlyOutput(outputId = "ddsb_cyc_collision_type_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = i18n$t("Vehicle classes involved (excl. cycle)"),
                plotlyOutput(outputId = "ddsb_cyc_vehicle_class_plot")
              ),
              box(
                width = 6,
                title = i18n$t("Vehicle maneuver (excl. cycle)"),
                plotlyOutput(outputId = "ddsb_cyc_vehicle_movement_plot")
              )
            ),

            fluidRow(
              box(
                width = 6,
                title = i18n$t("Cyclist action"),
                plotlyOutput(outputId = "ddsb_cyc_cyc_action_plot")
              ),
              box(
                width = 6,
                title = i18n$t("Road hierarchy"),
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
            title = span(icon("exclamation-triangle"), i18n$t("Pedestrian Collision Hotzones")),
            includeMarkdown("desc/hotzone.md"),

            tmapOutput(outputId = "hotzones_map", height = "50vh"),

            tags$br(),
            h4(i18n$t("Hotzones Table")),

            dataTableOutput(outputId = "hotzones_table")
          )
        )
      ),

      # Menu item: Key Facts ---------------------------------------------------

      tabItem(
        tabName = "tab_key_facts",
        fluidRow(
          # align the box to center if screen width is larger than max-width
          style = "display:flex; justify-content:center;",

          div(
            # box do not support custom style, need to warp it in div
            # 640 for body + 15px*2 for padding
            style = "max-width:670px !important",
            box(
              width = 12,

              title = span(icon("file-alt"), i18n$t("Key facts about pedestrian-related collisions")),
              includeMarkdown("desc/key_facts.md"),

              column(
                width = 6,
                img(src = "report-cover-chi.jpg", height = "100%", width = "100%")
              ),
              column(
                width = 6,
                img(src = "summary-chi.jpg", height = "100%", width = "100%")
              ),

              # Workaround to add line spacing between the top two images (Chi version) and bottom two images (Eng version)
              # FIXME: Investigate how to formally add line breaks between `column` objects
              p(" ", style = "white-space: pre-wrap"),

              column(
                width = 6,
                img(src = "report-cover-eng.jpg", height = "100%", width = "100%")
              ),
              column(
                width = 6,
                img(src = "summary-eng.jpg", height = "100%", width = "100%")
              )
            )
          )
        )
      ),

      # Menu item: Project Info ------------------------------------------------

      tabItem(
        tabName = "tab_project_info",
        fluidRow(

          # align the box to center if screen width is larger than max-width
          style = "display:flex; justify-content:center;",
          div(
            # box do not support custom style, need to warp it in div
            # 640 for body + 15px*2 for padding
            style = "max-width:670px !important",
            box(
              width = 12,
              includeMarkdown("desc/information.md")
            )
          )
        ),

        fluidRow(
          box(
            width = 12,
            # Add icon inside heading
            # https://community.rstudio.com/t/how-to-add-an-icon-in-shinydashboard-box-title/20650
            title = span(icon("th-list"), i18n$t("Glossary of Terms")),
            i18n$t("The following terms are used in this website."),
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
      ),

      # Menu item: User Survey ---------------------------------------------------

      tabItem(
        tabName = "tab_user_survey",
        fluidRow(
          tags$iframe(
            src = "https://docs.google.com/forms/d/e/1FAIpQLSd7mD-MiIn3T9wp3KREqut4BfzVFVXD-UfkWEf_-04Kg4kRVA/viewform?embedded=true",
            width = "100%",
            # TODO: Auto adjust height when form is updated; make the height responsive to users' device width
            height = "3600px",
            frameBorder= 0,
            marginheight = 0,
            marginwidth = 0
          )
        )
      ) # tabItem
    ) # tabItems
  ) # dashboardBody
) # dashboardPage
