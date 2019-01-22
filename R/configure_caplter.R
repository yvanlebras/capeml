#' @title configure_caplter
#'
#' @description configure_caplter establishes several data set elements that are
#'   likely to be consistent across all CAP LTER data sets, including the GIOS
#'   address, contact information, landuage, intellectual rights, access, and
#'   metadata distribution.
#'
#' @details configure_caplter establishes several data set elements that are
#'   likely to be consistent across all CAP LTER data sets, including the GIOS
#'   address, contact information, landuage, intellectual rights, access, and
#'   metadata distribution. Most of these eml entities are established in the R
#'   environment when the capeml package is loaded and available for references
#'   in the remlTemplate. Distribution is the exception as this is a function
#'   that requires the data set package identifier as an input.
#'
#' @import EML
#'
#' @return establishes in the R ennvironment upon package load, eml entities
#'   referenced in (or outside) the remlTemplate.
#'
#' @examples
#' \dontrun{
#'
#' # most entites loaded when the package is loaded, except distrubution.
#'
#' create_distribution(packageIdent)
#'
#' }
#'

# gios address, publisher, contact ----
#' @export giosAddress
giosAddress <- EML::eml$address(
  deliveryPoint = 'PO Box 875402',
  city = 'Tempe',
  administrativeArea = 'AZ',
  postalCode = '85287',
  country = 'USA')

#' @export giosPublisher
giosPublisher <- EML::eml$publisher(
  organizationName = 'Arizona State University, Julie Ann Wrigley Global Institute of Sustainability',
  address = giosAddress)

#' @export giosContact
giosContact <- EML::eml$contact(
  organizationName = 'Julie Ann Wrigley Global Institute of Sustainability, Arizona State University',
  positionName = 'Data Manager',
  electronicMailAddress = "caplter.data@asu.edu",
  address = giosAddress)

# language ----
#' @export giosLanguage
giosLanguage <- 'english'


# intellectual rights ----
#' @export capRights
capRights <- 'Copyright Board of Regents, Arizona State University. This information is released to the public and may be used for academic, educational, or commercial purposes subject to the following restrictions. While the CAP LTER will make every effort possible to control and document the quality of the data it publishes, the data are made available \'as is\'. The CAP LTER cannot assume responsibility for damages resulting from mis-use or mis-interpretation of datasets, or from errors or omissions that may exist in the data. It is considered a matter of professional ethics to acknowledge the work of other scientists that has resulted in data used in subsequent research. The CAP LTER expects that any use of data from this server will be accompanied with the appropriate citations and acknowledgments. The CAP LTER encourages users to contact the original investigator responsible for the data that they are accessing. Where appropriate, researchers whose projects are integrally dependent on CAP LTER data are encouraged to consider collaboration and/or co-authorship with original investigators. The CAP LTER requests that users submit to the Julie Ann Wrigley Global Institute of Sustainability at Arizona State University reference to any publication(s) resulting from the use of data obtained from this site.'


# lter_access ----
allow_cap <- EML::eml$allow(
  principal = "uid=CAP,o=LTER,dc=ecoinformatics,dc=org",
  permission = "all")

allow_public <- EML::eml$allow(
  principal = "public",
  permission = "read")


#' @export lterAccess
lterAccess <- EML::eml$access(
  authSystem = "knb",
  order = "allowFirst",
  scope = "document",
  allow = list(allow_cap,
               allow_public)
)


# metadata distribution (i.e., path to xml file) ----
#' @export create_distribution
create_distribution <- function(packageIdent) {

  xml_url <- EML::eml$online(
    onlineDescription = "CAPLTER Metadata URL",
    url = paste0("https://sustainability.asu.edu/caplter/data/data-catalog/view/", packageIdent, "/xml/"))

  metadata_dist <- EML::eml$distribution(
    online = xml_url)

}