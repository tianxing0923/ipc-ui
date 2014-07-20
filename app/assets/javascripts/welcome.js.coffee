$ ->
  $('ui.nav.nav-pills.nav-stacked li a').click ->
    $('ui.nav.nav-pills.nav-stacked li.active').removeClass('active')
    $(this).parent('li').addClass('active')

  $('.datetime').datetimepicker()
  $(".switch").bootstrapSwitch()
  $('.color-pick').colorpicker()

ipcApp = angular.module 'ipcApp', []

ipcApp.controller 'SettingController', [
  '$scope'
  ($scope) ->
    $scope.type = 'base_info'
    $scope.url = 'http://ipcbf.info/api/1.0'
    $scope.changeType = (type) ->
      $scope.type = type
]

ipcApp.controller 'BaseInfoController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/base_info.json",
        params:
          items: ['device_name', 'comment']
    .success (data) ->
      console.log data
    
    $scope.serial_no = '假的serial no'
    $scope.mac = '假的mac'
    $scope.device_name = ''
    $scope.comment = ''
]

ipcApp.controller 'UsersController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    console.log 'users'
]

ipcApp.controller 'DateTimeController', [
  '$scope'
  '$http'
  ($scope, $http) ->

]

ipcApp.controller 'UpgradeController', [
  '$scope'
  '$http'
  ($scope, $http) ->

]

ipcApp.controller 'StreamController', [
  '$scope'
  '$http'
  ($scope, $http) ->

]

ipcApp.controller 'SceneController', [
  '$scope'
  '$http'
  ($scope, $http) ->

]

ipcApp.controller 'OsdController', [
  '$scope'
  '$http'
  ($scope, $http) ->

]

ipcApp.controller 'InterfaceController', [
  '$scope'
  '$http'
  ($scope, $http) ->

]

ipcApp.controller 'PortController', [
  '$scope'
  '$http'
  ($scope, $http) ->

]
