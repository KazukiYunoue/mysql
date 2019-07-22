#
# Cookbook:: mysql
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

remote_file "/tmp/mysql80-community-release-el7-2.noarch.rpm" do
  source "https://dev.mysql.com/get/mysql80-community-release-el7-2.noarch.rpm"
  not_if "rpm -qa | grep -1 '^mysql80-community-release-'"
  action :create
end

yum_package "mysql80-community-release" do
  source "/tmp/mysql80-community-release-el7-2.noarch.rpm"
  action :install
end

template "/etc/yum.repos.d/mysql-community.repo" do
  source "mysql-community.repo.erb"
  user "root"
  group "root"
  mode 0644
end

package "mysql-community-server" do
  action :install
  version "#{node["mysql"]["version"]}"
end

service "mysqld" do
  action [:enable, :start]
  supports :status => true, :restart => true
end

execute "set root password" do
  command lazy { set_root_password }
  not_if "mysql -uroot -p#{node["mysql"]["root_password"]} -e 'show databases;'"
end

template "/tmp/grant_replication_user.sql" do
  source "grant_replication_user.sql.erb"
  user "root"
  group "root"
  mode 0644
end

execute "grant_replication_user" do
  command "mysql -uroot -p#{node["mysql"]["root_password"]} -e 'source /tmp/grant_replication_user.sql'"
  not_if "mysql -uroot -p#{node["mysql"]["root_password"]} -e \"SHOW GRANTS FOR '#{node["mysql"]["replication_user_name"]}'@'%'\""
end

template "/etc/my.cnf" do
  source "my.cnf.erb"
  user "root"
  group "root"
  mode 0644
  notifies :restart, "service[mysqld]", :immediately
end
