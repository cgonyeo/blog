#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'Derek Gonyeo'
SITENAME = u'Gonblag'
SITEURL = 'http://blog.gonyeo.com'

TIMEZONE = 'America/New_York'

DEFAULT_LANG = u'en'

#Static pages
STATIC_PATHS = ['pages']

DISPLAY_PAGES_ON_MENU = True
USE_FOLDER_AS_CATEGORY = True

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
FEED_RSS = 'feeds/all.rss.xml'
CATEGORY_FEED_RSS = 'feeds/%s.rss.xml'
FEED_ATOM = None

# Blogroll
#LINKS =  (('CSH', 'http://csh.rit.edu/'),
#          ('RIT', 'http://www.rit.edu/'),
#          ('Foss Box', 'http://foss.rit.edu/fossbox'))

# Social widget
EMAIL = 'dgonyeo@csh.rit.edu'
GITHUB_URL = 'http://github.com/dgonyeo/'
SOCIAL = (('Github', 'https://github.com/dgonyeo'),('LinkedIn', 'http://www.linkedin.com/pub/derek-gonyeo/41/7a6/412/'),)


DEFAULT_PAGINATION = False

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True
THEME = "/home/derek/git/pelican-themes/built-texts"

#Footer stuff
COLOPHON = True
COLOPHON_TITLE = "Gonblag: Gonyeo's Blog"
COLOPHON_CONTENT = "Hi! I'm Derek! This is my blag! If you want to contact me to let me know how rad my blag is, there's some links to the left here. I'm also on freenode as dgonyeo in #rit-foss, if IRC is your thing."
