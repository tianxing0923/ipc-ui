ipcApp.controller 'loginController', [
  '$scope'
  '$timeout'
  '$http'
  ($scope, $timeout, $http) ->
    $scope.username = ''
    $scope.password = ''
    $scope.language = '中文'
    
    $scope.username_msg = ''
    $scope.password_msg = ''
    $scope.login_fail_msg = ''
    $scope.uuid = Math.uuid()
    $scope.n = ''
    $scope.e = ''

    $http.get "#{window.apiUrl}/login.json",
      params:
        uuid: $scope.uuid
    .success (data) ->
      $scope.n = data.n
      $scope.e = data.e

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
      rsa = new RSAKey()
      rsa.setPublic($scope.n, $scope.e)
      pwd = hex2b64(rsa.encrypt($scope.password))
      $http.post "#{window.apiUrl}/login.json",
        params:
          username: $scope.username
          password: pwd
          uuid: $scope.uuid
      .success (data) ->
        if data.success
          setCookie('username', $scope.username)
          setCookie('password_plain', $scope.password)
          setCookie('password', pwd)
          setCookie('uuid', $scope.uuid)
          setTimeout(->
            location.href = '/'
          , 200)
          
]
