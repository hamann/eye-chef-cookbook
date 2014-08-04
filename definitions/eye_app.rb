define :eye_app, :enable => true, :load => false, :reload => false, :restart => false do
  include_recipe "eye::default"
  
  service_user = params[:user_srv_uid] || node['eye']['user']
  service_group = params[:user_srv_gid] || node['eye']['group']
  
  eye_service params[:name] do
    supports [:start, :stop, :restart, :enable, :load, :reload]
    user_srv params[:user_srv]
    user_srv_uid service_user
    user_srv_gid service_group
    init_script_prefix params[:init_script_prefix] || ''
    action :nothing
  end

  directory "#{node["eye"]["conf_dir"]}/#{service_user}" do
    owner service_user
    group node['eye']['group']
    action :create
    mode 0750
  end

  log_dir = "#{node["eye"]["log_dir"]}/#{service_user}"
  directory log_dir do
    owner service_user
    group node['eye']['group']
    action :create
    mode 0750
  end

  template "#{node["eye"]["conf_dir"]}/#{service_user}/config.rb" do
    owner service_user
    group node['eye']['group']
    source "config.rb.erb"
    variables :log_file => "#{log_dir}/eye.log"
    cookbook 'eye'
    action :create
    mode 0640
  end


  template "#{node["eye"]["conf_dir"]}/#{service_user}/#{params[:name]}.eye" do
    owner service_user
    group service_group
    mode 0640
    cookbook params[:cookbook] || "eye"
    variables params[:variables] || params
    source params[:template] || "eye_conf.eye.erb"
    if params[:enable]
      notifies :enable, resources(:eye_service => params[:name]), :immediately
    end
    if params[:load]
      notifies :load, resources(:eye_service => params[:name]), :immediately
    end
    if params[:reload]
      notifies :reload, resources(:eye_service => params[:name]), :immediately
    end
    if params[:restart]
      notifies :restart, resources(:eye_service => params[:name]), :immediately
    end
  end
end
