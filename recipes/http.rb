include_recipe 'eye::default'

gem_package 'eye-http' do
  version node['eye']['http']['version']
end
