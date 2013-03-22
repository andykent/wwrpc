module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json'),

    coffee:
      wwrpc:
        options:
          join: true
        files:
          'lib/wwrpc.js': ['src/wwrpc.coffee', 'src/*.coffee']

    uglify:
      wwrpc:
        files:
          'lib/wwrpc.min.js': 'lib/wwrpc.js'

    watch:
      scripts:
        files: ['src/*.coffee']
        tasks: ['build']



  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('build', ['coffee', 'uglify'])
  grunt.registerTask('default', ['build'])