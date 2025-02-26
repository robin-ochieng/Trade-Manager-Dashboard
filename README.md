# TradePulse Analytics

TradePulse Analytics is a Shiny-based dashboard application built with R. It provides a comprehensive interface for recording trade details, analyzing trade performance, and managing your trade data interactively.

---

## Overview

TradePulse Analytics allows users to:

- **Enter Trades:** Submit new trade records through a user-friendly form.
- **Analyze Performance:** View key metrics such as total trades, win rate, outcome distribution, and top-performing assets.
- **Manage Data:** Edit trade records directly in an interactive table, download trades data as a CSV file, or reset all trade data with confirmation.

---

## Features

- **Trade Entry Form:**  
  - Submit trade details including date, time, asset (currency pair), forecast, trade expiry time, outcome, and comments.
  
- **Real-Time Analytics Dashboard:**  
  - Displays total trades, win rate, a Plotly bar chart of trade outcomes, and lists of top 5 profitable/unprofitable currency pairs.
  
- **Editable Trade Table:**  
  - An interactive data table (powered by DT) where users can correct or update trade entries directly.
  
- **Data Management Tools:**  
  - Download the trades data as a CSV file.
  - Reset all trade data with a confirmation prompt.

---

## Requirements

- **R:** Version 3.6.0 or higher is recommended.
- **R Packages:**
  - `shiny`
  - `bs4Dash`
  - `DT`
  - `ggplot2`
  - `plotly`
  - `dplyr`
  - `bslib`

---

## Installation

1. **Clone or Download the Repository:**

   ```bash
   git clone https://github.com/yourusername/TradePulse-Analytics.git

2. **Install Required Packages:**
In your R console, run:
```r
install.packages(c("shiny", "bs4Dash", "DT", "ggplot2", "plotly", "dplyr", "bslib"))
```
3. **Project Structure:**
Ensure your project directory is structured as follows:

 ```bash
TradePulse-Analytics/
├── app.R              # Main Shiny app file
├── data/
│   └── trades_demo.csv  # CSV file for trade records (auto-created if missing)
├── www/
│   ├── css/
│   │   └── custom_styles.css  # Custom CSS
│   └── js/
│       └── custom.js   # Custom JavaScript
└── README.md          # This documentation file
```

## Usage

1. **Run the Application:**
- Open the project in RStudio (or your preferred R IDE) and run:

```r
shiny::runApp("path/to/TradePulse-Analytics")
```

2. **Entering Trades:**
- Use the form to enter trade details and click the Submit Trade button.

3. **Viewing Analytics:**
- Check the dashboard for key metrics, including total trades, win rate, and outcome distribution.

4. **Editing Trade Records:**
- Edit any trade record directly in the Trade Table. Changes are saved to both the reactive data and the underlying CSV file.

5. **Managing Data:**
- Download Trades Data: Click the download button to export the current trade data as a CSV file.
- Reset Trades Data: Click the reset button to clear all trade data (confirmation required).
