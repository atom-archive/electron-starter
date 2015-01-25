@pkgJson = require 'package.json'

# Start the crash reporter before anything else.
require('crash-reporter').start(productName: @pkgJson.name, companyName: 'atom-shell-starter')

h1 = document.createElement 'h1'
h1.innerText = 'Spec Suite'

document.body.appendChild h1
