@pkgJson = require 'package.json'

# Start the crash reporter before anything else.
require('crash-reporter').start(productName: @pkgJson.name, companyName: 'atom-shell-starter')

window.jasmineRequire = require '../vendor/jasmine/lib/jasmine-2.1.3/jasmine'
require '../vendor/jasmine/lib/jasmine-2.1.3/jasmine-html'
require '../vendor/jasmine/lib/jasmine-2.1.3/boot'
