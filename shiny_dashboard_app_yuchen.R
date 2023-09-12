# Load required libraries
#install.packages("DT")
library(shiny)
library(shinydashboard)
library(leaflet)
library(DBI)
library(odbc)
library(DT)


# Read database credentials
# source("./03_shiny_HW1/credentials_v3.R")
source("./credentials_v4.R")


ui <- dashboardPage(
  skin=("purple"),
  dashboardHeader(title = "ITOM6265-HW1"),
  
  #Sidebar content
  dashboardSidebar(
    #Add sidebar menus here
    sidebarMenu(
      menuItem("HW Summary", tabName = "HWSummary", icon = icon("compass")),
      menuItem("Q1-DB Query", tabName = "dbquery", icon = icon("bolt")),
      menuItem("Q2-Maps", tabName = "leaflet", icon = icon("map"))
    )
  ),
  dashboardBody(
    tabItems(
      # Add contents for first tab
      tabItem(tabName = "HWSummary",
              h3("This HW was submitted by Yuchen Huang of ITOM6265",style = "font-family: 'Times', serif;",align="center"),
              p("Welcome to Yuchen Huang's Dashboard!
              Firstly, I divide the whole project into three pages: the dashboard page, query page and map page. In the query page, I connect it to the SQL server and extract target date using key word and select certain range votes of data using SQL query. In the map page, I exclude the null values and combine the reasonable latitude and longitude data using SQL query.
Secondly, I change some matchable icons for the dashboard; alter the color scheme to purple and yellow, which are my favorite colors; change the font all words to Times, including the button; align every tag. Also, I change the style, color and class of the button. 
Hope you'll like it. Thank you~!
",style = "font-family: 'Times', serif;")
              
      ),
      # Add contents for second tab
      tabItem(tabName = "dbquery",
              fluidRow(
                column(width = 12,
                       box(width = NULL, solidHeader = TRUE,
                           textInput("rest_names", h3("Pattern of Name:",style = "font-family: 'Times', serif;")),
                           background=("yellow"),
                           sliderInput("rest_votes_slider", label = h3("Range of votes to search for:",style = "font-family: 'Times', serif;"), min = 0, 
                                       max = 100, value = c(0, 60)),
                           actionButton("Go", "Get results",style = "font-family: 'Times', serif;",class = "btn-warning",style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                           h1("The is your search result",align="center",style = "font-family: 'Times', serif;"),
                           DT::dataTableOutput("mytable")
                       )
                ))
      ),
      
      
      #  Add contents for third tab
      tabItem(tabName = "leaflet",
              fluidRow(
                column(width = 12,
                       box(width = NULL, solidHeader = TRUE,
                           h2("Map of restaurants in London. Click on teardrop to check names.",style = "font-family: 'Times', serif;",align="center"),
                           leafletOutput("mymap")
                       )
                )
              )
              
      )
    )
  )
)



server <- function(input, output) {
  
  #Develop your server side code (Model) here
  observeEvent(input$Go, {
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    db
    
    # browser()
    query <- paste("select name,Votes,city from zomato_rest where name like '%",input$rest_names,"%' AND  votes  between ", input$rest_votes_slider[1]," AND ",input$rest_votes_slider[2],  ";", sep="")
    print(query)
    data <- dbGetQuery(db, query)
    
    output$mytable = DT::renderDataTable({
      data
    })
    
  })
  
  
  
  output$mymap <- renderLeaflet({
    
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    #browser()
    query <- paste("select name,latitude,Longitude from zomato_rest where latitude is NOT NULL;")
    print(query)
    
    data <- dbGetQuery(db, query)
    
    leaflet(data = data) %>%
      addProviderTiles("Stamen.Watercolor") %>%
      addProviderTiles("Stamen.TonerHybrid") %>%
      addMarkers(lng = ~Longitude,
                 lat = ~latitude,
                 popup = paste("Name", data$name))  
    # addProviderTiles(providers$Stamen.Toner)
    #m
    
  })
  
  
  
}

shinyApp(ui, server)