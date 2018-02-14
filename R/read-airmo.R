#' Reads an AIRMO Export in DAT Format
#'
#' Reads the data from a AIRMO DAT file and returns it as a dataframe in rmo long format
#'
#' @param fn DAT file name, can be relative to current directory or absolut
#'
#' @return dataframe in rmo long format
#' @export
read_airmo_dat <- function(fn) {
  data <- read.table(fn, header = FALSE, sep = ";", encoding = "cp1252", na.strings = "", stringsAsFactors = FALSE)
  header <- data[c(1, 2, 4, 5), -1]
  data <- tail(data, -6)
  airmo_wide_to_rmo_long(header, data)
}


#' Reads an AIRMO Export in CSV Format
#'
#' Reads the data from a AIRMO CSV file and returns it as a dataframe in rmo long format
#'
#' @param fn CSV file name, can be relative to current directory or absolut
#'
#' @return dataframe in rmo long format
#' @export
read_airmo_csv <- function(fn) {
  data <- read.table(fn, header = FALSE, sep = ";", encoding = "cp1252", na.strings = "", stringsAsFactors = FALSE)
  header <- data[c(1, 5, 9, 8), -1]
  data <- tail(data, -10)
  airmo_wide_to_rmo_long(header, data)
}


#' Converts the wide format from the files to rmo long
#'
#' @param header dataframe containing airmo_kurzname, parameter, zeitfenster and einheit
#' @param data dataframe only containing the data from the file
#'
#' @return dataframe in rmo long format
#' @noRd
airmo_wide_to_rmo_long <- function(header, data) {
  colnames(data)[1] <- "startzeit"

  header_names <- lapply(header, paste, collapse = "&")
  colnames(data)[-1] <- header_names

  data[["startzeit"]] <- parse_date_time(data[["startzeit"]], c("dmYHMS", "dmYHM"), tz = "Etc/GMT-1")
  data_long <- gather(data, "key", "value", -"startzeit", na.rm = TRUE)
  data_long[["value"]] <- as.numeric(data_long[["value"]])
  data_long <- separate(data_long, "key", c("airmo_kurzname", "parameter", "zeitfenster", "einheit"), sep = "&")
  mutate_if(data_long, is.character, as.factor)
}
