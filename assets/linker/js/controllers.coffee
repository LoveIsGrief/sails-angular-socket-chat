"use strict"

# Controllers 
angular.module("mySailsApp.controllers", []).controller "MyCtrl1", [
	"$scope"
	($scope) ->
		$scope.name = "Someone"
]
