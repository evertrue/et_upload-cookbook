#!/usr/bin/env ruby2.0

gem 'aws-sdk', '~> 1.0'
require 'aws-sdk'
require 'shellwords'
require 'net/http'
require 'net/http/post/multipart'
require 'uri'
require 'json'
require 'zlib'
require 'date'
require 'yaml'
require 'pagerduty'
require 'sentry-raven'
require 'logger'
require 'pony'
require 'trollop'

def opts
  @opts ||= Trollop.options { opt :debug, 'Debug mode', short: '-d' }
end

def conf
  @conf ||= YAML.load_file('/opt/evertrue/config.yml')
end

def logger
  @logger ||= Logger.new($stdout.tty? ?STDOUT : conf[:log]).tap do |l|
    l.progname = 'process_uploads'
    l.level = opts[:debug] ? Logger::DEBUG : Logger::INFO
  end
end

def send_to_s3(org_slug, path)
  s3 = AWS::S3.new(
    access_key_id: conf[:aws_access_key_id],
    secret_access_key: conf[:aws_secret_access_key]
  )
  bucket = s3.buckets['onboarding.evertrue.com']
  now = DateTime.now.strftime('%Q')
  s3_filename = "#{now}-#{File.basename(path)}"
  bucket.objects["#{org_slug}/data/#{s3_filename}"].write(Pathname.new(path))
  s3_filename
end

def get_from_api(uri)
  uri = URI.parse(URI.encode(uri))

  http = Net::HTTP.new(uri.host, uri.post)
  http.use_ssl = true

  req = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(req)
  fail "API error, Response: #{response.code}, body: #{response.body}" unless response.code.to_i == 200

  JSON.parse(response.body)
end

def get_oid(org_slug)
  get_from_api(conf[:api_url] + "/auth/organizations/slug/#{org_slug}?" + auth_query_string)['id']
rescue => e
  logger.fatal "Error sending org_slug: #{org_slug}"
  raise e
end

def process(org_slug)

  oid = get_oid(org_slug)
  logger.debug "Got OID: #{oid}"

  exports = get_from_api(
    conf[:api_url] +
    "contacts/v2/exports/latest-scheduled?oid=#{oid}"
  )
  logger.debug "Retrieving Scheduled export for oid: #{oid}"

  #For each export"
    # read the "external path"
    # read from that external path in s3
    # rsync export file from s3 to sftp for current org
  #repeat


end

def main
  fail 'DEBUG_EMAIL required in debug mode' if opts[:debug] && !ENV['DEBUG_EMAIL']

  processed_users = conf[:unames].each_with_object([]) do |uname, processed_usernames|
    logger.debug "Processing user #{uname}"

    if uname == 'trial0928'
      logger.debug 'Skipping trial user trial0928'
      next
    end

    org_slug = uname.sub(/\d{4,}$/, '')

    logger.debug "Using org slug #{org_slug}"

    if process(org_slug)
      logger.debug "File for #{org_slug} was processed successfully"
      processed_usernames << uname
    end

  end
end

main
