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
require 'sentry-raven'
require 'logger'
require 'pony'
require 'trollop'
require 'fileutils'

def opts
  @opts ||= Trollop.options { opt :debug, 'Debug mode', short: '-d' }
end

def conf
  @conf ||= YAML.load_file('/opt/evertrue/config.yml')
end

def auth_query_string
  "auth=#{conf[:upload_auth_token]}&auth_provider=evertrueapptoken&app_key=#{conf[:upload_app_key]}"
end

def logger
  @logger ||= Logger.new($stdout.tty? ?STDOUT : conf[:log]).tap do |l|
    l.progname = 'process_scheduled_export'
    l.level = opts[:debug] ? Logger::DEBUG : Logger::INFO
  end
end

def get_from_api(uri)
  uri = URI.parse(URI.encode(uri))

  response = Net::HTTP.get_response URI uri
  fail "API error, Response: #{response.code}, body: #{response.body}" unless response.code.to_i == 200

  JSON.parse(response.body)
end

def get_oid(org_slug)
  get_from_api(conf[:api_url] + "/auth/organizations/slug/#{org_slug}?" + auth_query_string)['id']
rescue => e
  logger.fatal "Error sending org_slug: #{org_slug}"
  raise e
end

def process(uname, org_slug)!

  oid = get_oid(org_slug)
  logger.debug "Got OID: #{oid}"

  exports = get_from_api(
    conf[:api_url] +
    "/contacts/v2/exports/latest-scheduled?oid=#{oid}&#{auth_query_string}")

  logger.debug "Retrieving Scheduled export for oid: #{oid}"

  exports.each do |export|
    export_id = export["id"]
    export_name = export["name"]
    url = conf[:api_url] +
    "/contacts/v2/exports/#{export_id}?oid=#{oid}&#{auth_query_string}"
    export_path = "#{conf[:upload_dir]}/#{uname}/exports/#{export_name}"

    FileUtils.mkpath File.dirname export_path

    logger.info "Retrieving export from CAPI: #{url} and copying into SFTP "
    logger.info "Export path: #{export_path} "

    tmp_path = "#{conf[:upload_dir]}/tmp"
    FileUtils.mkpath tmp_path

    begin
      response = Net::HTTP.get_response URI url

      unless response.code == '200'
        fail "Failed to download file. Code #{response.code}. Body:\n#{response.body}"
      end

      File.open(export_path, 'w') { |f| f.write response.body }
      logger.info 'Unirest command succeeded'
    rescue RuntimeError => e
      logger.error "#{export_name} failed to download correctly because: #{e.message}"
    end
  end

end

def email_notify(msg)
  recipients =
    opts[:debug] ? ENV['DEBUG_EMAIL'] : [conf[:support_email], conf[:onboarding_email]].join(',')

  Pony.mail(
    to: recipients,
    from: 'sftp-uploader@priv.evertrue.com',
    subject: 'SFTP Uploader Alert',
    body: msg
  )
end

def main

  fail 'DEBUG_EMAIL required in debug mode' if opts[:debug] && !ENV['DEBUG_EMAIL']

  processed_users = conf[:unames].each_with_object([]) do |uname, processed_usernames|

    begin
    logger.debug "Processing user #{uname}"

    if uname == 'trial0928'
      logger.debug 'Skipping trial user trial0928'
      next
    end

    org_slug = uname.sub(/\d{4,}$/, '')

    logger.debug "Using org slug #{org_slug}"

      process(uname, org_slug)
      logger.debug "File for #{org_slug} was processed successfully"
      processed_usernames << uname

    rescue RuntimeError => e
      logger.error "Export failed because: #{e.message}"
    end
  end
end

main
