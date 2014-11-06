#### Install packages ####

install.packages("maptools")
library(maptools)
install.packages("scales")
library(scales)
install.packages("ggplot2")
library(ggplot2)
install.packages("gdalUtils")
library(gdalUtils)
#require("rgdal") - readOGR better for loading shapefiles?

#### Sheffield population map ####

# Data prep

sheffield <- readShapeSpatial('england_lsoa_2011PolygonS', proj4string = CRS("+init=epsg:27700"))
plot(sheffield)
download.file("https://raw.githubusercontent.com/tombro1987/sheffield-mapping
              /master/sheffield.csv", "sheffield.csv", method = "internal")
shef.lsoa <- read.csv("sheffield.csv", header = TRUE)
shef.lsoa <- shef.lsoa[, 7:12]
shef.lsoa <- shef.lsoa[1590:1934, ]
shef.lsoa[, 2] <- NULL
shef.lsoa[, 2] <- NULL
shef.lsoa[, 2] <- NULL
shef.lsoa[, 2] <- NULL
colnames(shef.lsoa) <- c("LSOAcode", "No cars")

# Joining

sheffield@data = data.frame(sheffield@data, shef.lsoa[match(sheffield@data[, "code"], shef.lsoa[, "LSOAcode"]),])
View(sheffield@data)

# breaks

y <- (shef.lsoa[, 2])
y <- as.numeric(as.character(y))
View(y)
range(y)
a <- cut(y, breaks = 5)
summary(a)
labs2 <- c("26-157", "158-290", "291-422", "423-555", "556-689") # based on the results of the previous line

# plotting

my_colour2 <- c("#33A1C9", "#FFEC8B", "#A2CD5A", "#CD7054", "#B7B7B7")
plot(sheffield, col=my_colour[a], axes = FALSE)
# locator () - This allows you to pinpoint a location on the plot where you want the legend to go. Press escape after clicking
legend(x=416120, y=386403, legend = labs2, fill = my_colour2, bty = "n", cex = .8, ncol =1, title = "Households \nper LSOA")
title("Sheffield population map - households with no cars")

#### Sheffield OAC map #### 

# Data prep

sheffield_OA <- readShapeSpatial('england_oa_2011Polygon', proj4string = CRS("+init=epsg:27700"))
plot(sheffield_OA)
download.file("https://raw.githubusercontent.com/tombro1987/sheffield-mapping
              /master/J31A0311_2774_2011SOA_YORK.csv", "J31A0311_2774_2011SOA_YORK.csv", method = "internal")
OAC.S <- read.csv('J31A0311_2774_2011SOA_YORK.csv', header = TRUE, skip = 5)
OAC.S <- OAC.S[8333:10149, ]

# Subsetting

OAC.S <- subset(OAC.S, select = c("OA_CODE", "DATA_VALUE", "DATA_VALUE.1", "DATA_VALUE.2", 
                                  "DATA_VALUE.3", "DATA_VALUE.4", "DATA_VALUE.5"))
colnames(OAC.S) <- c("OA_CODE", "Supergroup Name", "Supergroup Code", "Group Name", "Group Code",
                     "Subgroup Name", "Subgroup Code")

# Joining

sheffield_OA@data = data.frame(sheffield_OA@data, OAC.S[match(sheffield_OA@data[, "code"], OAC.S[, "OA_CODE"]),])
head(sheffield_OA@data)

# Plotting

my_colour3 <- c("#33A1C9","#FFEC8B","#A2CD5A","#CD7054","#B7B7B7","#9F79EE","#FCC08F", "#F30FD5")
plot(sheffield_OA, col = my_colour3[sheffield_OA@data$Supergroup.Code], axes = FALSE)
labels <- c("Rural Residents", "Cosmopolitans", "Ethnicity Central", "Multicultural Metropolitans", "Urbanites", "Suburbanites", "Constrained City Dwellers", "Hard-Pressed Living")
legend(x=411026, y=388645, legend = labels, fill = my_colour3, bty = "n", cex = .8, ncol =1, title = "OAC classification \n(2011)")
title("OAC classification map of Sheffield")
