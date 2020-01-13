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

## Files

### recipe/scripts

Performs several setup steps that are required for processing uploads and exports.  This script does the following:

1. Setup the rotation schedule for /var/log/process\_uploads.log and /var/log/process\_scheduled\_exports.log
2. Create /opt/evertrue/config.xml
3. Setup cron schedules for processing uploads and exports and removing old upload and export files

### recipe/users

Manages folder structure of all upload users.  This script does the following:

1. Load the upload.json content from the users databag
2. For each user do the following:
3. Determine the home folder of the user.  For most users the folder will be /mnt/dev0/evertrue/users/{username}.  However, if the parent\_user and partner values have been set for the user then the home folder will be a subfolder under the parent\_user named for the partner.
4. If the user's action is remove then delete the user's home directory and all files, otherwise do the following:
  5. Create the OS user and set the home folder
  6. Create the user's home folder
  7. If the user is using SSH keys then store those in the .ssh folder
  8. Create the uploads and exports folders under the home folder

An example user object from the upload.json file:

```
  "givingtreedemo": {
    "uid": 10150,
    "ssh_keys": [],
    "comment": "Chelsea Leavitt GivingTree Demo",
    "password": "abc"
  }
```

An example parter user object:

```
  "givingtreedemo-hustle": {
    "uid": 10663,
    "ssh_keys": [],
    "parent_user": "givingtreedemo",
    "partner": "hustle",
    "comment": "GivingTree Demo Hustle Access",
    "password": "abc"
  }
```


### files/default/process\_uploads

Sends files from the uploads directory for import processing.  This script does the following:

1. Load /opt/evertrue/config.xml
2. For each value in unames, do the following:
3. Get all file names stored under any uploads folder under the uname home folder
4. Ignore any upload file that does not have a csv, gz or zip extension.
5. Determine the type of import from the name of the upload file
6. Copy the upload file to the org's S3 folder
7. Check that a mapping exists for the upload file's headers
8. Post the upload file to the importer
9. If a mapping exists then queue the import file for processing if `ET.Importer.IngestionMode = AutoIngest`
10. If a mapping does not exist then notify support and set `ET.Importer.IngestionMode = NotifyOnly`

Logs for this script are saved to /var/log/process\_uploads.log

### files/default/process\_scheduled\_exports

Copies scheduled export files to the org's SFTP folder for download.  This script does the following:

1. Load /opt/evertrue/config.xml
2. For each value in unames, do the following:
3. Get the oid from the uname value.  Note that not all unames map directly to an org slug
4. Get the latest scheduled exports for the oid via /contacts/v2/exports/latest-scheduled
5. Download each export file via /contacts/v2/exports
6. Save the export file to the uname home exports folder

Logs for this script are saved to /var/log/process\_scheduled\_exports.log

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

For testing purposes, the users upload data bag item exists. The password for each user is `password`, salted & encrypted to best resemble a real password & allow for logging in via SFTP to do manual testing of SFTP functionality.

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: EverTrue, Inc. (<jeff@evertrue.com>)
