


# Start Application
shinyUI(
  bootstrapPage(
    fluidPage(
      theme = "bootstrap.css",


navbarPage("Film Network Analysis"),
# Panel 1
sidebarLayout(
  sidebarPanel(width = 3,

               selectInput("network", "Select Network:",
                           choices = c("Top 100 Action Movies from 2000-2017" = "option1",
                                       "Top 100 Comedy Movies from 2000-2017" = "option2",
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
                 column(6,numericInput("moviecount", "Number of Movies:",
                              20, min = 20, max = 150)),
                 column(6,numericInput("actorcount", "Number of Actors:",
                              7, min = 5, max = 15))
                 ),

               dateRangeInput('dateRange',
                                label = 'Date range for Movies:',
                                start = "2010/01/01", end = "2015/12/31"
                 )),

               br(),

               actionButton("goButton", "Find Movies:")
                ),

            mainPanel(
                #tableOutput("table")
              tabsetPanel(
                tabPanel("Network Diagram",
                  forceNetworkOutput("force", height = "660px", width = "110%")),
                tabPanel("Most Influencial Cast/Crew",
                         tableOutput("table2")))
            )
        )
    )
))





