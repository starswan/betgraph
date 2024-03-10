#
# $Id$
#
# This allows us to have multiple charts on the page, with the caveat that they
# all have to have unique id properties as Morris.Line uses the id to find them

@MORRIS_LINE_COLOURS = [
  '#006600',
  '#cc00cc',
  '#000000',
  '#003399',
  '#0000ff',
  '#006666',
  '#0066cc',
  '#00cc00',
#        '#00cc66',
  '#00cccc',
  '#660000',
#        '#660066',
  '#6600cc',
  '#666600',
#        '#666666',
  '#6666cc',
  '#66cc00',
#        '#66cc66',
  '#66cccc',
  '#cc0000',
  '#cc0066',
  '#cc6600',
  '#cc6666',
  '#cc66cc',
  '#cccc00',
#      '#cccc66',
  '#cccccc',
  '#ff0000',
#      '#ff0066',
  '#ff00cc',
  '#ff6600',
  '#ff6666',
  '#ff66cc',
  '#ffcc00',
  '#ffcc66',
  '#ffcccc',
]

jQuery ->
  $('.bet-markets-chart').each((index, chartdata) ->
    chart = $(chartdata)
    Morris.Line(
      element: chartdata.id
      data: chart.data('markets')
#      data: [
#        {xkey: '2006', a: 100}
#      ]
      xkey: chart.data('xkey')
      ykeys: chart.data('ykeys')
      labels: chart.data('labels')
      ymin: chart.data('ymin')
      ymax: chart.data('ymax')
      xLabels: 'minute'
      lineColors: MORRIS_LINE_COLOURS).on('click', (i, row) ->
      # example only - shows that the click event handler works. Not sure what the params are though
      console.log(' i = ' + i + ' row = ' + row)
    )
  )
