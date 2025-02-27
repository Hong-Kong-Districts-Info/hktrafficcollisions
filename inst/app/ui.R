# ---- #
# ui.R #
# ---- #
# DESC: Script should be relatively short and straightforward.
#       All that happens here is setting out where things go.
#       There are no calculations.

ui <- page_navbar(
  title = i18n$t("Hong Kong Traffic Injury Collision Database"),
  theme = bs_theme(
    bootswatch = "lumen",  # Using a similar theme to the yellow skin
    primary = "#f39c12"    # Yellow primary color
  ),
  
  # Header with language selector and links
  header = tags$div(
    class = "navbar-nav",
    style = "display: flex; align-items: center;",
    # Language selector
    tags$div(
      style = "margin-right: 20px;",
      radioGroupButtons(
        inputId = "selected_language",
        label = NULL,
        choices = setNames(i18n$get_languages(), c("EN", "中")),
        selected = "zh",
        status = "light",
        size = "xs"
      )
    ),
    # GitHub link
    tags$a(
      href = "https://github.com/Hong-Kong-Districts-Info/hktrafficcollisions",
      icon("github"),
      title = "GitHub",
      class = "mx-2"
    ),
    # Email link
    tags$a(
      href = "mailto: info@streetresethk.org",
      icon("envelope"),
      title = "Email us",
      class = "mx-2"
    ),
    # HKDI logo
    tags$a(
      href = "https://github.com/Hong-Kong-Districts-Info",
      img(src = "logo-bw.png", title = "Hong Kong Districts Info", height = "30px"),
      class = "mx-2"
    ),
    # Street Reset logo
    tags$a(
      href = "https://bit.ly/StreetresetHK",
      img(src = "street-reset-logo-bw.png", title = "Street Reset", height = "46px"),
      class = "mx-2"
    )
  ),
  
  # Navigation tabs (replacing sidebar menu)
  nav_panel(
    title = i18n$t("Collision Location Map"),
    icon = icon("map"),
    value = "tab_collision_location_map",
    # Content from original tab_collision_location_map 
    layout_columns(
      fill = TRUE,
      col_widths = c(9, 3),
      # Map panel
      card(
        full_screen = TRUE,
        leafletOutput(outputId = "main_map", height = "100vh")
      ),
      # Filter panel
      card(
        card_header(
          span(icon("filter"), " ", i18n$t("Filters"))
        ),
        p(
          i18n$t("Use the filter tools below to set your criteria and focus on specific collisions. The map will automatically update to show matching collisions."),
          # add spacing to the first widget
          style = "margin-bottom: 20px"
        ),
        p(
          tags$b(textOutput("nrow_filtered", inline = TRUE)),
          style = "font-size:20px;text-align:center;margin-bottom:5px"
        ),
        div(
          actionButton("zoom_to_pts", label = i18n$t("Zoom to matching collisions"), icon = icon("search-plus")),
          style = "display: flex;justify-content: center;align-items: center;margin-bottom: 20px;"
        ),
        uiOutput("district_filter_ui"),
        uiOutput("month_range_ui"),
        uiOutput("severity_filter_ui"),
        uiOutput("collision_type_filter_ui"),
        uiOutput("vehicle_class_filter_ui")
      )
    )
  ),
  
  nav_panel(
    title = i18n$t("Dashboard"),
    icon = icon("tachometer-alt"),
    value = "tab_dashboard",
    
    # Filter section
    card(
      card_header(
        span(icon("tachometer-alt"), i18n$t("District Dashboard"))
      ),
      layout_columns(
        h4(i18n$t("Choose collisions to analyse")),
        col_widths = c(4, 4, 4),
        uiOutput("dsb_filter_ui"),
        sliderInput(
          inputId = "ddsb_year_filter", 
          label = i18n$t("Year Range"),
          min = 2014, 
          max = 2023,
          value = c(2019, 2023),
          # Remove thousands separator
          sep = ""
        ),
        uiOutput("ksi_filter_ui")
      )
    ),
    
    # Dashboard tabs using bslib
    navset_card_tab(
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
            value = textOutput("box_ped_total_collision_value"),
            showcase = icon("car-crash"),
            theme = "primary"
          ),
          value_box(
            title = i18n$t("Total Casualties"),
            value = textOutput("box_ped_total_casualty_value"),
            showcase = icon("user-injured"),
            theme = "primary"
          ),
          value_box(
            title = i18n$t("Serious Injuries"),
            value = textOutput("box_ped_serious_stat_value"),
            showcase = icon("hospital"),
            theme = "warning"
          ),
          value_box(
            title = i18n$t("Fatalities"),
            value = textOutput("box_ped_fatal_stat_value"),
            showcase = icon("skull-crossbones"),
            theme = "danger"
          )
        ),
        
        # Collision maps and plots
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header(i18n$t("Collision location")),
            tmapOutput(outputId = "ddsb_ped_collision_heatmap")
          ),
          card(
            card_header(i18n$t("Collision severity")),
            plotlyOutput(outputId = "ddsb_ped_ksi_plot")
          )
        ),
        
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header(i18n$t("Vehicle classes involved")),
            plotlyOutput(outputId = "ddsb_ped_vehicle_class_plot")
          ),
          card(
            card_header(i18n$t("Vehicle maneuver")),
            plotlyOutput(outputId = "ddsb_ped_vehicle_movement_plot")
          )
        ),
        
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header(i18n$t("Pedestrian action")),
            plotlyOutput(outputId = "ddsb_ped_ped_action_plot")
          ),
          card(
            card_header(i18n$t("Road hierarchy")),
            plotlyOutput(outputId = "ddsb_ped_road_hierarchy_plot")
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
            value = textOutput("box_cyc_total_collision_value"),
            showcase = icon("car-crash"),
            theme = "primary"
          ),
          value_box(
            title = i18n$t("Total Casualties"),
            value = textOutput("box_cyc_total_casualty_value"),
            showcase = icon("user-injured"),
            theme = "primary"
          ),
          value_box(
            title = i18n$t("Serious Injuries"),
            value = textOutput("box_cyc_serious_stat_value"),
            showcase = icon("hospital"),
            theme = "warning"
          ),
          value_box(
            title = i18n$t("Fatalities"),
            value = textOutput("box_cyc_fatal_stat_value"),
            showcase = icon("skull-crossbones"),
            theme = "danger"
          )
        ),
        
        # Collision maps and plots
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header(i18n$t("Collision location")),
            tmapOutput(outputId = "ddsb_cyc_collision_heatmap")
          ),
          card(
            card_header(i18n$t("Collision severity")),
            plotlyOutput(outputId = "ddsb_cyc_ksi_plot")
          )
        ),
        
        layout_columns(
          col_widths = c(6),
          card(
            card_header(i18n$t("Collision type")),
            plotlyOutput(outputId = "ddsb_cyc_collision_type_plot")
          )
        ),
        
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header(i18n$t("Vehicle classes involved (excl. cycle)")),
            plotlyOutput(outputId = "ddsb_cyc_vehicle_class_plot")
          ),
          card(
            card_header(i18n$t("Vehicle maneuver (excl. cycle)")),
            plotlyOutput(outputId = "ddsb_cyc_vehicle_movement_plot")
          )
        ),
        
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header(i18n$t("Cyclist action")),
            plotlyOutput(outputId = "ddsb_cyc_cyc_action_plot")
          ),
          card(
            card_header(i18n$t("Road hierarchy")),
            plotlyOutput(outputId = "ddsb_cyc_road_hierarchy_plot")
          )
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
            value = textOutput("box_all_total_collision_value"),
            showcase = icon("car-crash"),
            theme = "primary"
          ),
          value_box(
            title = i18n$t("Total Casualties"),
            value = textOutput("box_all_total_casualty_value"),
            showcase = icon("user-injured"),
            theme = "primary"
          ),
          value_box(
            title = i18n$t("Serious Injuries"),
            value = textOutput("box_all_serious_stat_value"),
            showcase = icon("hospital"),
            theme = "warning"
          ),
          value_box(
            title = i18n$t("Fatalities"),
            value = textOutput("box_all_fatal_stat_value"),
            showcase = icon("skull-crossbones"),
            theme = "danger"
          )
        ),
        
        # Collision maps and plots
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header(i18n$t("Collision location")),
            tmapOutput(outputId = "ddsb_all_collision_heatmap")
          ),
          card(
            card_header(i18n$t("Collision severity")),
            plotlyOutput(outputId = "ddsb_all_ksi_plot")
          )
        ),
        
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header(i18n$t("Collision trend")),
            plotlyOutput(outputId = "ddsb_all_year_plot")
          ),
          card(
            card_header(i18n$t("Collision type")),
            plotlyOutput(outputId = "ddsb_all_collision_type_plot")
          )
        ),
        
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header(i18n$t("Vehicle classes involved")),
            plotlyOutput(outputId = "ddsb_all_vehicle_class_plot")
          ),
          card(
            card_header(i18n$t("Road hierarchy")),
            plotlyOutput(outputId = "ddsb_all_road_hierarchy_plot")
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
      tmapOutput(outputId = "hotzones_map", height = "50vh"),
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
  
  # Add OpenGraph tags for social media
  tags$head(
    tags$meta(property = "og:title", content = OPENGRAPH_PROPS$title),
    tags$meta(property = "og:url", content = OPENGRAPH_PROPS$url),
    tags$meta(property = "og:image", content = OPENGRAPH_PROPS$image),
    tags$meta(property = "og:description", content = OPENGRAPH_PROPS$description)
  )
)

# Now let's examine the body content for each tab and replace it with bslib components
