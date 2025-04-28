## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(rlandfire)
library(sf)
library(terra)
library(foreign)

## ----fig.align = "center", fig.height = 5, fig.width = 7----------------------
boundary_file <- file.path(tempdir(), "wildfire")
utils::unzip(system.file("extdata/wildfire.zip", package = "rlandfire"),
             exdir = tempdir())

boundary <- st_read(file.path(boundary_file, "wildfire.shp")) %>% 
  sf::st_transform(crs = st_crs(32613))

plot(boundary$geometry, main = "Calwood Fire Boundary (2020)", 
     border = "red", lwd = 1.5)

## -----------------------------------------------------------------------------
aoi <- getAOI(boundary, extend = 1000)
aoi

## -----------------------------------------------------------------------------
products <- c("200CC_19", "220CC_22", "200EVT")

## -----------------------------------------------------------------------------
email <- "rlandfire@example.com"

## -----------------------------------------------------------------------------
projection <- 32613
resolution <- 90

## -----------------------------------------------------------------------------
edit_rule <- list(c("condition","200EVT","ne",7054),
                  c("change", "200CC_19", "st", 1),
                  c("change", "220CC_22", "st", 1))

## ----eval=FALSE---------------------------------------------------------------
# edit_mask <- "path/to/wildfire.zip"

## -----------------------------------------------------------------------------
path <- tempfile(fileext = ".zip")

## ----eval=FALSE---------------------------------------------------------------
# resp <- landfireAPIv2(products = products,
#                     aoi = aoi,
#                     email = email,
#                     projection = projection,
#                     resolution = resolution,
#                     edit_rule = edit_rule,
#                     path = path,
#                     verbose = FALSE)

## ----eval=FALSE---------------------------------------------------------------
# resp$path

## ----include=FALSE------------------------------------------------------------
path <- system.file("extdata/LFPS_Return.zip", package = "rlandfire")

## -----------------------------------------------------------------------------
lf_dir <- file.path(tempdir(), "lf")
utils::unzip(path, exdir = lf_dir)

lf <- terra::rast(list.files(lf_dir, pattern = ".tif$", 
                             full.names = TRUE, 
                             recursive = TRUE))

## ----fig.align = "center", fig.height = 5, fig.width = 7----------------------
lf$US_200CC_19[lf$US_200CC_19 == 1] <- NA
lf$US_220CC_22[lf$US_220CC_22 == 1] <- NA

change <- lf$US_220CC_22 - lf$US_200CC_19

plot(change, col = rev(terrain.colors(250)),
     main = "Canopy Cover Loss - Calwood Fire (2020)",
     xlab = "Easting",
     ylab = "Northing")
plot(boundary$geometry, add = TRUE, col = NA,
     border = "black", lwd = 2)

## ----eval=FALSE---------------------------------------------------------------
# resp <- landfireAPIv2(products = "240EVC",
#                     aoi = aoi,
#                     email = email,
#                     verbose = FALSE)

## ----include=FALSE------------------------------------------------------------
resp <- c()
resp$path <- system.file("extdata/LFPS_cat_Return.zip", package = "rlandfire")

## -----------------------------------------------------------------------------
lf_cat <- file.path(tempdir(), "lf_cat")
utils::unzip(resp$path, exdir = lf_cat)

evc <- terra::rast(list.files(lf_cat, pattern = ".tif$", 
                             full.names = TRUE, 
                             recursive = TRUE))

plot(evc)

## -----------------------------------------------------------------------------
head(levels(evc)[[1]])

## -----------------------------------------------------------------------------
# cats
attr_tbl <- cats(evc)

# Find path to database file
dbf <- list.files(lf_cat, pattern = ".dbf$",
                  full.names = TRUE,
                  recursive = TRUE)

# Read file
dbf_tbl  <- foreign::read.dbf(dbf)

head(attr_tbl[[1]])
head(dbf_tbl)

