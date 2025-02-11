#
# $Id$
#
jQuery ->
  $('.delete-event').bind('ajax:beforeSend', () ->
      $(this).closest('td').fadeOut()
  )
  $('.delete-event').bind('ajax:failure', () ->
      $(this).closest('td').show()
  )
  $('.delete-event').bind('ajax:success', () ->
      $(this).closest('tr').fadeOut()
  )