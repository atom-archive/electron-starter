path = require 'path'
fs = require 'fs'
{compileFile} = require '../../src/6to5'
_ = require 'underscore-plus'

module.exports = (grunt) ->
  {cp} = require('./task-helpers')(grunt)

  grunt.registerTask 'compile-6to5', 'Compile ES6 JS to ES5', ->
    {src, dest} = grunt.config.get('compile-6to5')

    allFiles = _.map(grunt.file.expand(src), (x) -> path.resolve(x))

    srcRoot = path.resolve('.')

    for file in allFiles
      js = compileFile(file)
      fs.writeFileSync(file.replace(srcRoot, dest), js)
