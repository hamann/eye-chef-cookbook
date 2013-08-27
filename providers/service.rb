# Provider:: service
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

require 'chef/mixin/shell_out'
require 'chef/mixin/language'

include Chef::Mixin::ShellOut

action :enable do
  config_file = ::File.join(node['eye']['conf_dir'],
                            "#{new_resource.service_name}.rb")
  unless @current_resource.enabled
    template_suffix = case node['platform_family']
                      when 'implement_me' then node['platform_family']
                      else 'lsb'
                      end
    template "#{node['eye']['init_dir']}/eye-#{new_resource.service_name}" do
      source "eye_init.#{template_suffix}.erb"
      cookbook "eye"
      owner "root"
      group node['eye']['group']
      mode "0755"
      variables(
                :service_name => new_resource.service_name,
                :config_file => config_file
                )
      only_if { ::File.exists?(config_file) }
    end

    service "eye-#{new_resource.service_name}" do
      action [ :enable ]
    end

    new_resource.updated_by_last_action(true)
  end
end

action :load do
  unless @current_resource.running
    shell_out!(load_command)
    new_resource.updated_by_last_action(true)
  end
end

action :reload do
  shell_out!(stop_command) if @current_resource.running
  shell_out!(load_command)
  new_resource.updated_by_last_action(true)
end

action :start do
  unless @current_resource.running
    shell_out!(start_command)
    new_resource.updated_by_last_action(true)
  end
end

action :disable do
  if @current_resource.enabled
    file "#{node['eye']['conf_dir']}/#{new_resource.service_name}.pill" do
      action :delete
    end
    link "#{node['eye']['init_dir']}/#{new_resource.service_name}" do
      action :delete
    end
    new_resource.updated_by_last_action(true)
  end
end

action :stop do
  if @current_resource.running
    shell_out!(stop_command)
    new_resource.updated_by_last_action(true)
  end
end

action :restart do
  if @current_resource.running
    shell_out!(restart_command)
    new_resource.updated_by_last_action(true)
  end
end

def load_current_resource
  @current_resource = Chef::Resource::EyeService.new(new_resource.name)
  @current_resource.service_name(new_resource.service_name)

  determine_current_status!

  @current_resource
end

protected

def status_command
  "#{node['eye']['bin']} info #{new_resource.service_name}"
end

def load_command
  "#{node['eye']['bin']} load #{node['eye']['conf_dir']}/#{new_resource.service_name}.rb"
end

def start_command
  "#{node['eye']['bin']} start #{new_resource.service_name}"
end

def stop_command
  "#{node['eye']['bin']} stop #{new_resource.service_name}"
end

def restart_command
  "#{node['eye']['bin']} restart #{new_resource.service_name}"
end

def determine_current_status!
  service_running?
  service_enabled?
end

def service_running?
  begin
    # should find a better way to check if a process is up and running
    if shell_out!(status_command).stdout.nil?
      @current_resource.running false
    else
      @current_resource.running true
    end
  rescue Mixlib::ShellOut::ShellCommandFailed, SystemCallError
    @current_resource.running false
    nil
  end
end

def service_enabled?
  if ::File.exists?("#{node['eye']['conf_dir']}/#{new_resource.service_name}.rb") &&
      ::File.exists?("#{node['eye']['init_dir']}/eye-#{new_resource.service_name}")
    @current_resource.enabled true
  else
    @current_resource.enabled false
  end
end
