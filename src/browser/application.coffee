Menu = require 'menu'
BrowserWindow = require 'browser-window'
app = require 'app'
fs = require 'fs-plus'
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
    {@resourcePath, @devMode} = options

    @pkgJson = require '../../package.json'
    @windows = []

    app.on 'window-all-closed', ->
      app.quit() if process.platform in ['win32', 'linux']

    @openWithOptions(options)

  # Opens a new window based on the options provided.
  #
  # options -
  #   :resourcePath - The path to include specs from.
  #   :devMode - Boolean to determine if the application is running in dev mode.
  #   :test - Boolean to determine if the application is running in test mode.
  #   :exitWhenDone - Boolean to determine whether to automatically exit.
  #   :logfile - The file path to log output to.
  openWithOptions: (options) ->
    {test} = options

    if test
      newWindow = @openSpecsWindow(options)
    else
      newWindow = @openWindow(options)

    newWindow.show()
    @windows.push(newWindow)
    newWindow.on 'closed', =>
      @removeAppWindow(newWindow)

  # Opens up a new {AtomWindow} to run specs within.
  #
  # options -
  #   :exitWhenDone - Boolean to determine whether to automatically exit.
  #   :resourcePath - The path to include specs from.
  #   :logfile - The file path to log output to.
  openSpecsWindow: ({exitWhenDone, logFile}) ->
    try
      bootstrapScript = require.resolve(path.resolve(global.devResourcePath, 'spec', 'spec-bootstrap'))
    catch error
      bootstrapScript = require.resolve(path.resolve(__dirname, '..', '..', 'spec', 'spec-bootstrap'))

    isSpec = true
    devMode = true
    new AppWindow({bootstrapScript, exitWhenDone, @resourcePath, isSpec, devMode, logFile})

  # Opens up a new {AtomWindow} and runs the application.
  #
  # options -
  #   :resourcePath - The path to include specs from.
  #   :devMode - Boolean to determine if the application is running in dev mode.
  #   :test - Boolean to determine if the application is running in test mode.
  #   :exitWhenDone - Boolean to determine whether to automatically exit.
  #   :logfile - The file path to log output to.
  openWindow: (options) ->
    {resourcePath} = options
    bootstrapScript = if @pkgJson.rendererMain?
      if @devMode
        require.resolve(path.join(resourcePath, @pkgJson.rendererMain))
      else
        require.resolve(path.join(resourcePath, '..', 'extapp', @pkgJson.rendererMain))
    else
      require.resolve(path.join(resourcePath, 'src', 'renderer', 'main'))

    options.bootstrapScript = bootstrapScript
    appWindow = new AppWindow(options)
    @menu = new AppMenu(pkg: @pkgJson)

    @menu.attachToWindow(appWindow)

    @menu.on 'application:quit', -> app.quit()

    @menu.on 'window:reload', ->
      BrowserWindow.getFocusedWindow().reload()

    @menu.on 'window:toggle-full-screen', ->
      BrowserWindow.getFocusedWindow().toggleFullScreen()

    @menu.on 'window:toggle-dev-tools', ->
      BrowserWindow.getFocusedWindow().toggleDevTools()

    @menu.on 'application:run-specs', =>
      @openWithOptions(test: true)

    appWindow

  # Removes the given window from the list of windows, so it can be GC'd.
  #
  # options -
  #   :appWindow - The {AppWindow} to be removed.
  removeAppWindow: (appWindow) =>
    @windows.splice(idx, 1) for w, idx in @windows when w is appWindow
