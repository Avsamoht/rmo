% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rds-store.R
\name{rds_save_data}
\alias{rds_save_data}
\title{Saves data in rmo long format to rds store}
\usage{
rds_save_data(df, base_path = "rds")
}
\arguments{
\item{df}{dataframe in rmo long format}

\item{base_path}{relative to current directory or absolut path to rds store}
}
\description{
At the moment the design for the store is to split the data in year, zeitfenster and site chunks
and save every chunk as rds file. This functions automatically splits the data in the chunks and
merges the new data into existings rds files.
}
