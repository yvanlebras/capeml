
<!-- README.md is generated from README.Rmd. Please edit the latter. -->

## capeml: tools to aid the generation of EML metadata

### overview

This package contains tools to aid the generation of EML metadata with
intent to publish a data set (data + metadata) in the Environmental Data
Initiative (EDI) data repository. Functions and a workflow are included
that allow for the creation of metadata at the dataset level, and
individual data entities (e.g., spatial vectors, raster, other entities,
data tables).

Helper functions for the creation of dataset metadata, and
`dataTable()`, `otherEntity()`, `spatialRaster()`, and `spatialVector()`
entities using the [ropensci::eml
package](https://ropensci.github.io/EML/) are currently supported.

Note that the creation of people-related entities in EML are specific to
functions that rely on Global Institute of Sustainability
infrastructure; please see the
[gioseml](https://github.com/CAPLTER/gioseml) package for these tools.

A template workflow to generating a complete EML record is included with
this package:
[knb-lter-cap.xxx.Rmd](https://github.com/CAPLTER/capeml/blob/master/knb-lter-cap.xxx.Rmd).

#### tools to generate metadata

**building dataTable metadata**

  - `write_attributes()` creates a template as a csv file for supplying
    attribute metadata for a tabular data object that resides in the R
    environment
  - `write_factors()` creates a template as a csv file for supplying
    code definition metadata for factors in a tabular data object that
    resides in the R environment
  - `write_raster_factors()` creates a template as a csv file for
    supplying code definition metadata for spatial rasters if raster
    values are categorical

**building dataset metadata**

  - `write_keywords()` creates a template as a csv file for supplying
    dataset keywords

#### tools to create EML entities

**constructing dataset elements**

  - `create_dataTable()` creates a EML entity of type dataTable
  - `create_otherEntity()` creates a EML entity of type otherEntity
  - `create_spatialRaster()` creates a EML entity of type spatialRaster
    - see
    [vignette](https://caplter.github.io/capeml/articles/create_spatialRaster.html)
    for more detail
  - `create_spatialVector()` creates a EML entity of type spatialRaster

### installation

Install the current version from GitHub (after installing the
[devtools](https://cran.r-project.org/web/packages/devtools/index.html)
package:

``` r
devtools::install_github("CAPLTER/capeml")
```

### project naming

Most EML-generating functions in the capeml package will create both
physical objects and EML references to those objects with the format:
`project-id`\_`object-name`\_`object-hash`.`file-extension` (e.g.,
664\_site\_map\_5fb7b8d53d48010eab1a2e73db7f1941.png). The target object
(e.g., site\_map.png from the previous example) is renamed with the
additional metadata and this object name is referenced in the EML
metadata. The only exception to this approach are spatialVectors where
the hash of the file/object is not included in the new object name. Note
that the project-id is not passed to any of the functions, and must
exist in the working R environment (as `projectid`).

Project-naming functionality can be turned off by setting the
`projectNaming` option in `create_dataTable()`,
`create_spatialRaster()`, `create_spatialVector()`, and
`create_otherEntity()` to FALSE. When set to FALSE, the object name is
not changed, and the file name of the object is included in the EML.

### coverages

*Geographic* and *temporal* coverages are relatively straightfoward and
documented in the overall workflow, but creating a *taxonomic* coverage
is more involved.

A new approach for taxonomy is to use EDI’s taxonomyCleanr to build the
taxonomicCoverage. Note that at the time of this writing (2019-05-03),
taxonomyCleanr had not been ported to rOpenSci EML v2. As such, this
workflow employs a forked, feature branch of
[taxonomyCleanr](https://github.com/CAPLTER/taxonomyCleanr/tree/taxonomy-rEML2)
until EDI adapts taxonmyCleanr to ropensci EML v2.

*Note* that the `taxa_map.csv` built with the `create_taxa_map()`
function and resolving taxonomic IDs (i.e., `resolve_comm_taxa()`) only
needs to be run once per version/session – the taxonomicCoverage can be
built as many times as needed with `resolve_comm_taxa()` or
`resolve_sci_taxa` once the `taxa_map.csv` has been generated and the
taxonomic IDs resolved.

A sample workflow:

``` r
# load and call the feature branch of taxonomyCleanr
devtools::load_all('path-to-repo/taxonomyCleanr/') 
library(taxonomyCleanr)

# taxonomyCleanr requires a path to build the taxa_map
my_path <- getwd() 

# taxonomic data must be in a data frame (load if not already in the environment)
myTaxa <- read_csv('file with taxa') %>% 
  as.data.frame()

# create or update map. A taxa_map.csv is the heart of taxonomyCleanr. This
# function will build the taxa_map.csv and put it in the path identified with
# my_path.
create_taxa_map(path = my_path,
                x = myTaxa,
                col = "myTaxa column with taxonomic names") 

# resolve taxa by attempting to match the taxon names. In this case, data.source
# 3 is ITIS (which, as of 2019-05-03, is the only authority taxonomyCleanr will
# allow for common names).

# resolve from common name:
resolve_comm_taxa(path = my_path, data.sources = 3) # in this case, 3 is ITIS

-- OR --

# resolve from scientific name:
resolve_sci_taxa(path = my_path, data.sources = 3) # in this case, 3 is ITIS

# build the EML taxonomomic coverage
taxaCoverage <- make_taxonomicCoverage(path = my_path)

# add taxonomic to other coverages
coverage$taxonomicCoverage <- taxaCoverage
```

### overview: create a dataTable

Given a rectangular data matrix of type dataframe or Tibble in the R
envionment:

`write_attributes(data_entity)` will generate a template as a csv file
in the working directory based on properties of the data entity such
that metadata properties (e.g., attributeDefinition, units) can be added
via a editor or spreadsheet application.

`write_factors(data_entity)` will generate a template as a csv file in
the working directory based on columns of the data entity that are
factors such that details of factor levels can be added via a editor or
spreadsheet application.

`create_dataTable(data_entity)` performs many services:

  - the data entity is written to file as a csv in the working directory
    with the file name:
    *projectid\_data-entity-name\_md5-hash-of-file.csv*
  - metadata provided in the attributes and factors (if relevant)
    templates are ingested
  - a EML object of type dataTable is returned
  - note that the data entity name should be used consistently within
    the chunk, and the resulting dataTable entity should have the name:
    *data\_entity\_DT*

### overview: create a otherEntity

A EML object of type otherEntity can be created from a single file or a
directory. In the case of generating a otherEntity object from a
directory, pass the directory path to the targetFile argument, capeml
will recognize the target as a directory, and create a zipped file of
the identified directory.

If the otherEntity object already is a zip file with the desired name,
set the overwrite argument to FALSE to prevent overwriting the existing
object.

As with all objects created with the capeml package, the resulting
object is named with convention:
projectid\_object-name\_md5sum-hash.file extension by default but this
functionality can be turned off by setting projectNaming to FALSE.

### literature cited

Though not provided as a function, below is a workflow for adding
literature cited elements at the dataset level. The workflow capitalizes
on EML version 2.2 that accepts the BibTex format for references.

``` r
# libraries

library(rcrossref)
library(EML)


# references

# datasets: ndvi

ndvi2010 <- cr_cn(dois = 'https://doi.org/10.6073/pasta/8a465e9b76035bffeb00f3a6134eb913', format = 'bibtex')

ndvi2010cit <- eml$citation(id = "https://doi.org/10.6073/pasta/8a465e9b76035bffeb00f3a6134eb913")
ndvi2010cit$bibtex <- ndvi2010

# datasets: savi

savi2010 <- cr_cn(dois = 'https://doi.org/10.6073/pasta/f4988cde318c85b76b0edbaa3219d682', format = 'bibtex')

savi2010cit <- eml$citation(id = "https://doi.org/10.6073/pasta/f4988cde318c85b76b0edbaa3219d682")
savi2010cit$bibtex <- savi2010

# publications cited in methods

huete <- cr_cn(dois = 'https://doi.org/10.1016/0034-4257(88)90106-X', format = 'bibtex')

huetecit <- eml$citation(id = "https://doi.org/10.1016/0034-4257(88)90106-X")
huetecit$bibtex <- huete

# build list of citations

citationsAll <- list(citation = list(ndvi2010cit,
                                     savi2010cit,
                                     huetecit
) # close list of citations
) # close citation
```

The citations can then be added to the EML::eml$dataset() entity using:
`dataset$literatureCited <- citationsAll`
