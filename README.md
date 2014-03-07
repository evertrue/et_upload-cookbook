# et_upload-cookbook

A cookbook to provision an SFTP server which a collection of chroot jailed users. Primarily aimed at situations where end users need simple, but limited, SCP/SFTP access to provide data (e.g., automated importing).

## Supported Platforms

* Ubuntu 12.04

## Attributes

Key                      | Type    | Description              | Default
---                      | ----    | -----------              | -------
`['et_upload']['bacon']` | Boolean | whether to include bacon | `true`

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
