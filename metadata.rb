name             'et_upload'
maintainer       'EverTrue, Inc.'
maintainer_email 'jeff@evertrue.com'
license          'Apache 2.0'
description      'Installs/Configures et_upload'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.2'

depends 'cron',         '= 1.3.8'
depends 'yum',          '~> 3.1'
depends 'apt',          '~> 2.3'
depends 'openssh',      '~> 1.3'
depends 'apt',          '~> 2.3'
