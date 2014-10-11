ipcApp.controller 'SystemInfoController', [
  '$scope'
  '$timeout'
  ($scope, $timeout) ->
    $scope.cpu = ''
    $scope.memory = ''
    $scope.network = ''
    
]