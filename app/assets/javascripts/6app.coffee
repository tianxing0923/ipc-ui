window.apiUrl = 'http://192.168.1.217/api/1.0'

window.getVlc = ->
  vlc = null
  if window.document['vlc']
    vlc = window.document['vlc']
  if navigator.appName.indexOf('Microsoft Internet') == -1 && document.embeds && document.embeds['vlc']
    vlc = document.embeds['vlc']
  else
    vlc = document.getElementById('vlc')
  return vlc

window.playVlc = (profile) ->
  # vlc = getVlc()
  # if vlc
  #   ip = location.hostname
  #   rtsp_auth = false
  #   port = 554
  #   profile = profile || 'main_profile'
  #   $.ajax({
  #     async: false,
  #     url: "#{window.apiUrl}/misc.json",
  #     data: JSON.stringify({
  #       'items[]': ['rtsp_auth']
  #     }),
  #     success: (data) ->
  #       rtsp_auth = data.items.rtsp_auth
  #   })
  #   $.ajax({
  #     async: false,
  #     url: "#{window.apiUrl}/network.json",
  #     data: JSON.stringify({
  #       'items[]': ['port']
  #     }),
  #     success: (data) ->
  #       port = data.items.port.rtsp
  #   })
  #   $.ajax({
  #     async: false,
  #     url: "#{window.apiUrl}/video.json",
  #     data: JSON.stringify({
  #       'items[]': [profile]
  #     }),
  #     success: (data) ->
  #       profile = data.items.stream_path
  #   })
  #   mrl = 'rtsp://'
  #   if rtsp_auth == true
  #     mrl += getCookie('username') + ':' + getCookie('password_plain') + '@'
  #   mrl += ip
  #   if port != 554
  #     mrl += ':' + port
  #   mrl += '/' + profile
  #   vlc.MRL = mrl
  #   setTimeout(->
  #     vlc.Stop()
  #     vlc.Play()
  #   , 500)

window.stopVlc = ->
  vlc = getVlc()
  if vlc
    setTimeout(->
      vlc.Stop()
    , 500)

# 生成uuid
Math.uuid = ->
  chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('')
  uuid = new Array(36)
  rnd = 0
  for i in [0..35]
    if i == 8 || i == 13 || i == 18 || i == 23
      uuid[i] = '-'
    else if i == 14
      uuid[i] = '4'
    else
      if rnd <= 0x02
        rnd = 0x2000000 + (Math.random() * 0x1000000) | 0
      r = rnd & 0xf
      rnd = rnd >> 4
      uuid[i] = chars[if (i == 19) then (r & 0x3) | 0x8 else r]
  uuid.join('')

# base64编码
base64EncodeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
window.base64encode = (str) ->
  len = str.length;
  i = 0
  out = ""
  while (i < len)
    c1 = str.charCodeAt(i++) & 0xff
    if i == len
      out += base64EncodeChars.charAt(c1 >> 2)
      out += base64EncodeChars.charAt((c1 & 0x3) << 4)
      out += "=="
      break
    c2 = str.charCodeAt(i++)
    if i == len
      out += base64EncodeChars.charAt(c1 >> 2)
      out += base64EncodeChars.charAt(((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4))
      out += base64EncodeChars.charAt((c2 & 0xF) << 2)
      out += "="
      break
    c3 = str.charCodeAt(i++)
    out += base64EncodeChars.charAt(c1 >> 2)
    out += base64EncodeChars.charAt(((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4))
    out += base64EncodeChars.charAt(((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6))
    out += base64EncodeChars.charAt(c3 & 0x3F)
  return out

# 写入cookie
window.setCookie = (name, value) ->
  exp = new Date()
  exp.setTime(exp.getTime() + 1 * 24 * 60 * 60 * 1000)
  document.cookie = name + "="+ escape(value) + ";expires=" + exp.toGMTString()

# 读取cookie
window.getCookie = (name) ->
  reg = new RegExp("(^| )" + name + "=([^;]*)(;|$)")
  if arr = document.cookie.match(reg)
    return unescape(arr[2])
  else
    return null

# 删除cookie
window.delCookie = (name) ->
    exp = new Date()
    exp.setTime(exp.getTime() - 1)
    cval = getCookie(name)
    if cval != null
      document.cookie = name + "=" + cval + ";expires=" + exp.toGMTString()

# username = getCookie('username')
# password = getCookie('password')
# uuid = getCookie('uuid')
# if username && password && uuid
#   $.ajax(
#     url: "#{window.apiUrl}/login.json"
#     type: 'POST'
#     data:
#       username: username
#       password: password
#       uuid: uuid
#     success: (data) ->
#       if data.success == false
#         location.href = '/login'
#   )
# else
#   url = location.href
#   if url.indexOf('login') == -1
#     location.href = '/login'

window.ipcApp = angular.module('ipcApp', [])
ipcApp.config(['$sceProvider', ($sceProvider) ->
  $sceProvider.enabled(false)
])

ipcApp.controller 'navbarController', [
  '$scope'
  '$timeout'
  ($scope, $timeout) ->
    $scope.logout = ->
      delCookie('username')
      delCookie('password_plain')
      delCookie('password')
      delCookie('uuid')
      setTimeout(->
        location.href = '/login'
      , 200)
]

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

      $scope.$watch($attrs.ngModel, (newValue) ->
        if newValue == true && $attrs.type == 'checkbox'
          $element.iCheck('check').iCheck('update')
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
          $ngModel.$setViewValue({
            red: rgb.r,
            green: rgb.g,
            blue: rgb.b,
            alpha: rgb.a
          });
        )
      )
      $scope.$watch($attrs.ngModel, (newValue) ->
        if newValue
          hex = '#' + ((1 << 24) | (parseInt(newValue.red) << 16) | (parseInt(newValue.green) << 8) | parseInt(newValue.blue)).toString(16).substr(1)
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
          left: 0,
          top: 0,
          width: 100,
          height: 100
        }
      $element.css({
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height
      }).draggable({
        containment: $parent,
        iframeFix: true,
        stop: (e, ui) ->
          if ui.position.left + rect.width > parent_size.width
            rect.left = parent_size.width - rect.width
            $(this).css('left', rect.left)
          else
            rect.left = ui.position.left
          if ui.position.top + rect.height > parent_size.height
            rect.top = parent_size.height - rect.height
            $(this).css('top', rect.top)
          else
            rect.top = ui.position.top
          $scope.$apply( ->
            $ngModel.$setViewValue(rect)
          )
      }).resizable({
        containment: $parent,
        minWidth: parseInt($attrs.minwidth, 10) || 50,
        minHeight: parseInt($attrs.minheight, 10) || 50,
        stop: (e, ui) ->
          rect.width = ui.size.width
          rect.height = ui.size.height
          $scope.$apply( ->
            $ngModel.$setViewValue(rect)
          )
      })
      $scope.$watch($attrs.ngModel, (newValue) ->
        if newValue
          rect = newValue
          $element.css({
            left: newValue.left,
            top: newValue.top,
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
      labels = []
      data = []
      for i in [60...-1] by -2
        labels.push(i + 's')
        data.push(0)
      if data
        data.push($scope[$attrs.ngModel])
        data.shift()
      
      chart_options = {
        pointDot: false,
        scaleLineColor: $attrs.scalelinecolor,
        scaleGridLineColor: $attrs.scalegridlinecolor,
        showTooltips: false,
        scaleOverride: true,
        scaleSteps : 10,
        scaleStepWidth: 10,
        scaleStartValue: 0,
        animation: false
      }

      getLineChartData = (data) ->
        lineChartData = {
          labels: labels,
          datasets: [
            {
              label: $attrs.label || 'Chart',
              fillColor: $attrs.fillcolor || 'rgba(220,220,220,0.2)',
              strokeColor: $attrs.strokecolor || 'rgba(220,220,220,1)',
              data: data
            }
          ]
        }

      draw_chart = ->
        new Chart(ctx).Line(getLineChartData(data), chart_options);

      draw_chart(data)

      $scope.$watch($attrs.ngModel, (newValue) ->
        if newValue
          data.push(newValue)
          data.shift()
          new Chart(ctx).Line(getLineChartData(data), chart_options);
      )
  }
)