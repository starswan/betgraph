#
# $Id$
#
$ ->
  $('.delete-match').bind('ajax:beforeSend', () ->
    $(this).closest('td').fadeOut()
  )
  $('.delete-match').bind('ajax:failure', () ->
    $(this).closest('td').show()
  )
  $('.delete-match').bind('ajax:success', () ->
    $(this).closest('tr').fadeOut()
  )
  $('.submit_on_change').on('change', () ->
    this.form.submit()
  )
  $('.match-live-priced').on('ajax:success', (event) ->
    [data, _status, xhr] = event.detail
    if data.live_priced
      event.target.innerText = 'Live'
      $(event.target).removeClass('btn-success')
      $(event.target).addClass('btn-warning')
    else
      event.target.innerText = 'Inactive'
      $(event.target).removeClass('btn-warning')
      $(event.target).addClass('btn-success')
  )
