app = require 'app'
url = require 'url'
path = require 'path'
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
  wnd = new BrowserWindow
    width: 800
    height: 600
    show: false
    'web-preferences':
      'subpixel-font-scaling': true
      'direct-write': true

  target = url.format
    protocol: 'file'
    pathname: path.resolve(__dirname, '..', '..', 'static', 'index.html')
    slashes: true

  wnd.loadUrl(target)
  wnd.show()

  global.theWindow = wnd
