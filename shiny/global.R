

# Packages
library(shiny)
library(dplyr)
library(tidyr)
library(movieNetwork)
library(networkD3)

genreList <- movieNetwork::load_genres()$name

action2000 <- read.csv("data/action2000.csv", stringsAsFactors = FALSE)
comedy2000 <- read.csv("data/comedy2000.csv", stringsAsFactors = FALSE)
action1990 <- read.csv("data/action1990.csv", stringsAsFactors = FALSE)
comedy1990 <- read.csv("data/comedy1990.csv", stringsAsFactors = FALSE)
action1980 <- read.csv("data/action1980.csv", stringsAsFactors = FALSE)
comedy1980 <- read.csv("data/comedy1980.csv", stringsAsFactors = FALSE)

