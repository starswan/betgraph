# frozen_string_literal: true

#
# $Id$
#

##
# Backup Generated: backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t backup [-c <path_to_configuration_file>]
#
Backup::Model.new(:db_backup, "Backup betgraph database") do
  # I presume rails isn't loaded udring this script...
  database_yml = File.expand_path("../../config/database.yml", __FILE__)
  BACKUP_RAILS_ENV = ENV["RAILS_ENV"] || "development"

  require "yaml"
  require "erb"
  template = ERB.new File.read database_yml
  config = YAML.safe_load template.result binding

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = config[BACKUP_RAILS_ENV]["database"]
    db.username           = config[BACKUP_RAILS_ENV]["username"]
    db.password           = config[BACKUP_RAILS_ENV]["password"]
    db.host               = config[BACKUP_RAILS_ENV]["host"]
    db.port               = config[BACKUP_RAILS_ENV]["port"]
    db.socket             = config[BACKUP_RAILS_ENV]["socket"]
    # Note: when using `skip_tables` with the `db.name = :all` option,
    # table names should be prefixed with a database name.
    # e.g. ["db_name.table_to_skip", ...]
    db.skip_tables        = []
    # db.skip_tables        = ["skip", "these", "tables"]
    # db.only_tables        = ["only", "these" "tables"]
    # skip table creates (-t) and use full inserts (-c) and attempt postgres-compatible mode
    # db.additional_options = ["--quick", "--single-transaction", "--compatible=postgresql", "-c", "-t"]
    db.additional_options = ["--quick", "--single-transaction", "-c", "--no-tablespaces"]
    # Optional: Use to set the location of this utility
    #   if it cannot be found by name in your $PATH
    # db.mysqldump_utility = "/opt/local/bin/mysqldump"
  end

  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    # local.path       = "db/db_backup"
    local.path       = "db"
    local.keep       = 5
  end

  ##
  # Gzip [Compressor]
  #
  # compress_with Gzip
end
