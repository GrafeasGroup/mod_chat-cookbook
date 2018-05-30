#
# Cookbook:: mod_chat
# Recipe:: matterbridge
#
# Copyright:: 2018, Grafeas Group, LLC

directory '/opt/matterbridge'
directory '/tmp/matterbridge'

remote_file '/opt/matterbridge/matterbridge' do
  source "https://github.com/42wim/matterbridge/releases/download/v#{node['mod_chat']['matterbridge_version']}/matterbridge-linux-amd64"
  mode '0755'
  action :create

  not_if do
    next false unless ::File.exist?('/opt/matterbridge/matterbridge')

    out = shell_out!('/opt/matterbridge/matterbridge -version').stdout.strip
    out.split(' ').include?(node['mod_chat']['matterbridge_version'])
  end
end

template '/etc/matterbridge.toml' do
  source 'matterbridge.toml.erb'
  sensitive true

  variables(
    irc: {
      port: '6697',
      server_password: node['mod_chat']['irc_server_passwd_hash'],
      ignored_users: node['mod_chat']['ignored_syncing_users'] + [node['mod_chat']['irc_bridge_username']],
      bridge_username: node['mod_chat']['irc_bridge_username'],
    },
    slack: {
      token: node['mod_chat']['slack_token'],
    },
    channels: node['mod_chat']['synced_channels'],
  )

  notifies :restart, 'systemd_unit[matterbridge.service]', :delayed if ::File.exist?('/etc/systemd/system/matterbridge.service')
end

systemd_unit 'matterbridge.service' do
  content(
    Unit: {
      Description: '(Slack <-> IRC) bridge',
      ConditionPathExists: '/etc/matterbridge.toml',
      After: 'network.target',
    },
    Service: {
      Type: 'simple',
      ExecStart: '/opt/matterbridge/matterbridge -conf /etc/matterbridge.toml',
      WorkingDirectory: '/tmp/matterbridge',
      Restart: 'on-failure',
      StandardOutput: 'syslog',
      StandardError: 'syslog',
      SyslogIdentifier: 'matterbridge',
      Wants: 'oragono.service',
    },
  )

  action [:create, :enable, :start]

  only_if { ::File.exist?('/opt/matterbridge/matterbridge') }
end
