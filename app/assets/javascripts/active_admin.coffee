#= require active_admin/base
#= require rich
#= require activeadmin_sortable_table
#= require jquery-ui
#= require jquery-ui/autocomplete
#= require autocomplete-rails
#= require activeadmin_addons/all
  
usersPageReady = () ->
  window.autocomplete_state_admin_users_path = $('#user_home_address_attributes_state').attr('data-autocomplete')
  window.autocomplete_city_admin_users_path = $('#user_home_address_attributes_city').attr('data-autocomplete')
  $('#user_billing_address_attributes_state').blur () ->
    url = window.autocomplete_city_admin_users_path
    country = $('#user_billing_address_attributes_country').val()
    state = $(this).val()
    url = url + '/?country=' + country + '&state=' + state
    $('#user_billing_address_attributes_city').attr('data-autocomplete', url)
  $('#user_billing_address_attributes_country').change () ->
    url = window.autocomplete_state_admin_users_path
    url = url + '/?country=' + $(this).val()
    $('#user_billing_address_attributes_state').attr('data-autocomplete', url)
  $('#user_home_address_attributes_state').blur () ->
    url = window.autocomplete_city_admin_users_path
    country = $('#user_home_address_attributes_country').val()
    state = $(this).val()
    url = url + '/?country=' + country + '&state=' + state
    $('#user_home_address_attributes_city').attr('data-autocomplete', url)
  $('#user_home_address_attributes_country').change () ->
    url = window.autocomplete_state_admin_users_path
    url = url + '/?country=' + $(this).val()
    $('#user_home_address_attributes_state').attr('data-autocomplete', url)
    
$(document).ready usersPageReady

run = () ->
  $('select[name^="content_block[blocks_attributes]"]').change () ->
      $(':submit').click()

bind_content_block_event = () ->
  $('.has_many_add').click(bind_content_block_event)
  setTimeout(run, 1000)

pageReady = () ->
  $('.hasDatetimePicker').each () ->
    do (ele = $(this)) -> 
      name = ele.prop('name')
      altele = $('[name="' + name + '"]:last')
      yr_rng = if (name == 'user[birthday]') then '1920:2000' else '1900:2100'
      ele.datepicker({
          changeMonth: true,
          changeYear: true,
          dateFormat: 'm/d/yy',
          altField: altele,
          altFormat: 'm/d/yy',
          yearRange: yr_rng,
      })
  bind_content_block_event()

      
$(document).ready pageReady