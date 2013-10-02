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
This coookbook contains a LWRPs, eye_service.

	eye_service 'my_service' do
 		action [:enable, :reload, :restart]
	end

This loads eye with a needed configuration 'my_service.rb' in a subdirectory of `node['eye']['conf_dir']` named by the default eye owner (e.g /etc/eye/root/my_service.rb) and starts it.

The eye process can also be controlled by a different owner (with it's own logfile, e.g in '/var/log/eye/deploy/eye.log')

	eye_service 'my_service' do
		user_srv true
		user_srv_uid 'deploy'
		user_srv_gid 'deploy'
 		action [:enable, :reload, :restart]
	end

In that case the configuration file should be in '/etc/eye/deploy/my_service.rb'


Usage
-----
#### eye::default
TODO: Write usage instructions for each cookbook.

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
TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: TODO: List authors
