# Create React App for Parcel

## Description
This is a simple along the lines of [`create-react-app`](https://create-react-app.dev/docs/deployment) building a lean and easily configured react project for web development, with the primary feature of using [`parcel`](https://parceljs.org) as bundler and development server instead of webpack.

## Motivation
Why re-invent this particular wheel?
Yes, I am aware of [create-react-app-parcel](https://www.npmjs.com/package/create-react-app-parcel), but both times I tried to use it there were issues that did not occur if I built the app manually, including collisions between versions of dependencies or pulled in code that was somewhat out of date.

This utility is written in bash - not javascript - so requires no js dependancies of its own other than [npe](https://www.npmjs.com/package/npe) to add and update items in package.json other than dependencies. This of course does not support Windows, although may run anyway if using git-bash, cygwin or similar - I'd be interested in feedback and/or pull requests.

## NodeJS
This was developed using NodeJS v14.4.0 and npm 6.14.5, but there are no known requirements imposed by these versions other than the generated javascript requirements.

There are no version locks, and indeed the utility attempts to install and use the latest version of all modules it directly installs.

# Redux and Test support
The `-r` command line switch installs a top level reducer with no actions for the Redux store, with a Provider wrapping the App itself. No connect is used, instead redux (and react) using hooks is favoured. Note that the redux debugging interface is enabled by default.

The `-t` command line switch sets up unit testing as part of the environment, creating a simple dom validation test for the generated 'App' component.

# Code Generated
Only a basic, but functional, react (+redux +test) application is built - don't expect anything too fancy, it is a starting point only.
