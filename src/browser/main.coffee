app = require 'app'
url = require 'url'
path = require 'path'
BrowserWindow = require 'browser-window'
Application = require './application'

# NB: Hack around broken native modules atm
nslog = console.log

process.on 'uncaughtException', (error={}) ->
  nslog(error.message) if error.message?
  nslog(error.stack) if error.stack?

# Note: It's important that you don't do anything with Atom Shell
# unless it's after 'ready', or else mysterious bad things will happen
# to you.
app.on 'ready', ->
  global.application = new Application({})
