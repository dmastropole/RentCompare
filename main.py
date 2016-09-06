from flask import Flask, render_template
from bokeh.plotting import figure, output_notebook, output_file, vplot, show
from bokeh import embed

#for plotting
import numpy as np
import scipy.special

#for scraping 
from lxml import html
import requests

#set url - later change take user input
url = 'http://boston.craigslist.org/search/aap'

#function that scrapes prices
def scrape_prices(url):
    page = requests.get(url)
    tree = html.fromstring(page.content)
    
    #This will create a list of prices
    str_prices = tree.xpath('//span[@class="price"]/text()')
    
    #convert into floats
    prices = []
    for s in str_prices:
        prices.append(float(s[1:]))
    
    return prices

#function that makes a histogram from prices
def make_hist(prices):
    hist, edges = np.histogram(prices)
    x = np.linspace(min(prices), max(prices), 1)
    
    p = figure(title="Boston Apartments",tools="save", 
        background_fill_color="#E8DDCB", 
        x_axis_label="Prices [$]", y_axis_label="Number of Listings")
    p.quad(top=hist, bottom=0, left=edges[:-1], right=edges[1:],
        fill_color="#036564", line_color="#033649")
    return p

#flask part of the code
app = Flask(__name__)
@app.route('/')

def root():
    prices = scrape_prices(url)
    p = make_hist(prices)
    script, div = embed.components(p)
    return render_template('histograms.html',script = script,div = div)

if __name__ == '__main__':
    app.run(host='0.0.0.0')
