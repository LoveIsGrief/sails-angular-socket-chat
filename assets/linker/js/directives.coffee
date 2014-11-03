"use strict"

# Directives 
angular.module("mySailsApp.directives", []).directive "appVersion", [
	"version"
	(version) ->
		return (scope, elm, attrs) ->
			elm.text version
			return
]
