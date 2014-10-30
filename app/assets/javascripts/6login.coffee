ipcApp.controller 'loginController', [
  '$scope'
  '$timeout'
  '$http'
  ($scope, $timeout, $http) ->
    $scope.username = ''
    $scope.password = ''
    $scope.language = '简体中文'
    
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

    $scope.user_keydown = (e) ->
      if e.which == 13
        $scope.login()

    $scope.login = ->
      if !valid.username($scope.username) || !valid.password($scope.password)
        return
      pwd = CryptoJS.SHA1($scope.password).toString()
      $http.post "#{window.apiUrl}/login.json",
        username: $scope.username
        password: pwd
      .success (data) ->
        if data.success == true
          setCookie('username', $scope.username)
          setCookie('userrole', data.role)
          setCookie('token', data.token)
          setTimeout(->
            location.href = '/home'
          , 200)
        else
          $scope.login_fail_msg = '用户名或密码错误'
]
