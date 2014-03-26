# et_upload-cookbook

A cookbook to provision an SFTP server which a collection of chroot jailed users. Primarily aimed at situations where end users need simple, but limited, SCP/SFTP access to provide data (e.g., automated importing).

## Supported Platforms

* Ubuntu 12.04

## Attributes

Key                      | Type    | Description              | Default
---                      | ----    | -----------              | -------
`['openssh']['server']['port']`                    | Array  | Ports OpenSSH listens on           | `%w(22 43827)`
`['openssh']['server']['permit_root_login']`       | String | Allow remote root logins           | `'no'`
`['openssh']['server']['password_authentication']` | String | Allow password logins              | `'yes'`
`['openssh']['server']['subsystem']`               | String | Set a subsystem for OpenSSH        | `'sftp /usr/lib/sftp-server'`
`['openssh']['server']['match']`                   | Hash   | Provide a match config for OpenSSH | see below

```ruby
set['openssh']['server']['match'] = {
  'Group uploadonly' => {
    'chroot_directory' => '%h',
    'force_command' => 'internal-sftp',
    'allow_tcp_forwarding' => 'no'
  }
}
```

## Usage

### et_upload::default

Include `et_upload` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[et_upload::default]"
  ]
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: EverTrue, Inc. (<jeff@evertrue.com>)
