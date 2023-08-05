module Tasks
  module Db
    module YamlLoad
      class DumpDir
        Helper = Struct.new :dumper, :loader, :extension, keyword_init: true

        class << self
          def run
            dir = ENV["dir"] || Time.zone.now.strftime("%FT%H%M%S")
            helper = Helper.new dumper: Tasks::Db::YamlLoad::Dumper, loader: nil, extension: YamlDb::Helper.extension
            YamlDb::SerializationHelper::Base.new(helper).dump_to_dir(Rails.root.join("db/#{dir}").to_s)
          end
        end
      end
    end
  end
end
