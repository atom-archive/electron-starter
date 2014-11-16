fs = require 'fs'
path = require 'path'
_ = require 'underscore-plus'

module.exports = (grunt) ->
  {spawn, rm, mkdir} = require('./task-helpers')(grunt)

  fillTemplate = (filePath, data) ->
    template = _.template(String(fs.readFileSync("#{filePath}.in")))
    filled = template(data)
    pkgName = grunt.config.get('name')

    outputPath = path.join(grunt.config.get("#{pkgName}.buildDir"), path.basename(filePath))
    grunt.file.write(outputPath, filled)
    outputPath

  grunt.registerTask 'mkrpm', 'Create rpm package', ->
    done = @async()

    if process.arch is 'ia32'
      arch = 'i386'
    else if process.arch is 'x64'
      arch = 'amd64'
    else
      return done("Unsupported arch #{process.arch}")

    pkgName = grunt.config.get('name')
    {name, version, description} = grunt.config.get('pkg')
    buildDir = grunt.config.get("#{pkgName}.buildDir")
    executableName = grunt.config.get("#{pkgName}.executableName")

    rpmDir = path.join(buildDir, 'rpm')
    rm rpmDir
    mkdir rpmDir

    installDir = grunt.config.get("#{pkgName}.installDir")
    shareDir = path.join(installDir, 'share', executableName)
    iconName = path.join(shareDir, 'resources', 'app', 'resources', 'app.png')

    data = {name, version, description, installDir, iconName}
    specFilePath = fillTemplate(path.join('resources', 'linux', 'redhat', "#{executableName}.spec"), data)
    desktopFilePath = fillTemplate(path.join('resources', 'linux', "#{executableName}.desktop"), data)

    cmd = path.join('script', 'mkrpm')
    args = [specFilePath, desktopFilePath, buildDir]
    spawn {cmd, args}, (error) ->
      if error?
        done(error)
      else
        grunt.log.ok "Created rpm package in #{rpmDir}"
        done()
