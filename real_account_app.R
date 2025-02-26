library(shiny)
library(bs4Dash)
library(DT)
library(ggplot2)
library(plotly)
library(dplyr)
library(bslib)

# Define a custom theme using bslib
my_theme <- bs_theme(
  bg = "#202123", 
  fg = "#E1E1E1", 
  primary = "#EA80FC", 
  info = "#17a2b8",
  secondary = "#00BFA5",
  base_font = font_google("Mulish"),
  heading_font = font_google("Mulish"),
  code_font = font_google("Mulish"),
  navbar_bg = "#333333",  
  navbar_fg = "#ffffff"  
)


# Define the CSV file path
csv_file_path <- "data/trades_real.csv"


# Function to fetch trade data from the CSV file.
getTrades <- function(){
  # If the CSV doesn't exist, create it with the proper column names.
  if (!file.exists(csv_file_path)) {
    write.csv(
      data.frame(
        trade_date = character(),
        trade_time = character(),
        currency_pair = character(),
        entry_second = numeric(),
        trade_expiry_time = character(),
        outcome = character(),
        comment = character()
      ),
      csv_file_path,
      row.names = FALSE
    )
  }
  trades <- read.csv(csv_file_path, stringsAsFactors = FALSE)
  # Order trades by date and time in descending order
  trades <- trades %>% arrange(desc(trade_date), desc(trade_time))
  trades
}

# Function to insert a new trade record into the CSV file.
insertTrade <- function(date, time, currency_pair, entry_second, trade_expiry_time, outcome, comment){
  new_trade <- data.frame(
    trade_date = date,
    trade_time = time,
    currency_pair = currency_pair,
    entry_second = as.numeric(entry_second),
    trade_expiry_time = trade_expiry_time,
    outcome = outcome,
    comment = comment,
    stringsAsFactors = FALSE
  )
  # If the file doesn't exist, write the header; otherwise, append the new row.
  if (!file.exists(csv_file_path)) {
    write.csv(new_trade, csv_file_path, row.names = FALSE)
  } else {
    write.table(
      new_trade,
      csv_file_path,
      append = TRUE,
      sep = ",",
      row.names = FALSE,
      col.names = FALSE
    )
  }
}

ui <- bs4DashPage(
  title = "TradePulse Analytics",
  freshTheme = my_theme,
  dark = NULL,
  help = NULL,
  fullscreen = FALSE,
  scrollToTop = TRUE,
  header = bs4DashNavbar(
    fixed = TRUE,
    controlbarIcon = NULL,
    title = tags$div(
      class = "text-center header-title-container",
      tags$h4("TradePulse Analytics", class = "header-title")
    ),
    tags$li(
      class = "clock-container",
      tags$span(
        id = "dynamic-clock"
      ),
    )
  ),
  # Provide a minimal sidebar (which we then hide with CSS)
  sidebar = bs4DashSidebar(
    disable = TRUE,
    collapsed = TRUE
  ),
  body = bs4DashBody(
    tags$head(
      includeCSS("www/css/custom_styles.css"),      
      tags$script(src = "js/custom.js"),
      tags$link(rel = "shortcut icon", href = "favicon/kenbright.ico", type = "image/x-icon"),
      tags$link(
        href = "https://fonts.googleapis.com/css2?family=Nunito:wght@400;700&display=swap", 
        rel = "stylesheet")
    ),
    # Page content: first the Trade Entry Form, then the Analytics
    fluidRow(
      bs4Card(
        title = "Enter New Trade",
        width = 4,
        height = "750px",
        collapsible = TRUE,
        solidHeader = TRUE,
        status = "white",
        dateInput("trade_date", "Trade Date", value = Sys.Date()),
        textInput("trade_time", "Trade Time (HH:MM)", value = format(Sys.time(), "%H:%M")),
        textInput("currency_pair", "Currency Pair", placeholder = "e.g., EUR/USD"),
        numericInput("entry_second", "Entry Second", value = 0, min = 0),
        selectInput("trade_expiry_time", "Trade Expiry Time", 
                    choices = c("15 Seconds", "5 Seconds", "10 Seconds", "30 Seconds", 
                                "1 minute", "1.30 minute", "2 minutes", "5 minutes", 
                                "10 minutes", "15 minutes")),
        selectInput("outcome", "Outcome", choices = list("Win" = "win", "Loss" = "loss")),
        textAreaInput("comment", "Comment", placeholder = "Enter comments..."),
        actionButton("submit_trade", "Submit Trade", class = "btn-primary control-button"),
        hr(),
        actionButton("reset_data", "Reset Trades Data", icon = icon("redo"), class = "btn-danger reset-button")
      ),
      bs4Card(
        title = "Trade Analytics",
        width = 8,
        height = "750px",
        collapsible = TRUE,
        solidHeader = TRUE,
        status = "white",
        fluidRow(
          column(
            width = 6,
            div(
              style = "background-color: #e1f5fe; padding: 20px; border-radius: 8px;",
              h3(textOutput("total_trades")),
              p("Total Trades")
            )
          ),
          column(
            width = 6,
            div(
              style = "background-color: #e8f5e9; padding: 20px; border-radius: 8px;",
              h3(textOutput("win_rate")),
              p("Win Rate (%)")
            )
          )
        ),
        div(
          style = "margin-top: 65px;",
          plotlyOutput("outcome_plot")
        )
      )
    ),
    fluidRow(
      bs4Card(
        title = "Top 5 Most Profitable Currency Pairs",
        width = 6,
        collapsible = TRUE,
        solidHeader = TRUE,
        status = "success",
        DTOutput("top_profitable")
      ),
      bs4Card(
        title = "Top 5 Most Unprofitable Currency Pairs",
        width = 6,
        collapsible = TRUE,
        solidHeader = TRUE,
        status = "danger",
        DTOutput("top_unprofitable")
      )
    ),
    fluidRow(
      bs4Card(
        title = "Trade Table",
        width = 12,
        collapsible = TRUE,
        solidHeader = TRUE,
        status = "white",
        DTOutput("trade_table")
      )
    )
  ),
  controlbar = bs4DashControlbar(),  
  footer = bs4DashFooter()           
)

server <- function(input, output, session) {
  
  # Reactive value to store current trade data.
  tradeData <- reactiveVal(getTrades())
  
  # Observe when a new trade is submitted.
  observeEvent(input$submit_trade, {
    req(input$trade_date, input$trade_time, input$currency_pair, input$entry_second, input$trade_expiry_time, input$outcome)
    
    # Create a new record as a data frame.
    new_record <- data.frame(
      trade_date = as.character(input$trade_date),
      trade_time = input$trade_time,
      currency_pair = input$currency_pair,
      entry_second = as.numeric(input$entry_second),
      trade_expiry_time = input$trade_expiry_time,
      outcome = input$outcome,
      comment = input$comment,
      stringsAsFactors = FALSE
    )
    
    # Check for duplicates: Look for an identical record in the current data.
    existing <- tradeData() %>% 
      filter(
        trade_date == new_record$trade_date,
        trade_time == new_record$trade_time,
        currency_pair == new_record$currency_pair,
        entry_second == new_record$entry_second,
        trade_expiry_time == new_record$trade_expiry_time,
        outcome == new_record$outcome,
        comment == new_record$comment
      ) 
    
    
    if(nrow(existing) > 0) {
      showNotification("Duplicate record! Not submitted.", type = "error")
      return()
    }    
    
    # Insert new trade into the CSV file.
    insertTrade(
      new_record$trade_date,
      new_record$trade_time,
      new_record$currency_pair,
      new_record$entry_second,
      new_record$trade_expiry_time,
      new_record$outcome,
      new_record$comment
    )
    
    # Refresh the reactive trade data.
    tradeData(getTrades())
    
    # Reset the form fields after submission.
    updateDateInput(session, "trade_date", value = Sys.Date())
    updateTextInput(session, "trade_time", value = "")
    updateTextInput(session, "currency_pair", value = "")
    updateNumericInput(session, "entry_second", value = 0)
    updateSelectInput(session, "trade_expiry_time", selected = "15 Seconds")
    updateSelectInput(session, "outcome", selected = "win")
    updateTextAreaInput(session, "comment", value = "")   
    
    showNotification("Trade submitted successfully!", type = "message")
    
  })
  
  # Reset Data Button: Confirmation Modal
  observeEvent(input$reset_data, {
    showModal(modalDialog(
      title = "Confirm Data Reset",
      "This will delete all existing trade data. Are you sure you want to reset?",
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_reset", "Yes, Reset Data", class = "btn btn-danger")
      )
    ))
  })
  
  observeEvent(input$confirm_reset, {
    removeModal()
    # Overwrite CSV with header-only data.
    write.csv(
      data.frame(
        trade_date = character(),
        trade_time = character(),
        currency_pair = character(),
        entry_second = numeric(),
        trade_expiry_time = character(),
        outcome = character(),
        comment = character()
      ),
      csv_file_path,
      row.names = FALSE
    )
    # Refresh the reactive data.
    tradeData(getTrades())
    showNotification("Trade data has been reset!", type = "message")
  })
  
  
  
  
  
  # Summary Outputs
  
  # Calculate and display total number of trades.
  output$total_trades <- renderText({
    n <- nrow(tradeData())
    paste(n)
  })
  
  # Calculate and display win rate as a percentage.
  output$win_rate <- renderText({
    data <- tradeData()
    total <- nrow(data)
    if(total == 0) return("0")
    wins <- sum(data$outcome == "win")
    rate <- round((wins / total) * 100, 1)
    paste(rate)
  })
  
  
  
  # Top 5 Most Profitable Currency Pairs.
  output$top_profitable <- renderDT({
    data <- tradeData()
    if(nrow(data) == 0) return(datatable(data.frame()))
    summary <- data %>%
      group_by(currency_pair) %>%
      summarise(
        wins = sum(outcome == "win"),
        losses = sum(outcome == "loss")
      ) %>%
      mutate(profit_score = wins - losses) %>%
      arrange(desc(profit_score))
    top5 <- head(summary, 5)
    datatable(top5, options = list(dom = 't', paging = FALSE))
  })
  
  
  
  # Top 5 Most Unprofitable Currency Pairs.
  output$top_unprofitable <- renderDT({
    data <- tradeData()
    if(nrow(data) == 0) return(datatable(data.frame()))
    summary <- data %>%
      group_by(currency_pair) %>%
      summarise(
        wins = sum(outcome == "win"),
        losses = sum(outcome == "loss")
      ) %>%
      mutate(profit_score = wins - losses) %>%
      arrange(profit_score)
    top5 <- head(summary, 5)
    datatable(top5, options = list(dom = 't', paging = FALSE))
  })
  
  
  
  # Render a Plotly bar chart for outcome distribution.
  output$outcome_plot <- renderPlotly({
    data <- tradeData() %>% 
      group_by(outcome) %>% 
      summarise(count = n())
    # Define custom colors for outcomes.
    custom_colors <- c("win" = "#4CAF50", "loss" = "#F44336")
    p <- ggplot(data, aes(x = outcome, y = count, fill = outcome)) +
      geom_bar(stat = "identity", width = 0.6) +
      # Add count labels above the bars.
      geom_text(aes(label = count), vjust = -0.5, size = 5, color = "black") +
      scale_fill_manual(values = custom_colors) +
      labs(title = "Outcome Distribution", x = "Trade Outcome", y = "Number of Trades") +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
        axis.title = element_text(face = "bold"),
        legend.position = "none",
        panel.grid.major.x = element_blank()
      )
    ggplotly(p) %>% layout(margin = list(t = 80))
  })
  
  
  
  
  # Render the data table of trade entries.
  output$trade_table <- renderDT({
    datatable(
      tradeData() %>%
        rename(
          Date = trade_date,
          Time = trade_time,
          Asset = currency_pair,
          `Entry Second` = entry_second,
          `Trade Expiry Time` = trade_expiry_time,
          `Trade Outcome` = outcome,
          Comment = comment
        ),
      options = list(
        pageLength = 10,      # Number of rows per page
        autoWidth = TRUE,     # Auto adjust column widths
        dom = 'Bfrtip',       # Buttons, filter, table, pagination
        buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),  # Export buttons
        class = "table table-striped table-hover table-bordered"
      ),
      rownames = FALSE
    ) %>% 
      formatStyle(
        columns = c('Date', 'Time', 'Asset', 'Entry Second', 'Trade Expiry Time', 'Trade Outcome', 'Comment'),
        fontSize = '14px', 
        fontWeight = 'bold', 
        color = 'black',
        backgroundColor = 'white'
      )
  })
  
  
}

shinyApp(ui, server)