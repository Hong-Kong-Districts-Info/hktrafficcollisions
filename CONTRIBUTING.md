# Contributing to hktrafficcollisions
We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## We develop with Github
We use github to host code, to track issues and feature requests, as well as accept pull requests.

## We use [Github Flow](https://guides.github.com/introduction/flow/index.html), so all code changes happen through Pull Requests
Pull requests are the best way to propose changes to the codebase (we use [Github Flow](https://guides.github.com/introduction/flow/index.html)). We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Any contributions you make will be under the MIT Software License
In short, when you submit code changes, your submissions are understood to be under the same [MIT License](http://choosealicense.com/licenses/mit/) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using Github's [Issues](https://github.com/avisionh/dashboard-hkdistrictcouncillors/issues)
We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/avisionh/dashboard-hkdistrictcouncillors/issues); it's that easy!

## Write bug reports with detail, background, and sample code
[This is an example](http://stackoverflow.com/q/12488905/180626) of a bug report written, and it's not a bad model. Here's [another example from Craig Hockenberry](http://www.openradar.me/11905408).

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can. [My stackoverflow question](http://stackoverflow.com/q/12488905/180626) includes sample code that *anyone* with a base R setup can run to reproduce what I was seeing
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

People *love* thorough bug reports. I'm not even kidding.

***

## Use a consistent R coding style
Loosely borrowing these from [Facebook's Guidelines](https://github.com/facebook/draft-js/blob/a9316a723f9e918afde44dea68b5f9f39b7d9b00/CONTRIBUTING.md)

* Tabs or four spaces for indentation
* You can try running `npm run lint` for style unification
* Name your objects explicity, be descriptive

***

## Use a consistent Git messaging structure
More detail is available on the repo's wiki, [House Styles: Git](https://github.com/avisionh/dashboard-hkdistrictcouncillors/wiki/House-Styles:-Git), but in short.

### Branch
+ **Principle**: Each branch should have a single purpose.
+ **Frequency:** Every time you want to work on part of a project, create a branch for it.
+ **Naming Convention**:
  - `type/name` - this lets branches of the same type be grouped together in GitHub
  - Choose short and descriptive names

```
Note this is not an exhaustive list:

feature   Additional functionality or features
devops    Software development/IT operation-related changes
bugfix    Fixing an error
data      Updating data or data connections
format    Changing the format/layout
document  Create documents for community standards

Any suggestions, let us know!
```

### Commit
+ **Principle**: Include "what the commit does" as well as "why it does it" if the "what the commit does" message is not sufficient. Like Twitter, any commit message cannot be longer than 80 characters.
+ **Frequency:**  Commit often and early, to ensure you don't lose any work. Don't worry about your `git log` or `git nl` looking ugly. You can clean this up afterwards.
+ **Naming Convention**: Should follow the below form, where *<type*> and *<subject*> are mandatory, whilst *<body*> and `*<footer*> are optional.
    - If *<body*> and *<footer*> are present, *<BLANK LINE*> is mandatory.

```
<type>: <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

Most commits will be of the form `<type>: <subject>`.

```
feat      A new feature
fix       A bug
docs      Documentation only changes
style     Changes that do not affect the meaning of the code *e.g. white-space, formatting*
refactor  A code change that neither fixes a bug or adds a feature
perf      A code change that improves performance
test      Add missing tests
chore     Changes to build process or auxiliary tools and libraries such as documentation generator
```

***

## References
This document was adapted from the open-source contribution guidelines for [Facebook's Draft](https://github.com/facebook/draft-js/blob/a9316a723f9e918afde44dea68b5f9f39b7d9b00/CONTRIBUTING.md)
