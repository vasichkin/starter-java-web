
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

remote_file 'mysql schema' do
  path '/tmp/database.schema.sql'
  source node['database']['schema']
  mode '0777'
end

remote_file 'database data' do
  path '/tmp/database.data.sql'
  source node['database']['data']
  mode '0777'
end

template "/tmp/petstore-grants.sql" do
  source "jpetstore-mysql-grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node['database']['username'],
    :password => node['database']['password'],
    :database => node['database']['name']
  )
end

execute "database-install-privileges" do
  command "/usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" < /tmp/petstore-grants.sql"
  action :run
end

execute "create #{node['database']['name']} database" do
  command "/usr/bin/mysqladmin -u root -p\"#{node['mysql']['server_root_password']}\" create #{node['database']['name']}"
  creates "/var/lib/mysql/#{node['database']['name']}"
  notifies :create, "ruby_block[save node data]", :immediately unless Chef::Config[:solo]
end

# save node data after writing the MYSQL root password, so that a failed chef-client run that gets this far doesn't cause an unknown password to get applied to the box without being saved in the node data.
unless Chef::Config[:solo]
  ruby_block "save node data" do
    block do
      node.save
    end
    action :create
  end
end

execute "create-scheme" do
  command "/usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" < /tmp/database.schema.sql"
  action :run
end

execute "load-data" do
  command "/usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" < /tmp/database.data.sql"
  action :run
end
