library(shiny)
library(shinyBS)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)
library(DT)
library(tidyverse)
library(ggthemes)
library(hrbrthemes)
library(plotly)
library(readxl)
library(writexl)
library(janitor)
library(plyr)
library(tidyquant)
library(lubridate)
library(toOrdinal)
library(scales)
library(xkcd)
library(lifecontingencies)
library(bs4Dash)
library(bslib)
options(scipen=999)

# Frequencies -------------------------------------------------------------
freq_list = c("Annually", "Semi-Annually", "Quarterly", "Bi-Monthly", "Monthly", "Fortnightly", "Weekly", "Daily")
p_list = c(1, 2, 4, 6, 12, 26, 52, 365)

# Rounding to 2 Decimal Places --------------------------------------------
round_2d <- function(x, two_d = F){
    if(two_d == F) {
        if(round(as.numeric(x), 1)%%1 == 0){
          return(format(round(as.numeric(x), 0), nsmall = 0, big.mark = ",", scientific=FALSE))
        } else if ((10*round(as.numeric(x), 2))%%1 == 0){
          return(format(round(as.numeric(x), 1), nsmall = 1, big.mark = ",", scientific=FALSE))
        } 
    }
    return(format(round(as.numeric(x), 2), nsmall = 2, big.mark = ",", scientific=FALSE))
}

# Define a custom theme using bslib
my_theme <- bs_theme(
  bg = "#202123", 
  fg = "#E1E1E1", 
  primary = "#EA80FC", 
  secondary = "#00BFA5",
  base_font = font_google("Mulish"),
  heading_font = font_google("Mulish"),
  code_font = font_google("Mulish"),
  navbar_bg = "#333333", 
  navbar_fg = "#ffffff"  
)

ui <- dashboardPage(
  title = "Loan Calculator",
  dark = NULL,
  help = NULL,
  fullscreen = FALSE,
  scrollToTop = TRUE,
  freshTheme = my_theme,
  dashboardHeader(
    title = dashboardBrand(
      title = HTML("<div class='header-left'><strong style='font-weight: bold;'>Loan Calculator</strong></div>"),
      color = "white",
      href = "https://vehicle.co.ke/"
    ),
    controlbarIcon = NULL,
    fixed = TRUE
    #tags$div(class = "control-bar", actionButton("toggleControlbar", "Input Controls", class = "btn btn-primary control-button"))
  ),
  sidebar = dashboardSidebar(
    skin = "light",
    sidebarMenu(
      br(),
      br(),
      menuItem("Dashboard", tabName = "loan_calc", icon = icon("landmark"))
    ),
    div(class = "sidebar-footer",
        img(src = "images/kenbright2.png")
    )
  ),
  dashboardBody(
    useShinyjs(),
    tags$head(
      includeCSS("www/css/custom_styles.css"),
      tags$link(href = "https://fonts.googleapis.com/css2?family=Mulish:wght@400;700&display=swap", rel = "stylesheet"),
      tags$link(rel = "shortcut icon", href = "favicon/kenbright2.ico", type = "image/x-icon")
      ),
    tabItems(
      tabItem(tabName = "loan_calc", source("modules/loanCalculatorUI.R", local = TRUE)[1])
  )
  ),
  footer = bs4DashFooter(
    div(style = "background-color: #fff; color: black; text-align: center; padding: 8px;", 
        "© 2024 Loan Calculator | Powered by Robin")
  )
)


# Define server logic
server <- function(input, output, session) {

  source("modules/functions.R", local = TRUE)[1]
  source("modules/loanCalculatorServer.R", local = TRUE)[1]

}

# Run the application
shinyApp(ui = ui, server = server)