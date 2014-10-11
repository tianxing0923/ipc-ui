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

window.ipcApp = angular.module('ipcApp', [])
ipcApp.config(['$sceProvider', ($sceProvider) ->
  $sceProvider.enabled(false)
])

ipcApp.directive('ngIcheck', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link: ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $element.iCheck({
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

ipcApp.directive('ngBswitch', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link: ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $element.bootstrapSwitch({
        onText: $element.attr('onText'),
        offText: $element.attr('offText')
      }).on('switchChange.bootstrapSwitch', (e, state) ->
        $scope.$apply( ->
          $ngModel.$setViewValue(state);
        )
      )
      if $scope[$attrs.ngModel]
        $element.bootstrapSwitch('state', true, true)
      $scope.$watch($attrs.ngModel, (newValue) ->
        $element.bootstrapSwitch('state', newValue || false, true);
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
      $element.noUiSlider({
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
  }
)

ipcApp.directive('ngColor', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link: ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $element.colorpicker().on('changeColor', (e) ->
        rgb = e.color.toRGB()
        $scope.$apply( ->
          $ngModel.$setViewValue(rgb);
        )
      )
      $scope.$watch($attrs.ngModel, (newValue) ->
        if newValue
          hex = '#' + ((1 << 24) | (parseInt(newValue.r) << 16) | (parseInt(newValue.g) << 8) | parseInt(newValue.b)).toString(16).substr(1)
          hex.toUpperCase()
          $element.colorpicker('setValue', hex, true);
          $element.find('.color-block').css('background', hex)
          $element.parent().find('.color-text').val(hex)
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
      $parent = $element.parent()
      parent_size = {
        width: $parent.width(),
        height: $parent.height()
      }
      rect = $scope[$attrs.ngModel]
      if !rect
        rect = {
          x: 0,
          y: 0,
          width: 100,
          height: 100
        }
      $element.css({
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
            $ngModel.$setViewValue(rect)
          )
      })
      $scope.$watch($attrs.ngModel, (newValue) ->
        if newValue
          rect = newValue
          $element.css({
            left: newValue.x,
            top: newValue.y,
            width: newValue.width,
            height: newValue.height
          })
      )
  }
)

ipcApp.directive('ngDatetime', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link: ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $element.datetimepicker()
  }
)

ipcApp.directive('ngTimegantt', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link:  ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      debugger
      $element.timegantt({
        width: 782
      }).on('changeSelected', (e, data) ->
        $scope.$apply( ->
          $ngModel.$setViewValue(data)
        )
      )
  }
)

ipcApp.directive('ngChart', ($compile) ->
  return {
    restrict: 'A',
    require: '?ngModel',
    link:  ($scope, $element, $attrs, $ngModel) ->
      if (!$ngModel)
        return
      $parent = $element.parent()
      $element[0].width = $parent.width()
      $element[0].height = $parent.height()
      ctx = $element[0].getContext('2d')
      data = $scope[$attrs.ngModel]
      # if data

      # else
      #   data = []

      lineChartData = {
        labels: ['60s', '50s', '40s', '30s', '20s', '10s', '0s'],
        datasets: [
          {
            label: $attrs.label || 'Chart',
            fillColor: $attrs.fillColor || 'rgba(220,220,220,0.2)',
            strokeColor: $attrs.strokeColor || 'rgba(220,220,220,1)',
            data : [50, 60, 80, 90, 10, 50, 30]
          }
        ]
      }

      new Chart(ctx).Line(lineChartData);

      $scope.$watch($attrs.ngModel, (newValue) ->
        new Chart(ctx).Line(lineChartData);
      )
  }
)