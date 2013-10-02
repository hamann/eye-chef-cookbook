#
# Cookbook Name:: eye_test
# Recipe:: default
#
# Copyright 2013, Holger Amann <holger@fehu.org>
#
# All rights reserved - Do Not Redistribute
#
gem_package "unicorn"

include_recipe "eye::default"

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
