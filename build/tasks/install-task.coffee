path = require 'path'
_ = require 'underscore-plus'
fs = require 'fs-plus'
runas = null
temp = require 'temp'

module.exports = (grunt) ->
  {cp, mkdir, rm} = require('./task-helpers')(grunt)

  grunt.registerTask 'install', 'Install the built application', ->
    pkgName = grunt.config.get('name')
    installDir = grunt.config.get("#{pkgName}.installDir")
    shellAppDir = grunt.config.get("#{pkgName}.shellAppDir")

    if process.platform is 'win32'
      throw new Error("Install is only for Linux")
    else if process.platform is 'darwin'
      throw new Error("Install is only for Linux")
    else
      binDir = path.join(installDir, 'bin')
      shareDir = path.join(installDir, 'share', 'atom')

      iconName = path.join(shareDir, 'resources', 'app', 'resources', 'app.png')

      mkdir binDir
      rm shareDir
      mkdir path.dirname(shareDir)
      cp shellAppDir, shareDir
      
      fs.chmodSync(path.join(shareDir, pkgName), "755")
