## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message = FALSE, warning = FALSE----------------------------------
library(rlandfire)
library(sf)
library(terra)
library(foreign)

## ----fig.align = "center", fig.height = 5, fig.width = 7----------------------
boundary_file <- file.path(tempdir(), "wildfire")
utils::unzip(system.file("extdata/wildfire.zip", package = "rlandfire"),
             exdir = tempdir())

boundary <- st_read(file.path(boundary_file, "wildfire.shp")) |>
  sf::st_transform(crs = st_crs(32613))

plot(boundary$geometry, main = "Calwood Fire Boundary (2020)", 
     border = "red", lwd = 1.5)

## -----------------------------------------------------------------------------
aoi <- getAOI(boundary, extend = 1000)
aoi

## -----------------------------------------------------------------------------
products <- c("LF2016_CC", "LF2022_CC", "LF2016_EVT")

## -----------------------------------------------------------------------------
email <- "rlandfire@markabuckner.com"

## -----------------------------------------------------------------------------
projection <- 32613 # WGS 84 / UTM zone 13N
resolution <- 90

## -----------------------------------------------------------------------------
edit_rule <- list(
  c("condition", "LF2016_EVT", "ne", 7054),
  c("change", "LF2016_CC", "st", 1),
  c("change", "LF2022_CC", "st", 1)
)

## ----eval=FALSE---------------------------------------------------------------
# edit_mask <- "path/to/wildfire.zip"

## -----------------------------------------------------------------------------
path <- tempfile(fileext = ".zip")

## ----eval=FALSE---------------------------------------------------------------
# resp <- landfireAPIv2(products = products,
#                       aoi = aoi,
#                       email = email,
#                       projection = projection,
#                       resolution = resolution,
#                       edit_rule = edit_rule,
#                       path = path,
#                       verbose = TRUE)

## ----include=FALSE------------------------------------------------------------
# Build example without calling API
resp <- landfireAPIv2(products = products,
                      aoi = aoi,
                      email = email,
                      projection = projection,
                      resolution = resolution,
                      edit_rule = edit_rule,
                      path = path,
                      execute = FALSE,
                      verbose = FALSE)

## ----eval=FALSE---------------------------------------------------------------
# resp$path

## ----include=FALSE------------------------------------------------------------
# Modify path to extdata
resp$path <- system.file("extdata/LFPS_Return_new.zip", package = "rlandfire")

## ----eval=FALSE---------------------------------------------------------------
# lf_dir <- file.path(tempdir(), "lf")
# utils::unzip(path, exdir = lf_dir)
# 
# lf <- terra::rast(list.files(lf_dir, pattern = ".tif$",
#                              full.names = TRUE,
#                              recursive = TRUE))

## -----------------------------------------------------------------------------
lf  <- landfireVSI(resp)
lf

## ----fig.align = "center", fig.height = 5, fig.width = 7----------------------
lf$LF2016_CC_CONUS[lf$LF2016_CC_CONUS == 1] <- NA
lf$LF2022_CC_CONUS[lf$LF2022_CC_CONUS == 1] <- NA

change <- lf$LF2022_CC_CONUS - lf$LF2016_CC_CONUS

plot(change, col = rev(terrain.colors(250)),
     main = "Canopy Cover Loss - Calwood Fire (2020)",
     xlab = "Easting",
     ylab = "Northing")
plot(boundary$geometry, add = TRUE, col = NA,
     border = "black", lwd = 2)

## ----eval=FALSE---------------------------------------------------------------
# resp <- landfireAPIv2(products = "LF2023_EVC",
#                     aoi = aoi,
#                     email = email,
#                     verbose = FALSE)

## ----include=FALSE------------------------------------------------------------
resp <- landfireAPIv2(products = "LF2023_EVC",
                    aoi = aoi,
                    email = email,
                    execute = FALSE,
                    verbose = FALSE)

resp$path <- system.file("extdata/LFPS_Return_cat_new.zip", package = "rlandfire")

## -----------------------------------------------------------------------------
evc <- landfireVSI(resp)
plot(evc)

## -----------------------------------------------------------------------------
head(levels(evc)[[1]])

## -----------------------------------------------------------------------------
# cats
attr_tbl <- cats(evc)

# Find path to database file
lf_cat <- file.path(tempdir(), "lf_cat")
utils::unzip(resp$path, exdir = lf_cat)

dbf <- list.files(lf_cat, pattern = ".dbf$",
                  full.names = TRUE,
                  recursive = TRUE)

# Read file
dbf_tbl  <- foreign::read.dbf(dbf)

head(attr_tbl[[1]])
head(dbf_tbl)

