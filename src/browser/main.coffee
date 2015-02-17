app = require 'app'
url = require 'url'
path = require 'path'
fs = require 'fs-plus'
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

  yargs = require('yargs')
    .alias('d', 'dev').boolean('d').describe('d', 'Run in development mode.')
    .alias('h', 'help').boolean('h').describe('h', 'Print this usage message.')
    .alias('l', 'log-file').string('l').describe('l', 'Log all output to file.')
    .alias('r', 'resource-path').string('r').describe('r', 'Set the path to the App source directory and enable dev-mode.')
    .alias('s', 'spec-directory').string('s').describe('s', 'Set the directory from which to run package specs (default: Atom\'s spec directory).')
    .alias('t', 'test').boolean('t').describe('t', 'Run the specified specs and exit with error code on failures.')
    .alias('v', 'version').boolean('v').describe('v', 'Print the version.')

  args = yargs.parse(process.argv[1..])

  process.stdout.write(JSON.stringify(args) + "\n")

  if args.help
    help = ""
    yargs.showHelp((s) -> help += s)
    process.stdout.write(help + "\n")
    process.exit(0)

  if args.version
    process.stdout.write("#{version}\n")
    process.exit(0)

  devMode = args['dev']
  test = args['test']
  exitWhenDone = test
  specDirectory = args['spec-directory']
  logFile = args['log-file']

  if args['resource-path']
    devMode = true
    resourcePath = args['resource-path']
  else
    # Set resourcePath based on the specDirectory if running specs on atom core
    if specDirectory?
      packageDirectoryPath = path.join(specDirectory, '..')
      packageManifestPath = path.join(packageDirectoryPath, 'package.json')
      if fs.statSyncNoException(packageManifestPath)
        try
          packageManifest = JSON.parse(fs.readFileSync(packageManifestPath))
          resourcePath = packageDirectoryPath if packageManifest.name is 'atom'

    if devMode
      resourcePath ?= global.devResourcePath

  unless fs.statSyncNoException(resourcePath)
    resourcePath = path.dirname(path.dirname(__dirname))

  resourcePath = path.resolve(resourcePath)

  {resourcePath, devMode, test, exitWhenDone, specDirectory, logFile}

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

  # Note: It's important that you don't do anything with Atom Shell
  # unless it's after 'ready', or else mysterious bad things will happen
  # to you.
  app.on 'ready', ->
    setupCoffeeScript()
    require('../babel').register()

    if args.devMode
      require(path.join(args.resourcePath, 'src', 'coffee-cache')).register()
      Application = require path.join(args.resourcePath, 'src', 'browser', 'application')
    else
      Application = require './application'

    global.application = new Application(args)
    console.log("App load time: #{Date.now() - global.shellStartTime}ms") unless args.test

start()
