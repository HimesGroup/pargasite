## Reviewer's comments:

Please always write package names, software names and API (application
programming interface) names in single quotes in title and description.
e.g: --> 'Air Quality System' API
Please note that package names are case sensitive. -> 'shiny'

- We added single quotes for Air Quality System API
- We changed 'Shiny' -> 'shiny'

Please add a web reference for the API in the form <[https:.....]https:.....> to
the description of the DESCRIPTION file with no space after 'https:' and angle
brackets for auto-linking.

- We added a web reference for the API with angle brackets in the DESCRIPTION
  file.

## Test environments

* Local
  - Ubuntu 22.04 LTS: release
* GitHub Actions
  - Ubuntu-latest: release, devel
  - Windows-latest: release, devel
  - Mac-latest: release
* Win-builder
  - old-release, release, devel
* Mac-builder
  - release

## R CMD check results

0 errors | 0 warnings | 1 note

* Possibly misspelled words in DESCRIPTION:
  - AQS, CBSA, NAAQS: acronyms used by the U.S Environmental Protection Agency
  - Geospatial: capitalized to indicate the package full name
