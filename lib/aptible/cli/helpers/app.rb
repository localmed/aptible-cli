require 'aptible/api'
require 'git'

module Aptible
  module CLI
    module Helpers
      module App
        include Helpers::Token

        def ensure_app(options = {})
          handle = options[:app] || ensure_default_handle
          app = app_from_handle(handle)
          return app if app
          fail Thor::Error, "Could not find app #{handle}"
        end

        def app_from_handle(handle)
          Aptible::Api::App.all(token: fetch_token).find do |a|
            a.handle == handle
          end
        end

        def ensure_default_handle
          return default_handle if default_handle
          fail Thor::Error, <<-ERR.gsub(/\s+/, ' ').strip
            Could not find app in current working directory, please specify
            with --app
          ERR
        end

        def default_handle
          git = Git.open(Dir.pwd)
          aptible_remote = git.remote(:aptible).url || ''
          aptible_remote[/:(?<name>.+)\.git/, :name]
        rescue
          nil
        end
      end
    end
  end
end
