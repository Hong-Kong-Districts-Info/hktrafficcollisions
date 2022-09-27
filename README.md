# 香港車禍傷亡資料庫 \| Hong Kong Traffic Injury Collision Database

<img src="https://user-images.githubusercontent.com/29334677/180681488-53b69199-d57b-4ff7-af1d-d090e24b132c.png" align="right" height="140"/><img src="https://user-images.githubusercontent.com/29334677/180681494-c693e520-9eab-4f95-a4ad-0b5837d8b246.png" align="right" height="140"/>

<!-- badges: start -->

[![Travis build Status](https://travis-ci.org/Hong-Kong-Districts-Info/hktrafficcollisions.svg?branch=main)](https://travis-ci.org/Hong-Kong-Districts-Info/hktrafficcollisions) [![R build status](https://github.com/Hong-Kong-Districts-Info/hktrafficcollisions/workflows/R-CMD-check/badge.svg)](https://github.com/Hong-Kong-Districts-Info/hktrafficcollisions/actions) [![Codecov test coverage](https://codecov.io/gh/Hong-Kong-Districts-Info/hktrafficcollisions/branch/master/graph/badge.svg)](https://codecov.io/gh/Hong-Kong-Districts-Info/hktrafficcollisions?branch=master) [![CodeFactor](https://www.codefactor.io/repository/github/hong-kong-districts-info/hktrafficcollisions/badge)](https://www.codefactor.io/repository/github/hong-kong-districts-info/hktrafficcollisions) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<!-- badges: end -->

[![](man/figures/website-preview.png)](https://hkdistricts-info.shinyapps.io/trafficcollisions/)

[香港車禍傷亡資料庫](https://hkdistricts-info.shinyapps.io/trafficcollisions/)是街道變革和 Hong Kong District Info 共同開發的項目，旨在利用互動地圖和儀表版，將香港車禍位置和相關數據可視化。

這個項目有三個目標：

-   提醒公眾注意目前香港車禍的嚴重性，尤其是對行人和單車使用者的嚴重影響
-   讓各方注意到街道設計如何導致目前的情況，以及應採取哪些系統性的補救措施，以提高弱勢道路使用者的安全
-   為記者、區議員和政府部門提供簡易數據和見解，有助深入探討及改善車禍問題

[Hong Kong Traffic Injury Collision Database](https://hkdistricts-info.shinyapps.io/trafficcollisions/) is a project co-developed by Street Reset and Hong Kong District Info, which aims to visualise Hong Kong traffic collision data with interactive mapping. Our objective is three-fold:

-   To alert the public on the current severity of traffic collisions in Hong Kong, with particular dire implications for pedestrians and cyclists,
-   To draw attention to how street design has contributed to the current situation, and what systemic remedies should be made to enhance the safety of vulnerable road users, and
-   To provide journalists, district councillors, and government departments with insights and map-based data evidence to understand this issue.

------------------------------------------------------------------------

## Development

The Shiny app is deployed onto shinyapps.io in the links below:

-   Production: <https://hkdistricts-info.shinyapps.io/trafficcollisions/>
-   Development: <https://hkdistricts-info.shinyapps.io/trafficcollisions-dev/>

------------------------------------------------------------------------

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

TODO

## Data source

TODO

## Getting help

TODO

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/Hong-Kong-Districts-Info/hktrafficcollisions/blob/main/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

## Project Team website

To find out more about our project team and other projects by us, please visit our [website](https://hong-kong-districts-info.github.io/).
