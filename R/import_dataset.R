#' imports given dataset into the database
#' @description
#' Imports dataset prepared by the \code{\link{check_dataset}}
#' @param data data.frame returned by the \code{\link{check_dataset}}
#' @param year dataset year
#' @param user database user name
#' @param password database password
#' @export
import_dataset = function(data, year, user, password) {
  stopifnot(
    is.data.frame(data),
    is.vector(year), is.numeric(year), length(year) == 1, all(!is.na(year)),
    is.vector(user), is.character(user), length(user) == 1, all(!is.na(user)),
    is.vector(password), is.character(password), length(password) == 1, all(!is.na(password))
  )
  if (!methods::is(data, 'eurrepDataset')) {
    stop('the data argument must be a result of the check_dataset() function')
  }

  conn = DBI::dbConnect(DBI::dbDriver('PostgreSQL'), host = 'zozlak.org', dbname = 'eurrep', user = user, password = password)
  cntr = data$country[1]
  dtsrc = data$data_source[1]
  count = unlist(db_exec(
      conn,
      "SELECT count(*) FROM data_sources WHERE country = ?c AND data_source = ?ds",
      list(c = cntr, ds = dtsrc)
  ))
  if (count == 0) {
    db_exec(
      conn,
      "INSERT INTO data_sources (country, data_source, year) VALUES (?c, ?ds, ?y)",
      list(c = cntr, ds = dtsrc, y = year)
    )
  }

  db_exec(conn, "DELETE FROM data WHERE country = ?c AND data_source = ?ds", list(c = cntr, ds = dtsrc))

  DBI::dbWriteTable(conn, 'data', as.data.frame(data), append = TRUE, row.names = FALSE)

  message("Don't forget to upload the documentation under the name '", paste0(cntr, '_', dtsrc, ".pdf'"))
  return(invisible(TRUE))
}