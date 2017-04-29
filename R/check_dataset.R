#' checks and sanitizes a dataset
#' @description
#' Checks if a given data contains correct values.
#'
#' Deals with most common discrepancies and returns a sanitized dataset
#' which is ready to import.
#' @param data data.frame containing data to be checked
#' @return data.frame with checked and sanitized data
#' @import dplyr
#' @export
check_dataset = function(data) {
  stopifnot(
    is.data.frame(data)
  )

  # COLUMNS
  names(data) = tolower(names(data))
  reqCols = c('country', 'data_source', 'cohort_from', 'cohort_to', 'edu_eurrep', 'isced_from', 'isced_to', 'sex', 'origin', 'stat', 'value')
  missCols = setdiff(reqCols, names(data))
  if (length(missCols) > 0) {
    stop('missing columns: ', paste0(missCols, collapse = ', '))
  }
  data = data[, reqCols]

  # SANITIZE COLUMNS
  for (col in names(data)) {
    data[, col] = as.character(data[, col])
    if (!col %in% c('country', 'data_source', 'stat')) {
      data[, col] = toupper(data[, col])
    }
  }
  data$value = as.numeric(data$value)

  # MISSINGS
  if (any(is.na(data))) {
    stop('data can not contain missing values')
  }

  # COHORTS
  for (col in c('cohort_from', 'cohort_to')) {
    data[, col] = sub('UNKNOWN', '-1', data[, col])
    data[, col] = as.integer(data[, col])
  }
  if (any(data$cohort_to < data$cohort_from)) {
    stop('cohort_to can not be lower the cohort_from')
  }

  # EDU EURREP
  data$edu_eurrep = sub('LEVEL ', '', data$edu_eurrep)
  dictEurrep = c(1:4, 'UNKNOWN')
  check_mismatch('edu_eurrep', data$edu_eurrep, dictEurrep)

  # EDU
  dictEdu = c('ISCED0', 'ISCED1', 'ISCED2C', 'ISCED2B', 'ISCED2A', 'ISCED3C', 'ISCED3B', 'ISCED3A', 'ISCED4B', 'ISCED4A', 'ISCED5B', 'ISCED5A', 'ISCED6', 'UNKNOWN')
  for (col in c('isced_from', 'isced_to')) {
    check_mismatch(col, data[, col], dictEdu)
    data[, col] = sub('UNKNOWN', 'Unknown', data[, col])
    f = data[, col] == 'ISCED3B'
    data[f, col] = ifelse(data$edu_eurrep[f] == '2', 'ISCED3B-', 'ISCED3B+')
  }

  # SEX
  data$sex = sub('FALSE', 'F', data$sex) # read.csv() promotes F to logical false
  dictSex = c('F', 'M', 'TOTAL')
  check_mismatch('sex', data$sex, dictSex)
  if (length(unique(data$sex)) > 2) {
    stop('sex can have no more then two disctinct values')
  }
  data$sex = sub('TOTAL', 'Total', data$sex)

  # ORIGIN
  dictOrigin = c('NATIVE', 'FOREIGN', 'TOTAL', 'UNKNOWN')
  check_mismatch('origin', data$origin, dictOrigin)
  if (any(data$origin == 'TOTAL') & length(unique(data$origin)) > 2) {
    stop('origin can have no more the two disctinct values if TOTAL is one of them')
  }
  data$origin = paste0(substring(data$origin, 1, 1), tolower(substring(data$origin, 2)))

  # STAT
  data$stat = tolower(data$stat)
  data$stat = sub('^child_', 'parity_', data$stat)
  data$stat = sub('([0-9])p$', '\\1', data$stat)
  dictStat = c('women_total', 'children_total', paste0('parity_', 0:20), 'parity_unknown')
  check_mismatch('stat', data$stat, dictStat)

  # FILL IN GAPS IN PARITY
  # (at least one record for each parity is required for the database to work properly)
  tmp = unique(grep('^parity_[0-9]+$', data$stat, value = T))
  tmp = as.integer(sub('parity_', '', tmp))
  wzor = data[data$stat %in% paste0('parity_', max(tmp)), ][1, ]
  wzor$value = 0
  for (i in setdiff(min(tmp):max(tmp), tmp)) {
    wzor$stat = paste0('parity_', i)
    data[nrow(data) + 1, ] = wzor
  }

  # UNIQUE
  keyCols = c('country', 'data_source', 'cohort_from', 'cohort_to', 'edu_eurrep', 'isced_from', 'isced_to', 'sex', 'origin', 'stat')
  data = data %>%
    group_by_(.dots = keyCols) %>%
    summarize_(value = ~sum(value)) %>%
    ungroup()

  # MINOR STUFF
  data = select_(data, '-edu_eurrep')
  class(data) = c('eurrepDataset', class(data))
  return(data)
}
