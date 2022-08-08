# Hong Kong Traffic Injury Collision Database

<img src="https://user-images.githubusercontent.com/29334677/180681488-53b69199-d57b-4ff7-af1d-d090e24b132c.png" align="right" height="140"/><img src="https://user-images.githubusercontent.com/29334677/180681494-c693e520-9eab-4f95-a4ad-0b5837d8b246.png" align="right" height="140"/>

<!-- badges: start -->
[![Travis build Status](https://travis-ci.org/Hong-Kong-Districts-Info/hktrafficcollisions.svg?branch=main)](https://travis-ci.org/Hong-Kong-Districts-Info/hktrafficcollisions) [![R build status](https://github.com/Hong-Kong-Districts-Info/hktrafficcollisions/workflows/R-CMD-check/badge.svg)](https://github.com/Hong-Kong-Districts-Info/hktrafficcollisions/actions) [![Codecov test coverage](https://codecov.io/gh/Hong-Kong-Districts-Info/hktrafficcollisions/branch/master/graph/badge.svg)](https://codecov.io/gh/Hong-Kong-Districts-Info/hktrafficcollisions?branch=master) [![CodeFactor](https://www.codefactor.io/repository/github/hong-kong-districts-info/hktrafficcollisions/badge)](https://www.codefactor.io/repository/github/hong-kong-districts-info/hktrafficcollisions) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

> *To provide a convenient site for information on traffic collisions that result in injury in Hong Kong.*

The Shiny app is deployed onto shinyapps.io in the links below:

- Production:
- Pre-production: https://hkdistricts-info.shinyapps.io/trafficcollisions-preprod/
- Development: https://hkdistricts-info.shinyapps.io/trafficcollisions-dev/

***

## Project organisation
    ├── LICENSE                                 <- Sharing agreement
    │
    ├── README.md                               <- Introduces project
    │
    ├── DESCRIPTION                             <- Store important metadata about project
    │
    ├── CODE_OF_CONDUCT.md                      <- Guide to define community standards
    │
    ├── CONTRIBUTING.md                         <- Guide to how contributors can help
    │
    ├── NAMESPACE                               <- Prevent conflict in package names
    │
    ├── .gitignore                              <- Files and folders to be ignored by git
    │
    ├── inst/
    │   ├── app.R                               <- App script calling sub-scripts
    │   └── app/               
    |       ├── extdata/                        <- Data for app
    |       ├── R/                              <- Functions for app
    |       ├── www/                            <- Logo files for app
    |       ├── helpfiles/                      <- Markdown of shinyhelper tips
    |       ├── google-analytics.html           <- Link app with Google Analytics
    |       ├── global.R                        <- Static objects for app
    |       ├── server.R                        <- Reactive objects for app
    |       └── ui.R                            <- User-interface for app
    │
    ├── .github/                         
    │   ├── pull_request_template.md            <- Pull request template
    |   └── ISSUE_TEMPLATE/
    |       ├── bug_report.md                   <- Issue template for bugs
    |       └── feature_report.md               <- Issue template for features
    |   └── workflows/
    |       └── rcmd_build.yml                  <- Instructions for R CMD checks
    │
    ├── renv/                                   <- Config to use renv package
    │
    ├── renv.lock                               <- Package versions used for project
    │
    ├── travis.yml                              <- Instructions for travis.ci checks
    │
    ├── codecov.yml                             <- Instructions for codecov.io checks
    │
    └── hktrafficcollisions.Rproj               <- Config to establish Rproject

------------------------------------------------------------------------

## Installation

## Data source

## Getting help

## Code of Conduct

Please note that the hkdistrictcouncillors project is released with a [Contributor Code of Conduct](https://github.com/avisionh/hktrafficcollisions/blob/document/community-standards/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

## Project Team website
To find out more about our project team and other projects by us, please visit our [website](https://hong-kong-districts-info.github.io/).

You can find out about our current backlog of work on our public Trello [Doing board](https://trello.com/b/n5l7DMS5/doing).
