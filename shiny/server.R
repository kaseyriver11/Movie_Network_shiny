

shinyServer(function(input, output, session){
    
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
            network_df <- create_network_df("6df77c0d4d734469b206f490ea084869", genres(),
                                            dates()[1], dates()[2],
                                            movie_request_lim = movie_count())

            # network_df <- create_network_df("6df77c0d4d734469b206f490ea084869", 'Comedy',
            #                                 '2010-01-01', '2015-01-01',
            #                                 movie_request_lim = 100)
            # input <- list(cast_crew = 'cast')

       }
        if(input$network == "option1"){
            network_df <- action2000
        }
        if(input$network == "option2"){
            network_df <- comedy2000
        }
        
        network_df
        
    })
    
    
    output$force <- renderForceNetwork({
        # Look at only the cast members
        network_df <- dframe()
        #format movie df into the name connecitons df 
        pairwise_names <- create_name_combinations(network_df, input$cast_crew, 
                                                   k = input$actor_count)
        # make unique dataframe of cast/crew with ids
        unique_names <- unique(c(pairwise_names$source_name, pairwise_names$target_name))
        id <- 0:(length(unique_names)-1)
        id_df <- data.frame(name = unique_names, id, stringsAsFactors = F)
        # Add id's to the pairwise names and make a column 'value' containing the number of times
        # that single pairwise combination occurred (how many movies did this pair work on togethor)
        links <<- add_ids_to_names(pairwise_names, id_df) %>% as.data.frame
        # Find Betweeness
        between_matrix <- igraph::graph_from_data_frame(links, directed = FALSE)
        between_value <- round(igraph::betweenness(between_matrix),2)
        between_df <- data.frame(id = as.numeric( names(between_value) ), 
                                 between_value, stringsAsFactors = F)
        #Create nodes labels containing the movies, connections, and betweenness
        node_labels <<- create_node_labels(links, id_df, between_df, network_df) %>% as.data.frame
        popular_df <<- find_most_popular(links, id_df, between_df, network_df, 7) %>% as.data.frame
        # Make the visual
        forceNetwork(Links = links, Nodes = node_labels, #height = 800, width = 1000,
                     Source = "source", Target = "target",
                     linkWidth = JS("function(d) { return Math.pow(d.value,1.2); }"), # width of links
                     linkDistance = JS("function(d){return d.value * 10}"), # tightness of movie clusters
                     Value = "value", NodeID = "name", zoom = TRUE,
                     charge = -15, legend = TRUE,
                     colourScale = JS("d3.scaleOrdinal(d3.schemeCategory10);"),
                     bound = FALSE,
                     Group = "group", opacity = 0.8, fontSize = 12)
    })
    
    output$table <- renderTable({
        df <- network_df%>% select(-overview)
        df
    })
    
    output$table2 <- renderTable({
        df <- popular_df
        df
    })
    
    output$actors <- renderUI({
        # Look at only the cast members
        network_df <- dframe()
        #format movie df into the name connecitons df 
        pairwise_names <- create_name_combinations(network_df, input$cast_crew, 
                                                   k = input$actor_count)
        # make unique dataframe of cast/crew with ids
        unique_names <- unique(c(pairwise_names$source_name, pairwise_names$target_name))
        selectInput("actorSelect", "Search Nodes (hover graph to update):", 
                    choices = c("...", as.list(unique_names)))
    })
    
    
    
})
