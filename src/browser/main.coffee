app = require 'app'
url = require 'url'
path = require 'path'
optimist = require 'optimist'
spawn = require('child_process').spawn

BrowserWindow = require 'browser-window'
Application = require './application'

# NB: Hack around broken native modules atm
nslog = console.log

global.shellStartTime = Date.now()

process.on 'uncaughtException', (error={}) ->
  nslog(error.message) if error.message?
  nslog(error.stack) if error.stack?

parseCommandLine = ->
  version = app.getVersion()
  options = optimist(process.argv[1..])
  options.usage """App Version v#{version}"""

  options.alias('h', 'help').boolean('h').describe('h', 'Print this usage message.')
  options.alias('r', 'resource-path').string('r').describe('r', 'Set the path to the Atom source directory and enable dev-mode.')
  options.alias('v', 'version').boolean('v').describe('v', 'Print the version.')
  args = options.argv

  if args.help
    process.stdout.write(options.help())
    process.exit(0)

  if args.version
    process.stdout.write("#{version}\n")
    process.exit(0)

  if args['resource-path']
    devMode = true
    resourcePath = args['resource-path']

  unless fs.statSyncNoException(resourcePath)
    resourcePath = path.dirname(path.dirname(__dirname))

  resourcePath = path.resolve(resourcePath)

  {resourcePath, version, devMode }

setupCoffeeScript = ->
  CoffeeScript = null

  require.extensions['.coffee'] = (module, filePath) ->
    CoffeeScript ?= require('coffee-script')
    coffee = fs.readFileSync(filePath, 'utf8')
    js = CoffeeScript.compile(coffee, filename: filePath)
    module._compile(js, filePath)

start = ->
  # Enable ES6 in the Renderer process
  app.commandLine.appendSwitch 'js-flags', '--harmony'

  args = parseCommandLine()

  if (args.devMode)
    app.commandLine.appendSwitch 'remote-debugging-port', '8315'

  app.on 'ready', ->
    setupCoffeeScript()

    if args.devMode
      require(path.join(args.resourcePath, 'src', 'coffee-cache')).register()
      Application = require path.join(args.resourcePath, 'src', 'browser', 'application')
    else
      Application = require './application'

    global.application = new Application(args)
    console.log("App load time: #{Date.now() - global.shellStartTime}ms") unless args.test


# Note: It's important that you don't do anything with Atom Shell
# unless it's after 'ready', or else mysterious bad things will happen
# to you.
app.on 'ready', ->
  global.application = new Application({})
