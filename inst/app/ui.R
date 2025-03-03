# ---- #
# ui.R #
# ---- #
# DESC: Script should be relatively short and straightforward.
#       All that happens here is setting out where things go.
#       There are no calculations.

ui <- page_navbar(
  title = tagList(shiny.i18n::usei18n(i18n), i18n$t("Hong Kong Traffic Injury Collision Database")),
  theme = bs_theme(
    bootswatch = "lumen",
    primary = "#343434"  # Dark grey primary color
  ),

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$script(src = "collapsible-checkbox.js")
  ),

  # Navigation tabs (replacing sidebar menu)
  nav_panel(
    title = i18n$t("Collision Location Map"),
    icon = icon("map"),
    value = "tab_collision_location_map",

    # Use layout_sidebar instead of layout_columns for better control
    layout_sidebar(
      sidebar = sidebar(
        width = 350, # Fixed width for the filter panel
        title = span(icon("filter"), " ", i18n$t("Filters")),

        # Filter panel content
        p(
          i18n$t("Use the filter tools below to set your criteria and focus on specific collisions. The map will automatically update to show matching collisions.")
        ),
        p(
          tags$b(textOutput("nrow_filtered", inline = TRUE)),
          style = "font-size:20px;text-align:center"
        ),
        div(
          actionButton(
            "zoom_to_pts",
            label = i18n$t("Zoom to matching collisions"),
            icon = icon("search-plus"),
            width = "100%",
            class = "btn-primary"
          )
        ),
        uiOutput("district_filter_ui"),
        uiOutput("month_range_ui"),
        uiOutput("severity_filter_ui"),
        uiOutput("collision_type_filter_ui"),
        uiOutput("vehicle_class_filter_ui")
      ),

      # Main map panel
      leafletOutput(outputId = "main_map")
    )
  ),

  nav_panel(
    title = i18n$t("Dashboard"),
    icon = icon("tachometer-alt"),
    value = "tab_dashboard",

    # Main container div to enforce vertical layout
    div(
      class = "dashboard-container",
      style = "display: flex; flex-direction: column; width: 100%;",

      # Filter section container
      div(
        class = "filter-section-container",
        style = "width: 100%; margin-bottom: 20px;",

        # Header for filters section
        div(
          class = "filter-section-header",
          style = "background-color: #f8f9fa; padding: 10px 15px; border-radius: 4px 4px 0 0; border-bottom: 1px solid rgba(0, 0, 0, 0.1); margin-bottom: 15px;",
          span(icon("filter"), " ", i18n$t("Choose collisions to analyse"))
        ),

        # Filter components in three columns without individual cards
        layout_columns(
          col_widths = c(4, 4, 4),

          # District filter
          div(
            class = "filter-component",
            style = "padding: 8px; margin: 4px;",
            uiOutput("dsb_filter_ui")
          ),

          # Year range slider
          div(
            class = "filter-component",
            style = "padding: 8px; margin: 4px;",
            sliderInput(
              inputId = "ddsb_year_filter",
              label = i18n$t("Year Range"),
              min = 2014,
              max = 2023,
              value = c(2019, 2023),
              # Remove thousands separator
              sep = ""
            )
          ),

          # KSI filter
          div(
            class = "filter-component",
            style = "padding: 8px; margin: 4px;",
            uiOutput("ksi_filter_ui")
          )
        ),
        style = "position: relative; z-index: 100; background-color: white; border-radius: 4px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);"
      ),

      # Dashboard content container
      div(
        class = "dashboard-content-container",
        style = "width: 100%;",

        # Dashboard tabs using bslib
        navset_tab(
          id = "dashboard_collision_category",

          # Pedestrian Collision tab
          nav_panel(
            value = "vehicle_with_pedestrians",
            title = i18n$t("Pedestrian Collision"),

            # Info boxes
            layout_columns(
              col_widths = c(3, 3, 3, 3),
              value_box(
                title = i18n$t("Total Collisions"),
                value = textOutput("ped_total_collision"),
                showcase = icon("car-crash"),
                theme = "primary",
                height = "100%",
                min_height = "120px"
              ),
              value_box(
                title = i18n$t("Total Casualties"),
                value = textOutput("ped_total_casualty"),
                showcase = icon("user-injured"),
                theme = "primary",
                height = "100%",
                min_height = "120px"
              ),
              value_box(
                title = i18n$t("Serious casualties (% of total)"),
                value = textOutput("ped_serious_stat"),
                showcase = icon("hospital"),
                theme = "warning",
                height = "100%",
                min_height = "120px"
              ),
              value_box(
                title = i18n$t("Fatalities (% of total)"),
                value = textOutput("ped_fatal_stat"),
                showcase = icon("skull-crossbones"),
                theme = "danger",
                height = "100%",
                min_height = "120px"
              )
            ),

            # Collision maps and plots - directly in layout_columns without extra cards
            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header(i18n$t("Collision location")),
                tmapOutput(outputId = "ddsb_ped_collision_heatmap", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              ),
              card(
                card_header(i18n$t("Collision severity")),
                plotlyOutput(outputId = "ddsb_ped_ksi_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              )
            ),

            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header(i18n$t("Vehicle classes involved")),
                plotlyOutput(outputId = "ddsb_ped_vehicle_class_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              ),
              card(
                card_header(i18n$t("Vehicle maneuver")),
                plotlyOutput(outputId = "ddsb_ped_vehicle_movement_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              )
            ),

            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header(i18n$t("Pedestrian action")),
                plotlyOutput(outputId = "ddsb_ped_ped_action_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              ),
              card(
                card_header(i18n$t("Road hierarchy")),
                plotlyOutput(outputId = "ddsb_ped_road_hierarchy_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              )
            )
          ),

          # Cyclist Collision tab
          nav_panel(
            value = "vehicle_with_bicycles",
            title = i18n$t("Cyclist Collision"),

            # Info boxes
            layout_columns(
              col_widths = c(3, 3, 3, 3),
              value_box(
                title = i18n$t("Total Collisions"),
                value = textOutput("cyc_total_collision"),
                showcase = icon("car-crash"),
                theme = "primary",
                height = "100%",
                min_height = "120px"
              ),
              value_box(
                title = i18n$t("Total Casualties"),
                value = textOutput("cyc_total_casualty"),
                showcase = icon("user-injured"),
                theme = "primary",
                height = "100%",
                min_height = "120px"
              ),
              value_box(
                title = i18n$t("Serious casualties (% of total)"),
                value = textOutput("cyc_serious_stat"),
                showcase = icon("hospital"),
                theme = "warning",
                height = "100%",
                min_height = "120px"
              ),
              value_box(
                title = i18n$t("Fatalities (% of total)"),
                value = textOutput("cyc_fatal_stat"),
                showcase = icon("skull-crossbones"),
                theme = "danger",
                height = "100%",
                min_height = "120px"
              )
            ),

            # Collision maps and plots
            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header(i18n$t("Collision location")),
                tmapOutput(outputId = "ddsb_cyc_collision_heatmap", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              ),
              card(
                card_header(i18n$t("Collision severity")),
                plotlyOutput(outputId = "ddsb_cyc_ksi_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              )
            ),

            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header(i18n$t("Collision type")),
                plotlyOutput(outputId = "ddsb_cyc_collision_type_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              ),
              card(
                card_header(i18n$t("Vehicle classes involved (excl. cycle)")),
                plotlyOutput(outputId = "ddsb_cyc_vehicle_class_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              )
            ),

            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header(i18n$t("Vehicle maneuver (excl. cycle)")),
                plotlyOutput(outputId = "ddsb_cyc_vehicle_movement_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              ),
              card(
                card_header(i18n$t("Cyclist action")),
                plotlyOutput(outputId = "ddsb_cyc_cyc_action_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              )
            ),

            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header(i18n$t("Road hierarchy")),
                plotlyOutput(outputId = "ddsb_cyc_road_hierarchy_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              ),
              # Empty card to maintain layout balance - can be removed for better responsiveness
              NULL
            )
          ),

          # All Vehicle Collision tab
          nav_panel(
            value = "all_vehicle_collision",
            title = i18n$t("All Vehicle Collision"),

            # Info boxes
            layout_columns(
              col_widths = c(3, 3, 3, 3),
              value_box(
                title = i18n$t("Total Collisions"),
                value = textOutput("all_total_collision"),
                showcase = icon("car-crash"),
                theme = "primary",
                height = "100%",
                min_height = "120px"
              ),
              value_box(
                title = i18n$t("Total Casualties"),
                value = textOutput("all_total_casualty"),
                showcase = icon("user-injured"),
                theme = "primary",
                height = "100%",
                min_height = "120px"
              ),
              value_box(
                title = i18n$t("Serious casualties (% of total)"),
                value = textOutput("all_serious_stat"),
                showcase = icon("hospital"),
                theme = "warning",
                height = "100%",
                min_height = "120px"
              ),
              value_box(
                title = i18n$t("Fatalities (% of total)"),
                value = textOutput("all_fatal_stat"),
                showcase = icon("skull-crossbones"),
                theme = "danger",
                height = "100%",
                min_height = "120px"
              )
            ),

            # Collision maps and plots
            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header(i18n$t("Collision location")),
                tmapOutput(outputId = "ddsb_all_collision_heatmap", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              ),
              card(
                card_header(i18n$t("Collision severity")),
                plotlyOutput(outputId = "ddsb_all_ksi_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              )
            ),

            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header(i18n$t("Collision trend")),
                plotlyOutput(outputId = "ddsb_all_year_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              ),
              card(
                card_header(i18n$t("Collision type")),
                plotlyOutput(outputId = "ddsb_all_collision_type_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              )
            ),

            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header(i18n$t("Vehicle classes involved")),
                plotlyOutput(outputId = "ddsb_all_vehicle_class_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              ),
              card(
                card_header(i18n$t("Road hierarchy")),
                plotlyOutput(outputId = "ddsb_all_road_hierarchy_plot", height = "400px"),
                height = "auto",
                min_height = "450px",
                full_screen = TRUE
              )
            )
          )
        )
      )
    )
  ),

  nav_panel(
    title = i18n$t("Pedestrian Collision Hotzones"),
    icon = icon("exclamation-triangle"),
    value = "tab_pedestrian_collision_hotzones",
    card(
      card_header(
        span(icon("exclamation-triangle"), i18n$t("Pedestrian Collision Hotzones"))
      ),
      includeMarkdown("desc/hotzone.md"),
      tmapOutput(outputId = "hotzones_map", height = "500px"),
      tags$br(),
      h4(i18n$t("Hotzones Table")),
      dataTableOutput(outputId = "hotzones_table")
    )
  ),

  nav_panel(
    title = i18n$t("Key Facts"),
    icon = icon("file-alt"),
    value = "tab_key_facts",

    # Center the card if screen width is larger than max-width
    div(
      style = "display:flex; justify-content:center;",
      div(
        style = "max-width:670px !important",
        card(
          card_header(
            span(icon("file-alt"), i18n$t("Key facts about pedestrian-related collisions"))
          ),
          includeMarkdown("desc/key_facts.md"),
          layout_columns(
            col_widths = c(6, 6),
            img(src = "report-cover-chi.jpg", height = "100%", width = "100%"),
            img(src = "summary-chi.jpg", height = "100%", width = "100%")
          ),
          # Spacing between image sets
          p(" ", style = "white-space: pre-wrap"),
          layout_columns(
            col_widths = c(6, 6),
            img(src = "report-cover-eng.jpg", height = "100%", width = "100%"),
            img(src = "summary-eng.jpg", height = "100%", width = "100%")
          )
        )
      )
    )
  ),

  nav_panel(
    title = i18n$t("Project Info"),
    icon = icon("info"),
    value = "tab_project_info",

    # Project information
    div(
      style = "display:flex; justify-content:center;",
      div(
        style = "max-width:670px !important",
        card(
          includeMarkdown("desc/information.md")
        )
      )
    ),

    # Glossary
    card(
      card_header(
        span(icon("th-list"), i18n$t("Glossary of Terms"))
      ),
      i18n$t("The following terms are used in this website."),
      dataTableOutput(outputId = "terminology_table")
    ),

    # Version information
    card(
      hr(),
      paste("Hong Kong Traffic Injury Collision Database ver.", get_last_modified_date(getwd())),
      br(),
      paste("hkdatasets ver.", utils::packageVersion("hkdatasets"))
    )
  ),

  # Add a spacer to push the following items to the right
  nav_spacer(),

  # GitHub link
  nav_item(
    tags$a(
      href = "https://github.com/Hong-Kong-Districts-Info/hktrafficcollisions",
      icon("github"),
      title = "GitHub",
      class = "nav-link"
    )
  ),

  # Email link
  nav_item(
    tags$a(
      href = "mailto: info@streetresethk.org",
      icon("envelope"),
      title = "Email us",
      class = "nav-link"
    )
  ),

  # HKDI logo
  nav_item(
    tags$a(
      href = "https://github.com/Hong-Kong-Districts-Info",
      img(src = "logo-bw.png", title = "Hong Kong Districts Info", height = "30px"),
      class = "nav-link p-0 mx-2"
    )
  ),

  # Street Reset logo
  nav_item(
    tags$a(
      href = "https://bit.ly/StreetresetHK",
      img(src = "street-reset-logo-bw.png", title = "Street Reset", height = "46px"),
      class = "nav-link p-0 mx-2"
    )
  ),

  # Language selector
  nav_item(
    radioGroupButtons(
      inputId = "selected_language",
      label = NULL,
      choices = setNames(i18n$get_languages(), c("EN", "中")),
      selected = "zh",
      status = "light",
      size = "xs"
    )
  ),

  # Add OpenGraph tags for social media
  tags$head(
    tags$meta(property = "og:title", content = OPENGRAPH_PROPS$title),
    tags$meta(property = "og:url", content = OPENGRAPH_PROPS$url),
    tags$meta(property = "og:image", content = OPENGRAPH_PROPS$image),
    tags$meta(property = "og:description", content = OPENGRAPH_PROPS$description)
  )
)

# Now let's examine the body content for each tab and replace it with bslib components
