# frozen_string_literal: true

namespace :db do
  namespace :yaml do
    desc "dump db to YAML dir"
    task dump_dir: :environment do
      Helper = Struct.new :dumper, :loader, :extension, keyword_init: true

      dir = ENV["dir"] || Time.zone.now.strftime("%FT%H%M%S")
      helper = Helper.new dumper: Tasks::Db::YamlLoad::Dumper, loader: nil, extension: YamlDb::Helper.extension
      YamlDb::SerializationHelper::Base.new(helper).dump_to_dir("#{Rails.root}/db/#{dir}")
    end

    desc "Load from YAML dir"
    task load_dir: :environment do
      dir = ENV["dir"] || "base"
      Tasks::Db::YamlLoad::Loader.load_dir(dir)
    end
  end
end
