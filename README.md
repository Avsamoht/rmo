# rmo: data store for air quality measurements

**rmo** reads exports from AIRMO in CSV or DAT format and saves the data as rds files. 
The data is split in chunks grouped by year, site and zeitfenster.
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
rds_save_data(df, "rds")

# CSV format
df <- read_airmo_csv("O:/060_R/import_airmo/STA_data_2013_2015.csv")
rds_save_data(df, "rds")

# optional specify a file encoding, time zone and a time shift (eg. for converting end time to start time)
fn <- "O:/060_R/import_airmo/dat/wied_jahr_m30.dat"
df <- read_airmo_dat(fn, encoding = "cp1252", tz = "Etc/GMT-1",
  time_shift = lubridate::minutes(-30))
```

### load data from the store

``` r
sites <- c("Zch_Stampfenbachstrasse", "Zch_Schimmelstrasse")
df <- rds_load_data(sites, "min30", 2014:2017, c("NO", "NOx", "O3"), "rds")

str(df)
## 'data.frame':	312189 obs. of  6 variables:
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
## 312184 2017-12-31 23:30:00     Zch_Schimmelstrasse        NO       min30   µg/m3  1.415176
## 312185 2017-12-31 23:30:00     Zch_Schimmelstrasse       NOx       min30     ppb  5.711500
## 312186 2017-12-31 23:30:00     Zch_Schimmelstrasse        O3       min30   µg/m3 54.884442
## 312187 2017-12-31 23:30:00 Zch_Stampfenbachstrasse        NO       min30   µg/m3  1.045155
## 312188 2017-12-31 23:30:00 Zch_Stampfenbachstrasse       NOx       min30     ppb  6.752600
## 312189 2017-12-31 23:30:00 Zch_Stampfenbachstrasse        O3       min30   µg/m3 52.877472


# all parameter for a station (set parameters = NULL)
df <- rds_load_data("Zch_Stampfenbachstrasse", "min30", 2014:2017, base_path="rds")
df <- rds_load_data("Zch_Stampfenbachstrasse", "min30", 2014:2017, NULL, "rds")

```

### utility functions

#### merge_rmo_longformat

Merge two rmo dataframes

``` r
# Mergin: missing values (NA) in y will be replaced with the values from x
df <- rds_load_data("Zch_Stampfenbachstrasse", "min30", 2017, "NOx", base_path="rds")
x <- df[1:5,]
y <- df[3:7,]
y$value <- y$value * 2
xy <- merge_rmo_longformat(x, y)
print(x)
##             startzeit          airmo_kurzname parameter zeitfenster einheit  value
## 1 2017-01-01 00:00:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 27.672
## 2 2017-01-01 00:30:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 26.875
## 3 2017-01-01 01:00:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 30.437
## 4 2017-01-01 01:30:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 35.397
## 5 2017-01-01 02:00:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 27.928
print(y)
##             startzeit          airmo_kurzname parameter zeitfenster einheit  value
## 3 2017-01-01 01:00:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 60.874
## 4 2017-01-01 01:30:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 70.794
## 5 2017-01-01 02:00:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 55.856
## 6 2017-01-01 02:30:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 59.332
## 7 2017-01-01 03:00:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 58.624
print(xy)
##             startzeit          airmo_kurzname parameter zeitfenster einheit  value
## 1 2017-01-01 00:00:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 27.672
## 2 2017-01-01 00:30:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 26.875
## 3 2017-01-01 01:00:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 60.874
## 4 2017-01-01 01:30:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 70.794
## 5 2017-01-01 02:00:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 55.856
## 6 2017-01-01 02:30:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 59.332
## 7 2017-01-01 03:00:00 Zch_Stampfenbachstrasse       NOx       min30     ppb 58.624
```

#### rmo_to_openair

``` r
library(openair)
df <- rds_load_data("Zch_Stampfenbachstrasse", "min30", 2017, NULL, "rds")
td <- rmo_to_openair(df)
head(td)
##                  date                    site zeitfenster        co        no      no2    nox
## 1 2017-01-01 00:00:00 Zch_Stampfenbachstrasse       min30 0.3642325  9.362537 38.56268 27.672
## 2 2017-01-01 00:30:00 Zch_Stampfenbachstrasse       min30 0.3620788  9.481529 36.85615 26.875
## 3 2017-01-01 01:00:00 Zch_Stampfenbachstrasse       min30 0.3663280 12.429375 39.14822 30.437
## 4 2017-01-01 01:30:00 Zch_Stampfenbachstrasse       min30 0.3693082 18.150572 39.86169 35.397
## 5 2017-01-01 02:00:00 Zch_Stampfenbachstrasse       min30 0.3642325 10.406644 37.45144 27.928
## 6 2017-01-01 02:30:00 Zch_Stampfenbachstrasse       min30 0.3643955 11.167741 39.60812 29.666
##          o3 pm1.0f_roh      pm10 pm25    pn      so2     wd      ws
## 1 1.4207791         NA  76.37508   NA 16254 3.349949 296.15 1.31050
## 2 1.4741852         NA 135.38172   NA 15579 3.114319 288.27 1.41930
## 3 1.4191033         NA  94.85740   NA 12497 1.998468 301.20 1.20090
## 4 1.2726902         NA  77.34658   NA 12020 1.967742 291.53 1.01940
## 5 1.2167305         NA  78.60730   NA 10350 1.813478 286.61 1.12830
## 6 0.8141794         NA  77.15706   NA 10742 1.791059 271.17 0.61363

summaryPlot(td)

# optional add an id column and rename some parameters
site_ids <- list("Zch_Schimmelstrasse"="Wied", "Zch_Stampfenbachstrasse"="Staba")
df <- rds_load_data(names(site_ids), "min30", 2017, c("NOx", "O3", "PM2.5", "WD"), "rds")
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

