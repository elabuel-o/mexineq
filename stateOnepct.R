
#################################
######## The One Percent ########
#################################

## Mexico income threshold of the top 1% by state.
## Author: Armando Enriquez.
## Date: June 19th, 2016.
## Purpose: map and charts of income inequality by state.


## =================
## Initial setup 
## =================

## Packages required
## In case you don't have installed these, just type install.packages() from
## your R console
library(stringr)
library(ggplot2)
library(ineq)
library(foreign)
library(survey)

## Additional setup:
## You may want to create a folder and set it as your working directory.
## Just type setwd() after you have created the folder.
## It is recommended that you have subfolders for data, shapefiles and so.


## =================
## Loading data and state names
## =================

## Data downloaded from the MCS-ENIGH-INEGI website.
## Notice that the data from MCS was corrected in 2015. 
mydata <- read.dbf("./data/concentradohogar.dbf")
mynames <- read.csv("./data/names.csv", header = TRUE)

## Official names from federative entities (they must match the attributes 
## stored in the shapefiles).
colnames(mynames) <- c("CVE_ENT", "NOM_ENT", "NOM_ABR", "NOM_CAP")

## Create a new variable named CVE_ENT, in order to match data and shapefiles
mydata$CVE_ENT <- as.numeric(str_sub(mydata$ubica_geo, 1, 2))

## =================
## Nationwide Income Analysis
## =================

## Monthly income
## The MCS reports household income in a quarterly fashion. 
## Create a new variable with monthly income:
mydata$ing_men <- mydata$ing_cor/3

## The MCS has a survey design
## Create a survey object (survey package) in order to do it in a suitable way
svy_mydata <- svydesign(id = ~upm + folioviv, strata = ~est_dis, 
                      weights = ~factor_hog, data = mydata)

## Nationwide statistics
svymean(~ing_men, svy_mydata) ## mean
svyquantile(~ing_men, svy_mydata, seq(0.1, 0.9, by = 0.1)) ## deciles
svyquantile(~ing_men, svy_mydata, 0.99) ## the One Percent

## =================
## Income Analysis by state
## =================

## Mean income by state
state_income <- svyby(~ing_men, ~CVE_ENT, svy_mydata, svymean)

dec <- seq(0, 0.9, by = 0.1)

deciles <- svyby(~ing_men, ~CVE_ENT, svy_mydata, svyquantile,
                 quantiles = dec, keep.var = FALSE)

## The one percent threshold by state
onepct <- svyby(~ing_men, ~CVE_ENT, svy_mydata, svyquantile,
                quantiles = 0.99, ci = TRUE, vartype = "ci")

## Merging both data frames (onepct data and the federative entities names)
onepct <- merge(onepct, mynames, by = "CVE_ENT")

## A dot (Cleveland) plot showing the top 1% income thresholds by state
ggplot(onepct, aes(x = ing_men, y = reorder(NOM_ENT, ing_men))) + 
        geom_point(size = 3) + xlab("Income threshold of top 1%") + ylab("") + 
        geom_segment(aes(yend = NOM_ENT), xend = 0, colour = "blue") + 
        theme_bw() + 
        theme(panel.grid.major.x = element_line(), 
              panel.grid.minor.x = element_blank(), 
              panel.grid.major.y = element_line(colour = "gray60", linetype = "dotted"))

## The map
library(ggplot2) ## graphics 
library(sp) ## spatial objects
library(maps)
library(maptools)
library(mapproj)
library(RColorBrewer) ## color palettes

mapDesc <- read.csv("./shapefiles/MEX_adm1.csv") ## state-level map information
mapMex <- readShapePoly("./shapefiles/MEX_adm1.shp") ## state-level map
mapMex <- fortify(mapMex)

## Notice that the ids in the mapMex dataframe begin with "0", and the ids in 
## the onepct dataframe begin with "1". Additionally, id in mapMex is of 
## class "character".
mapMex$id <- as.numeric(mapMex$id)
mapMex$id <- mapMex$id + 1
mapMex$CVE_ENT <- mapMex$id

## We already know that the id's between lifeExp and mapMex do not match
## The problem are Baja, Baja Sur, Coahuila, Colima, Chiapas & Chihuahua
## Fix the problem by rearranging the lifeExp data frame to coincide w/ mapMex
onepct[2, 1] <- 3 ## Baja California to id 3
onepct[3, 1] <- 2 ## Baja Sur to id 2
onepct[5, 1] <- 7 ## Coahuila to id 7
onepct[6, 1] <- 8 ## Colima to id 8
onepct[7, 1] <- 5 ## Chiapas to id 5
onepct[8, 1] <- 6 ## Chihuahua to id 6

## The Map
ggplot(onepct, aes(map_id = CVE_ENT, fill = ing_men)) +
        geom_map(map = mapMex, colour = "black") +
        scale_fill_gradient2(low = "#FFFFB2", mid = "#FD8D3C", high = "#BD0026",
                              midpoint = median(onepct$ing_men)) +
        expand_limits(x = mapMex$long, y = mapMex$lat) + 
        coord_map("polyconic") +
        labs(fill = "Income threshold of top 1%") + 
        xlab("") + ylab("")



