fs = require 'fs'
path = require 'path'
_ = require 'underscore-plus'

module.exports = (grunt) ->
  {cp, mkdir, rm} = require('./task-helpers')(grunt)

  grunt.registerTask 'copy-app', 'Copy resources from the external app', ->
    pkgName = grunt.config.get('name')

    appPaths = grunt.config.get("#{pkgName}.appPaths")
    appPackageJson = grunt.config.get("#{pkgName}.appPackageJson")
    extAppDir = path.resolve(path.join(grunt.config.get("#{pkgName}.appDir"), '..', 'extapp'))

    mkdir path.dirname(extAppDir)

    grunt.log.ok "Copying external app #{path.join(appPaths.root, 'package.json')}"
    cp path.join(appPaths.root, 'package.json'), path.join(extAppDir, 'package.json')

    nonPackageDirectories = []
    {dependencies} = appPackageJson
    dependencies = _.clone(dependencies)
    delete dependencies['atom-shell-starter']

    appSrc = path.join(appPaths.root, appPaths.src)
    appNodeModules = path.join(appPaths.root, 'node_modules')
    moduleRegex = new RegExp("^#{_.escapeRegExp(appNodeModules)}#{_.escapeRegExp(path.sep)}([\\w_-]+)\\b")

    grunt.log.ok "Copying external app #{appSrc}"
    cp appSrc, path.join(extAppDir, appPaths.src)

    grunt.log.ok "Copying external app #{appNodeModules}"
    cp appNodeModules, path.join(extAppDir, 'node_modules'),
      filter: (sourcePath) ->
        matches = sourcePath.match(moduleRegex)
        not (matches?[1] of dependencies)
