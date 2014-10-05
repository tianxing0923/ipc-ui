window.getVlc = ->
  vlc = null
  if window.document['vlc']
    vlc = window.document['vlc']
  if navigator.appName.indexOf('Microsoft Internet') == -1 && document.embeds && document.embeds['vlc']
    vlc = document.embeds['vlc']
  else
    vlc = document.getElementById('vlc')
  return vlc

window.playVlc = ->
  vlc = getVlc()
  if vlc
    vlc.MRL = 'rtsp://192.168.1.100:8554/liveStream'
    vlc.playlist.stop()
    vlc.playlist.play()

window.stopVlc = ->
  vlc = getVlc()
  if vlc
    vlc.MRL = 'rtsp://192.168.1.100:8554/liveStream'
    vlc.playlist.stop()

# ipcApp = angular.module 'ipcApp', ['frapontillo.bootstrap-switch']
window.ipcApp = angular.module 'ipcApp', []

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
      $el = $($element)
      $el.noUiSlider({
        start: [ $scope[$attrs.ngModel] || 0 ],
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
      $scope.$watch($attrs.ngModel, (newValue) ->
        if newValue
          $el.val(newValue)
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
      $el.colorpicker({
        # format: 'rgba'
      }).on('changeColor', (e) ->
        rgb = e.color.toRGB()
        hex = e.color.toHex().toUpperCase()
        $scope[$attrs.ngModel] = rgb
        $el.find('.color-block').css('background', hex)
        $el.parent().find('.color-text').val(hex)
      )
      $scope.$watch($attrs.ngModel, (newValue) ->
        if newValue
          hex = '#' + ((1 << 24) | (parseInt(newValue.r) << 16) | (parseInt(newValue.g) << 8) | parseInt(newValue.b)).toString(16).substr(1)
          hex.toUpperCase()
          $el.colorpicker('setValue', newValue, true);
          $el.find('.color-block').css('background', hex)
          $el.parent().find('.color-text').val(hex)
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
