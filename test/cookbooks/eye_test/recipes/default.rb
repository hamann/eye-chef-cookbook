#
# Cookbook Name:: eye_test
# Recipe:: default
#
# Copyright 2013, Holger Amann <holger@fehu.org>
#
# All rights reserved - Do Not Redistribute
#

directory "/var/log/eye/hamann" do
  owner "hamann"
  group "users"
  mode 0775
  action :create
end

eye_monitor "sleep" do
  start_command "/bin/sleep 10000"
  stop_signals "[:term, 10.seconds, :kill]"
  stop_grace "20.seconds"
  pid_file "/var/tmp/sleep.pid"
  user_srv true
  user_srv_uid "hamann"
  user_srv_gid "users"
  log_file "/var/log/eye/hamann/sleep.log"
  daemonize true
end
