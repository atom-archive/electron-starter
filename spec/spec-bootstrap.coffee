@pkgJson = require '../../package.json'

# Start the crash reporter before anything else.
require('crash-reporter').start(productName: @pkgJson.name, companyName: 'atom-shell-starter')
