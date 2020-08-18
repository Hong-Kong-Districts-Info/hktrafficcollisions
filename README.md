# Dashboard: Hong Kong Traffic Collisions <img src="https://raw.githubusercontent.com/avisionh/dashboard-hkdistrictcouncillors/master/inst/app/www/logo.png" align="right" height="140" />

<!-- badges: start -->
[![Travis build Status](https://travis-ci.org/Hong-Kong-Districts-Info/hktrafficcollisions.svg?branch=main)](https://travis-ci.org/Hong-Kong-Districts-Info/hktrafficcollisions) [![R build status](https://github.com/Hong-Kong-Districts-Info/hktrafficcollisions/workflows/R-CMD-check/badge.svg)](https://github.com/Hong-Kong-Districts-Info/hktrafficcollisions/actions) [![Codecov test coverage](https://codecov.io/gh/Hong-Kong-Districts-Info/hktrafficcollisions/branch/master/graph/badge.svg)](https://codecov.io/gh/Hong-Kong-Districts-Info/hktrafficcollisions?branch=master) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
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

***
## Installation


***
## Installing pre-commit hooks
You can install the package from CRAN:

``` r
install.packages("precommit")
```

To access pre-commit functionality from R, you also need to install the
[pre-commit framework](https://pre-commit.com). The following command
line methods are tested to work with this R package:

  - `$ pip install pre-commit --user` (macOS, Linux and Windows)
    **outside** a conda or virtual environment.

  - `$ brew install pre-commit` (macOS).

Alternatively, you can handle the installation from R using
[miniconda](https://docs.conda.io/en/latest/miniconda.html):

  - install miniconda if you don’t have it already:
    `reticulate::install_miniconda()`. This needs reticulate \>= 1.14.

  - install the pre-commit framework with
    `precommit::install_precommit()` into the conda environment
    `r-precommit`.

Then, in a fresh R session:

``` r
# once in every git repo either
# * after cloning a repo that already uses pre-commit or
# * if you want introduce pre-commit to this repo
precommit::use_precommit()
```

The last command initializes pre-commit in your repo and performs some
set-up tasks like creating the config file `.pre-commit-config.yaml`,
where the hooks that will be run on `git commit` are specified. See
`?precommit::use_precommit()` to see how you can use a custom
`.pre-commit-config.yaml` instead of the default at initialization. You
can (obviously) change edit the file manually at any time.

### Usage

The next time you run `git commit`, the hooks listed in your
`.pre-commit-config.yaml` will get executed before the commit. The
helper function `precommit::open_config()` let’s you open and edit the
`.pre-commit-config.yaml` conveniently from the RStudio console. When
any file is changed due to running a hook or the hook script errors, the
commit will fail. You can inspect the changes introduced by the hook and
if satisfied, you can add the changes made by the hook to the index with
`git add path/to/file` and attempt to commit again. Some hooks change
files, like the styler hook, so all you need to do to make the hook pass
is `git add` the changes introduced by the hook. Other hooks, like the
parsable-R hook, will need your action, e.g. add a missing closing brace
to a call like `library(styler`, before they pass at the next attempt.
If all hooks pass, the commit is made. You can also [temporarily disable
hooks](https://pre-commit.com/#temporarily-disabling-hooks). If you
succeed, it should look like this:

<img src="man/figures/precommit.png" width="639" />

See the hooks provided by this repo under `vignette("available-hooks")`.
You can also add other hooks from other repos, by extending the
`.pre-commit-config.yaml` file, e.g. like this:

``` yaml
-   repo: https://github.com/pre-commit/precommit
    rev: v1.2.3
    hooks: 
    -   id: check-added-large-files
```

To update the hook revisions, run `precommit::autoupdate()`.

### Caution

  - **Do not abort while hooks are running in RStudio git tab.**
    Non-staged changes are stashed to a temp directory and when you
    abort in RStudio, these changes are not brought back to you repo.
    Upvote [this issue](https://github.com/rstudio/rstudio/issues/6471)
    to change this. We hope that in the future, the changes will be
    recovered in RStudio too. Note that this is only an issue with
    RStudio. Stashes are restored when you abort a `git commit` with
    `INT` (e.g. Ctrl+C) on the command line. To restore stashes,
    manually after hitting *abort* in the RStudio git tab, you can `git
    apply /path/to/patch_with_id` whereas you find the patch under your
    pre-commit cache, which is usually under `$HOME/.cache/pre-commit/`.

  - Because R is not officially supported as a language in the
    pre-commit framework (yet), there is no R package dependency
    management for the R hooks provided in this repo. If an R package
    that is needed by a hook is not yet installed, you might get this
    error:

### Documentation
The [online documentation](https://lorenzwalthert.github.io/precommit/index.html) of this package only covers the functionality added on top of pre-commit by this package. Everything else is covered in the extensive [online documentation](https://pre-commit.com/) of the pre-commit framework itself, including how to:

- create pre-push hooks
- create local hooks
- and more

***

## Data source

## Getting help

## Code of Conduct

Please note that the hkdistrictcouncillors project is released with a [Contributor Code of Conduct](https://github.com/avisionh/hktrafficcollisions/blob/document/community-standards/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

## Project Team website
To find out more about our project team and other projects by us, please visit our [website](https://hong-kong-districts-info.github.io/).

You can find out about our current backlog of work on our public Trello [Doing board](https://trello.com/b/n5l7DMS5/doing).
