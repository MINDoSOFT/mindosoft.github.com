#!/usr/bin/python

import urllib2
import xml.etree.ElementTree as etree
import string
import HTMLParser

'''
gistEmbedScriptGenerator.py

This script fetches every embed gist script link from the github profile
defined by the variable username which you must define accordingly.

Two kinds of embed scripts exists. 

-The one which embeds all files in a gist
and has the following format 
<script src="https://gist.github.com/1237019.js"> </script>

-And the one which embeds a single file from a gist and has this format
<script src="https://gist.github.com/1237019.js?file=get_external_ip_thomson.bash"></script>

'''

username = "mindosoft" # Modify this variable!

htmlparser = HTMLParser.HTMLParser()
url = urllib2.urlopen("https://gist.github.com/" + username)
html = url.readlines()

i = 0 
gist_urls = []
gist_titles = []

for line in html:
  if ( ( line.find('>gist: ') > -1 ) and ( i == 0 ) ):
    #print line
    element1 = etree.fromstring(line)
    for child in element1:
      #print child.text # gist: 1237019
      gist_urls.append(child.text)

    i = 1
  elif ( i == 1 ):
    #print line
    element2 = etree.fromstring(line)
    gist_titles.append(element2.text)
    i = i - 1

#print gist_urls
#print gist_titles

gist_scripts = []
i = -1

for gist_url in gist_urls:
  i = i + 1
  uri = "https://gist.github.com/" + string.split(gist_urls[i], ' ')[1] #1237019
  url = urllib2.urlopen(uri)
  html = url.readlines()
  for line in html:
    if ( line.find('"gist-embed-box"') > -1 ):
      line = htmlparser.unescape(line)
      start = string.find(line, '<script src')
      finish = string.rfind(line, '</script>') + len('</script>')
      #print gist_titles[i], line[start:finish]
      gist_scripts.append(line[start:finish])

for gist_script in gist_scripts:
  print gist_script
