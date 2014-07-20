$ ->
  $('ui.nav.nav-pills.nav-stacked li a').click ->
    $('ui.nav.nav-pills.nav-stacked li.active').removeClass('active')
    $(this).parent('li').addClass('active')

  $('.datetime').datetimepicker()
  $(".switch").bootstrapSwitch()
  $('.color-pick').colorpicker()
