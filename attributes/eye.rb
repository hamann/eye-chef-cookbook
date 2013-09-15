#
# Cookbook Name:: eye
# Attributes:: eye 
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

default["eye"]["version"] = "0.4.1"
default["eye"]["install_dir"] = "/opt/eye"
default["eye"]["conf_dir"] = "/etc/eye"
default["eye"]["bin"] = "#{node["eye"]["install_dir"]}/bin/eye"
default["eye"]["log_dir"] = "/var/log/eye"
default["eye"]["run_dir"] = "/var/run/eye"
default["eye"]["use_rsyslog"] = false
default["eye"]["user"] = "root"
default["eye"]["group"] = "root"

case platform
when "arch"
  default["eye"]["init_dir"] = "/etc/rc.d"
else
  default["eye"]["init_dir"] = "/etc/init.d"
end

