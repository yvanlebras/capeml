#' @title write_attributes
#'
#' @description write_attributes creates a template as a csv file for supplying
#'   attribute metadata for a tabular data object that resides in the R
#'   environment.
#'
#' @details The csv template generated by write_attributes includes the field
#'   names of the data entity. The number type, column class (e.g., factor,
#'   numeric), minimum and maximum values (if numeric), and missing value code
#'   and explanation (if provided) for each field. The template supports input
#'   of format string, unit, definition, and attribute definition. The csv file
#'   is written with the name of the data object in R + "_attrs". The
#'   create_dataTable function will search for this file will creating a EML
#'   dataTable entity.
#'
#' @param dfname The unquoted name of the R data frame or Tibble.
#' @param overwrite Logical indicating if an existing attributes file in the
#'   target directory should be overwritten.
#'
#' @import dplyr
#' @importFrom purrr map_chr
#'
#' @return The name of the file generated is returned, and a template for
#'   providing attribute metadata as a csv file with the file name of the R data
#'   object + "_attrs.csv" is created in the working directory.
#'
#' @examples
#'
#'  # write_attributes(R data object)
#'
#'  # overwrite existing attributes file
#'  # write_attributes(R data object,
#'  #                  overwrite = TRUE)
#'
#' @export

write_attributes <- function(dfname, overwrite = FALSE) {

  # establish object name for checking if exists and, ultimately, writing to file
  objectName <- paste0(deparse(substitute(dfname)), "_attrs")
  fileName <- paste0(objectName, ".csv")

  # check if attributes already exist for given data entity
  if(file.exists(fileName) && overwrite == FALSE) {
    stop(paste0("file ", fileName, " already exists, use write_attributes(overwrite = TRUE) to overwrite"))
  }

  # when we write attributes from a spatial file, column classes can be vectors.
  # as such, we need to pull the first entity only
  check_class <- function(x) { class(x)[[1]] }

  # set up the data frame for metadata
  rows <- ncol(dfname)
  df_attrs <- data.frame(attributeName = names(dfname),
                         formatString = character(rows),
                         unit = character(rows),
                         numberType = character(rows),
                         definition = character(rows),
                         attributeDefinition = character(rows),
                         columnClasses = map_chr(dfname, check_class),
                         minimum = map_chr(dfname, function(x) if (is.numeric(x)) { x = min(x, na.rm = TRUE) } else { x = "" }),
                         maximum = map_chr(dfname, function(x) if (is.numeric(x)) { x = max(x, na.rm = TRUE) } else { x = "" }),
                         stringsAsFactors = FALSE)

  # need to change any integer type values to type numeric
  df_attrs$columnClasses <- lapply(df_attrs$columnClasses, function(x) if(any(grepl("integer", x))) { x <- 'numeric' } else { x <- x })

  # need to change any POSIX type values to the character Date
  df_attrs$columnClasses <- lapply(df_attrs$columnClasses, function(x) if(any(grepl("POSIX", x))) { x <- 'Date' } else { x <- x })

  # if there were POSIX values, the column classes will be a list so we need to change the list to a type character
  df_attrs$columnClasses <- as.character(df_attrs$columnClasses)

  # calculate numberType for numeric values

  # the flow here omits NAs and NaNs whereas assemblyline omits values
  # identified by the missingValueCode; the assemblyline approach is more robust
  # but may not be as relevant here where we work exclusively in R; still
  # careful of this and this function certainly will not work if data are not
  # imported to R

  if(any(sapply(dfname, function(x) { is.numeric(x) }))) {

    is_numeric <- which(df_attrs$columnClasses == "numeric")

    for (j in 1:length(is_numeric)){

      raw <- na.omit(dfname[ ,is_numeric[j]])
      raw <- as.matrix(raw) # convert to a matrix in attempt to rectify error when
      # there is only one numeric column "Error in is.finite(raw) : default method
      # not implemented for type 'list'"
      raw <- raw[is.finite(raw)] # remove infs (just in case)

      # code to omit missing values from EMLassemblyline
      # if (df_attrs$missingValueCode[is_numeric[j]] != ""){
      #   useI <- raw == df_attrs$missingValueCode[is_numeric[j]]
      #   raw <- as.numeric(raw[!useI])
      # }

      rounded <- floor(raw)
      if (length(raw) - sum(raw == rounded, na.rm = T) > 0){
        df_attrs$numberType[is_numeric[j]] <- "real" # all
      } else if (min(raw, na.rm = T) > 0){
        df_attrs$numberType[is_numeric[j]] <- "natural" # 1, 2, 3, ... (sans 0)
      } else if (min(raw, na.rm = T) < 0){
        df_attrs$numberType[is_numeric[j]] <- "integer" # whole + negative values
      } else {
        df_attrs$numberType[is_numeric[j]] <- "whole" # natural + 0
      }

    } # close number type loop

  } # close the if-statement

  # write attribute df to file
  write.csv(df_attrs, file = fileName, row.names = FALSE)

  return(objectName)

}
