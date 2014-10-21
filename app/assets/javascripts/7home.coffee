ipcApp.controller 'HomeController', [
  '$scope'
  '$timeout'
  '$http'
  ($scope, $timeout, $http) ->
    $scope.speed = 50
    $scope.restore_val = 0
    $scope.light = true
    $scope.wiper = false
    $scope.current_stream = 'main_profile'
    $scope.microphone = 50
    $scope.off_microphone = false
    $scope.volume = 40
    $scope.mute = false
    $scope.play_status = 'play'
    $scope.ptz_position = 'left'
    $scope.ptz_status = 'show'

    restore_interval = null

    # 复位光圈、焦距、变焦
    $('.special').on({
      slide: ->
        clearInterval(restore_interval)
        restore_interval = setInterval(->
          if $scope.restore_val > 0
            console.log('++++++')
          else
            console.log('------')
        , 500)
      change: ->
        $scope.restore_val = 0
        $(this).val(0)
        clearInterval(restore_interval)
    })

    direction_status = false
    $scope.start_direction = (direction) ->
      direction_status = true
      console.log direction

    $scope.stop_direction = ->
      direction_status = false
      console.log 'stop direction'

    # 鼠标移开后释放需清楚interval
    $(document).on('mouseup', ->
      if direction_status == true
        $scope.stop_direction()
    )

    $scope.toggle_device_control = ->
      if $scope.ptz_status == 'show'
        $scope.ptz_status = 'hide'
        if $scope.ptz_position == 'left'
          sidebar_params = {
            left: -300
          }
          screen_params = {
            left: 0
          }
        else
          sidebar_params = {
            right: -300
          }
          screen_params = {
            right: 0
          }
      else
        $scope.ptz_status = 'show'
        if $scope.ptz_position == 'left'
          sidebar_params = {
            left: 0
          }
          screen_params = {
            left: 300
          }
        else
          sidebar_params = {
            right: 0
          }
          screen_params = {
            right: 300
          }
      $('#home_sidebar').animate(sidebar_params, 500)
      $('#screen_wrap').animate(screen_params, 500)
      $('#collapse_block').animate(screen_params, 500)
      return

    $scope.change_stream = (stream) ->
      $scope.current_stream = stream
      getVideo(stream)

    $scope.toggle_microphone = ->
      $scope.off_microphone = !$scope.off_microphone

    $scope.toggle_volume = ->
      $scope.mute = !$scope.mute

    $scope.play_or_pause = ->
      if $scope.play_status == 'play'
        $scope.play_status = 'stop'
        stopVlc()
      else
        $scope.play_status = 'play'
        playVlc()
    
    $scope.change_ptz_position = ->
      $('#collapse_block, #home_sidebar, #screen_wrap').removeAttr('style')
      $scope.ptz_status = 'show'
      if $scope.ptz_position == 'left'
        $scope.ptz_position = 'right'
      else
        $scope.ptz_position = 'left'

    $scope.show_device_operation_infos = ->
      $('#device_operation_infos').modal()
      return

    resolution_mapping = {
      '1080P':
        width: 1920
        height: 1080
      'UXGA':
        width: 1600
        height: 1200
      '960H':
        width: 1280
        height: 960
      '720P':
        width: 1280
        height: 720
      'D1':
        width: 720
        height: 576
      'CIF':
        width: 352
        height: 288
    }

    getVideo = (stream)->
      $http.get window.apiUrl + "/video.json",
        params:
          'items[]': [stream]
      .success (data) ->
        size = resolution_mapping[data.items[stream].resolution]
        $screen_wrap = $('#screen_wrap')
        actual_size = {
          width: $screen_wrap.width(),
          height: $screen_wrap.height()
        }
        _width = size.width
        _height = size.height
        if size.width > actual_size.width && size.height > actual_size.height
          width_ratio = actual_size.width / size.width
          height_ratio = actual_size.height / size.height
          ratio = width_ratio
          if width_ratio > height_ratio
            ratio = height_ratio
          _width = size.width * ratio
          _height = size.height * ratio
        $('#vlc').width(_width).height(_height)
        if _height < actual_size.height
          margin_top = (actual_size.height - _height) / 2
          $('#vlc').css('margin-top', margin_top + 'px')
        else
          $('#vlc').css('margin-top', '0px')
        playVlc()

    getVideo($scope.current_stream)

    $(window).on('resize', (e) ->
      getVideo($scope.current_stream)
    )
]