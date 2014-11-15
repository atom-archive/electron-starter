app = require 'app'
BrowserWindow = require 'browser-window'

# NB: Hack around broken native modules atm
nslog = console.log

process.on 'uncaughtException', (error={}) ->
  nslog(error.message) if error.message?
  nslog(error.stack) if error.stack?

# Note: It's important that you don't do anything with Atom Shell
# unless it's after 'ready', or else mysterious bad things will happen
# to you.
app.on 'ready', ->
  global.theWindow = new BrowserWindow
    width: 800
    height: 600
    'web-preferences':
      'subpixel-font-scaling': true
      'direct-write': true

  window.loadUrl('https://www.example.com')
