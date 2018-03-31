#!/usr/bin/python3

import ntpath, os.path, urllib, argparse, datetime

from urllib.request import urlopen
from xml.etree import ElementTree
from subprocess import call

parser = argparse.ArgumentParser(description='Downloads the daily wallpapers from bing.com')
parser.add_argument('-d', required=True, help='Target directory')
parser.add_argument('-i', required=True, help='File to touch after successful run')
args = parser.parse_args()

base_dir = args.d
touch_file = args.i

jpg_url_prefix = 'https://www.bing.com'
base_url = 'https://www.bing.com/HPImageArchive.aspx?format=xml&idx=%s&n=8&mkt=%s'

indices = [ 0, 8 ]
markets = [ 'en-US', 'en-AU', 'pt-BR', 'de-DE', 'fr-FR', 'en-IN', 'ja-JP', 'en-CA', 'fr-CA', 'en-GB', 'zh-CN', 'de-AT' ]
resolutions = [ '1920x1080', '1080x1920' ]

print(datetime.datetime.now())

for market in markets:
    print(market)
    for index in indices:
        print(index)
        url = base_url % (index, market)

        root = ElementTree.parse(urlopen(url)).getroot()

        for image in root.findall('image'):
            copyright = image.find('copyright').text

            for resolution in resolutions:
                print(resolution)
                directory = base_dir + resolution
                if not os.path.isdir(directory):
                    os.makedirs(directory)

                jpg_url = jpg_url_prefix + image.find('urlBase').text + '_' + resolution + '.jpg'
                filename = base_dir + resolution + '/' + ntpath.basename(jpg_url).replace(market.upper(), '').replace('ROW', '')

                if not os.path.isfile(filename):
                    print(jpg_url)
                    urllib.request.urlretrieve(jpg_url, filename)

                    call(['jhead', '-cl', copyright, filename])

print(datetime.datetime.now())

with open(touch_file, 'a'):
    os.utime(touch_file)

