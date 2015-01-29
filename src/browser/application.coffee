Menu = require 'menu'
BrowserWindow = require 'browser-window'
app = require 'app'
fs = require 'fs'
ipc = require 'ipc'
path = require 'path'
os = require 'os'
net = require 'net'
url = require 'url'

{EventEmitter} = require 'events'
_ = require 'underscore-plus'
{spawn} = require 'child_process'

AppMenu = require './appmenu'
AppWindow = require './appwindow'

module.exports =
class Application
  _.extend @prototype, EventEmitter.prototype

  constructor: (options) ->
    {@resourcePath, @version, @devMode } = options

    @pkgJson = require '../../package.json'

    @openWithOptions(options)

  # Opens a new window based on the options provided.
  openWithOptions: (options) ->
    {devMode, test, specDirectory, logFile} = options

    if test
      window = @runSpecs({exitWhenDone: true, @resourcePath, specDirectory, devMode, logFile})
    else
      window = new AppWindow(options)
      @menu = new AppMenu(pkg: @pkgJson)


      @menu.attachToWindow(window)
      @handleMenuItems(@menu)

    window.show()

  handleMenuItems: (menu, thisWindow) ->
    menu.on 'application:quit', -> app.quit()

    menu.on 'window:reload', ->
      BrowserWindow.getFocusedWindow().reload()

    menu.on 'window:toggle-full-screen', ->
      BrowserWindow.getFocusedWindow().toggleFullScreen()

    menu.on 'window:toggle-dev-tools', ->
      BrowserWindow.getFocusedWindow().toggleDevTools()

    menu.on 'application:run-specs', =>
      @openWithOptions(test: true)

  # Opens up a new {AtomWindow} to run specs within.
  #
  # options -
  #   :exitWhenDone - A Boolean that, if true, will close the window upon
  #                   completion.
  #   :resourcePath - The path to include specs from.
  #   :specPath - The directory to load specs from.
  runSpecs: ({exitWhenDone, resourcePath, specDirectory, logFile}) ->
    if resourcePath isnt @resourcePath and not fs.existsSync(resourcePath)
      resourcePath = @resourcePath

    try
      bootstrapScript = require.resolve(path.resolve(global.devResourcePath, 'spec', 'spec-bootstrap'))
    catch error
      bootstrapScript = require.resolve(path.resolve(__dirname, '..', '..', 'spec', 'spec-bootstrap'))

    isSpec = true
    devMode = true
    new AppWindow({bootstrapScript, resourcePath, exitWhenDone, isSpec, devMode, specDirectory, logFile})
