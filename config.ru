require 'rubygems'
require 'bundler/setup'
require 'sequenceserver'

SequenceServer::App.config_file = '/var/www/asparagus_virtual_machine/sequenceserver-asparagus.conf'
SequenceServer::App.init
run SequenceServer::App
