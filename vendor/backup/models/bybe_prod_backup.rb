# encoding: utf-8

##
# Backup Generated: bybe_prod_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t bybe_prod_backup [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://meskyanichi.github.io/backup
#
Model.new(:bybe_prod_backup, 'Description for bybe_prod_backup') do

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    DB = YAML.load_file("#{DIR}/config/database.yml")
    # try to get RAILS_ENV variable,
    # if it is not set, use 'production'
    RAILS_ENV = ENV.fetch('RAILS_ENV'){'production'}
    puts "DBG: env #{RAILS_ENV}"
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = DB[RAILS_ENV]['database']
    db.username           = DB[RAILS_ENV]['username']
    db.password           = DB[RAILS_ENV]['password']
    db.host               = DB[RAILS_ENV]['host']
    db.additional_options = ["-x"]
    db.socket             = DB[RAILS_ENV]['socket']

    # Note: when using `skip_tables` with the `db.name = :all` option,
    # table names should be prefixed with a database name.
    # e.g. ["db_name.table_to_skip", ...]
    #db.skip_tables        = ["skip", "these", "tables"]
    #db.only_tables        = ["only", "these", "tables"]
    #db.additional_options = ["--quick", "--single-transaction"]
  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  store_with S3 do |s3|
    S3 = YAML.load_file("#{DIR}/config/s3.yml")

    # AWS Credentials
    s3.access_key_id     = S3[RAILS_ENV]['access_key_id']
    s3.secret_access_key = S3[RAILS_ENV]['secret_access_key']
    s3.fog_options = { :path_style => true }

    s3.region            = "us-east-1"
    s3.bucket            = S3[RAILS_ENV]['backup_bucket_name']
    s3.path              = S3[RAILS_ENV]['backup_path']
    s3.keep              = 31 # three weeks' worth
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

end
