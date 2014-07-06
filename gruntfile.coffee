module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      build:
        options:
          join: true
        files:
          "js/befunge-torus.js": ["src/*.coffee"]

    connect:
      build:
        options:
          port: 3000
          livereload: 35729

    esteWatch:
      options:
        dirs: ["src/"]
        livereload:
          enabled: true
          port: 35729
          extensions: ["coffee"]
      coffee: -> ["coffee"]

  pkg = grunt.file.readJSON "package.json"

  for taskName of pkg.devDependencies
    if taskName.substring(0, 6) == "grunt-"
      grunt.loadNpmTasks taskName

  grunt.registerTask "default", [
    "coffee"
    "connect"
    "esteWatch"
  ]
