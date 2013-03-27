#
# Cookbook Name:: petstore
# Recipe:: default
#
# Copyright 2012, Cometera
#
# All rights reserved - Do Not Redistribute
#

# Creating app war

if not node['war']['deploy']['url'].empty?
  remote_file 'app.war' do
    path '/tmp/app.war'
    source node['war']['deploy']['url']
    mode '0777'
  end
elsif not node['war']['deploy']['git']['url'].empty?
  execute "clear" do
    command "rm -rf /tmp/app"
    action :run
  end

  cookbook_file ::File.join( ENV['HOME'], '.ssh', 'config' ) do
    mode 0644
    user "ubuntu"
    group "ubuntu"
  end

  case node[:platform]
  when "debian", "ubuntu"
    package "git-core" do
      action :install
    end
  else
    package "git" do
      action :install
    end
  end

  git "/tmp/app" do 
    repository node['war']['deploy']['git']['url']
    reference node['war']['deploy']['git']['revision']
    action :sync
  end

  package "maven2" do
    action :install
  end

  execute "package" do
    command "cd /tmp/app; mvn clean package"
    action :run
  end

  execute "move" do 
    command "cd /tmp/app; cp target/*.war /tmp/app.war; rm -rf /tmp/app"
    action :run
  end
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
