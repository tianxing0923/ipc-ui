ipcApp = angular.module 'ipcApp', ['frapontillo.bootstrap-switch']

ipcApp.directive('ngIcheck', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link: ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $($element).iCheck({
        checkboxClass: 'icheckbox_square-blue',
        radioClass: 'iradio_square-blue',
        increaseArea: '20%'
      }).on('ifClicked', (event) ->
        if ($attrs.type == 'checkbox')
          $scope.$apply( ->
            $ngModel.$setViewValue(!($ngModel.$modelValue == undefined ? false : $ngModel.$modelValue))
          )
        else
          $scope.$apply( ->
            $ngModel.$setViewValue($attrs.value);
          )
      )
  }
)

ipcApp.directive('ngSlider', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link: ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $($element).noUiSlider({
        start: [ $scope[$attrs.ngModel] ],
        step: 1,
        connect: 'lower',
        range: {
          'min': [ parseInt($attrs.min, 10) || 0 ],
          'max': [ parseInt($attrs.max, 10) || 100 ]
        }
      }).on('slide', (e, val) ->
        $scope[$attrs.ngModel] = parseInt(val)
        $scope.$apply()
      )
  }
)

ipcApp.directive('ngShelter', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link: ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $parent = $($element).parent()
      parent_pos = $parent.offset()
      parent_size = {
        width: $parent.width(),
        height: $parent.height()
      }
      minWidth = parseInt($attrs.minWidth, 10) || 50
      minHeight = parseInt($attrs.minHeight, 10) || 50
      $($element).resizable({
        containment: $parent,
        minWidth: minWidth,
        minHeight: minHeight
      }).draggable({
        containment: $parent,
        stop: (e, ui)->
          ui_size = {
            width: $(this).width(),
            height: $(this).height()
          }
          ui_pos = ui.position
          if ui_pos.left + ui_size.width > parent_size.width
            $(this).css('left', parent_size.width - ui_size.width)
          if ui_pos.top + ui_size.height > parent_size.height
            $(this).css('top', parent_size.height - ui_size.height)
      })
# [ parent_pos.left, parent_pos.top, parent_size.width - minWidth + 8, parent_size.height - minHeight + 2 ]

  }
)

ipcApp.controller 'HomeController', [
  '$scope'
  '$timeout'
  ($scope, $timeout) ->
    $scope.flip = true
]

ipcApp.controller 'SettingController', [
  '$scope'
  '$timeout'
  ($scope, $timeout) ->
    $scope.type = 'base_info'
    $scope.url = 'http://192.168.1.100/api/1.0'
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
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'UsersController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.authentication = true
]



ipcApp.controller 'DateTimeController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $('.datetime').datetimepicker()

    $http.get "#{$scope.$parent.url}/datetime.json",
      params:
        'items[]': ['timezone', 'use_ntp', 'ntp_server', 'datetime']
    .success (data) ->
      $scope.datetimeType = data.items.use_ntp.int_value
      $scope.datetime = data.items.datetime.str_value
      $scope.ntpServer = data.items.ntp_server.str_value
      $('[name="datetimeType"][value="' + $scope.datetimeType + '"]').iCheck('check')

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





ipcApp.controller 'MaintenanceController', [
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

ipcApp.controller 'ImageController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.brightness = 50
    $scope.chrominance = 30
    $scope.contrast = 80
    $scope.saturation = 0
    $scope.watermark = true
    $scope.dnr = false
    $scope.scence = 50

    $('[name="scence1"][value="' + $scope.scence + '"]').iCheck('check')
]

ipcApp.controller 'PrivacyBlockController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $('.color-input').colorpicker().on('changeColor', (e) ->
      $(this).css('background', e.color.toHex())
    )

    $scope.region = 1
    $scope.privacy_switch = true
    $scope.color = '#008def'
]

play = ->
  if window.document['vlc']
    vlc = window.document['vlc'];
  if navigator.appName.indexOf('Microsoft Internet') == -1
    if document.embeds && document.embeds['vlc']
      vlc = document.embeds['vlc'];
  else
    vlc = document.getElementById('vlc');
  targetURL = 'rtsp://192.168.1.100:8554/liveStream'
  if vlc
    vlc.playlist.items.clear()
    options = [':rtsp-tcp']
    itemId = vlc.playlist.add(targetURL,'',options)
    options = [];
    if itemId != -1
      vlc.playlist.playItem(itemId)
    else
      alert('cannot play at the moment !')

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
    $('.color-input').colorpicker().on('changeColor', (e) ->
      $(this).css('background', e.color.toHex())
    )

    $http.get "#{$scope.$parent.url}/osd.json",
      params:
        'items[]': ['datetime', 'device_name', 'comment', 'frame_rate', 'bit_rate']
    .success (data) ->
      console.log data.items
      for osd in data.items
        $scope["#{osd['name']}_display"] = osd['isshow']
        $scope["#{osd['name']}_font_size"] = osd['size']
        $scope["#{osd['name']}_left"] = osd['x']
        $scope["#{osd['name']}_top"] = osd['y']

    $scope.save = ->
      $http.put "#{$scope.$parent.url}/osd.json",
        items:
          scenario: $scope.scene
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'SzycController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    
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
      parseInt($scope.autoconf) != 0
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


ipcApp.controller 'InputController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.input = 0
    $scope.input_on = true

    times = new DateSelect('input_canvas')

    $scope.save = ->
      selected = times.getSelectedCells()
      console.log selected
]

ipcApp.controller 'OutputController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.output1_normal = true
    $scope.output1_trigger = false
    $scope.output1_period = 1000
    $scope.output2_normal = true
    $scope.output2_trigger = false
    $scope.output2_period = 2000
]

ipcApp.controller 'MotionDetectController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.sensitivity = 50
    $scope.detect_regional = [100, 100, 200, 200]
    $scope.detect_switch = true
    times = new DateSelect('montion_detect_canvas')

    $scope.save = ->
      selected = times.getSelectedCells()
      console.log selected
]

ipcApp.controller 'VideoCoverageController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.sensitivity = 70
    $scope.coverage_regional = [100, 100, 200, 200]
    $scope.coverage_switch = true
    
    times = new DateSelect('video_coverage_canvas')

    $scope.save = ->
      selected = times.getSelectedCells()
      console.log selected
]

ipcApp.controller 'EventProcessController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    
]

