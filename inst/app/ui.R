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

      # Tab: Overview ----------------------------------------------------------

      tabItem(
        tabName = "tab_overview"
      ) # tabItem
    ) # tabItems
  ) # dashboardBody
) # dashboardPage
