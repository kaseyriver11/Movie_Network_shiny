
shinyServer(function(input, output, session){
    Sys.setlocale(locale="C")
    
    url <- a("Google Homepage", href="https://www.google.com/")
    output$link1 <- renderUI({
        tagList("URL link:", url)
    })
    
    # The list of Genres
    output$genres <- renderUI({
        selectizeInput("genreSelect", "Choose Genres:", as.list(genreList),
                       multiple = TRUE, options = list(maxItems = 3))
    })
    # Using the action button
    genres <- eventReactive(input$goButton, {
        input$genreSelect
    })
    dates <- eventReactive(input$goButton,{
        input$dateRange
    })
    movie_count <- eventReactive(input$goButton,{
        input$movie_count
    })
    actor_count <- eventReactive(input$goButton,{
        input$actor_count
    })
    # dframe will only rendered when the button is selected
    dframe <- reactive({
        
        if(input$network == "custom"){
            network_df <- create_network_df("Enter API Key", genres(),
                                            dates()[1], dates()[2],
                                            movie_request_lim = movie_count())
       }
        if(input$network == "option1"){network_df <- action2000}
        if(input$network == "option2"){network_df <- comedy2000}
        if(input$network == "option3"){network_df <- action1990}
        if(input$network == "option4"){network_df <- comedy1990}
        if(input$network == "option5"){network_df <- action1980}
        if(input$network == "option6"){network_df <- comedy1980}

        network_df
    })
    
    
    output$force <- renderForceNetwork({
        # Load the dataframe
        network_df <- dframe()
      
        # Create paired names
        pairwise_names <-
            create_link_df(network_df, input$cast_crew, k = input$actor_count)
        
        unique_names <- unique(c(pairwise_names$link_df$source_name,
                               pairwise_names$link_dftarget_name))
        # Find Betweeness
        between_matrix <- igraph::graph_from_data_frame(pairwise_names$link_df, directed = FALSE)
        between_value <- round(igraph::betweenness(between_matrix),2)
        between_df <- data.frame(id = as.numeric( names(between_value) ), 
                                 between_value, stringsAsFactors = F)
    
        # Create nodes labels containing the movies, connections, and betweenness
        node_labels <<- create_node_labels(pairwise_names$link_df, network_df, pairwise_names$id_df) %>% as.data.frame
        popular_df <<- find_most_popular(pairwise_names$link_df, pairwise_names$id_df, between_df, network_df, 20) %>% as.data.frame
        
        # Make the visual
        forceNetwork(Links = pairwise_names$link_df, Nodes = node_labels, #height = 800, width = 1000,
                     Source = "source", Target = "target",
                     linkWidth = JS("function(d) { return Math.pow(d.value,1.2); }"), # width of links
                     linkDistance = JS("function(d){return d.value * 10}"), # tightness of movie clusters
                     Value = "value", NodeID = "name", zoom = TRUE,
                     charge = -50, legend = TRUE,
                     colourScale = JS("d3.scaleOrdinal(d3.schemeCategory10);"),
                     bound = TRUE,
                     Group = "group", opacity = 0.8, fontSize = 12)
    })
    
    output$table <- renderTable({
        df <- network_df%>%
          select(-overview)
        df
    })
    
    output$table2 <- renderTable({
        popular_df
    })
    
    output$actors <- renderUI({

        network_df <- dframe()

        pairwise_names <- create_link_df(network_df, input$cast_crew, 
                                                   k = input$actor_count)

        unique_names <- unique(c(pairwise_names$link_df$source_name, pairwise_names$link_df$target_name))
        selectInput("actorSelect", "Search Nodes:", 
                    choices = c("...", as.list(unique_names)))
    })
    
    output$movieTable <- renderTable({
        network_df <- dframe()
        network_df <- subset(network_df, network_df$name == input$actorSelect)
        a <- data.frame(network_df$title)
        a <- unique(a)
        colnames(a) <- "Movie Titles"
        a
    })

})
