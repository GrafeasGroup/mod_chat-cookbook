name 'mod_chat'
maintainer 'David Alexander'
maintainer_email 'opensource@thelonelyghost.com'
license 'MIT'
description 'Installs/Configures mod chat compatibility tools'
long_description 'Installs/Configures mod chat compatibility tools'
version '0.2.0'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url 'https://github.com/GrafeasGroup/mod_chat-cookbook/issues'
source_url 'https://github.com/GrafeasGroup/mod_chat-cookbook'

supports 'centos', '>= 7.4'

if respond_to?(:attribute)
  attribute 'mod_chat/matterbridge_version',
    display_name: 'Matterbridge Version',
    description: 'Slack &larr;&rarr; IRC bridge version',
    type: 'string',
    required: 'optional',
    recipes: ['mod_chat::matterbridge'],
    default: '1.10.1'
  attribute 'mod_chat/oragono_version',
    display_name: 'Oragono Version',
    description: 'Oragono IRC server version',
    type: 'string',
    required: 'optional',
    recipes: ['mod_chat::irc'],
    default: '0.11.0'
  attribute 'mod_chat/synced_channels',
    display_name: 'Channels to Sync',
    description: 'Slack and IRC channels in which to sync',
    type: 'array',
    required: 'recommended',
    recipes: ['mod_chat::matterbridge'],
    default: ['general', 'dev', 'botstuffs']
  attribute 'mod_chat/ignore_syncing_users',
    display_name: 'Ignored Users',
    description: 'Slack and IRC bridge skips mirroring posts by the following user',
    type: 'array',
    required: 'recommended',
    recipes: ['mod_chat::matterbridge'],
    default: ['bubbles', 'kierra']
  attribute 'mod_chat/irc_bridge_username',
    display_name: 'IRC Nick (bridge)',
    description: 'Nick for the bridging user on the IRC side (Slack\'s is determined by the token)',
    type: 'string',
    required: 'optional',
    recipes: ['mod_chat::matterbridge'],
    default: 'kierra'
  attribute 'mod_chat/irc_server_passwd_hash',
    display_name: 'IRC server password (hash)',
    description: 'A password hash for access to the IRC server, generated by `oragono genpasswd`',
    type: 'string',
    required: 'required',
    recipes: ['mod_chat::matterbridge']
  attribute 'mod_chat/slack_token',
    display_name: 'Slack Legacy token',
    description: 'A token generated at https://api.slack.com/custom-integrations/legacy-tokens',
    type: 'string',
    required: 'required',
    recipes: ['mod_chat::matterbridge']
end

recipe 'mod_chat::default', 'Default recipe for installing/configuring everything'
recipe 'mod_chat::irc', 'A basic IRC server providing a connection on port 6667 and (TLS) 6697'
recipe 'mod_chat::matterbridge', 'A bridge for connecting Slack and IRC portals'

provides 'mod_chat::default'
provides 'mod_chat::irc'
provides 'mod_chat::matterbridge'
