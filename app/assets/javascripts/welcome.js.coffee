play = ->
  if window.document['vlc']
    vlc = window.document['vlc'];
  if navigator.appName.indexOf('Microsoft Internet') == -1
    if document.embeds && document.embeds['vlc']
      vlc = document.embeds['vlc'];
  else
    vlc = document.getElementById('vlc');
  if vlc
    vlc.MRL = "rtsp://192.168.1.100:8554/liveStream";
    vlc.playlist.stop();
    vlc.playlist.play();

# ipcApp = angular.module 'ipcApp', ['frapontillo.bootstrap-switch']
ipcApp = angular.module 'ipcApp', []

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
      if $attrs.value == $scope[$attrs.ngModel]
        $($element).iCheck('check')
  }
)

ipcApp.directive('ngBswitch', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link: ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $el = $($element)
      $el.bootstrapSwitch().on('switchChange.bootstrapSwitch', (e, state) ->
        $scope.$apply( ->
          $ngModel.$setViewValue(state);
        )
      )
      if $scope[$attrs.ngModel]
        $el.bootstrapSwitch('state', true, true)
      $scope.$watch($attrs.ngModel, (newValue) ->
        $el.bootstrapSwitch('state', newValue || false, true);
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
        $scope.$apply( ->
          $ngModel.$setViewValue(parseInt(val));
        )
      )
  }
)

ipcApp.directive('ngColor', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link: ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $el = $($element)
      $el.colorpicker().on('changeColor', (e) ->
        $scope[$attrs.ngModel] = e.color.toHex()
        $el.css('background', e.color.toHex())
      )
      if $scope[$attrs.ngModel]
        $el.colorpicker('setValue', $scope[$attrs.ngModel])
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
      parent_size = {
        width: $parent.width(),
        height: $parent.height()
      }
      rect = $scope[$attrs.ngModel]
      $($element).css({
        left: rect.x,
        top: rect.y,
        width: rect.width,
        height: rect.height
      }).resizable({
        containment: $parent,
        minWidth: parseInt($attrs.minWidth, 10) || 50,
        minHeight: parseInt($attrs.minHeight, 10) || 50,
        stop: (e, ui) ->
          rect.width = ui.size.width
          rect.height = ui.size.height
          $scope.$apply( ->
            $ngModel.$setViewValue(rect)
          )
      }).draggable({
        containment: $parent,
        stop: (e, ui) ->
          if ui.position.left + rect.width > parent_size.width
            rect.x = parent_size.width - rect.width
            $(this).css('left', rect.x)
          if ui.position.top + rect.height > parent_size.height
            rect.y = parent_size.height - rect.height
            $(this).css('top', rect.y)
          $scope.$apply( ->
            $ngModel.$setViewValue({
              x: rect.y,
              y: rect.y,
              width: rect.width,
              height: rect.height
            })
          )
      })
  }
)

ipcApp.directive('ngDatetime', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link: ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $($element).datetimepicker()
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
      $scope.serial = data.items.serial
      $scope.mac = data.items.mac
      $scope.manufacturer = data.items.manufacturer
      $scope.model = data.items.model
      $scope.firmware = data.items.firmware
      $scope.hardware = data.items.hardware
      $scope.device_name = data.items.device_name
      $scope.comment = data.items.comment
      $scope.location = data.items.location

    $scope.device_name_msg = ''
    $scope.comment_msg = ''
    $scope.location_msg = ''

    valid = (msg_name, value, msg) ->
      if value && value.length > 32
        $scope[msg_name] = 'Length cannot exceed 32 characters'
      else
        $scope[msg_name] = ''

    $scope.$watch('device_name', (newValue) ->
      if !newValue
        $scope.device_name_msg = 'Can not be empty'
      else if newValue.length > 32
        $scope.device_name_msg = 'Length cannot exceed 32 characters'
      else
        $scope.device_name_msg = ''
    )
    $scope.$watch('comment', (newValue) ->
      valid('comment_msg', newValue)
    )
    $scope.$watch('location', (newValue) ->
      valid('location_msg', newValue)
    )

    $scope.save = ->
      if $scope.device_name_msg || $scope.comment_msg || $scope.location_msg
        return
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
    $scope.operate_type = ''
    $scope.authentication = true
    $scope.add_user_name = ''
    $scope.add_password = ''
    $scope.add_role = 'user'
    $scope.add_user_msg = ''
    $scope.current_user = ''
    $scope.items = []

    get_user_list = ->
      # $http.get "#{$scope.$parent.url}/user_list.json"
      # .success (data) ->
      #   $scope.items = data
      $scope.items = [
        {username: 'tangc', password: '123', role: 'administrator'},
        {username: 'tianx', password: '456', role: 'user'}
      ]

    get_user_list()

    show_msg = (type, msg) ->
      $scope.ajax_msg = {
        type: type,
        content: 'Success'
      }
      $('#msg_modal').modal()
      setTimeout(->
        $('#msg_modal').modal('hide')
      , 2000)

    $scope.show_add_modal = ->
      $scope.operate_type = 'add'
      $scope.add_user_name = ''
      $scope.add_password = ''
      $scope.add_role = 'user'
      $scope.add_user_msg = ''
      $('#user_modal').modal()
      return

    $scope.show_edit_modal = (item) ->
      $scope.operate_type = 'edit'
      $scope.add_user_name = item.username
      $scope.add_password = item.password
      $scope.add_role = item.role
      $scope.add_user_msg = ''
      $('#user_modal').modal()
      return

    $scope.show_delete_modal = (item) ->
      $scope.operate_type = 'delete'
      $scope.current_user = item.username
      $('#confirm_modal').modal()
      return

    $scope.add_or_edit_user = ->
      reg = /^\w-+|$/
      if $scope.add_user_name == ''
        return $scope.add_user_msg = 'Please enter the username'
      else if $scope.add_user_name.length > 16 || !reg.test($scope.add_user_name)
        return $scope.add_user_msg = 'Please enter the correct user name'
      else if $scope.add_password == ''
        return $scope.add_user_msg = 'Please enter the password'
      else if $scope.add_password.length > 16
        return $scope.add_user_msg = 'Password length can not exceed 16'
      else if $scope.add_role == ''
        return $scope.add_user_msg = 'Please select a role'
      $http.put "#{$scope.$parent.url}/#{$scope.operate_type}_user.json",        
        user_name: $scope.add_user_name
        password: $scope.add_password
        role: $scope.add_role
      .success (msg) ->
        $('#user_modal').modal('hide')
        show_msg('alert-success', msg)
        get_user_list()
      .error (msg) ->
        $('#user_modal').modal('hide')
        show_msg('alert-danger', msg)

    $scope.delete_user = ->
      $http.put "#{$scope.$parent.url}/#{$scope.operate_type}_user.json",
        user_name: $scope.current_user
      .success (msg) ->
        $('#confirm_modal').modal('hide')
        show_msg('alert-success', msg)
        get_user_list()
      .error (msg) ->
        $('#confirm_modal').modal('hide')
        show_msg('alert-danger', msg)

    $scope.save = ->
]

ipcApp.controller 'DateTimeController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    # $http.get "#{$scope.$parent.url}/datetime.json",
    #   params:
    #     'items[]': ['timezone', 'use_ntp', 'ntp_server', 'datetime']
    # .success (data) ->
    #   $scope.timezone = data.items.timezone
    #   $scope.datetime_type = data.items.use_ntp.int_value
    #   $scope.datetime = data.items.datetime.str_value
    #   $scope.ntp_server = data.items.ntp_server.str_value
    $scope.datetime_type = '1'
    $scope.datetime = '2014'
    $scope.ntp_server = ''

    $scope.datetime_msg = ''
    $scope.ntp_server_msg = ''

    valid = (msg_name, value, msg) ->
      if !value
        $scope[msg_name] = 'Can not be empty'
      else if value.length > 32
        $scope[msg_name] = 'Length cannot exceed 32 characters'
      else
        $scope[msg_name] = ''

    $scope.$watch('datetime_type', (newValue) ->
      if $scope.datetime_type == '0'
        valid('datetime_msg', $scope.datetime)
        $scope.ntp_server_msg = ''
      else if $scope.datetime_type == '1'
        valid('ntp_server_msg', $scope.ntp_server)
        $scope.datetime_msg = ''
    )
    $scope.$watch('datetime', (newValue) ->
      if $scope.datetime_type == '0'
        valid('datetime_msg', newValue)
    )
    $scope.$watch('ntp_server', (newValue) ->
      if $scope.datetime_type == '1'
        valid('ntp_server_msg', newValue)
    )

    $scope.save = ->
      console.log $scope.datetime, $scope.ntp_server
      if $scope.datetime_msg || $scope.ntp_server_msg
        return
      $http.put "#{$scope.$parent.url}/datetime.json",
        items:
          timezone:
            int_value: 1
            str_value: ''
          use_ntp:
            int_value: $scope.datetime_type
            str_value: ''
          ntp_server:
            int_value: if $scope.datetime_type == '0' then 0 else 1
            str_value: $scope.ntp_server
          datetime:
            int_value: if $scope.datetime_type == '0' then 1 else 0
            str_value: $scope.datetime
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'MaintenanceController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.operate_type = ''
    $scope.confirm_content = ''
    $scope.upgrading = false
    $scope.progress_val = 0

    show_confirm = ->
      $('#confirm_modal').modal()

    hide_confirm = ->
      $('#confirm_modal').modal('hide')

    $scope.soft_reset = ->
      $scope.operate_type = 'soft_reset'
      $scope.confirm_content = 'Are you sure you want to soft reset ?'
      show_confirm()

    $scope.hard_reset = ->
      $scope.operate_type = 'hard_reset'
      $scope.confirm_content = 'Are you sure you want to hard reset ?'
      show_confirm()

    $scope.reboot = ->
      $scope.operate_type = 'reboot'
      $scope.confirm_content = 'Are you sure you want to reboot ?'
      show_confirm()

    $scope.reset_or_reboot = ->
      $http.put "#{$scope.$parent.url}/#{$scope.operate_type}.json"
      .success (msg) ->
        hide_confirm()
        $scope.$parent.success('Success')
      .error (msg) ->
        hide_confirm()
        $scope.$parent.error('Error')

    $scope.upload_file = ->
      $scope.upgrading = true
      temp = setInterval(->
        $scope.progress_val = $scope.progress_val + 10
        $scope.$apply()
        if $scope.progress_val == 100
          clearInterval(temp)
      , 1000)
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
    $scope.scence = '50'
]

ipcApp.controller 'PrivacyBlockController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.region = 1
    $scope.privacy_switch = true
    $scope.shelter_color = '#008def'
    $scope.coverage_regional = {
      x: 200,
      y: 150,
      width: 300,
      height: 100
    }

    $scope.play_v = ->
      play()

    $scope.stop_v = ->
      if window.document['vlc']
        vlc = window.document['vlc'];
      if navigator.appName.indexOf('Microsoft Internet') == -1
        if document.embeds && document.embeds['vlc']
          vlc = document.embeds['vlc'];
      else
        vlc = document.getElementById('vlc');
      if vlc
        vlc.playlist.stop();

    $scope.save = ->
      console.log($scope.shelter_color)
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
    $http.get "#{$scope.$parent.url}/osd.json",
      params:
        'items[]': ['datetime', 'device_name', 'comment', 'frame_rate', 'bit_rate']
    .success (data) ->
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
    $scope.train_no = '123123'
    $scope.carriage_no = 'SDFSDF'
    $scope.index_no = '12313'

    $scope.save = ->

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
      $scope.http_port = data.items.server_port.http
      $scope.ftp_port = data.items.server_port.ftp
      $scope.rtsp_port = data.items.server_port.rtsp

    $scope.http_port_msg = ''
    $scope.ftp_port_msg = ''
    $scope.rtsp_port_msg = ''

    valid = (msg_name, value) ->
      reg = /^[0-9]*$/
      if value && !reg.test(value)
        $scope[msg_name] = 'Please enter number'
      else
        $scope[msg_name] = ''

    $scope.$watch('http_port', (newValue) ->
      valid('http_port_msg', newValue)
    )
    $scope.$watch('ftp_port', (newValue) ->
      valid('ftp_port_msg', newValue)
    )
    $scope.$watch('rtsp_port', (newValue) ->
      valid('rtsp_port_msg', newValue)
    )

    $scope.save = ->
      if $scope.http_port_msg || $scope.ftp_port_msg || $scope.rtsp_port_msg
        return
      $http.put "#{$scope.$parent.url}/network.json",
        items:
          server_port:
            http: parseInt($scope.http_port, 10)
            ftp: parseInt($scope.ftp_port, 10)
            rtsp: parseInt($scope.rtsp_port, 10)
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
    $scope.detect_regional = {
      x: 100,
      y: 100,
      width: 200,
      height: 200
    }
    $scope.detect_switch = true
    times = new DateSelect('montion_detect_canvas')

    $scope.save = ->
      selected = times.getSelectedCells()
      console.log $scope.detect_regional
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

