#' Saves data in rmo long format to rds store
#'
#'  At the moment the design for the store is to split the data in year, zeitfenster and site chunks
#'  and save every chunk as rds file. This functions automatically splits the data in the chunks and
#'  merges the new data into existings rds files.
#'
#' @param df dataframe in rmo long format
#' @param base_path relative to current directory or absolut path to rds store
#'
#' @export
rds_save_data <- function(df, base_path="rds") {
  for (zf in levels(df[["zeitfenster"]])) {
    for (site in levels(df[["airmo_kurzname"]])) {
      df_filtered <- filter(df, zeitfenster == zf & airmo_kurzname == site)
      df_split <- split(df_filtered, as.factor(year(df_filtered[["startzeit"]])))
      imap(df_split, rds_merge_into_store, zf, site, base_path)
    }
  }
}


#' Load data from the rds store
#'
#' Loads the specified data from the rds store and returns it as dataframe in
#' rmo long format
#'
#' @param sites character vector with the airmo_kurzname of all sites to load
#' @param zfs character vector with all zeitfenster to load
#' @param years integer vector with all years to load
#' @param parameters opt. character vector to only return the parameters in the vector.
#'   Use NULL to get all parameters saved in the rds file. Default: NULL
#' @param base_path relative to current directory or absolut path to rds store
#'
#' @return dataframe in rmo long format
#' @export
#'
#' @examples
#' \dontrun{
#' load_data("Zch_Schimmelstrasse", "min30", 2017, c("PM10", "NOx", "NO2"), "tmp")
#' load_data(c("Zch_Schimmelstrasse", "Zch_Stampfenbachstrasse", "Zch_Heubeeribüel"),
#'           "d1", 2017, "O3_max_h1", "tmp")
#' }
rds_load_data <- function(sites, zfs, years, parameters=NULL, base_path="rds") {
  files <- expand(data.frame(), sites, zfs, years)
  files <- transmute(files, rds_get_store_fn(years, zfs, sites, base_path))
  # need to transpose files to use it for purrr::map
  # supress Warnings for file not found?
  df <- map(t(files), rds_read_store, parameters)
  df <- df[!is.na(df)]
  # suppress warnings vor factor -> character conversion
  suppressWarnings(
    df <- invoke(bind_rows, df)
  )
  df <- arrange(df, startzeit)
  mutate_if(df, is.character, as.factor)
}


#' Generates the name of the rds file
#'
#' The file name is based on the year, zeitfenster and site name. At the moment the design for the
#' store is to split the data in year, zeitfenster and site chunks and save every chunk as rds file.
#'
#' @keywords internal
#'
#' @param year year of data to save
#' @param zf zeitfenster of data to save
#' @param site of data to save
#' @param base_path relative to current directory or absolut path to rds store
#'
#' @return file name as string
rds_get_store_fn <- function(year, zf, site, base_path) {
  file.path(base_path, paste(year, "-", zf, "-", site, ".rds", sep = ""))
}


#' Merges data into to the rds store
#'
#' @keywords internal
#'
#' @param df dataframe in rmo long format
#' @param year of data to save
#' @param zf zeitfenster of data to save
#' @param site of data to save
#' @param base_path relative to current directory or absolut path to rds store
rds_merge_into_store <- function(df, year, zf, site, base_path) {
  fn <- rds_get_store_fn(year, zf, site, base_path)
  dir.create(dirname(fn), showWarnings = FALSE)

  # if there already is a rds file, merge the two
  if (file.exists(fn)) {
    # there is probably a more elegant way to do this, but hey it works
    dfo <- readRDS(fn)
    dfn <- merge_rmo_longformat(dfo, df)
  } else {
    dfn <- arrange(df, startzeit)
  }
  dfn <- droplevels(dfn)
  saveRDS(dfn, fn)
}


#' Reads data from a rds file
#'
#' @keywords internal
#'
#' @param fn file name of the rds file
#' @param parameters opt. character vector to only return the parameters in the vector.
#'   Use NULL to get all parameters saved in the rds file. Default: NULL
#'
#' @return dataframe in rmo long format
rds_read_store <- function(fn, parameters=NULL) {
  tryCatch(
    {
      df <- readRDS(fn)
      if (!is.null(parameters)) {
        df <- filter(df, parameter %in% parameters)
      }
      droplevels(df)
    },
    error = function(cond) {
      message(paste("error while reading file ", fn, ": ", cond))
      return(NA)
    },
    warning = function(cond) {
      message(paste("warning while reading file  ", fn, ": ", cond))
      return(NA)
    }
  )
}
