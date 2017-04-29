#' removes given dataset from the database
#' @description
#' removes given dataset from the database
#' @param country country name
#' @param dataSource data source name
#' @param password database password
#' @export
remove_dataset = function(country, dataSource, user, password) {
  stopifnot(
    is.vector(country), is.character(country), length(country) == 1, all(!is.na(country)),
    is.vector(dataSource), is.character(dataSource), length(dataSource) == 1, all(!is.na(dataSource)),
    is.vector(user), is.character(user), length(user) == 1, all(!is.na(user)),
    is.vector(password), is.character(password), length(password) == 1, all(!is.na(password))
  )

  conn = DBI::dbConnect(DBI::dbDriver('PostgreSQL'), host = 'zozlak.org', dbname = 'eurrep', user = 'eurrep', password = password)
  param = list(c = country, ds = dataSource)
  count = unlist(db_exec(
    conn,
    "SELECT count(*) FROM data_sources WHERE country = ?c AND data_source = ?ds",
    param
  ))
  if (count == 0) {
    stop('no such dataset')
  }
  db_exec(conn, "DELETE FROM data WHERE country = ?c AND data_source = ?ds", param)
  db_exec(conn, "DELETE FROM data_sources WHERE country = ?c AND data_source = ?ds", param)
  return(invisible(TRUE))
}