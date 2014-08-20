$ ->
  $('ui.nav.nav-pills.nav-stacked li a').click ->
    $('ui.nav.nav-pills.nav-stacked li.active').removeClass('active')
    $(this).parent('li').addClass('active')

  $('.datetime').datetimepicker()
  $('.color-pick').colorpicker()

ipcApp = angular.module 'ipcApp', ['frapontillo.bootstrap-switch']

ipcApp.controller 'SettingController', [
  '$scope'
  '$timeout'
  ($scope, $timeout) ->
    $scope.type = 'interface'
    $scope.url = 'http://ipcbf.info/api/1.0'
    $scope.message_type = 0
    $scope.message = ''
    timer = null
    
    $scope.changeType = (type) ->
      $scope.type = type
      
    $scope.success = (message) ->
      $scope.message_type = 1
      $scope.message = message
      $timeout.cancel timer
      timer = $timeout ->
        $scope.message_type = 0
      , 3000
    
    $scope.error = (message) ->
      $scope.message_type = 2
      $scope.message = message
      $timeout.cancel timer
      timer = $timeout ->
        $scope.message_type = 0
      , 3000
]

ipcApp.controller 'BaseInfoController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/base_info.json",
      params:
        'items[]': ['device_name', 'comment', 'location', 'manufacturer', 'model', 'serial', 'firmware', 'hardware']
    .success (data) ->
      $scope.device_name = data.items.device_name
      $scope.comment = data.items.comment
      $scope.serial = data.items.serial
      $scope.location = data.items.location
      $scope.manufacturer = data.items.manufacturer
      $scope.model = data.items.model
      $scope.firmware = data.items.firmware
      $scope.hardware = data.items.hardware
      
    $scope.save = ->
      $http.put "#{$scope.$parent.url}/base_info.json",        
        items:
          device_name: $scope.device_name
          comment: $scope.comment
          location: $scope.location
          manufacturer: $scope.manufacturer
          model: $scope.model
          firmware: $scope.firmware
          hardware: $scope.hardware
          serial: $scope.serial
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'UsersController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    
]



ipcApp.controller 'DateTimeController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/datetime.json",
      params:
        'items[]': ['timezone', 'use_ntp', 'ntp_server', 'datetime']
    .success (data) ->
      $scope.datetimeType = data.items.use_ntp.int_value
      $scope.datetime = data.items.datetime.str_value
      $scope.ntpServer = data.items.ntp_server.str_value

    $scope.save = ->
      $http.put "#{$scope.$parent.url}/datetime.json",
        items:
          timezone:
            int_value: 1
            str_value: ''
          use_ntp:
            int_value: $scope.datetimeType
            str_value: ''
          ntp_server:
            int_value: if $scope.datetimeType == 0 then 0 else 1
            str_value: $scope.ntpServer
          datetime:
            int_value: if $scope.datetimeType == 0 then 1 else 0
            str_value: $scope.datetime
      .success ->
        $scope.$parent.success('Save Success')
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
    $http.get "#{$scope.$parent.url}/video.json",
      params:
        'items[]': ['profile', 'flip', 'quanlity', 'frame_rate', 'bit_rate', 'bit_rate_value']
    .success (data) ->
      $scope.stream_profile = data.items.profile
      $scope.flip = data.items.flip
      $scope.quanlity = data.items.quanlity
      $scope.frame_rate = data.items.frame_rate
      $scope.bit_rate = data.items.bit_rate
      $scope.bit_rate_value = data.items.bit_rate_value

    $scope.save = ->
      console.log $scope.flip
      $http.put "#{$scope.$parent.url}/video.json",
        items:
          profile: $scope.stream_profile
          flip: if $scope.flip then 1 else 0
          quanlity: parseInt($scope.quanlity)
          frame_rate: parseInt($scope.frame_rate)
          bit_rate: parseInt($scope.bit_rate)
          bit_rate_value: parseInt($scope.bit_rate_value)
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'SceneController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/scene.json",
      params:
        'items[]': ['scenario']
    .success (data) ->
      $scope.scene = data.items.scenario

    $scope.save = ->
      $http.put "#{$scope.$parent.url}/scene.json",
        items:
          scenario: $scope.scene
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'OsdController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/scene.json",
      params:
        'items[]': ['datetime', 'device_name', 'comment', 'frame_rate', 'bit_rate']
    .success (data) ->
      for osd in data.items
        $scope["#{osd['name']}_display"] = osd['isshow']
        $scope["#{osd['name']}_font_size"] = osd['size']

    $scope.save = ->
      $http.put "#{$scope.$parent.url}/scene.json",
        items:
          scenario: $scope.scene
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'InterfaceController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/network.json",
      params:
        'items[]': ['autoconf', 'address', 'pppoe']
    .success (data) ->
      console.log data.items
      $scope.autoconf = data.items.autoconf
      $scope.network_username = data.items.pppoe.username
      $scope.network_password = data.items.pppoe.password

      $scope.network_address = data.items.address.ipaddr
      $scope.network_netmask = data.items.address.netmask
      $scope.network_gateway = data.items.address.gateway
      $scope.network_primary_dns = data.items.address.dns1
      $scope.network_second_dns = data.items.address.dns2

    $scope.save = ->
      $http.put "#{$scope.$parent.url}/network.json",
        items:
          scenario: $scope.scene
      .success ->
        $scope.$parent.success('Save Success')
        
    $scope.canShow = ->
      parseInt($scope.autoconf) == 2
      
    $scope.canEdit = ->
      parseInt($scope.autoconf) == 1
]

ipcApp.controller 'PortController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/network.json",
      params:
        'items[]': ['server_port']
    .success (data) ->
      console.log data.items.server_port
      $scope.http_port = data.items.server_port.http
      $scope.rtsp_port = data.items.server_port.rtsp

    $scope.save = ->
      $http.put "#{$scope.$parent.url}/network.json",
        items:
          server_port:
            http: parseInt($scope.http_port)
            rtsp: parseInt($scope.rtsp_port)
      .success ->
        $scope.$parent.success('Save Success')
]
