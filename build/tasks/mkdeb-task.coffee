fs = require 'fs'
path = require 'path'
_ = require 'underscore-plus'

module.exports = (grunt) ->
  {spawn} = require('./task-helpers')(grunt)

  fillTemplate = (filePath, data) ->
    template = _.template(String(fs.readFileSync("#{filePath}.in")))
    filled = template(data)

    outputPath = path.join(grunt.config.get('atom.buildDir'), path.basename(filePath))
    grunt.file.write(outputPath, filled)
    outputPath

  getInstalledSize = (buildDir, callback) ->
    cmd = 'du'
    args = ['-sk', path.join(buildDir, 'Atom')]
    spawn {cmd, args}, (error, {stdout}) ->
      installedSize = stdout.split(/\s+/)?[0] or '200000' # default to 200MB
      callback(null, installedSize)

  grunt.registerTask 'mkdeb', 'Create debian package', ->
    done = @async()
    buildDir = grunt.config.get('atom.buildDir')

    if process.arch is 'ia32'
      arch = 'i386'
    else if process.arch is 'x64'
      arch = 'amd64'
    else
      return done("Unsupported arch #{process.arch}")

    pkgName = grunt.config.get('name')
    executableName = grunt.config.get("#{pkgName}.executableName")

    {name, version, description, author} = grunt.config.get('pkg')

    section = 'devel'
    maintainer = author
    installDir = '/usr'
    iconName = 'atom'
    getInstalledSize buildDir, (error, installedSize) ->
      data = {name, version, description, section, arch, maintainer, installDir, iconName, installedSize, executableName}
      controlFilePath = fillTemplate(path.join('resources', 'linux', 'debian', 'control'), data)
      desktopFilePath = fillTemplate(path.join('resources', 'linux', "#{executableName}.desktop"), data)
      icon = path.join('resources', 'app.png')

      cmd = path.join('script', 'mkdeb')
      args = [version, arch, controlFilePath, desktopFilePath, icon, buildDir]
      spawn {cmd, args}, (error) ->
        if error?
          done(error)
        else
          grunt.log.ok "Created #{buildDir}/#{executableName}-#{version}-#{arch}.deb"
          done()
