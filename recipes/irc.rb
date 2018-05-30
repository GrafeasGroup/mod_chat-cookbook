#
# Cookbook:: mod_chat
# Recipe:: irc
#
# Copyright:: 2018, Grafeas Group, LLC

user 'oragono' do
  system true
end

directory '/tmp/oragono' do
  owner 'oragono'
  group 'oragono'
end
directory '/etc/oragono' do
  owner 'oragono'
  group 'oragono'
end

directory '/opt/oragono'

template '/etc/oragono/ircd.yaml' do
  source 'ircd.yaml.erb'
  sensitive true

  variables(
    irc_name: 'ModChat',
    server_name: node['mod_chat']['servername'],
    server_passwd: node['mod_chat']['irc_server_passwd'],
    tls_key_path: '/etc/oragono/tls.key',
    tls_crt_path: '/etc/oragono/tls.crt',
    datastore_path: '/tmp/oragono/ircd.db',
    languages_path: '/opt/oragono/languages',
    motd_file_path: '/etc/oragono/ircd.motd',
  )

  notifies :restart, 'systemd_unit[oragono.service]', :delayed if ::File.exist?('/etc/systemd/system/oracono.service')
end

template '/etc/oragono/ircd.motd' do
  source 'ircd.motd.erb'

  notifies :restart, 'systemd_unit[oragono.service]', :delayed if ::File.exist?('/etc/systemd/system/oracono.service')
end

remote_file '/tmp/oragono.tar.gz' do
  source "https://github.com/oragono/oragono/releases/download/v#{node['mod_chat']['oragono_version']}/oragono-#{node['mod_chat']['oragono_version']}-linux-x64.tar.gz"

  only_if do
    next true unless ::File.exist?('/opt/oragono/oragono')

    out = shell_out!('/opt/oragono/oragono --version').stdout.strip
    out.split(' ').include?(node['mod_chat']['oragono_version'])
  end
end

execute 'extract_oragono' do
  cwd '/opt/oragono'

  command <<-EOH
  tar xzf /tmp/oragono.tar.gz
  rm -f /tmp/oragono.tar.gz
  EOH

  creates '/opt/oragono/oragono'

  only_if { ::File.exist?('/tmp/oragono.tar.gz') }
  action :run

  notifies :restart, 'systemd_unit[oragono.service]', :delayed if ::File.exist?('/etc/systemd/system/oracono.service')
end

execute 'oragono_initdb' do
  cwd '/tmp/oragono'

  command '/opt/oragono/oragono initdb --conf /etc/oragono/ircd.yaml'
  user 'oragono'

  action :run

  not_if { ::File.exist?('/tmp/oragono/ircd.db') }

  notifies :restart, 'systemd_unit[oragono.service]', :delayed if ::File.exist?('/etc/systemd/system/oracono.service')
end

execute 'oragono_mkcerts' do
  cwd '/etc/oragono'

  command '/opt/oragono/oragono mkcerts --conf /etc/oragono/ircd.yaml'
  user 'oragono'

  action :run

  not_if { ::File.exist?('/etc/oragono/tls.key') }
  notifies :restart, 'systemd_unit[oragono.service]', :delayed if ::File.exist?('/etc/systemd/system/oracono.service')
end

systemd_unit 'oragono.service' do
  content(
    Unit: {
      Description: 'IRC Daemon for ModChat accessibility',
      ConditionPathExists: '/etc/oragono/ircd.yaml',
      After: 'network.target',
    },
    Service: {
      Type: 'simple',
      ExecStart: '/opt/oragono/oragono run --conf /etc/oragono/ircd.yaml',
      WorkingDirectory: '/tmp/oragono',
      Restart: 'on-failure',
      User: 'oragono',
      Group: 'oragono',
      StandardOutput: 'syslog',
      StandardError: 'syslog',
      SyslogIdentifier: 'oragono',
    },
  )

  action [:create, :enable, :start]

  only_if { ::File.exist?('/opt/oragono/oragono') }
end
