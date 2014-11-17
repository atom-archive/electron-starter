Menu = require 'menu'
app = require 'app'
fs = require 'fs'
ipc = require 'ipc'
path = require 'path'
os = require 'os'
net = require 'net'
url = require 'url'

{EventEmitter} = require 'events'
BrowserWindow = require 'browser-window'
_ = require 'underscore-plus'

module.exports =
class AppWindow
  _.extend @prototype, EventEmitter.prototype

  constructor: (options) ->
    windowOpts =
      width: 800
      height: 600
      'auto-hide-menu-bar': false #process.platform is 'win32'
      title: "Main Window"
      'web-preferences':
        'subpixel-font-scaling': true
        'direct-write': true

    windowOpts = _.extend(windowOpts, options)

    @window = new BrowserWindow(windowOpts)

    @window.on 'closed', (e) =>
      this.emit 'closed', e

    @window.on 'devtools-opened', (e) =>
      @window.webContents.send 'window:toggle-dev-tools', true

    @window.on 'devtools-closed', (e) =>
      @window.webContents.send 'window:toggle-dev-tools', false

  show: ->
    targetPath = path.resolve(__dirname, '..', '..', 'static', 'index.html')

    targetUrl = url.format
      protocol: 'file'
      pathname: targetPath
      slashes: true

    @window.loadUrl targetUrl
    @window.show()

  reload: ->
    @window.webContents.reload()

  toggleFullScreen: ->
    @window.setFullScreen(not @window.isFullScreen())

  toggleDevTools: ->
    @window.toggleDevTools()

  close: ->
    @window.close()
    @window = null
