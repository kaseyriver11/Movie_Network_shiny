


# Start Application
shinyUI(
  bootstrapPage(
    fluidPage(
      theme = "bootstrap.css",


navbarPage("Film Network: An R Shiny Application"),
# Panel 1
sidebarLayout(
  sidebarPanel(width = 3,

               selectInput("network", "Select Network:",
                           choices = c("Top 70 Action Movies from 2000-2017" = "option1",
                                       "Top 70 Comedy Movies from 2000-2017" = "option2",
                                       "Top 70 Action Movies from 1990-2000" = "option3",
                                       "Top 70 Comedy Movies from 1990-2000" = "option4",
                                       "Top 70 Action Movies from 1980-1990" = "option5",
                                       "Top 70 Comedy Movies from 1980-1990" = "option6",
                                       "Custom Network (use selections below)" = "custom"),
                           selected = "option1"),

               fluidRow(
                 column(6,selectInput("cast_crew", "Cast or Crew:",
                                      choices = c("cast" = "cast", "crew" = "crew"),
                                      selected = "cast"))
               ),

               conditionalPanel(
                 condition = "input.network == 'custom'",
                 
                 uiOutput("genres"),

               fluidRow(
                 column(6,numericInput("movie_count", "Number of Movies:",
                              20, min = 20, max = 150)),
                 column(6,numericInput("actor_count", "Number of People:",
                              7, min = 1, max = 20))
                 ),

               dateRangeInput('dateRange',
                                label = 'Date range for Movies:',
                                start = "2010/01/01", end = "2015/12/31"
                 ),
               
               actionButton("goButton", "Find Movies:")
               ),

               br(),
               br(),

               helpText("----------------------------------------"),
               uiOutput("actors"),
               conditionalPanel(
                   condition = "input.actorSelect != '...'",
                   tableOutput("movieTable")
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
))





