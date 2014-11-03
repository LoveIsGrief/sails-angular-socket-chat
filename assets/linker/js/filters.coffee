"use strict"

# Filters 
angular.module("mySailsApp.filters", []).filter "interpolate", [
	"version"
	(version) ->
		return (text) ->
			String(text).replace /\%VERSION\%/g, version
]
