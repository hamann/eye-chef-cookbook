define :eye_monitor do
  include_recipe "eye::default"
  
  service_user = params[:user_srv_uid] || node['eye']['user']
  service_group = params[:user_srv_gid] || node['eye']['group']
  
  log_file = params[:log_file] || ::File.join(node['eye']['log_dir'], "eye.log")

  eye_service params[:name] do
    supports [:start, :stop, :restart, :enable, :load, :reload]
    user_srv params[:user_srv]
    user_srv_uid service_user
    user_srv_gid service_group
    action :nothing
  end

  template "#{node["eye"]["conf_dir"]}/#{params[:name]}.rb" do
    owner service_user
    group service_group
    mode 0600
    cookbook params[:cookbook] || "eye"
    variables (params[:variables] || params).merge(:log_file => log_file)
    source params[:template] || "eye_conf.rb.erb"
    notifies :enable, resources(:eye_service => params[:name]), :immediately
    notifies :reload, resources(:eye_service => params[:name]), :immediately
    notifies :restart, resources(:eye_service => params[:name]), :immediately
  end
  
end
