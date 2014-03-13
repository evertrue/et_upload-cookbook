# ssh config
# set['openssh']['client']['host'] = '*'
# set['openssh']['client']['send_env'] = 'LANG LC_*'
# set['openssh']['client']['hash_known_hosts'] = 'yes'
# set['openssh']['client']['gssapi_authentication'] = 'yes'
# set['openssh']['client']['gssapi_delegate_credentials'] = 'no'

# sshd config
set['openssh']['server']['port'] = %w(22 43827)
# set['openssh']['server']['protocol'] = '2'
# set['openssh']['server']['host_key_rsa'] = '/etc/ssh/ssh_host_rsa_key'
# set['openssh']['server']['host_key_dsa'] = '/etc/ssh/ssh_host_dsa_key'
# set['openssh']['server']['host_key_ecdsa'] = '/etc/ssh/ssh_host_ecdsa_key'
# set['openssh']['server']['use_privilege_separation'] = 'yes'
# set['openssh']['server']['key_regeneration_interval'] = '3600'
# set['openssh']['server']['server_key_bits'] = '768'
# set['openssh']['server']['syslog_facility'] = 'AUTH'
# set['openssh']['server']['log_level'] = 'INFO'
# set['openssh']['server']['login_grace_time'] = '120'
set['openssh']['server']['permit_root_login'] = 'no'
# set['openssh']['server']['strict_modes'] = 'yes'
# set['openssh']['server']['r_s_a_authentication'] = 'yes'
# set['openssh']['server']['pubkey_authentication'] = 'yes'
# set['openssh']['server']['ignore_rhosts'] = 'yes'
# set['openssh']['server']['rhosts_r_s_a_authentication'] = 'no'
# set['openssh']['server']['hostbased_authentication'] = 'no'
# set['openssh']['server']['permit_empty_passwords'] = 'no'
# set['openssh']['server']['challenge_response_authentication'] = 'no'
set['openssh']['server']['password_authentication'] = 'yes'
# set['openssh']['server']['x11_forwarding'] = 'yes'
# set['openssh']['server']['x11_display_offset'] = '10'
# set['openssh']['server']['print_motd'] = 'no'
# set['openssh']['server']['print_last_log'] = 'yes'
# set['openssh']['server']['t_c_p_keep_alive'] = 'yes'
# set['openssh']['server']['accept_env'] = 'LANG LC_*'
set['openssh']['server']['subsystem'] = 'sftp /usr/lib/sftp-server'
# set['openssh']['server']['use_p_a_m'] = 'yes'
# set['openssh']['server']['use_d_n_s'] = 'no'

set['openssh']['server']['match'] = {
  'Group uploadonly' => {
    'chroot_directory' => '%h',
    'force_command' => 'internal-sftp',
    'allow_tcp_forwarding' => 'no'
  }
}
