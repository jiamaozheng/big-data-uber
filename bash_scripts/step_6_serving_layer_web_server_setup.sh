#!/bin/bash


# ##################################### The year 2014 #######################################


# Part 1. Perl code
sudo mkdir /usr/lib/cgi-bin/xinran
sudo cp web_server_usr_lib_cgi-bin/xinran_uber_2014_map.pl /usr/lib/cgi-bin/xinran/
sudo chmod a+rx /usr/lib/cgi-bin/xinran/xinran_uber_2014_map.pl
# This Perl file can be tested on its own in browser, e.g.
#     http://localhost/cgi-bin/xinran/xinran_uber_2014_map.pl?daySince20140401=123


# Part 2. HTML + JavaScript + CSS + other static files
sudo mkdir /var/www/html/xinran
sudo cp web_server_var_www_html/xinran_uber_2014_map.html /var/www/html/xinran/
sudo cp web_server_var_www_html/xinran_uber_2014_map.css /var/www/html/xinran/
sudo cp web_server_var_www_html/xinran_uber_2014_map.js /var/www/html/xinran/
sudo chmod a+rx /var/www/html/xinran/xinran_uber_2014_map.html
sudo chmod a+rx /var/www/html/xinran/xinran_uber_2014_map.css
sudo chmod a+rx /var/www/html/xinran/xinran_uber_2014_map.js
# For development purpose, this web app can be locally accessed at
#     http://localhost/xinran/xinran_uber_2014_map.html
# Deployed to Google Cloud Platform, this web app now can be publicly accessed at
#     http://104.197.248.161/xinran/xinran_uber_2014_map.html


# ##################################### The year 2015 #######################################


# Part 1. Perl code
sudo mkdir /usr/lib/cgi-bin/xinran
sudo cp web_server_usr_lib_cgi-bin/xinran_uber_2015_plot.pl /usr/lib/cgi-bin/xinran/
sudo chmod a+rx /usr/lib/cgi-bin/xinran/xinran_uber_2015_plot.pl
# This Perl file can be tested on its own in browser, e.g.
# For the data of a single month (i.e. only batch layer)
#     http://localhost/cgi-bin/xinran/xinran_uber_2015_plot.pl?locationName=Bronx, Bronxdale&timeRange=201504
# For the data of all the time (i.e. batch layer + speed layer)
#     http://localhost/cgi-bin/xinran/xinran_uber_2015_plot.pl?locationName=Bronx, Bronxdale&timeRange=-1


# Part 2. HTML + JavaScript + CSS + other static files
sudo mkdir /var/www/html/xinran
sudo cp web_server_var_www_html/xinran_uber_2015_plot.html /var/www/html/xinran/
sudo cp web_server_var_www_html/c3.min.js /var/www/html/xinran/
sudo cp web_server_var_www_html/c3.css /var/www/html/xinran/
sudo chmod a+rx /var/www/html/xinran/xinran_uber_2015_plot.html
sudo chmod a+rx /var/www/html/xinran/c3.min.js
sudo chmod a+rx /var/www/html/xinran/c3.css
# For development purpose, this web app can be locally accessed at
#     http://localhost/xinran/xinran_uber_2015_plot.html
# Deployed to Google Cloud Platform, this web app now can be publicly accessed at
#     http://104.197.248.161/xinran/xinran_uber_2015_plot.html


