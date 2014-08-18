require 'rubygems'
require 'bundler/setup'
require 'sequenceserver'

SequenceServer::App.config_file = '/var/www/amborella_virtual_machine/sequenceserver-amborella.conf'
SequenceServer::App.init
run SequenceServer::App
