async = require 'async'
path = require 'path'

module.exports = (grunt) ->
  {spawn} = require('./task-helpers')(grunt)

  logDeprecations = (label, {stderr}={}) ->
     return unless process.env.JANKY_SHA1
     stderr ?= ''
     deprecatedStart = stderr.indexOf('Calls to deprecated functions')
     return if deprecatedStart is -1

     grunt.log.error(label)
     stderr = stderr.substring(deprecatedStart)
     stderr = stderr.replace(/^\s*\[[^\]]+\]\s+/gm, '')
     stderr = stderr.replace(/source: .*$/gm, '')
     stderr = stderr.replace(/^"/gm, '')
     stderr = stderr.replace(/",\s*$/gm, '')
     grunt.log.error(stderr)

  getAppPath = ->
    pkgName = grunt.config.get 'name'

    contentsDir = grunt.config.get(pkgName + '.contentsDir')
    switch process.platform
      when 'darwin'
        path.join(contentsDir, 'MacOS', pkgName)
      when 'linux'
        path.join(contentsDir, 'atom')
      when 'win32'
        path.join(contentsDir, 'atom.exe')

  runCoreSpecs = (callback) ->
    appPath = getAppPath()
    resourcePath = process.cwd()
    coreSpecsPath = path.resolve('spec')

    if process.platform in ['darwin', 'linux']
      options =
        cmd: appPath
        args: ['--test', "--resource-path=#{resourcePath}", "--spec-directory=#{coreSpecsPath}"]
    else if process.platform is 'win32'
      options =
        cmd: process.env.comspec
        args: ['/c', appPath, '--test', "--resource-path=#{resourcePath}", "--spec-directory=#{coreSpecsPath}", "--log-file=ci.log"]

    spawn options, (error, results, code) ->
      if process.platform is 'win32'
        process.stderr.write(fs.readFileSync('ci.log')) if error
        fs.unlinkSync('ci.log')
      else
        # TODO: Restore concurrency on Windows
        logDeprecations('Core Specs', results)

      callback(null, error)

  grunt.registerTask 'run-specs', 'Run the specs', ->
    done = @async()
    startTime = Date.now()
    runCoreSpecs (error, results) ->
      console.log error
      console.log results
      elapsedTime = Math.round((Date.now() - startTime) / 100) / 10
      grunt.log.ok("Total spec time: #{elapsedTime}s")
      done();
