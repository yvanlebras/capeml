% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_otherEntity.R
\name{create_otherEntity}
\alias{create_otherEntity}
\title{Create EML entity of type otherEntity}
\usage{
create_otherEntity(
  targetFile,
  description,
  baseURL = "https://data.gios.asu.edu/datasets/cap/",
  overwrite = FALSE,
  projectNaming = TRUE
)
}
\arguments{
\item{targetFile}{The quoted name and path of the data file or directory.}

\item{description}{A description of the data entity.}

\item{baseURL}{The base path of the web-accessible location of the data file;
the name of the resulting file will be passed to the base path to generate
a web-resolvable file path.}

\item{overwrite}{If creating otherEntity by zipping a directory, this is a
logical indicating whether to overwrite an already existing zip file that
has the same name and location as the temporary zip object to be created.}

\item{projectNaming}{Logical indicating if the file or directory should be
renamed per the style used by the CAP LTER (default) with the project id +
base file name + md5sum + file extension. The passed file or directory name
will be used if this parameter is set to FALSE.}
}
\value{
EML entity of type otherEntity is returned. Additionally, the data
  file is renamed with the project id + base file name + md5sum + file
  extension.
}
\description{
create_otherEntity generates a EML entity of type otherEntity.
}
\details{
A otherEntity entity is created from a single file (e.g.,
  desert_fertilization_sampling_sites.kml) or a directory. The resulting
  entity is renamed with the project id + base file name + md5sum + file
  extension. File extension is always .zip if the otherEntity is being
  created by zipping a directory.
}
\note{
create_otherEntity will look for a project id in the working
  environment; this parameter is not passed to the function and it must
  exist.

The target data file or directory can be located anywhere on a local
  computer but the renamed file with project id and hash will be written to
  the current working directory.
}
\examples{

 # using default parameters
 # desert_fertilization_sites <- create_otherEntity(
 #   targetFile = "~/Desktop/desert_fertilization_sampling_sites.kml",
 #   description = "approximate location of desert fertiliztion long-term study sites")

 # set overwrite = TRUE - has the effect of overwriting an existing zipped
 # directory of the same name if the otherEntity is being generated by zipping
 # a directory (i.e. as opposed to from a single file)
 # pass_codebook_2011 <- create_otherEntity(
 #   targetFile = "PASS-2011-Codebook-Feb2016rev.pdf",
 #   description = "PASS 2011 survey codebook",
 #   overwrite = TRUE)

 # do not use project naming
 # pass_codebook_2011 <- create_otherEntity(
 #   targetFile = "~/Desktop/max_temperature",
 #   description = "rasters of max temperature years 2000-2016",
 #   projectNaming = FALSE)

 # The EML::eml$otherEntity() can then be
 # added to a EML::eml$dataset() entity:

 # dataset <- EML::eml$dataset(otherEntity = listOfOtherEntities)

}
