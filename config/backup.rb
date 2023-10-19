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
  backup_rails_env = ENV["RAILS_ENV"] || "development"

  require "yaml"
  require "erb"
  template = ERB.new File.read database_yml
  config = YAML.safe_load template.result binding

  ##
  # MySQL [Database]
  #
  database PostgreSQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = config[backup_rails_env]["database"]
    db.username           = config[backup_rails_env]["username"]
    db.password           = config[backup_rails_env]["password"]
    db.host               = config[backup_rails_env]["host"]
    db.port               = config[backup_rails_env]["port"]
    db.socket             = config[backup_rails_env]["socket"]
    # Note: when using `skip_tables` with the `db.name = :all` option,
    # table names should be prefixed with a database name.
    # e.g. ["db_name.table_to_skip", ...]
    db.skip_tables        = []
    # db.skip_tables        = ["skip", "these", "tables"]
    # db.only_tables        = ["only", "these" "tables"]
    # skip table creates (-t) and use full inserts (-c) and attempt postgres-compatible mode
    # db.additional_options = ["--quick", "--single-transaction", "--compatible=postgresql", "-c", "-t"]
    # db.additional_options = ["--quick", "--single-transaction", "-c", "--no-tablespaces"]
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
