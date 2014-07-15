#
# Cookbook Name:: eye_test
# Recipe:: default
#
# Copyright 2013, Holger Amann <holger@fehu.org>
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'
include_recipe 'build-essential'

gem_package "unicorn"

node.default['eye']['http']['install'] = true
include_recipe "eye::default"

directory "#{node['eye']['conf_dir']}/vagrant" do
  user 'vagrant'
end

template "#{node['eye']['conf_dir']}/vagrant/http_config.rb" do
  source "http_config.erb"
  user 'vagrant'
  group 'vagrant'
end

eye_app "sleep_vagrant" do
  start_command "/bin/sleep 10000"
  stop_signals "[:term, 10.seconds, :kill]"
  stop_grace "20.seconds"
  pid_file "/var/tmp/sleep_vagrant.pid"
  user_srv true
  user_srv_uid "vagrant"
  user_srv_gid "users"
  daemonize true
end

eye_app "sleep_root" do
  start_command "/bin/sleep 10000"
  stop_signals "[:term, 10.seconds, :kill]"
  stop_grace "20.seconds"
  pid_file "/var/tmp/sleep_root.pid"
  init_script_prefix ''
  daemonize true
end



rails_dir = '/var/www/www.railsapp.dev/current'
directory rails_dir do
  user 'vagrant'
  group 'users'
  recursive true
end

eye_app "test_unicorn" do
  user_srv true
  user_srv_uid "vagrant"
  user_srv_gid "users"
  template "test_unicorn.conf.erb"
  cookbook "eye_test"
  variables :ruby => "#{node['languages']['ruby']['bin_dir']}/ruby",
    :environment => 'test',
    :working_dir => rails_dir
end
