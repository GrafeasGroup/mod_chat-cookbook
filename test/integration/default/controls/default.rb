# vim: syn=inspec

control 'mod_chat-matterbridge' do
  title 'Matterbridge settings'
  desc <<-EOH
    Confirms Matterbridge is configured for Slack <-> IRC bridging
  EOH
  impact 0.1

  describe file('/etc/matterbridge.toml') do
    it { should exist }
    its('content') { should match(/^\s*\[slack\./) }
    its('content') { should match(/^\s*\[irc\./) }
  end

  describe directory('/opt/matterbridge') do
    it { should exist }
  end

  describe file('/opt/matterbridge/matterbridge') do
    it { should exist }
    it { should be_executable }
    it 's version should be 1.10.1' do
      cmd = command('/opt/matterbridge/matterbridge -version')
      expect(cmd.stdout.strip).to include '1.10.1'
    end
  end

  describe service('matterbridge') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

control 'mod_chat-irc' do
  title 'Oragono IRC server'
  desc <<-EOH
    Ensures IRC server is configured
  EOH
  impact 0.1

  describe user('oragono') do
    it { should exist }
  end

  describe directory('/tmp/oragono') do
    it { should exist }
  end

  describe file('/tmp/oragono/ircd.db') do
    it { should exist }
    it { should be_readable.by_user('oragono') }
    it { should be_writable.by_user('oragono') }
  end

  describe directory('/etc/oragono') do
    it { should exist }
  end

  describe file('/etc/oragono/tls.key') do
    it { should exist }
    it { should be_readable.by_user('oragono') }
  end

  describe file('/etc/oragono/tls.crt') do
    it { should exist }
    it { should be_readable.by_user('oragono') }
  end

  describe file('/etc/oragono/ircd.yaml') do
    it { should exist }
    its('content') { should include '---' }
  end

  describe file('/etc/oragono/ircd.motd') do
    it { should exist }
    its('content') { should_not be_empty }
  end

  describe directory('/opt/oragono') do
    it { should exist }
  end

  describe file('/opt/oragono/oragono') do
    it { should exist }
    it { should be_executable }

    it 's version should be 0.11.0' do
      cmd = command('/opt/oragono/oragono --version')
      expect(cmd.stdout.strip).to include '0.11.0'
    end
  end

  describe service('oragono') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
