
# Start Application
shinyUI(
  bootstrapPage(
    fluidPage(
      theme = "bootstrap.css",


navbarPage("Film Network: An R Shiny Application Example"),
# Panel 1
sidebarLayout(
  sidebarPanel(
    width = 3,
    selectInput("network", "Select Network:",
                choices = c("Top 70 Action Movies from 2000-2017" = "option1",
                            "Top 70 Comedy Movies from 2000-2017" = "option2",
                            "Top 70 Action Movies from 1990-2000" = "option3",
                            "Top 70 Comedy Movies from 1990-2000" = "option4",
                            "Top 70 Action Movies from 1980-1990" = "option5",
                            "Top 70 Comedy Movies from 1980-1990" = "option6",
                            "Custom Network (use selections below)" = "custom"),
                selected = "option3"),
    
    fluidRow(
      column(
        6,
        selectInput("cast_crew", "Cast or Crew:",
                    choices = c("cast" = "cast", "crew" = "crew"),
                    selected = "cast")),
      column(
          6,
          sliderInput("actor_count", "Number of People:",
                      min = 10, max = 100,  step = 1,  value = 35, ticks = FALSE))
      ),
    
    conditionalPanel(
      condition = "input.network == 'custom'",
      
      h5("NOTE: Custom lookup is disabled in this sample app. Please clone from github and use your own API key."),
      
      uiOutput("genres"),
      
      fluidRow(
        column(
          6,
          numericInput("movie_count", "Number of Movies:", 20, 20, 150)
          )
        ),
      
      dateRangeInput('dateRange',
                     label = 'Date range for Movies:',
                     start = "2010/01/01", end = "2015/12/31"
                     ),
      
      actionButton("goButton", "Find Movies:")
      ),
    
    br(),
    
    helpText("----------------------------------------"),
    
    uiOutput("actors"),
    
    conditionalPanel(
      condition = "input.actorSelect != '...'",
      tableOutput("movieTable")
      ),
    
    fluidRow(
        h6("This work was in calibration with my friend Will Burton.
           Feel free to checkout his profile.", 
           a(icon("linkedin-square", class = NULL, lib = "font-awesome"),
             href="https://www.linkedin.com/in/wjburton/")
           )
    )
    ),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Network Diagram",
               forceNetworkOutput("force", height = "660px", width = "110%")),
      tabPanel("Most Influencial Cast/Crew",
               tableOutput("table2")))
    )
  )
)
)
)

