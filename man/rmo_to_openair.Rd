% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{rmo_to_openair}
\alias{rmo_to_openair}
\title{Converts rmo to openair format}
\usage{
rmo_to_openair(df, ids = NULL, parameter_names = NULL)
}
\arguments{
\item{df}{dataframe in rmo format}

\item{ids}{opt. named list of ids for sites. if provided an id column will be added.
name = parameter to rename, value = new name. Default NULL}

\item{parameter_names}{opt. list of parameters to rename.  name = parameter to rename,
value = new name. Default NULL}
}
\value{
dataframe in openair format
}
\description{
Beware of some Pitfalls: the openair format has no represantation of the unit. This column will
be dropped. This is a problem for the case that the data contains values with different units
for the same parameter. Another problem appears for data containing mulitplezeitfenster. This
will duplicate data for shared start times.
}
\details{
all parameter names will be converted to lower case. Following parameters will be automatically
renamed to match the openair conventions:
\itemize{
\item startzeit => date
\item airmo_kurzname => site
\item WVv => ws
\item PM2.5 => pm25
}
}
\examples{
\dontrun{
site_ids <- list("Zch_Schimmelstrasse"="Wiedikon", "Zch_Stampfenbachstrasse"="Staba")
pnames <- list("PM10h"="PM10")
theData <- rmo_to_openair(df, site_ids, pnames)  # data with id column an PM10h renamed to PM10
theData <- rmo_to_openair(df)                    # data without id column and PM10h as PM10h
}
}
\seealso{
\url{https://davidcarslaw.github.io/openair/}
}
