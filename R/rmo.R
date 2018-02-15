#' rmo: rmo - data store for air quality measurements
#'
#' reads exports from AIRMO in CSV or DAT format and saves the data as rds file. Provides utility
#' function to convert the data into a compatible format for openair.
#'
#'
#' @docType package
#' @name rmo
#'
#' @importFrom lubridate year parse_date_time is.period
#' @importFrom tidyr expand gather spread separate
#' @importFrom dplyr arrange bind_rows filter full_join mutate_if select transmute recode_factor
#' @importFrom purrr imap invoke map prepend list_modify
#' @importFrom stats na.omit
#' @importFrom utils read.table tail
NULL
