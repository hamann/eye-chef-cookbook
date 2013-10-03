eye Cookbook
============
[eye](https://github.com/kostya/eye) is a process monitoring tool, inspired by bluepill and god.
This chef cookbook installs the eye RubyGem and configures it to manage services. It also includes a LWRP.

Requirements
------------
eye is written in Ruby, so it should work on any system. If you want to use eye's `uid` or `gid` features, Ruby > 2.0.0 is required.


Attributes
----------
* `node['eye']['version']` - Version of eye, default is '0.4.2'
* `node['eye']['install_dir']` - Location of eye, will be installed by `bundler`, default "/opt/eye"
* `node['eye']['conf_dir']` - Location of eye's configuration files, default '/etc/eye'
* `node['eye']['bin']` - Location of eye binary, default '/opt/eye/bin/eye'
* `node['eye']['log_dir']` - Location of eye's logfiles, default '/var/log/eye'
* `node['eye']['run_dir']` - Path of state directory, default '/var/run/eye'
* `node['eye']['user']` - Owner of eye process, directories and configuration files, default 'root'
* `node['eye']['group']` - Group of eye process, directories and configuration files, default 'root'
* `node['eye']['bin_link_dir']` - if set, eye binary will be linked to specified location, default '/usr/local/bin'

Resources/Providers
-------------------
This cookbook contains a LWRPs, eye_service.

	eye_service 'my_service' do
 		action [:enable, :reload, :restart]
	end

This loads eye daemon with a needed configuration 'my_service.eye' in a subdirectory of `node['eye']['conf_dir']` named by the default eye owner (e.g /etc/eye/root/my_service.rb) and starts the according process. The owner of eye daemon and the process itself is the user defined with `node['eye']['user']`

An (additional) eye daemon can also be started by a different owner (with it's own logfile, e.g in '/var/log/eye/deploy/eye.log')

	eye_service 'my_service' do
		user_srv true
		user_srv_uid 'deploy'
		user_srv_gid 'deploy'
 		action [:enable, :reload, :restart]
	end

In that case the configuration file should be in '/etc/eye/deploy/my_service.eye'

If eye daemon should by controlled by `node['eye']['user']`, but the process should be started as different user, use eye's `uid` or `gid` configuration features.

`eye_service` creates an init script, e.g. '/etc/init.d/my_service'. This init script can be prefixed, like

	eye_service 'my_service' do
		init_script_prefix 'eye-'
		...
	end


There's also a definition `eye_app` which creates the necessary configuration files, log directories and calls `eye_service` afterwards.

Example for unicorn:
	
	eye_app "test_unicorn" do
  		user_srv true
  		user_srv_uid "deploy"
  		user_srv_gid "deploy"
  		template "rails_unicorn.conf.erb"
  		cookbook "rails_app"
  		variables :ruby => "#{node['languages']['ruby']['bin_dir']}/ruby",
    	          :environment => 'test',
    	          :working_dir => '/var/www/rails_dir'
	end
	
with according template:

```
Eye.application "test_unicorn" do
  env "RAILS_ENV" => '<%= @environment %>'
  env "PATH" => "#{File.dirname("<%= @ruby %>")}:#{ENV['PATH']}"

  working_dir "<%= @working_dir %>"

  process("unicorn") do
    pid_file "tmp/pids/unicorn.pid"
    start_command "<%= @ruby %> ./bin/unicorn -Dc ./config/unicorn.rb -E <%= @environment %>"
    stdall "log/unicorn.log"

    stop_signals [:TERM, 10.seconds]

    restart_command "kill -USR2 {PID}"

    check :cpu, :every => 30, :below => 80, :times => 3
    check :memory, :every => 30, :below => 150.megabytes, :times => [3,5]

    start_timeout 30.seconds
    restart_grace 30.seconds

    monitor_children do
      stop_command "kill -QUIT {PID}"
      check :cpu, :every => 30, :below => 80, :times => 3
      check :memory, :every => 30, :below => 150.megabytes, :times => [3,5]
    end
  end

end
```

Usage
-----

e.g.
Just include `eye` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[eye]"
  ]
}
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Holger Amann <holger@fehu.org>

Licensed under Apache License, Version 2.0 
http://www.apache.org/licenses/LICENSE-2.0
