fs = require 'fs-plus'

@pkgJson = require 'package.json'

# Start the crash reporter before anything else.
require('crash-reporter').start(productName: @pkgJson.name, companyName: 'atom-shell-starter')


link = document.createElement 'link'
link.rel = 'stylesheet'
link.href = '../vendor/jasmine/lib/jasmine-2.1.3/jasmine.css'
document.head.appendChild link

window.jasmineRequire = require '../vendor/jasmine/lib/jasmine-2.1.3/jasmine'
require '../vendor/jasmine/lib/jasmine-2.1.3/jasmine-html'
require '../vendor/jasmine/lib/jasmine-2.1.3/boot'

for specFilePath in fs.listTreeSync('spec/') when /-spec\.(coffee|js)$/.test specFilePath
  require specFilePath

window.jasmineExecute()
