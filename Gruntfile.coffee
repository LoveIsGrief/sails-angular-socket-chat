###*
Gruntfile

If you created your Sails app with `sails new foo --linker`,
the following files will be automatically injected (in order)
into the EJS and HTML files in your `views` and `assets` folders.

At the top part of this file, you'll find a few of the most commonly
configured options, but Sails' integration with Grunt is also fully
customizable.  If you'd like to work with your assets differently
you can change this file to do anything you like!

More information on using Grunt to work with static assets:
http://gruntjs.com/configuring-tasks
###
module.exports = (grunt) ->

	###*
	CSS files to inject in order
	(uses Grunt-style wildcard/glob/splat expressions)

	By default, Sails also supports LESS in development and production.
	To use SASS/SCSS, Stylus, etc., edit the `sails-linker:devStyles` task
	below for more options.  For this to work, you may need to install new
	dependencies, e.g. `npm install grunt-contrib-sass`
	###
	cssFilesToInject = ["linker/**/*.css"]

	###*
	Javascript files to inject in order
	(uses Grunt-style wildcard/glob/splat expressions)

	To use client-side CoffeeScript, TypeScript, etc., edit the
	`sails-linker:devJs` task below for more options.
	###
	jsFilesToInject = [

		# Below, as a demonstration, you'll see the built-in dependencies
		# linked in the proper order order

		# Include the angular dependency.
		"linker/lib/angularjs/angular.min.js"

		# NOTE: For all other angular dependencies, include the path
		# 'linker/lib/angular/desiredAngularDependecy.js'

		# All of the rest of your app scripts imported here
		"linker/js/**/*.js"
	]

	###*
	Client-side HTML templates are injected using the sources below
	The ordering of these templates shouldn't matter.
	(uses Grunt-style wildcard/glob/splat expressions)

	By default, Sails uses JST templates and precompiles them into
	functions for you.  If you want to use jade, handlebars, dust, etc.,
	edit the relevant sections below.
	###
	templateFilesToInject = ["linker/**/*.html"]

	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#
	# DANGER:
	#
	# With great power comes great responsibility.
	#
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////
	#///////////////////////////////////////////////////////////////

	# Modify css file injection paths to use
	cssFilesToInject = cssFilesToInject.map((path) ->
		".tmp/public/" + path
	)

	# Modify js file injection paths to use
	jsFilesToInject = jsFilesToInject.map((path) ->
		".tmp/public/" + path
	)
	templateFilesToInject = templateFilesToInject.map((path) ->
		"assets/" + path
	)

	# Get path to core grunt dependencies from Sails
	path = require("path")
	depsPath = "node_modules"
	grunt.loadTasks path.join(depsPath, "/grunt-contrib-clean/tasks")
	grunt.loadTasks path.join(depsPath, "/grunt-contrib-copy/tasks")
	grunt.loadTasks path.join(depsPath, "/grunt-contrib-concat/tasks")
	grunt.loadTasks path.join(depsPath, "/grunt-sails-linker/tasks")
	grunt.loadTasks path.join(depsPath, "/grunt-contrib-jst/tasks")
	grunt.loadTasks path.join(depsPath, "/grunt-contrib-watch/tasks")
	grunt.loadTasks path.join(depsPath, "/grunt-contrib-uglify/tasks")
	grunt.loadTasks path.join(depsPath, "/grunt-contrib-cssmin/tasks")
	grunt.loadTasks path.join(depsPath, "/grunt-contrib-less/tasks")
	grunt.loadTasks path.join(depsPath, "/grunt-contrib-coffee/tasks")
	grunt.loadTasks path.join(depsPath, "/grunt-sync/tasks")

	# Project configuration.
	grunt.initConfig
		pkg: grunt.file.readJSON("package.json")
		copy:
			dev:
				files: [
					expand: true
					cwd: "./assets"
					src: ["**/*"]
					dest: ".tmp/public"
				]

			build:
				files: [
					expand: true
					cwd: ".tmp/public"
					src: ["**/*"]
					dest: "www"
				]

		sync:
			dev:
				files: [
					cwd: "./assets"
					src: ["**/*.!(coffee)"]
					dest: ".tmp/public"
				]

		clean:
			dev: [".tmp/public/**"]
			build: ["www"]

		jst:
			dev:

				# To use other sorts of templates, specify the regexp below:
				# options: {
				#   templateSettings: {
				#     interpolate: /\{\{(.+?)\}\}/g
				#   }
				# },
				files:
					".tmp/public/jst.js": templateFilesToInject

		less:
			dev:
				files: [
					{
						expand: true
						cwd: "assets/styles/"
						src: ["*.less"]
						dest: ".tmp/public/styles/"
						ext: ".css"
					}
					{
						expand: true
						cwd: "assets/linker/styles/"
						src: ["*.less"]
						dest: ".tmp/public/linker/styles/"
						ext: ".css"
					}
				]

		coffee:
			dev:
				options:
					bare: true
					sourceMap: true
					sourceRoot: "./"

				files: [
					{
						expand: true
						cwd: "assets/js/"
						src: ["**/*.coffee"]
						dest: ".tmp/public/js/"
						ext: ".js"
					}
					{
						expand: true
						cwd: "assets/linker/js/"
						src: ["**/*.coffee"]
						dest: ".tmp/public/linker/js/"
						ext: ".js"
					}
				]


		###*
		Production JS and CSS minification
		###
		concat:
			js:
				src: jsFilesToInject
				dest: ".tmp/public/concat/production.js"

			css:
				src: cssFilesToInject
				dest: ".tmp/public/concat/production.css"

		uglify:
			dist:
				src: [".tmp/public/concat/production.js"]
				dest: ".tmp/public/min/production.js"

		cssmin:
			dist:
				src: [".tmp/public/concat/production.css"]
				dest: ".tmp/public/min/production.css"


		###*
		Automatically injects <link> and <script> tags
		###
		"sails-linker":
			devJs:
				options:
					startTag: "<!--SCRIPTS-->"
					endTag: "<!--SCRIPTS END-->"
					fileTmpl: "<script src=\"%s\"></script>"
					appRoot: ".tmp/public"

				files:
					".tmp/public/**/*.html": jsFilesToInject
					"views/**/*.html": jsFilesToInject
					"views/**/*.ejs": jsFilesToInject

			prodJs:
				options:
					startTag: "<!--SCRIPTS-->"
					endTag: "<!--SCRIPTS END-->"
					fileTmpl: "<script src=\"%s\"></script>"
					appRoot: ".tmp/public"

				files:
					".tmp/public/**/*.html": [".tmp/public/min/production.js"]
					"views/**/*.html": [".tmp/public/min/production.js"]
					"views/**/*.ejs": [".tmp/public/min/production.js"]

			devStyles:
				options:
					startTag: "<!--STYLES-->"
					endTag: "<!--STYLES END-->"
					fileTmpl: "<link rel=\"stylesheet\" href=\"%s\">"
					appRoot: ".tmp/public"


				# cssFilesToInject defined up top
				files:
					".tmp/public/**/*.html": cssFilesToInject
					"views/**/*.html": cssFilesToInject
					"views/**/*.ejs": cssFilesToInject

			prodStyles:
				options:
					startTag: "<!--STYLES-->"
					endTag: "<!--STYLES END-->"
					fileTmpl: "<link rel=\"stylesheet\" href=\"%s\">"
					appRoot: ".tmp/public"

				files:
					".tmp/public/index.html": [".tmp/public/min/production.css"]
					"views/**/*.html": [".tmp/public/min/production.css"]
					"views/**/*.ejs": [".tmp/public/min/production.css"]


			# Bring in JST template object
			devTpl:
				options:
					startTag: "<!--TEMPLATES-->"
					endTag: "<!--TEMPLATES END-->"
					fileTmpl: "<script type=\"text/javascript\" src=\"%s\"></script>"
					appRoot: ".tmp/public"

				files:
					".tmp/public/index.html": [".tmp/public/jst.js"]
					"views/**/*.html": [".tmp/public/jst.js"]
					"views/**/*.ejs": [".tmp/public/jst.js"]

		watch:
			api:

				# API files to watch:
				files: ["api/**/*"]

			assets:

				# Assets to watch:
				files: ["assets/**/*"]

				# When assets are changed:
				tasks: [
					"syncAssets"
					"linkAssets"
				]


	# When Sails is lifted:
	grunt.registerTask "default", [
		"compileAssets"
		"linkAssets"
		"watch"
	]
	grunt.registerTask "compileAssets", [
		"clean:dev"
		"jst:dev"
		"less:dev"
		"copy:dev"
		"coffee:dev"
	]
	grunt.registerTask "syncAssets", [
		"jst:dev"
		"less:dev"
		"sync:dev"
		"coffee:dev"
	]
	grunt.registerTask "linkAssets", [

		# Update link/script/template references in `assets` index.html
		"sails-linker:devJs"
		"sails-linker:devStyles"
		"sails-linker:devTpl"
	]

	# Build the assets into a web accessible folder.
	# (handy for phone gap apps, chrome extensions, etc.)
	grunt.registerTask "build", [
		"compileAssets"
		"linkAssets"
		"clean:build"
		"copy:build"
	]

	# When sails is lifted in production
	grunt.registerTask "prod", [
		"clean:dev"
		"jst:dev"
		"less:dev"
		"copy:dev"
		"coffee:dev"
		"concat"
		"uglify"
		"cssmin"
		"sails-linker:prodJs"
		"sails-linker:prodStyles"
		"sails-linker:devTpl"
	]
	return
