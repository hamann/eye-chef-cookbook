#
# Cookbook Name:: eye
# Recipe:: default
#
# Copyright 2013, Holger Amann <holger@fehu.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

gem_package "eye" do
  version node["eye"]["version"] if node["eye"]["version"]
  action :install
end

%w(conf_dir run_dir log_dir).each do |dir|
  directory "#{node["eye"][dir]}" do
    owner node['eye']['user']
    group node['eye']['group']
    recursive true
  end
end

eye_conf = ::File.join(node['eye']['conf_dir'], 'config.rb')
template eye_conf do
  owner node['eye']['user']
  group node['eye']['group']
  source "config.rb.erb"
  variables :log_file => ::File.join(node['eye']['log_dir'], 'eye.log')
end

include_recipe "eye::rsyslog" if node["eye"]["use_rsyslog"]

