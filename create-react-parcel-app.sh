#!/bin/bash

usage() {
	prog=$(basename $0)
  	code=$1
  	message=$2
  	if [[ ! -z "${message}" ]]; then
    	echo "==>" ${message}
  	fi
  	cat <<EOF

usage: ${prog} [options] <appname>
options:
	-h        display help
	-o        overwrite existing folder (if it exists)
	-r        add redux support
	-t        add testing support
	-n NAME   set author name
	-e EMAIL  set author email
EOF
    exit ${code}
}

cmd() {
	cmd="$*"
	echo '=>' ${cmd}
	${cmd}
}

overwrite=0
testing=0
redux=0
author_name="$(git config user.name)"
author_email="$(git config user.email)"

while getopts "hotrn:e:" opt
do
	case ${opt} in
		h)
			usage 2 "command line help"
			;;
		o)
			overwrite=1
			;;
		t)
			testing=1
			;;
		r)
			redux=1
			;;
	  n)
	    author_name=${OPTARG}
	    ;;
	  e)
	    author_email=${OPTARG}
	    ;;
		*)
			usage 1
			;;
	esac
done

shift $((OPTIND-1))

appname=$1
[[ -z "$appname" ]] && usage 1 "app name required" || echo "AppName: ${appname}"
[[ -e "$appname" ]] && [[ ${overwrite} -eq 0 ]] && usage 3 "Object ${appname} already exists"

[[ ${redux} -gt 0 ]] && echo "=> Redux support enabled" || echo "=> NO redux support"
[[ ${testing} -gt 0 ]] && echo "=> Testing support enabled" || echo "=> NO testing support"

cmd mkdir -p "${appname}" 2>/dev/null || usage 4 "is ${appname} a directory?"
cmd cd "${appname}" 2>/dev/null || usage 4 "is ${appname} a directory?"
echo "Creating app in" "$(pwd)"

rm -rf package.json package-lock.json node-modules
cmd npm init -y >/dev/null
cmd npm install --save react react-dom
cmd npm install --save-dev npe @babel/core @babel/preset-env @babel/preset-react parcel-bundler

npe="npx npe"

cat <<BABELRC > .babelrc
{
	"presets": ['@babel/preset-env', '@babel/preset-react']
}
BABELRC

cmd mkdir -p public src src/components src/components/App

cat <<HTML > public/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="theme-color" content="#282c34">
  <link rel="shortcut icon" href="favicon.ico">
  <link rel="manifest" href="manifest.json">
  <title>${appname}</title>
</head>
<body>
  <noscript>
    You need to enable JavaScript to run this app.
  </noscript>
  <div id="app"></div>
  <script type="text/javascript" src="../src/index.js"></script>
</body>
</html>
HTML

cat <<MANIFEST > public/manifest.json
{
  "short_name": "${appname}",
  "name": "${appname} Application",
  "icons": [
    {
      "src": "favicon.ico",
      "sizes": "64x64 32x32 24x24 16x16",
      "type": "image/x-icon"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#ffffff",
  "background_color": "#282c34"
}
MANIFEST

base64 --decode <<FAVICON > public/favicon.ico
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
FAVICON

	cat <<CSS > src/index.css
html {
    box-sizing: border-box;
    font-size: 16px;
}

*, *:before, *:after {
    box-sizing: inherit;
}

body, h1, h2, h3, h4, h5, h6, p, ol, ul {
    margin: 0;
    padding: 0;
    font-weight: normal;
  	font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans',
    'Droid Sans', 'Helvetica Neue', sans-serif;
  	-webkit-font-smoothing: antialiased;
  	-moz-osx-font-smoothing: grayscale;
}

code {
  	font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New', monospace;
}
CSS

cat <<APP > src/components/App/index.js
import React, {useState} from 'react';
import './index.css';

const App = (props) => {
  const title = props.title || 'React App'
  return (
      <div className="App">
        <header className="App-header">
          <h1 data-testid="title">{title}</h1>
        </header>
        <div className="App-body">
	      <p>Replace this with your own app</p>
	    </div>
      </div>
	)
}

export default App
APP

cat <<CSS > src/components/App/index.css
body {
  background-color: #282c34;
  color: white;
}

.App {
  min-height: 50vh;
  text-align: center;
}

.App-header {
  min-height: 50vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 2vmin);
}

.App-body {
  text-align: center;
  font-size: calc(10px * 1vmin);
}
CSS

if [[ ${redux} -gt 0 ]]; then

	cmd npm install --save redux react-redux
	cmd mkdir -p src/store src/store/actions src/store/reducers

	cat <<MAIN > src/index.js
import React from 'react'
import ReactDOM from 'react-dom'
import { createStore } from 'redux'
import { Provider } from 'react-redux'
import rootReducer from './store/reducers'

import './index.css'
import App from './components/App'

const store = createStore(
	rootReducer, /* preloadedState, */
	window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
)

ReactDOM.render(
	<Provider store={store}>
		<App title="${appname}" />
	</Provider>
	, document.getElementById('app')
)
MAIN

	cat <<STATE >src/store/initialState.js
const initialState = {}
export default initialState
STATE

	cat <<ROOT > src/store/reducers/index.js
import initialState from '../initialState'

const rootReducer = (state = initialState, action) => {
	switch (action.type) {
		default:
			return state
	}
}
export default rootReducer
ROOT

	else

	cat <<MAIN >src/index.js
import React from 'react'
import ReactDOM from 'react-dom'

import './index.css'
import App from './components/App'

ReactDOM.render(<App title="${appname}" />, document.getElementById('app'))
MAIN

fi

${npe} description "${appname} by ${author_name} ${author_email}"
${npe} version "0.1.0"
${npe} main "public/index.html"
${npe} author.name "${author_name}"
${npe} author.email "${author_email}"
${npe} scripts.start "parcel serve watch public/index.html"
${npe} scripts.build "parcel build public/index.html"

if [[ ${testing} -gt 0 ]]; then

    cmd mkdir -p __mocks__
	  cmd npm install --save-dev jest babel-jest react-test-renderer @testing-library/react @testing-library/react-hooks
    ${npe} scripts.test "jest"
    ${npe} scripts.testing "jest --watch"

  cat <<JEST > jest.config.js
// https://jestjs.io/docs/en/configuration.html

module.exports = {
  // The glob patterns Jest uses to detect test files
  testMatch: [
    "**/?(*.)+(spec|test).[tj]s?(x)"
  ],

  testPathIgnorePatterns: [
    "/node_modules/"
  ],

  moduleNameMapper: {
    "\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$": "<rootDir>/__mocks__/fileMock.js",
    "\\.(css|less)$": "<rootDir>/__mocks__/styleMock.js"
  }
}
JEST

  cat <<FILEMOCK > ./__mocks__/fileMock.js
module.exports = 'test-file-stub'
FILEMOCK

  cat <<STYLEMOCK > ./__mocks__/styleMock.js
module.exports = {}
STYLEMOCK

  cat <<TEST > src/components/App/index.test.js
import React from 'react'
import {render} from '@testing-library/react'
import App from '.'

test('title prop loads correctly', () => {
    const {getByTestId} = render(<App title={"${appname}"}/>)
    const titleElement = getByTestId('title')
    expect(titleElement.textContent).toBe("${appname}")
})
TEST
fi

cat <<IGNORE > .gitignore
/.idea
/.cache
/node_modules
/dist
IGNORE


cmd git init .
cmd git add -A
git commit -m \'"${appname} Initial commit"\'
