#
# $Id$
#
$ ->
  $('.delete-market-price-time').bind('ajax:beforeSend',()  ->
      $(this).closest('tr').fadeOut()
  )
  $('.delete-market-price-time').bind('ajax:failure', () ->
      $(this).closest('tr').show()
  )
  $('.delete-market-price-time').bind('ajax:success', () ->
      $(this).closest('tr').fadeOut()
  )