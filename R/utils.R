#' Merges two dataframe in rmo long format into one
#'
#' Missing values in y will be replaced with the values from x.
#'
#' @param x dataframe in rmo long format
#' @param y dataframe in rmo long format
#'
#' @return merged dataframe
#' @export
merge_rmo_longformat <- function(x, y) {
  # for some reason, factors can be coerced to character vectors
  suppressWarnings(
    dfn <- full_join(y, x, by = c("startzeit", "airmo_kurzname", "parameter", "zeitfenster", "einheit"),
                     suffix = c("", ".old"))
  )
  dfn[["value"]][is.na(dfn["value"])] <- dfn[["value.old"]][is.na(dfn["value"])]
  dfn <- select(dfn, -value.old)
  dfn <- arrange(dfn, startzeit)
  mutate_if(dfn, is.character, as.factor)
}


#' Converts rmo to openair format
#'
#' Beware of some Pitfalls: the openair format has no represantation of the unit. This column will
#' be dropped. This is a problem for the case that the data contains values with different units
#' for the same parameter. Another problem appears for data containing mulitplezeitfenster. This
#' will duplicate data for shared start times.
#'
#' all parameter names will be converted to lower case. Following parameters will be automatically
#' renamed to match the openair conventions:
#' * startzeit => date
#' * airmo_kurzname => site
#' * WVv => ws
#' * PM2.5 => pm25
#'
#' @param df dataframe in rmo format
#' @param ids opt. named list of ids for sites. if provided an id column will be added.
#'   name = parameter to rename, value = new name. Default NULL
#' @param parameter_names opt. list of parameters to rename.  name = parameter to rename,
#'   value = new name. Default NULL
#'
#' @return dataframe in openair format
#' @export
#'
#' @seealso \url{https://davidcarslaw.github.io/openair/}
#'
#' @examples
#' \dontrun{
#' site_ids <- list("Zch_Schimmelstrasse"="Wiedikon", "Zch_Stampfenbachstrasse"="Staba")
#' pnames <- list("PM10h"="PM10")
#' theData <- rmo_to_openair(df, site_ids, pnames)  # data with id column an PM10h renamed to PM10
#' theData <- rmo_to_openair(df)                    # data without id column and PM10h as PM10h
#' }
rmo_to_openair <- function(df, ids=NULL, parameter_names=NULL) {
  tdd <- select(df, -einheit) # problem wenn ein parameter mit 2 einheiten vorhanden ist (ev. NO2 mit ug/m3 und ppb?)
  tdd <- spread(tdd, parameter, value)

  default_names <- list("PM2.5" = "pm25", "WVv" = "ws", "startzeit" = "date", "airmo_kurzname" = "site")
  if (is.list(parameter_names)) {
    default_names <- list_modify(default_names, !!! parameter_names)
  }

  # renaming der der parameter
  existing <- match(names(default_names), names(tdd))
  names(tdd)[na.omit(existing)] <- default_names[which(!is.na(existing))]
  names(tdd) <- tolower(names(tdd))

  # add site id
  if (is.list(ids)) {
    myargs <- prepend(ids, list(.x = tdd[["site"]]))
    tdd[["id"]] <- invoke(recode_factor, myargs)
  }
  return(tdd)
}
