
<!-- README.md is generated from README.Rmd. Please edit the latter. -->

# capeml: tools to aid the generation of EML metadata

### overview

This package contains tools to aid the generation of EML metadata with
intent to publish a data set (data + metadata) in the Environmental Data
Initiative (EDI) data repository. Functions and a workflow are included
that allow for the creation of metadata at the data set level, and
individual data entities (e.g., spatial vectors, raster, other entities,
data tables).

Helper functions for the creation of data set metadata and a dataTable
entity using the ropensci/eml are currently supported. Helper functions
for the creation of metadata for spatial data (e.g., spatialRaster)
currently are built on an earlier version of ropensci/eml and not
functional - these will be updated soon (2018-12-17). Note that the
creation of people-related entities in EML are specific to functions
that rely on Global Institute of Sustainability infrastructure - these
tools are located in a the [gioseml](https://github.com/CAPLTER/gioseml)
package.

**navigation**

  - [installation](https://github.com/CAPLTER/capeml#installation)
  - [dataTable](https://github.com/CAPLTER/capeml#dataTable)
  - [dataSet](https://github.com/CAPLTER/capeml#dataSet)

currently unsupported - [spatial
raster](https://github.com/CAPLTER/capeml#generate-spatialraster) -
[generate keyword
set](https://github.com/CAPLTER/capeml#generate-keywordset-from-file) -
[generate taxonomic
coverage](https://github.com/CAPLTER/capeml#generate-taxonomiccoverage)

### installation

Install the current version from GitHub (after installing the `devtools`
package from CRAN):

``` r
devtools::install_github("CAPLTER/capeml")
```

### dataTable

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

`create_dataTable(data_entity)` performs many services: \* the data
entity is written to file as a csv in the working directory with the
file name: projectid\_data-entity-name\_md5-hash-of-file.csv \* metadata
provided in the attributes and factors (if relevant) templates are
ingested \* a EML object of type dataTable is returned \* note that the
data entity name should be used consistently within the chunk, and the
resulting dataTable entity should have the name: data\_entity\_DT

``` r
data_entity <- read("data source") %>% 
  processing %>% 
  processing

write_attributes(data_entity)
write_factors(data_entity)

data_entity_desc <- "snow leopard data"

data_entity_DT <- create_dataTable(dfname = data_entity,
                                   description = data_entity_desc)
```

### dataSet

…most documentation in project template (in progress)…

`write_keywords()` will generate a template as a csv file in the working
directory with default CAP LTER keywords, and the appropriate thesaurii
for adding and referencing additional keywords.

### generate spatialRaster

Please see the
[create\_spatialRaster](https://github.com/CAPLTER/capeml/blob/master/vignettes/create_spatialRaster.Rmd)
vignette for more information about creating EML for raster data.

### generate keywordSet (from file)

The function `create_keywordSet` generates a EML object of type
keywordSet from a csv file containing thesaurus, keyword, and type where
type is an optional keyword attribute. Keyword files should be
structured like the following…

<table>

<thead>

<tr>

<th style="text-align:left;">

thesaurus

</th>

<th style="text-align:left;">

keyword

</th>

<th style="text-align:left;">

type

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

LTER controlled vocabulary

</td>

<td style="text-align:left;">

nutrients

</td>

<td style="text-align:left;">

theme

</td>

</tr>

<tr>

<td style="text-align:left;">

LTER controlled vocabulary

</td>

<td style="text-align:left;">

nitrate

</td>

<td style="text-align:left;">

theme

</td>

</tr>

<tr>

<td style="text-align:left;">

LTER core areas

</td>

<td style="text-align:left;">

water and fluxes

</td>

<td style="text-align:left;">

theme

</td>

</tr>

<tr>

<td style="text-align:left;">

LTER core areas

</td>

<td style="text-align:left;">

parks and rivers

</td>

<td style="text-align:left;">

theme

</td>

</tr>

<tr>

<td style="text-align:left;">

Creator Defined Keyword Set

</td>

<td style="text-align:left;">

stormwater

</td>

<td style="text-align:left;">

theme

</td>

</tr>

<tr>

<td style="text-align:left;">

Creator Defined Keyword Set

</td>

<td style="text-align:left;">

catchment

</td>

<td style="text-align:left;">

theme

</td>

</tr>

<tr>

<td style="text-align:left;">

CAPLTER Keyword Set List

</td>

<td style="text-align:left;">

arid land

</td>

<td style="text-align:left;">

theme

</td>

</tr>

<tr>

<td style="text-align:left;">

CAPLTER Keyword Set List

</td>

<td style="text-align:left;">

az

</td>

<td style="text-align:left;">

place

</td>

</tr>

</tbody>

</table>

Call the function:

``` r
datasetKeywords <- create_keywordSet('path/keywordFile.csv')
```

The object (e.g., datasetKeywords) can then be included in the EML
generation script.

### generate taxonomicCoverage

The function `set_taxonomicCoverage` is borrowed from [rOpenSci
EML](https://github.com/ropensci/EML) to create a EML entity of type
taxonomicCoverage that can be added to the coverage element of an EML
document. This function and approach is a fast-and-easy way to generate
a taxonomicCoverage for resolvable taxa in a data set - it is not
designed to resolve or address any challenges to resolving the ITIS
identification of a taxa. That is, only taxa that are cleanly matched to
the ITIS database are included in the taxonomicCoverage. As such, some
taxa may not be included in the taxonomicCoverage element. For a more
iterative approach that allows for resolving the corresponding ITIS ID
of all taxa (but also may require taxonomic expertise), users should
consider the EDI’s
[taxonomyCleanr](https://github.com/EDIorg/taxonomyCleanr) package.

Taxa should first be passed through the `indentify_resolvable_taxa`
function to identify those taxa for which an ITIS ID is resolvable.

``` r
all_taxa <- identify_resolvable_taxa(listOfTaxa)
```

Run setTaxonomicCoverage on the subset of taxa for which an ITIS ID is
resolvable.

``` r
resolved_taxa <- c(all_taxa[!is.na(all_taxa$resolve),]$taxon)a
taxaCoverage <- set_taxonomicCoverage(resolved_taxa, expand = T, db = 'itis')
```

``` r
coverage@taxonomicCoverage <- c(taxaCoverage)
```

### generate otherEntity with dataType kml

The function `create_KML`…

``` r
desert_fertilization_sites <- create_KML(
  kmlFile = "~/Desktop/desert_fertilization_sampling_sites.kml",
  description = "approximate location of desert fertiliztion long-term study sites")
```
