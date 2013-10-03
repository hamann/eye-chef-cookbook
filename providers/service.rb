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
  config_file = ::File.join(user_conf_dir,
                            "#{new_resource.service_name}.eye")

  unless @current_resource.enabled
    template_suffix = case node['platform_family']
                      when 'implement_me' then node['platform_family']
                      else 'lsb'
                      end
    template "#{node['eye']['init_dir']}/#{new_resource.init_script_prefix}#{new_resource.service_name}" do
      source "eye_init.#{template_suffix}.erb"
      cookbook "eye"
      owner service_user
      group service_group
      mode "0755"
      variables(
                :service_name => new_resource.service_name,
                :config_file => config_file,
                :user => service_user
                )
      only_if { ::File.exists?(config_file) }
    end

    service "#{new_resource.init_script_prefix}#{new_resource.service_name}" do
      action [ :enable ]
    end

    new_resource.updated_by_last_action(true)
  end
end

action :load do
  unless @current_resource.running
    run_command(load_command)
    new_resource.updated_by_last_action(true)
  end
end

action :reload do
  run_command(stop_command) if @current_resource.running
  run_command(load_command)
  new_resource.updated_by_last_action(true)
end

action :start do
  unless @current_resource.running
    run_command(start_command)
    new_resource.updated_by_last_action(true)
  end
end

action :disable do
  if @current_resource.enabled
    file "#{user_conf_dir}/#{new_resource.service_name}.eye" do
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
    run_command(stop_command)
    new_resource.updated_by_last_action(true)
  end
end

action :restart do
  if @current_resource.running
    run_command(restart_command)
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
  "#{node['eye']['bin']} load #{user_conf_dir}/#{new_resource.service_name}.eye"
end

def load_eye
  "#{node['eye']['bin']} load"
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

def run_command(command)
  # if user isn't root, eye daemon places socket and pid in ~/.eye/sock 
  env_variables = { 'HOME' => node['etc']['passwd'][service_user]['dir'] }
  shell_out!(command, :user => service_user, :env => env_variables)
end

def determine_current_status!
  service_running?
  service_enabled?
end

def service_running?
  begin
    # get sure eye master process is running
    run_command(load_eye)

    # should find a better way to check if a process is up and running
    if run_command(status_command).stdout.chomp.empty?
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
  if ::File.exists?("#{user_conf_dir}/#{new_resource.service_name}.eye") &&
      ::File.exists?("#{node['eye']['init_dir']}/eye-#{new_resource.service_name}")
    @current_resource.enabled true
  else
    @current_resource.enabled false
  end
end

def service_user
  new_resource.user_srv ? new_resource.user_srv_uid : node['eye']['user']
end

def service_group
  new_resource.user_srv ? new_resource.user_srv_gid : node['eye']['group']
end

def user_conf_dir
  ::File.join(node['eye']['conf_dir'], service_user)
end

def user_log_dir
  ::File.join(node['eye']['log_dir'], service_user)
end
