#' checks if values fit in provided dict
#' @description
#' Small helper for nicely reporting values outside of allowed set.
#' @param col data column name
#' @param values vector of values
#' @param dict vector of allowed values
check_mismatch = function(col, values, dict) {
  if (!all(values %in% dict)) {
    diff = setdiff(unique(values), dict)
    stop(col, ' values ', paste0(diff, collapse = ', '), ' do not match allowed ones - ', paste0(dict, collapse = ', '))
  }
}