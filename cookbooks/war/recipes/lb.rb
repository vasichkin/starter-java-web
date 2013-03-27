include_recipe "haproxy"

template "/etc/haproxy/haproxy.cfg" do
  source "jpetstore-haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 0777
  variables(
    :nodes => node['haproxy.rebalance']['nodes']
  )
end

(node['haproxy.rebalance']['nodes'].size * 2).times do
  bash "stop all mysql" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    sleep 1; curl 'http://127.0.0.1:80/status.do'
    EOH
  end
end