namespace :db do
  namespace :yaml do
    desc "dump db to YAML dir"
    task dump_dir: :environment do
      Tasks::Db::YamlLoad::DumpDir.run
    end

    desc "Load from YAML dir"
    task load_dir: :environment do
      dir = ENV["dir"] || "base"
      Tasks::Db::YamlLoad::Loader.load_dir(dir)
    end
  end
end
