#
# Cookbook Name:: petstore
# Recipe:: default
#
# Copyright 2012, Cometera
#
# All rights reserved - Do Not Redistribute
#

# Creating app war

remote_file 'app.war' do
  path '/tmp/app.war'
  source node['war']['deploy']
  mode '0777'
end


# Creating tomcat context xml

template '/tmp/app.xml' do
  source 'jpetstore-context.xml.erb'
  owner 'root'
  group 'root'
  mode '0777'
  variables(
      :war => '/tmp/app.war'
  )
end

directory "#{node['tomcat']['webapp_dir']}/ROOT" do
  recursive true
  action :delete
end

link "#{node['tomcat']['context_dir']}/ROOT.xml" do
  to "/tmp/app.xml"
end
