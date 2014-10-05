ipcApp.controller 'HomeController', [
  '$scope'
  '$timeout'
  ($scope, $timeout) ->
    $scope.current_stream = 'master'
    $scope.microphone = 50
    $scope.volume = 40

    $scope.change_stream = (stream) ->
      $scope.current_stream = stream
    
]