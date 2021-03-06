#' @title 
#' **Get composite team talent rankings for all teams in a given year**\cr
#' 
#' @description
#' Extracts team talent composite as sourced from 247 rankings
#' @param year (\emph{Integer} optional): Year 4 digit format (\emph{YYYY})
#' @param verbose Logical parameter (TRUE/FALSE, default: FALSE) to return warnings and messages from function
#'
#' @return [cfbd_team_talent()] - A data frame with 3 variables:
#' \describe{
#'   \item{`year`: integer.}{Season for the talent rating.}
#'   \item{`school`: character.}{Team name.}
#'   \item{`talent`: double.}{Overall roster talent points (as determined by 247Sports).}
#' }
#' @source \url{https://api.collegefootballdata.com/talent}
#' @keywords Team talent
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @importFrom utils URLencode
#' @importFrom assertthat assert_that
#' @importFrom glue glue
#' @export
#' @examples
#' \donttest{
#' cfbd_team_talent()
#'
#' cfbd_team_talent(year = 2018)
#' }
#'
cfbd_team_talent <- function(year = NULL,
                             verbose = FALSE) {
  if (!is.null(year)) {
    ## check if year is numeric
    assert_that(is.numeric(year) & nchar(year) == 4,
                msg = "Enter valid year as a number (YYYY)"
    )
  }
  
  base_url <- "https://api.collegefootballdata.com/talent?"
  
  full_url <- paste0(
    base_url,
    "year=", year
  )
  
  # Check for CFBD API key
  if (!has_cfbd_key()) stop("CollegeFootballData.com now requires an API key.", "\n       See ?register_cfbd for details.", call. = FALSE)
  
  # Create the GET request and set response as res
  res <- httr::RETRY(
    "GET", full_url,
    httr::add_headers(Authorization = paste("Bearer", cfbd_key()))
  )
  
  # Check the result
  check_status(res)
  
  df <- data.frame()
  tryCatch(
    expr = {
      # Get the content and return it as data.frame
      df <- res %>%
        httr::content(as = "text", encoding = "UTF-8") %>%
        jsonlite::fromJSON() %>%
        as.data.frame() %>%
        mutate(talent = as.numeric(.data$talent))
      
      if(verbose){ 
        message(glue::glue("{Sys.time()}: Scraping team talent..."))
      }
    },
    error = function(e) {
      message(glue::glue("{Sys.time()}:Invalid arguments or no team talent data available!"))
    },
    warning = function(w) {
    },
    finally = {
    }
  )
  return(df)
}
