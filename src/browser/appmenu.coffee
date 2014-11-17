app = require 'app'
ipc = require 'ipc'
Menu = require 'menu'
path = require 'path'

season = require 'season'
_ = require 'underscore-plus'
{EventEmitter} = require 'events'

module.exports =
class ApplicationMenu
  _.extend @prototype, EventEmitter.prototype

  constructor: ->
    menuJson = season.resolve(path.join(process.resourcesPath, 'app', 'menus', process.platform))
    template = season.readFileSync(menuJson)

    @template = @translateTemplate(template.menu)

  attachToWindow: (window) ->
    @menu = Menu.buildFromTemplate(_.deepClone(@template))
    Menu.setApplicationMenu(@menu)

  wireUpMenu: (menu, command) ->
    menu.click = => @emit(command)

  translateTemplate: (template) ->
    emitter = @emit

    for item in template
      item.metadata ?= {}
      if item.command
        @wireUpMenu item, item.command

      @translateTemplate(item.submenu) if item.submenu

    return template

  acceleratorForCommand: (command, keystrokesByCommand) ->
    firstKeystroke = keystrokesByCommand[command]?[0]
    return null unless firstKeystroke

    modifiers = firstKeystroke.split('-')
    key = modifiers.pop()

    modifiers = modifiers.map (modifier) ->
      modifier.replace(/shift/ig, "Shift")
              .replace(/cmd/ig, "Command")
              .replace(/ctrl/ig, "Ctrl")
              .replace(/alt/ig, "Alt")

    keys = modifiers.concat([key.toUpperCase()])
    keys.join("+")
