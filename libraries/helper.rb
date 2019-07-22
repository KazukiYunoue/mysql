def set_root_password
  cmd = "mysql -uroot -p'"
  cmd << get_temporary_password_from('/var/log/mysqld.log')
  cmd << "' -e \"set password = '"
  cmd << node["mysql"]["root_password"]
  cmd << "'\" --connect-expired-password"
  cmd
end

def get_temporary_password_from(log_file)
  File.read(log_file).lines.select {|line| line.include? "temporary password"}.first.chomp.split(" ").last
end
