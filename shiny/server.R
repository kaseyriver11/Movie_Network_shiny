

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
movieCount <- eventReactive(input$goButton,{
  input$moviecount
})
# dframe will only be rendered when the button is selected
dframe <- reactive({
  genres10 <- genres()
  dates10 <- dates()
  count <- movieCount()
  if(input$network == "custom"){
  df <- create_network_df("6df77c0d4d734469b206f490ea084869", genres10,
                          dates10[1], dates10[2],
                          movie_request_lim = count)
  }
  if(input$network == "option1"){
    df <- action2000
  }
  if(input$network == "option2"){
    df <- comedy2000
  }
  df

})


output$force <- renderForceNetwork({
  # Look at only the cast members
  df <- dframe()

  cast <- df[df$cast_crew == input$cast_crew,]

  movies <- unique(df$title)
  ## We want only the first K actors per movie:
  k = 7
  firstK <- cast[cast$title == "nothinginging", ]
  for(i in 1:length(movies)){
    dframe <- cast[cast$title == movies[i],]
    dframe <- dframe[1:(min(k, dim(dframe)[1])),]
    firstK <- rbind(firstK, dframe)
  }

  # Make the connections for every pair of actors that are in the same movie
  frame <- data.frame(source = character(), target = character())
  for(i in 1:length(movies)){
    currentDF <- firstK[firstK$title == movies[i],]
    # Data is too large - look at top K actors only
    columns <- dim(currentDF)[1]
    count <- columns
    for(j in 1:(columns-1)){
      count = count - 1
      source <- rep(currentDF[j,"name"], (columns-j))
      target <- currentDF$name[(j+1):columns]
      c <- as.data.frame(cbind(source,target))
      frame <- rbind(frame,c)
    }
  }
  # Convert to character
  frame$source <- as.character(frame$source)
  frame$target <- as.character(frame$target)
  # Sort each row alphabetically
  for(i in 1:length(frame)){
    a <- sort(frame[i,])
    frame[i,1] <- a[1]
    frame[i,2] <- a[2]
  }

  # Grab the Unique names of the actors
  keep <- unique(c(frame$source, frame$target))
  names <- unique(df$name[(df$name %in% keep)])
  ID <- 0:(length(names)-1)


  convertDF <- data.frame(Names=names, ID = ID)

  frame$source  <- convertDF$ID[match(frame$source, convertDF$Names)]
  frame$target  <- convertDF$ID[match(frame$target, convertDF$Names)]

  library(plyr)
  dupframe <- ddply(frame,.(source,target),nrow)
  name <- as.character(convertDF$Names)
  name2 <- name
  count <- as.numeric()
  # How many connections?
  keep <- c(dupframe$source, dupframe$target)
  connections <- c()
  for(i in 1:length(names)){
    number <- length(which(keep == (i-1)))
    connections <- c(connections,number)
  }
  # Find Betweeness
  a <- dupframe
  colnames(a) <- c("from", "to", "value")
  g <- graph_from_data_frame(a, directed = FALSE)
  btw <- round(betweenness(g),2)
  df <- data.frame(btw, as.numeric(names(btw)))
  df <- df[order(df$as.numeric.names.btw..),]

  # Create the JS Output
  for(i in 1:length(name)){
    dframe <- firstK[firstK$name == name[i],]
    name[i] <- paste0("., ", capitalize(selection), ": ", name[i], ", Movies: ",
                      paste(dframe$title, collapse = "; "),
                      ", Connections: ", connections[i],
                      ", Betweeness Score: ", df$btw[i])
    count[i] <- dim(dframe)[1]
  }

  # Make Links
  links <- dupframe
  colnames(links) <- c("source", "target", "value")

  # Make Nodes
  group <- count
  size <- rep(1,length(name))
  nodes <- as.data.frame(cbind(name, group, size))
  #nodes <- nodes[order(nodes$group),]

  # Make a Dframe of the top people
  most <- data.frame(name2, count, connections)
  most <- most[order(-count, -connections),]
  colnames(most) <- c(capitalize(selection), "Total Movies", "Connections")
  most <<- most[1:18,]

  # Make the visual
  forceNetwork(Links = links, Nodes = nodes, #height = 800, width = 1000,
               Source = "source", Target = "target",
               linkWidth = JS("function(d) { return Math.pow(d.value,1.7); }"), # width of links
               linkDistance = JS("function(d){return d.value * 10}"), # tightness of movie clusters
               Value = "value", NodeID = "name", zoom = TRUE,
               charge = -5, legend = TRUE,
               colourScale = JS("d3.scaleOrdinal(d3.schemeCategory10);"),
               height = "1000px", bound = TRUE,
               Group = "group", opacity = 0.8, fontSize = 12)
})



output$table <- renderTable({
  df <- dframe()
  df <- subset(df, select = -c(overview))
  df
})

output$table2 <- renderTable({
  df <- most
  cc <- input$cast_crew
  print(cc)
  df
})



})









