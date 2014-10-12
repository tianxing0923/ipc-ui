ipcApp.controller 'SystemInfoController', [
  '$scope'
  '$timeout'
  ($scope, $timeout) ->
    $scope.cpu = Math.floor(Math.random() * 100)
    $scope.memory = Math.floor(Math.random() * 100)
    $scope.network = Math.floor(Math.random() * 100)
    
    $scope.changeVal = ->
      $scope.cpu = Math.floor(Math.random() * 100)
      $scope.memory = Math.floor(Math.random() * 100)
      $scope.network = Math.floor(Math.random() * 100)
]