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

    add_watch = ->
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

    add_watch()

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
    # $http.get "#{$scope.$parent.url}/video.json",
    #   params:
    #     'items[]': ['profile', 'flip', 'quanlity', 'frame_rate', 'bit_rate', 'bit_rate_value']
    # .success (data) ->
    #   $scope.stream_profile = data.items.profile
    #   $scope.flip = data.items.flip
    #   $scope.mirrow = true
    #   $scope.quanlity = data.items.quanlity
    #   $scope.frame_rate = data.items.frame_rate
    #   $scope.bit_rate = data.items.bit_rate
    #   $scope.bit_rate_value = data.items.bit_rate_value

    $scope.stream_profile = 1
    $scope.flip = false
    $scope.mirrow = true
    $scope.quanlity = 1
    $scope.frame_rate = 30
    $scope.bit_rate = 1
    $scope.bit_rate_value = 1024
    $scope.slave_quanlity = 4
    $scope.slave_frame_rate = 20
    $scope.slave_bit_rate = 0
    $scope.slave_bit_rate_value = 512

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
      $scope.$watch('frame_rate', (newValue) ->
        valid('Master frame rate', newValue, 1, 30)
      )
      $scope.$watch('bit_rate_value', (newValue) ->
        valid('Master bit rate', newValue, 128, 10240)
      )
      $scope.$watch('slave_frame_rate', (newValue) ->
        valid('Slave frame rate', newValue, 1, 30)
      )
      $scope.$watch('slave_bit_rate_value', (newValue) ->
        valid('Slave bit rate', newValue, 128, 10240)
      )

    add_watch()

    isValid = ->
      if valid('Master frame rate', $scope.frame_rate, 1, 30) && valid('Master bit rate', $scope.bit_rate_value, 128, 10240) && valid('Slave frame rate', $scope.slave_frame_rate, 1, 30) && valid('Slave bit rate', $scope.slave_bit_rate_value, 128, 10240)
        return true
      else
        return false

    $scope.save = ->
      if !isValid()
        return
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
      playVlc()

    $scope.stop_v = ->
      stopVlc()

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
    getOsdInfo = (params) ->
      $http.get "#{$scope.$parent.url}/osd.json",
        params:
          'items[]': params
      .success (data) ->
        console.log data
        for osd in data.items
          name = osd['name'].split(':')[1]
          $scope["#{name}_display"] = osd['isshow']
          $scope["#{name}_font_size"] = osd['size']
          $scope["#{name}_left"] = osd['left'] / 10
          $scope["#{name}_top"] = osd['top'] / 10
          $scope["#{name}_color"] = {
            a: osd['color'].alpha,
            b: osd['color'].blue,
            g: osd['color'].green,
            r: osd['color'].red,
          } 

    master_params = ['master:datetime', 'master:device_name', 'master:comment', 'master:frame_rate',
      'master:bit_rate', 'master:color']

    slave_params = ['slave:datetime', 'slave:device_name', 'slave:comment', 'slave:frame_rate',
      'slave:bit_rate', 'slave:color']

    getOsdInfo(master_params)

    $scope.osd_type = 0
    $scope.valid_msg = ''

    $scope.changeOsd = (type) ->
      $scope.osd_type = type
      if type = 0
        getOsdInfo(master_params)
      else
        getOsdInfo(slave_params)

    obj = {
      'device_name': 'Device name',
      'comment': 'Comment',
      'frame_rate': 'Frame rate',
      'bit_rate': 'Bit rate',
      'datetime': 'Datetime'
    }

    # 添加校验监听
    for name of obj
      $scope.$watch("#{name}_font_size", (newValue) ->
        valid_font_size(obj[this.exp.split('_font_size')[0]], ' font size', newValue)
      )
      $scope.$watch("#{name}_left", (newValue) ->
        valid_left_or_top(obj[this.exp.split('_left')[0]], ' left', newValue)
      )
      $scope.$watch("#{name}_top", (newValue) ->
        valid_left_or_top(obj[this.exp.split('_top')[0]], ' top', newValue)
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
          $scope.valid_msg = name + field + ' numerical range of ' + min + ' - ' + max
          return false
        else
          $scope.valid_msg = ''
          return true

    # 校验left或top
    valid_left_or_top = (name, field, value) ->
      if value == null
          $scope.valid_msg = name + field + ' left can not be empty'
          return false
        else if value == undefined
          $scope.valid_msg = name + field + ' must be numeric'
          return false
        else if value < 1 || value > 100
          $scope.valid_msg = name + field + ' numerical range of ' + min + ' - ' + max
          return false
        else
          $scope.valid_msg = ''
          return true

    isValid = ->
      for name of obj
        if !valid_font_size(obj[name], ' font size', $scope[name + '_font_size'])
          return false
        else if !valid_left_or_top(obj[name], ' left', $scope[name + '_left'])
          return false
        else if !valid_left_or_top(obj[name], ' top', $scope[name + '_top'])
          return false
      return true

    $scope.save = ->
      if !isValid()
        return

]

ipcApp.controller 'SzycController', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.train_no = '1231213'
    $scope.carriage_no = '12'
    $scope.index_no = '5'

    $scope.train_no_msg = ''
    $scope.carriage_no_msg = ''
    $scope.index_no_msg = ''

    train_no_reg = /^[A-Za-z0-9]{0,7}$/
    carriage_no_reg = /^[0-9]{1,2}$/
    index_no_reg = /^[1-8]{1}$/

    add_watch = ->
      $scope.$watch('train_no', (newValue) ->
        if !train_no_reg.test(newValue)
          $scope.train_no_msg = 'Please enter the correct train no.'
        else
          $scope.train_no_msg = ''
      )
      $scope.$watch('carriage_no', (newValue) ->
        if !carriage_no_reg.test(newValue) || parseInt(newValue, 10) < 1 || parseInt(newValue, 10) > 32
          $scope.carriage_no_msg = 'Please enter the correct carriage no.'
        else
          $scope.carriage_no_msg = ''
      )
      $scope.$watch('index_no', (newValue) ->
        if !index_no_reg.test(newValue)
          $scope.index_no_msg = 'Please enter the correct index no.'
        else
          $scope.index_no_msg = ''
      )

    add_watch()

    $scope.save = ->
      if $scope.train_no_msg || $scope.carriage_no_msg || $scope.index_no_msg
        return
      console.log('valid success')
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
      $scope.$watch('autoconf', (newValue) ->
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
      method = parseInt($scope.autoconf)
      if method == 0
        if !valid.network_address($scope.network_address) || !valid.network_netmask($scope.network_netmask) ||
        !valid.network_gateway($scope.network_gateway) || !valid.network_primary_dns($scope.network_primary_dns) ||
        !valid.network_second_dns($scope.network_second_dns)
          return false
        return true
      else if method == 1
        return true
      else if method == 2
        if !valid.network_username($scope.network_username) || !valid.network_password($scope.network_password)
          return false
        return true
      return true

    $scope.save = ->
      if !isValid()
        return
      console.log 'success'
      # $http.put "#{$scope.$parent.url}/network.json",
      #   items:
      #     scenario: $scope.scene
      # .success ->
      #   $scope.$parent.success('Save Success')
        
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
      console.log 'success'
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

    $scope.output1_period_msg = ''
    $scope.output2_period_msg = ''

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
      output2_period: (value) ->
        this.common('output2_period_msg', value, 'output2 period')
    }

    add_watch = ->
      $scope.$watch('output1_period', (newValue) ->
        valid.output1_period(newValue)
      )
      $scope.$watch('output2_period', (newValue) ->
        valid.output2_period(newValue)
      )
    add_watch()

    isValid = ->
      if !valid.output1_period($scope.output1_period) || !valid.output2_period($scope.output2_period)
        return false
      return true

    $scope.save = ->
      if !isValid()
        return
      console.log 'success'
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

