# rmo: data store for air quality measurements

**rmo** reads exports from AIRMO in CSV or DAT format and saves the data as rds file. 
Provides utility function to convert the data into a compatible format for openair.

Installation
------------

``` r
require(devtools)
install_github('Avsamoht/rmo')
```

Brief examples
--------------

### rmo long format

``` r
str(df)
## 'data.frame':	312183 obs. of  6 variables:
## $ startzeit     : POSIXct, format: "2014-01-01 00:00:00" "2014-01-01 00:00:00" "2014-01-01 00:00:00" "2014-01-01 00:00:00" ...
##  $ airmo_kurzname: Factor w/ 2 levels "Zch_Schimmelstrasse",..: 1 1 1 2 2 2 1 1 1 2 ...
##  $ parameter     : Factor w/ 3 levels "NO","NOx","O3": 2 1 3 2 1 3 2 1 3 2 ...
##  $ zeitfenster   : Factor w/ 1 level "min30": 1 1 1 1 1 1 1 1 1 1 ...
##  $ einheit       : Factor w/ 2 levels "µg/m3","ppb": 2 1 1 2 1 1 2 1 1 2 ...
##  $ value         : num  89.58 76.74 1.59 75.4 63.81 ...

head(df)
##    startzeit          airmo_kurzname parameter zeitfenster einheit value
## 1 2014-01-01     Zch_Schimmelstrasse       NOx       min30     ppb 89.58
## 2 2014-01-01     Zch_Schimmelstrasse        NO       min30   µg/m3 76.74
## 3 2014-01-01     Zch_Schimmelstrasse        O3       min30   µg/m3  1.59
## 4 2014-01-01 Zch_Stampfenbachstrasse       NOx       min30     ppb 75.40
## 5 2014-01-01 Zch_Stampfenbachstrasse        NO       min30   µg/m3 63.81
## 6 2014-01-01 Zch_Stampfenbachstrasse        O3       min30   µg/m3  1.74
```

### read an export file from AIRMO and save it in the store

``` r
library(rmo)
# DAT format
df <- read_airmo_dat("O:/060_R/import_airmo/dat/wied_jahr_m30.dat")
rds_save_data(df, "O:/060_R/rds")

# CSV format
df <- read_airmo_csv("O:/060_R/import_airmo/STA_data_2013_2015.csv")
rds_save_data(df, "O:/060_R/rds")
```

### save the data into the store

``` r
sites <- c("Zch_Stampfenbachstrasse", "Zch_Schimmelstrasse")
df <- rds_load_data(sites, "min30", 2014:2017, c("NO", "NOx", "O3"), "O:/060_R/rds")

str(df)
## 'data.frame':	312183 obs. of  6 variables:
## $ startzeit     : POSIXct, format: "2014-01-01 00:00:00" "2014-01-01 00:00:00" "2014-01-01 00:00:00" "2014-01-01 00:00:00" ...
##  $ airmo_kurzname: Factor w/ 2 levels "Zch_Schimmelstrasse",..: 1 1 1 2 2 2 1 1 1 2 ...
##  $ parameter     : Factor w/ 3 levels "NO","NOx","O3": 2 1 3 2 1 3 2 1 3 2 ...
##  $ zeitfenster   : Factor w/ 1 level "min30": 1 1 1 1 1 1 1 1 1 1 ...
##  $ einheit       : Factor w/ 2 levels "µg/m3","ppb": 2 1 1 2 1 1 2 1 1 2 ...
##  $ value         : num  89.58 76.74 1.59 75.4 63.81 ...

head(df)
##    startzeit          airmo_kurzname parameter zeitfenster einheit value
## 1 2014-01-01     Zch_Schimmelstrasse       NOx       min30     ppb 89.58
## 2 2014-01-01     Zch_Schimmelstrasse        NO       min30   µg/m3 76.74
## 3 2014-01-01     Zch_Schimmelstrasse        O3       min30   µg/m3  1.59
## 4 2014-01-01 Zch_Stampfenbachstrasse       NOx       min30     ppb 75.40
## 5 2014-01-01 Zch_Stampfenbachstrasse        NO       min30   µg/m3 63.81
## 6 2014-01-01 Zch_Stampfenbachstrasse        O3       min30   µg/m3  1.74

tail(df)
##                  startzeit          airmo_kurzname parameter zeitfenster einheit     value
## 312178 2017-12-31 23:30:00     Zch_Schimmelstrasse        NO       min30   µg/m3  1.415176
## 312179 2017-12-31 23:30:00     Zch_Schimmelstrasse       NOx       min30     ppb  5.711500
## 312180 2017-12-31 23:30:00     Zch_Schimmelstrasse        O3       min30   µg/m3 54.884442
## 312181 2017-12-31 23:30:00 Zch_Stampfenbachstrasse        NO       min30   µg/m3  1.045155
## 312182 2017-12-31 23:30:00 Zch_Stampfenbachstrasse       NOx       min30     ppb  6.752600
## 312183 2017-12-31 23:30:00 Zch_Stampfenbachstrasse        O3       min30   µg/m3 52.877472


# all parameter for a station (set parameters = null)
df <- rds_load_data("Zch_Stampfenbachstrasse", "min30", 2014:2017, base_path="O:/060_R/rds")
df <- rds_load_data("Zch_Stampfenbachstrasse", "min30", 2014:2017, NULL, "O:/060_R/rds")

```

### utility functions

the package containts the utility functions **merge_rmo_longformat** and **rmo_to_openair**.

``` r
# Missing values (NA) in y will be replaced with the values from x
xy <- rds_load_data("Zch_Stampfenbachstrasse", "min30", 2017, base_path="O:/060_R/rds")
x <- tail(xy, -10000)  # remove 10000 starting rows
y <- head(xy, -10000)  # remove 10000 ending rows
xy2 <- merge_rmo_longformat(x, y)
dplyr::setequal(xy, xy2)
## TRUE


parameters <- c("Wvv", "WD", "O3", "PM2.5", "NOx")
df <- rds_load_data(c("Zch_Stampfenbachstrasse", "Zch_Schimmelstrasse"), "min30", 2017, parameters, "O:/060_R/rds")
td <- rmo_to_openair(df)
head(td)
##                  date                    site zeitfenster    nox       o3     pm25     wd
## 1 2017-01-01 00:30:00     Zch_Schimmelstrasse       min30 49.573 1.432410 69.07397 336.86
## 2 2017-01-01 00:30:00 Zch_Stampfenbachstrasse       min30 27.672 1.420779       NA 296.15
## 3 2017-01-01 01:00:00     Zch_Schimmelstrasse       min30 57.428 1.428300 72.01043 338.13
## 4 2017-01-01 01:00:00 Zch_Stampfenbachstrasse       min30 26.875 1.474185       NA 288.27
## 5 2017-01-01 01:30:00     Zch_Schimmelstrasse       min30 72.514 1.479951 65.96797 340.56
## 6 2017-01-01 01:30:00 Zch_Stampfenbachstrasse       min30 30.437 1.419103       NA 301.20


# optional add an id column and rename some parameters
site_ids <- list("Zch_Schimmelstrasse"="Wied", "Zch_Stampfenbachstrasse"="Staba")
parameter_names <- list("O3"="O3_renamed")
td <- rmo_to_openair(df, site_ids, parameter_names)
head(td)
##                  date                    site zeitfenster    nox o3_renamed     pm25     wd    id
## 1 2017-01-01 00:30:00     Zch_Schimmelstrasse       min30 49.573   1.432410 69.07397 336.86  Wied
## 2 2017-01-01 00:30:00 Zch_Stampfenbachstrasse       min30 27.672   1.420779       NA 296.15 Staba
## 3 2017-01-01 01:00:00     Zch_Schimmelstrasse       min30 57.428   1.428300 72.01043 338.13  Wied
## 4 2017-01-01 01:00:00 Zch_Stampfenbachstrasse       min30 26.875   1.474185       NA 288.27 Staba
## 5 2017-01-01 01:30:00     Zch_Schimmelstrasse       min30 72.514   1.479951 65.96797 340.56  Wied
## 6 2017-01-01 01:30:00 Zch_Stampfenbachstrasse       min30 30.437   1.419103       NA 301.20 Staba
```

