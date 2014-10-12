ipcApp.controller 'loginController', [
  '$scope'
  '$timeout'
  ($scope, $timeout) ->
    $scope.username = ''
    $scope.password = ''
    $scope.language = '中文'
    
    $scope.username_msg = ''
    $scope.password_msg = ''
    $scope.login_fail_msg = ''

    valid = {
      username: (value) ->
        if value
          $scope.username_msg = ''
          return true
        else
          $scope.username_msg = 'Please enter username'
          return false
      password: (value) ->
        if value
          $scope.password_msg = ''
          return true
        else
          $scope.password_msg = 'Please enter password'
          return false
    }

    $scope.valid_username = ->
      valid.username($scope.username)
      $scope.login_fail_msg = ''

    $scope.valid_password = ->
      valid.password($scope.password)
      $scope.login_fail_msg = ''

    $scope.change_language = (value) ->
      $scope.language = value

    $scope.login = ->
      if !valid.username($scope.username) || !valid.password($scope.password)
        return
      console.log 'success'
]