ipcApp.controller 'HomeController', [
  '$scope'
  '$timeout'
  ($scope, $timeout) ->
    $scope.speed = 50
    $scope.restore_val = 0
    $scope.light = true
    $scope.wiper = false
    $scope.current_stream = 'master'
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

    $scope.toggle_microphone = ->
      $scope.off_microphone = !$scope.off_microphone

    $scope.toggle_volume = ->
      $scope.mute = !$scope.mute

    $scope.play_or_pause = ->
      debugger
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
]