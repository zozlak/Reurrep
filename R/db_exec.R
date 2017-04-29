#' simple helper for running SQL queries
#' @description
#' simple helper for running SQL queries
#' @param conn DBI connection
#' @param query SQL query
#' @param param list of values to substitute
#' @return data.frame with query results
db_exec = function(conn, query, param) {
  return(DBI::dbGetQuery(conn, DBI::sqlInterpolate(conn, query, .dots = param)))
}