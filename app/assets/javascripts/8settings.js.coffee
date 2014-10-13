window.VIDEO_WIDTH = 750
window.VIDEO_HEIGHT = 560

ipcApp.controller 'SettingController', [
  '$scope'
  '$timeout'
  ($scope, $timeout) ->
    $scope.type = 'base_info'
    # $scope.url = 'http://192.168.1.217/api/1.0'
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
        'items[]': ['device_name', 'hwaddr', 'comment', 'location', 'manufacturer', 'model', 'serial', 'firmware', 'hardware']
    .success (data) ->
      $scope.serial = data.items.serial
      $scope.mac = data.items.hwaddr
      $scope.manufacturer = data.items.manufacturer
      $scope.model = data.items.model
      $scope.firmware = data.items.firmware
      $scope.hardware = data.items.hardware
      $scope.device_name = data.items.device_name
      $scope.comment = data.items.comment
      $scope.location = data.items.location

      add_watch()

    $scope.device_name_msg = ''
    $scope.comment_msg = ''
    $scope.location_msg = ''

    valid = (msg_name, value, msg) ->
      if value && value.length > 32
        $scope[msg_name] = 'Length cannot exceed 32 characters'
      else
        $scope[msg_name] = ''

    add_watch = ->
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

    get_user_list = ->
      $http.get "#{$scope.$parent.url}/users.json",
        params:
          'items[]': ['role']
      .success (data) ->
        $scope.items = data.items

    get_user_list()

    show_msg = (type, msg) ->
      $scope.ajax_msg = {
        type: type,
        content: msg
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
      $scope.add_title = '添加用户'
      $('#user_modal').modal()
      return

    $scope.show_edit_modal = (item) ->
      $scope.operate_type = 'edit'
      $scope.add_user_name = item.username
      $scope.add_password = ''
      $scope.add_role = item.role
      $scope.add_user_msg = ''
      $scope.add_title = '编辑用户'
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
      if $scope.operate_type == 'add'
        if $scope.add_password == ''
          return $scope.add_user_msg = 'Please enter the password'
        else if $scope.add_password.length > 16
          return $scope.add_user_msg = 'Password length can not exceed 16'
      if $scope.add_role == ''
        return $scope.add_user_msg = 'Please select a role'

      if $scope.operate_type == 'add'
        http_type = 'post'
        postData = {
          username: $scope.add_user_name,
          password: $scope.add_password,
          role: $scope.add_role
        }
      else
        http_type = 'put'
        postData = {
          username: $scope.add_user_name,
          role: $scope.add_role
        }
        if $scope.add_password
          postData.password = $scope.add_password
      $http[http_type]("#{$scope.$parent.url}/users.json", 
        items: [postData]
      ).success (result) ->
        if result.items && result.items.length != 0
          $('#user_modal').modal('hide')
          show_msg('alert-success', 'success')
          get_user_list()
        else
          $('#user_modal').modal('hide')
          show_msg('alert-danger', 'error')
      .error (msg) ->
        $('#user_modal').modal('hide')
        show_msg('alert-danger', 'error')

    $scope.delete_user = ->
      $.ajax({
        url: "#{$scope.$parent.url}/users.json",
        type: 'DELETE',
        data: JSON.stringify({
          items: [{
            username: $scope.current_user
          }]
        }),
        success: (data) ->
          $('#confirm_modal').modal('hide')
          show_msg('alert-success', 'delete success')
          get_user_list()
        error: (data) ->
          $('#confirm_modal').modal('hide')
          show_msg('alert-danger', 'delete error')
      })

      # $http.delete "#{$scope.$parent.url}/users.json?username=" + $scope.current_user
      # .success (msg) ->
      #   $('#confirm_modal').modal('hide')
      #   show_msg('alert-success', 'delete success')
      #   get_user_list()
      # .error (msg) ->
      #   $('#confirm_modal').modal('hide')
      #   show_msg('alert-danger', 'delete error')

    $scope.save = ->
]

ipcApp.controller 'DateTimeController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/datetime.json",
      params:
        'items[]': ['timezone', 'use_ntp', 'ntp_server', 'datetime']
    .success (data) ->
      $scope.timezone = data.items.timezone
      $scope.datetime_type = if data.items.use_ntp then '2' else '1'
      $scope.datetime = data.items.datetime
      $scope.ntp_server = data.items.ntp_server
      $('[name=datetime_type][value=' + $scope.datetime_type + ']').iCheck('check')

      add_watch()

    $scope.datetime_msg = ''
    $scope.ntp_server_msg = ''

    valid = (msg_name, value, msg) ->
      if !value
        $scope[msg_name] = 'Can not be empty'
      else if value.length > 32
        $scope[msg_name] = 'Length cannot exceed 32 characters'
      else
        $scope[msg_name] = ''

    add_watch = ->
      $scope.$watch('datetime_type', (newValue) ->
        if $scope.datetime_type == '1'
          valid('datetime_msg', $scope.datetime)
          $scope.ntp_server_msg = ''
        else if $scope.datetime_type == '2'
          valid('ntp_server_msg', $scope.ntp_server)
          $scope.datetime_msg = ''
      )
      $scope.$watch('datetime', (newValue) ->
        if $scope.datetime_type == '1'
          valid('datetime_msg', newValue)
      )
      $scope.$watch('ntp_server', (newValue) ->
        if $scope.datetime_type == '2'
          valid('ntp_server_msg', newValue)
      )

    $scope.save = ->
      if $scope.datetime_msg || $scope.ntp_server_msg
        return
      use_ntp = if $scope.datetime_type == '1' then false else true
      postData = {
        timezone: $scope.timezone,
        use_ntp: use_ntp
      }
      if use_ntp
        postData.ntp_server = $scope.ntp_server
      else
        postData.datetime = $scope.datetime
      $http.put "#{$scope.$parent.url}/datetime.json",
        items: postData
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
        'items[]': ['profile', 'flip', 'mirror', 'main_profile', 'sub_profile']
    .success (data) ->
      console.log data
      $scope.profile = data.items.profile
      $scope.flip = data.items.flip
      $scope.mirrow = data.items.mirror
      $scope.main_profile = data.items.main_profile
      $scope.sub_profile = data.items.sub_profile

      add_watch()

    $scope.valid_msg = ''

    valid = (name, value, min, max, msg) ->
      if value == null
        $scope.valid_msg = name + ' can not be empty'
        return false
      else if value == undefined
        $scope.valid_msg = name + ' must be numeric'
        return false
      else if value < min || value > max
        $scope.valid_msg = name + ' numerical range of ' + min + ' - ' + max
        return false
      else
        $scope.valid_msg = ''
        return true

    add_watch = ->
      $scope.$watch('main_profile.frame_rate', (newValue) ->
        valid('Master frame rate', newValue, 1, 30)
      )
      $scope.$watch('main_profile.bit_rate_value', (newValue) ->
        valid('Master bit rate', newValue, 128, 10240)
      )
      $scope.$watch('sub_profile.frame_rate', (newValue) ->
        valid('Slave frame rate', newValue, 1, 30)
      )
      $scope.$watch('sub_profile.bit_rate_value', (newValue) ->
        valid('Slave bit rate', newValue, 128, 10240)
      )

    isValid = ->
      if valid('Master frame rate', $scope.main_profile.frame_rate, 1, 30) &&
      valid('Master bit rate', $scope.main_profile.bit_rate_value, 128, 10240) &&
      valid('Slave frame rate', $scope.sub_profile.frame_rate, 1, 30) &&
      valid('Slave bit rate', $scope.sub_profile.bit_rate_value, 128, 10240)
        return true
      else
        return false

    $scope.save = ->
      if !isValid()
        return
      $http.put "#{$scope.$parent.url}/video.json",
        items:
          profile: $scope.profile
          flip: $scope.flip
          mirrow: $scope.mirror
          main_profile: $scope.main_profile
          sub_profile: $scope.sub_profile
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'ImageController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/image.json",
      params:
        'items[]': ['watermark','3ddnr','brightness','chrominance','contrast','saturation','scenario']
    .success (data) ->
      $scope.watermark = data.items.watermark
      $scope.dnr = data.items['3ddnr']
      $scope.brightness = data.items.brightness
      $scope.chrominance = data.items.chrominance
      $scope.contrast = data.items.contrast
      $scope.saturation = data.items.saturation
      $scope.scenario = data.items.scenario
      $('#brightness_slider').val($scope.brightness)
      $('#chrominance_slider').val($scope.chrominance)
      $('#contrast_slider').val($scope.contrast)
      $('#saturation_slider').val($scope.saturation)
      $('[name=scenario][value=' + $scope.scenario + ']').iCheck('check')

    $scope.save = ->
      $http.put "#{$scope.$parent.url}/image.json",
        items:
          watermark: $scope.watermark
          '3ddnr': $scope.dnr
          brightness: $scope.brightness
          chrominance: $scope.chrominance
          contrast: $scope.contrast
          saturation: $scope.saturation
          scenario: $scope.scenario
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'PrivacyBlockController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/privacy_block.json",
      params:
        'items[]': ['region1','region2']
    .success (data) ->
      console.log data
      $scope.region1 = data.items.region1
      $scope.region2 = data.items.region2
      $scope.region1_rect = {
        left: Math.round($scope.region1.rect.left / 1000 * VIDEO_WIDTH),
        top: Math.round($scope.region1.rect.top / 1000 * VIDEO_HEIGHT),
        width: Math.round($scope.region1.rect.width / 1000 * VIDEO_WIDTH),
        height: Math.round($scope.region1.rect.height / 1000 * VIDEO_HEIGHT)
      }
      $scope.region2_rect = {
        left: Math.round($scope.region2.rect.left / 1000 * VIDEO_WIDTH),
        top: Math.round($scope.region2.rect.top / 1000 * VIDEO_HEIGHT),
        width: Math.round($scope.region2.rect.width / 1000 * VIDEO_WIDTH),
        height: Math.round($scope.region2.rect.height / 1000 * VIDEO_HEIGHT)
      }
      $scope.current_region = 'region1'

      add_watch()

    add_watch = ->
      $scope.$watch('region1.color', (newValue) ->
        if newValue
          hex = '#' + ((1 << 24) | (parseInt(newValue.red) << 16) | (parseInt(newValue.green) << 8) | parseInt(newValue.blue)).toString(16).substr(1)
          $scope.region1_color_hex = hex.toUpperCase()
      )
      $scope.$watch('region2.color', (newValue) ->
        if newValue
          hex = '#' + ((1 << 24) | (parseInt(newValue.red) << 16) | (parseInt(newValue.green) << 8) | parseInt(newValue.blue)).toString(16).substr(1)
          $scope.region2_color_hex = hex.toUpperCase()
      )

    $scope.play_v = ->
      playVlc()

    $scope.stop_v = ->
      stopVlc()

    $scope.save = ->
      $scope.region1.rect = {
        left: Math.round($scope.region1_rect.left / VIDEO_WIDTH * 1000),
        top: Math.round($scope.region1_rect.top / VIDEO_HEIGHT * 1000),
        width: Math.round($scope.region1_rect.width / VIDEO_WIDTH * 1000),
        height: Math.round($scope.region1_rect.height / VIDEO_HEIGHT * 1000)
      }
      $scope.region2.rect = {
        left: Math.round($scope.region2_rect.left / VIDEO_WIDTH * 1000),
        top: Math.round($scope.region2_rect.top / VIDEO_HEIGHT * 1000),
        width: Math.round($scope.region2_rect.width / VIDEO_WIDTH * 1000),
        height: Math.round($scope.region2_rect.height / VIDEO_HEIGHT * 1000)
      }
      $http.put "#{$scope.$parent.url}/privacy_block.json",
        items:
          region1: $scope.region1
          region2: $scope.region2
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'DayNightModeController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/day_night_mode.json",
      params:
        'items[]': ['night_mode_threshold', 'ir_intensity']
    .success (data) ->
      console.log data
      $scope.night_mode_threshold = data.items.night_mode_threshold
      $scope.ir_intensity = data.items.ir_intensity
      $('#night_mode_threshold_slider').val($scope.night_mode_threshold)
      $('#ir_intensity_slider').val($scope.ir_intensity)

    $scope.save = ->
      $http.put "#{$scope.$parent.url}/day_night_mode.json",
        items:
          night_mode_threshold: $scope.night_mode_threshold
          ir_intensity: $scope.ir_intensity
      .success ->
        $scope.$parent.success('Save Success')
]


ipcApp.controller 'OsdController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    getOsdInfo = (name, params) ->
      $.ajax({
        url: "#{$scope.$parent.url}/osd.json",
        data: {
          items: params
        },
        success: (data) ->
          console.log data
          $scope.device_name = data.items[name].device_name
          $scope.device_name.left = ($scope.device_name.left / 10).toFixed(1)
          $scope.device_name.top = ($scope.device_name.top / 10).toFixed(1)
          $scope.comment = data.items[name].comment
          $scope.comment.left = ($scope.comment.left / 10).toFixed(1)
          $scope.comment.top = ($scope.comment.top / 10).toFixed(1)
          $scope.frame_rate = data.items[name].frame_rate
          $scope.frame_rate.left = ($scope.frame_rate.left / 10).toFixed(1)
          $scope.frame_rate.top = ($scope.frame_rate.top / 10).toFixed(1)
          $scope.bit_rate = data.items[name].bit_rate
          $scope.bit_rate.left = ($scope.bit_rate.left / 10).toFixed(1)
          $scope.bit_rate.top = ($scope.bit_rate.top / 10).toFixed(1)
          $scope.datetime = data.items[name].datetime
          $scope.datetime.left = ($scope.datetime.left / 10).toFixed(1)
          $scope.datetime.top = ($scope.datetime.top / 10).toFixed(1)
          add_watch()
          $scope.$apply()
      })

    master_params = {master: ['datetime', 'device_name', 'comment', 'frame_rate', 'bit_rate']}

    slave_params = {slave: ['datetime', 'device_name', 'comment', 'frame_rate', 'bit_rate']}

    getOsdInfo('master', master_params)

    $scope.osd_type = 0
    $scope.valid_msg = ''

    $scope.changeOsd = (type) ->
      $scope.osd_type = type
      if type == 0
        getOsdInfo('master', master_params)
      else
        getOsdInfo('slave', slave_params)

    obj = {
      'device_name': 'Device name',
      'comment': 'Comment',
      'frame_rate': 'Frame rate',
      'bit_rate': 'Bit rate',
      'datetime': 'Datetime'
    }

    add_watch = ->

      # 添加校验监听
      for name of obj
        $scope.$watch("#{name}.size", (newValue) ->
          valid_font_size(obj[this.exp.split('.size')[0]], ' font size', newValue)
        )
        $scope.$watch("#{name}.left", (newValue) ->
          valid_left_or_top(obj[this.exp.split('.left')[0]], ' left', newValue)
        )
        $scope.$watch("#{name}.top", (newValue) ->
          valid_left_or_top(obj[this.exp.split('.top')[0]], ' top', newValue)
        )

    # 校验font size
    valid_font_size = (name, field, value) ->
      if value == null
          $scope.valid_msg = name + field + ' can not be empty'
          return false
        else if value == undefined
          $scope.valid_msg = name + field + ' must be numeric'
          return false
        else if value < 1 || value > 100
          $scope.valid_msg = name + field + ' numerical range of 1 - 100'
          return false
        else
          $scope.valid_msg = ''
          return true

    # 校验left或top
    valid_left_or_top = (name, field, value) ->
      if !value
          $scope.valid_msg = name + field + ' can not be empty'
          return false
        else if isNaN(value)
          $scope.valid_msg = name + field + ' must be numeric'
          return false
        else if parseFloat(value) < 1 || parseFloat(value) > 100
          $scope.valid_msg = name + field + ' numerical range of 1 - 100'
          return false
        else
          $scope.valid_msg = ''
          return true

    isValid = ->
      for name of obj
        if !valid_font_size(obj[name], ' font size', $scope[name].size)
          return false
        else if !valid_left_or_top(obj[name], ' left', $scope[name].left)
          return false
        else if !valid_left_or_top(obj[name], ' top', $scope[name].top)
          return false
      return true

    $scope.save = ->
      if !isValid()
        return
      postData = {
        device_name: $.extend({}, $scope.device_name),
        comment: $.extend({}, $scope.comment),
        frame_rate: $.extend({}, $scope.frame_rate),
        bit_rate: $.extend({}, $scope.bit_rate),
        datetime: $.extend({}, $scope.datetime)
      }
      postData.device_name.left = parseFloat($scope.device_name.left) * 10
      postData.device_name.top = parseFloat($scope.device_name.top) * 10
      postData.comment.left = parseFloat($scope.comment.left) * 10
      postData.comment.top = parseFloat($scope.comment.top) * 10
      postData.frame_rate.left = parseFloat($scope.frame_rate.left) * 10
      postData.frame_rate.top = parseFloat($scope.frame_rate.top) * 10
      postData.bit_rate.left = parseFloat($scope.bit_rate.left) * 10
      postData.bit_rate.top = parseFloat($scope.bit_rate.top) * 10
      postData.datetime.left = parseFloat($scope.datetime.left) * 10
      postData.datetime.top = parseFloat($scope.datetime.top) * 10
      debugger
      if $scope.osd_type == 0
        data = {
          master: postData
        }
      else
        data = {
          slave: postData
        }
      $http.put "#{$scope.$parent.url}/osd.json",
        items: data
      .success ->
        $scope.$parent.success('Save Success')

]

ipcApp.controller 'SzycController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/szyc.json",
        params:
          'items[]': ['train_num', 'carriage_num', 'position_num']
      .success (data) ->
        console.log data
        $scope.train_num = data.items.train_num
        $scope.carriage_num = data.items.carriage_num
        $scope.position_num = data.items.position_num

        add_watch()

    $scope.train_num_msg = ''
    $scope.carriage_num_msg = ''
    $scope.position_num_msg = ''

    train_num_reg = /^[A-Za-z0-9]{0,7}$/
    carriage_num_reg = /^[0-9]{1,2}$/
    position_num_reg = /^[1-8]{1}$/

    valid = {
      train_num: (value) ->
        if !train_num_reg.test(value)
          $scope.train_num_msg = 'Please enter the correct train number.'
          return false
        else
          $scope.train_num_msg = ''
          return true
      carriage_num: (value) ->
        if !carriage_num_reg.test(value) || parseInt(value, 10) < 1 || parseInt(value, 10) > 32
          $scope.carriage_num_msg = 'Please enter the correct carriage number.'
          return false
        else
          $scope.carriage_num_msg = ''
          return true
      position_num: (value) ->
        if !position_num_reg.test(value)
          $scope.position_num_msg = 'Please enter the correct index no.'
          return false
        else
          $scope.position_num_msg = ''
          return true
    }

    add_watch = ->
      $scope.$watch('train_num', (newValue) ->
        valid.train_num(newValue)
      )
      $scope.$watch('carriage_num', (newValue) ->
        valid.carriage_num(newValue)
      )
      $scope.$watch('position_num', (newValue) ->
        valid.position_num(newValue)
      )

    $scope.save = ->
      if !valid.train_num($scope.train_num) || !valid.carriage_num($scope.carriage_num) ||
      !valid.position_num($scope.position_num)
        return
      console.log('valid success')
      $http.put "#{$scope.$parent.url}/szyc.json",
        items:
          train_num: $scope.train_num
          carriage_num: $scope.carriage_num
          position_num: $scope.position_num
      .success ->
        $scope.$parent.success('Save Success')
]


ipcApp.controller 'InterfaceController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/network.json",
      params:
        'items[]': ['method', 'address', 'pppoe', 'port']
    .success (data) ->
      console.log data
      $scope.method = data.items.method
      $scope.network_username = data.items.pppoe.username
      $scope.network_password = data.items.pppoe.password
      $scope.network_address = data.items.address.ipaddr
      $scope.network_netmask = data.items.address.netmask
      $scope.network_gateway = data.items.address.gateway
      $scope.network_primary_dns = data.items.address.dns1
      $scope.network_second_dns = data.items.address.dns2
      $scope.http_port = data.items.port.http

      add_watch()

    $scope.network_username_msg = ''
    $scope.network_password_msg = ''
    $scope.network_address_msg = ''
    $scope.network_netmask_msg = ''
    $scope.network_gateway_msg = ''
    $scope.network_primary_dns_msg = ''
    $scope.network_second_dns_ms = ''

    ip_reg = /^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])$/
    valid = {
      common: (name, value, msg) ->
        if value && !ip_reg.test(value)
          $scope[name] = 'Please enter the correct ' + msg
          return false
        else
          $scope[name] = ''
          return true
      common_required: (name, value, msg) ->
        if !ip_reg.test(value)
          $scope[name] = msg
          return false
        else
          $scope[name] = ''
          return true
      network_username: (value) ->
        if !value
          $scope.network_username_msg = 'Please enter the username'
          return false
        else
          $scope.network_username_msg = ''
          return true
      network_password: (value) ->
        if !value
          $scope.network_password_msg = 'Please enter the password'
          return false
        else
          $scope.network_password_msg = ''
          return true
      network_address: (value) ->
        this.common_required('network_address_msg', value, 'address')
      network_netmask: (value) ->
        this.common_required('network_netmask_msg', value, 'netmask')
      network_gateway: (value) ->
        this.common('network_gateway_msg', value, 'gateway')
      network_primary_dns: (value) ->
        this.common('network_primary_dns_msg', value, 'primary DNS')
      network_second_dns: (value) ->
        this.common('network_second_dns_msg', value, 'second DNS')
    }

    add_watch = ->
      $scope.$watch('method', (newValue) ->
        $scope.network_username_msg = ''
        $scope.network_password_msg = ''
        $scope.network_address_msg = ''
        $scope.network_netmask_msg = ''
        $scope.network_gateway_msg = ''
        $scope.network_primary_dns_msg = ''
        $scope.network_second_dns_msg = ''
      )
      $scope.$watch('network_username', (newValue) ->
        valid.network_username(newValue)
      )
      $scope.$watch('network_password', (newValue) ->
        valid.network_password(newValue)
      )
      $scope.$watch('network_address', (newValue) ->
        valid.network_address(newValue)
      )
      $scope.$watch('network_netmask', (newValue) ->
        valid.network_netmask(newValue)
      )
      $scope.$watch('network_gateway', (newValue) ->
        valid.network_gateway(newValue)
      )
      $scope.$watch('network_primary_dns', (newValue) ->
        valid.network_primary_dns(newValue)
      )
      $scope.$watch('network_second_dns', (newValue) ->
        valid.network_second_dns(newValue)
      )

    isValid = ->
      if $scope.method == 'static'
        if !valid.network_address($scope.network_address) || !valid.network_netmask($scope.network_netmask) ||
        !valid.network_gateway($scope.network_gateway) || !valid.network_primary_dns($scope.network_primary_dns) ||
        !valid.network_second_dns($scope.network_second_dns)
          return false
        return true
      else if $scope.method == 'dhcp'
        return true
      else if $scope.method == 'pppoe'
        if !valid.network_username($scope.network_username) || !valid.network_password($scope.network_password)
          return false
        return true
      return true

    $scope.canShow = ->
      $scope.method == 'pppoe'
      
    $scope.canEdit = ->
      $scope.method != 'static'

    $scope.save = ->
      if !isValid()
        return
      postData = {
        method: $scope.method
      }
      if postData.method == 'static'
        postData.address = {
          ipaddr: $scope.network_address,
          netmask: $scope.network_netmask,
          gateway: $scope.network_gateway,
          dns1: $scope.network_primary_dns,
          dns2: $scope.network_second_dns
        }
      else if postData.method == 'pppoe'
        postData.pppoe = {
          username: $scope.network_username,
          password: $scope.network_password
        }
      $http.put "#{$scope.$parent.url}/network.json",
        items: postData
      .success ->
        $scope.$parent.success('Save Success')
        if postData.method == 'static'
          location.href = 'http://' + postData.address.ipaddr + (if $scope.http_port == 80 then '' else ':' + $scope.http_port)

]

ipcApp.controller 'PortController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/network.json",
      params:
        'items[]': ['port']
    .success (data) ->
      $scope.http_port = data.items.port.http
      $scope.ftp_port = data.items.port.ftp
      $scope.rtsp_port = data.items.port.rtsp
      add_watch()

    $scope.http_port_msg = ''
    $scope.ftp_port_msg = ''
    $scope.rtsp_port_msg = ''
    $scope.common_msg = ''

    number_reg = /^[0-9]*$/
    valid = {
      common: (name, value, msg) ->
        if !value
          $scope[name] = 'Please enter the ' + msg + ' port'
          return false
        else if !number_reg.test(value)
          $scope[name] = 'Please enter the correct ' + msg + ' port'
          return false
        else
          $scope[name] = ''
          return true
      http_port: (value) ->
        this.common('http_port_msg', value, 'http')
      ftp_port: (value) ->
        this.common('ftp_port_msg', value, 'ftp')
      rtsp_port: (value) ->
        this.common('rtsp_port_msg', value, 'rtsp')
    }

    add_watch = ->
      $scope.$watch('http_port', (newValue) ->
        valid.http_port(newValue)
      )
      $scope.$watch('ftp_port', (newValue) ->
        valid.ftp_port(newValue)
      )
      $scope.$watch('rtsp_port', (newValue) ->
        valid.rtsp_port(newValue)
      )

    isValid = ->
      if !valid.http_port($scope.http_port) || !valid.ftp_port($scope.ftp_port) || !valid.rtsp_port($scope.rtsp_port)
        return false
      if $scope.http_port == $scope.ftp_port || $scope.http_port == $scope.rtsp_port ||
      $scope.ftp_port == $scope.rtsp_port
        $scope.common_msg = 'Port cannot be the same'
        return false
      $scope.common_msg = ''
      return true

    $scope.save = ->
      if !isValid()
        return
      $http.put "#{$scope.$parent.url}/network.json",
        items:
          port:
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
    $http.get "#{$scope.$parent.url}/event_input.json",
      params:
        'items[]': ['input1']
    .success (data) ->
      console.log data
      $scope.input1 = data.items.input1
      $scope.current_input = 'input1'
      $('#input1_schedules').timegantt('setSelected', $scope.input1.schedules)

    $scope.save = ->
      $http.put "#{$scope.$parent.url}/event_input.json",
        items:
          input1: $scope.input1
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'OutputController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/event_output.json",
      params:
        'items[]': ['output1', 'output2']
    .success (data) ->
      console.log data
      # $scope.output1 = data.items.output1
      $scope.output1_normal = if data.items.output1.normal == 'open' then true else false
      $scope.output1_trigger = if data.items.output1.normal == 'close' then false else true
      $scope.output1_period = data.items.output1.period
      # $scope.output2_normal = true
      # $scope.output2_trigger = false
      # $scope.output2_period = 2000
      add_watch()

    $scope.output1_period_msg = ''
    # $scope.output2_period_msg = ''

    number_reg = /^[0-9]*$/
    valid = {
      common: (name, value, msg) ->
        if !value
          $scope[name] = 'Please enter the ' + msg
          return false
        else if !number_reg.test(value) || parseInt(value) < 1 || parseInt(value) > 3600
          $scope[name] = 'Please enter the correct ' + msg
          return false
        else
          $scope[name] = ''
          return true
      output1_period: (value) ->
        this.common('output1_period_msg', value, 'output1 period')
      # output2_period: (value) ->
      #   this.common('output2_period_msg', value, 'output2 period')
    }

    add_watch = ->
      $scope.$watch('output1_normal', (newValue) ->
        $scope.output1_trigger = !newValue
      )
      $scope.$watch('output1_trigger', (newValue) ->
        $scope.output1_normal = !newValue
      )
      $scope.$watch('output1_period', (newValue) ->
        valid.output1_period(newValue)
      )
      # $scope.$watch('output2_period', (newValue) ->
      #   valid.output2_period(newValue)
      # )

    isValid = ->
      if !valid.output1_period($scope.output1_period)
      # || !valid.output2_period($scope.output2_period)
        return false
      return true

    $scope.save = ->
      if !isValid()
        return
      $http.put "#{$scope.$parent.url}/event_output.json",
        items:
          output1:
            normal: if $scope.output1_normal == true then 'open' else 'close'
            period: parseInt($scope.output1_period)
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'MotionDetectController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/event_motion.json",
      params:
        'items[]': ['region1', 'region2']
    .success (data) ->
      console.log data
      $scope.region1 = data.items.region1
      $scope.region1_rect = {
        left: Math.round($scope.region1.rect.left / 1000 * VIDEO_WIDTH),
        top: Math.round($scope.region1.rect.top / 1000 * VIDEO_HEIGHT),
        width: Math.round($scope.region1.rect.width / 1000 * VIDEO_WIDTH),
        height: Math.round($scope.region1.rect.height / 1000 * VIDEO_HEIGHT)
      }
      $scope.region2 = data.items.region2
      $scope.region2_rect = {
        left: Math.round($scope.region2.rect.left / 1000 * VIDEO_WIDTH),
        top: Math.round($scope.region2.rect.top / 1000 * VIDEO_HEIGHT),
        width: Math.round($scope.region2.rect.width / 1000 * VIDEO_WIDTH),
        height: Math.round($scope.region2.rect.height / 1000 * VIDEO_HEIGHT)
      }
      $scope.current_region = 'region1'
      $('#region1_sensitivity').val($scope.region1.sensitivity)
      $('#region2_sensitivity').val($scope.region2.sensitivity)
      $('#region1_schedules').timegantt('setSelected', $scope.region1.schedules)
      $('#region2_schedules').timegantt('setSelected', $scope.region2.schedules)

    $scope.save = ->
      $scope.region1.rect = {
        left: Math.round($scope.region1_rect.left / VIDEO_WIDTH * 1000),
        top: Math.round($scope.region1_rect.top / VIDEO_HEIGHT * 1000),
        width: Math.round($scope.region1_rect.width / VIDEO_WIDTH * 1000),
        height: Math.round($scope.region1_rect.height / VIDEO_HEIGHT * 1000)
      }
      $scope.region2.rect = {
        left: Math.round($scope.region2_rect.left / VIDEO_WIDTH * 1000),
        top: Math.round($scope.region2_rect.top / VIDEO_HEIGHT * 1000),
        width: Math.round($scope.region2_rect.width / VIDEO_WIDTH * 1000),
        height: Math.round($scope.region2_rect.height / VIDEO_HEIGHT * 1000)
      }
      $http.put "#{$scope.$parent.url}/event_motion.json",
        items:
          region1: $scope.region1
          region2: $scope.region2
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'VideoCoverageController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/event_cover.json",
      params:
        'items[]': ['region1', 'region2']
    .success (data) ->
      console.log data
      $scope.region1 = data.items.region1
      $scope.region1_rect = {
        left: Math.round($scope.region1.rect.left / 1000 * VIDEO_WIDTH),
        top: Math.round($scope.region1.rect.top / 1000 * VIDEO_HEIGHT),
        width: Math.round($scope.region1.rect.width / 1000 * VIDEO_WIDTH),
        height: Math.round($scope.region1.rect.height / 1000 * VIDEO_HEIGHT)
      }
      $scope.region2 = data.items.region2
      $scope.region2_rect = {
        left: Math.round($scope.region2.rect.left / 1000 * VIDEO_WIDTH),
        top: Math.round($scope.region2.rect.top / 1000 * VIDEO_HEIGHT),
        width: Math.round($scope.region2.rect.width / 1000 * VIDEO_WIDTH),
        height: Math.round($scope.region2.rect.height / 1000 * VIDEO_HEIGHT)
      }
      $scope.current_region = 'region1'
      $('#region1_sensitivity').val($scope.region1.sensitivity)
      $('#region2_sensitivity').val($scope.region2.sensitivity)
      $('#region1_schedules').timegantt('setSelected', $scope.region1.schedules)
      $('#region2_schedules').timegantt('setSelected', $scope.region2.schedules)

    $scope.save = ->
      $scope.region1.rect = {
        left: Math.round($scope.region1_rect.left / VIDEO_WIDTH * 1000),
        top: Math.round($scope.region1_rect.top / VIDEO_HEIGHT * 1000),
        width: Math.round($scope.region1_rect.width / VIDEO_WIDTH * 1000),
        height: Math.round($scope.region1_rect.height / VIDEO_HEIGHT * 1000)
      }
      $scope.region2.rect = {
        left: Math.round($scope.region2_rect.left / VIDEO_WIDTH * 1000),
        top: Math.round($scope.region2_rect.top / VIDEO_HEIGHT * 1000),
        width: Math.round($scope.region2_rect.width / VIDEO_WIDTH * 1000),
        height: Math.round($scope.region2_rect.height / VIDEO_HEIGHT * 1000)
      }
      $http.put "#{$scope.$parent.url}/event_cover.json",
        items:
          region1: $scope.region1
          region2: $scope.region2
      .success ->
        $scope.$parent.success('Save Success')
]

ipcApp.controller 'EventProcessController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $http.get "#{$scope.$parent.url}/event_proc.json",
      params:
        'items[]': ['input1', 'motion', 'cover']
    .success (data) ->
      console.log data
      $scope.input1 = data.items.input1
      $scope.motion = data.items.motion
      $scope.cover = data.items.cover

    $scope.save = ->
      console.log $scope.input1, $scope.motion, $scope.cover
      $http.put "#{$scope.$parent.url}/event_proc.json",
        items:
          input1: $scope.input1
          motion: $scope.motion
          cover: $scope.cover
      .success ->
        $scope.$parent.success('Save Success')
]

