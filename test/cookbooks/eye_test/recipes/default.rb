#
# Cookbook Name:: eye_test
# Recipe:: default
#
# Copyright 2013, Holger Amann <holger@fehu.org>
#
# All rights reserved - Do Not Redistribute
#

include_recipe "eye::default"

eye_monitor "sleep" do
  start_command "/bin/sleep 10000"
  stop_signals "[:term, 10.seconds, :kill]"
  stop_grace "20.seconds"
  pid_file "/var/tmp/sleep.pid"
  user_srv true
  user_srv_uid "vagrant"
  user_srv_gid "users"
  daemonize true
end
