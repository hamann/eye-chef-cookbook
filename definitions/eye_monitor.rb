define :eye_monitor do
  include_recipe "eye::default"

  eye_service params[:name] do
    supports [:start, :stop, :restart, :enable, :load, :reload]
    action :nothing
  end

  template "#{node["eye"]["conf_dir"]}/#{params[:name]}.rb" do
    owner "root"
    group "root"
    mode 0600
    cookbook params[:cookbook] || "eye"
    variables params[:variables] || params
    source params[:template] || "eye_conf.rb.erb"
    notifies :enable, resources(:eye_service => params[:name]), :immediately
    notifies :reload, resources(:eye_service => params[:name]), :immediately
    notifies :restart, resources(:eye_service => params[:name]), :immediately
  end
  
end
