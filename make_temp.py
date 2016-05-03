from bokeh.plotting import figure, output_file, show


p = figure(title="Prices",tools="save",background_fill_color="#E8DDCB")
p.xaxis.axis_label = 'prices [$]'
p.yaxis.axis_label = 'number of listings'

output_file("/Users/Dana/Dropbox/RentCompare_PythonGUI/templates/histograms.html")

show(p)
