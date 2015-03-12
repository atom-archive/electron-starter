fs = require 'fs'
path = require 'path'
_ = require 'underscore-plus'

module.exports = (grunt) ->
  {cp, mkdir, rm} = require('./task-helpers')(grunt)

  grunt.registerTask 'copy-app', 'Copy resources from the external app', ->
    pkgName = grunt.config.get('name')

    appDir = grunt.config.get("#{pkgName}.appDir")
    extAppPaths = grunt.config.get("#{pkgName}.extAppPaths")
    extAppPackageJSON = grunt.config.get("#{pkgName}.extAppPackageJSON")
    extAppDir = path.resolve(path.join(appDir, '..', 'extapp'))

    mkdir path.dirname(extAppDir)

    grunt.log.ok "Copying external app #{path.join(extAppPaths.root, 'package.json')}"
    cp path.join(extAppPaths.root, 'package.json'), path.join(extAppDir, 'package.json')

    {dependencies} = extAppPackageJSON
    dependencies = _.clone(dependencies)
    delete dependencies['atom-shell-starter']

    extAppSrc = path.join(extAppPaths.root, extAppPaths.src)
    extAppNodeModules = path.join(extAppPaths.root, 'node_modules')
    moduleRegex = new RegExp("^#{_.escapeRegExp(extAppNodeModules)}#{_.escapeRegExp(path.sep)}([\\w_-]+)\\b")

    grunt.log.ok "Copying external app source #{extAppSrc}"
    cp extAppSrc, path.join(extAppDir, extAppPaths.src)

    grunt.log.ok "Copying external app dependencies #{extAppNodeModules}"
    cp extAppNodeModules, path.join(extAppDir, 'node_modules'),
      filter: (sourcePath) ->
        matches = sourcePath.match(moduleRegex)
        not (matches?[1] of dependencies)

    grunt.log.ok "Writing main path to app/package.json"
    appPackageJSONPath = path.join(appDir, 'package.json')
    appPackageJSON = grunt.file.readJSON(appPackageJSONPath)
    appPackageJSON.rendererMain = extAppPackageJSON.main
    grunt.file.write(appPackageJSONPath, JSON.stringify(appPackageJSON, null, '  '))
