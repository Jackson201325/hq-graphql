# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strong
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/combustion/all/combustion.rbi
#
# combustion-1.1.2
module Combustion
  def path; end
  def path=(obj); end
  def schema_format; end
  def schema_format=(obj); end
  def self.include_capybara_into(config); end
  def self.include_database(modules, options); end
  def self.include_rspec; end
  def self.initialize!(*modules, &block); end
  def self.path; end
  def self.path=(obj); end
  def self.schema_format; end
  def self.schema_format=(obj); end
  def self.setup_environment; end
  def self.setup_environment=(obj); end
  def setup_environment; end
  def setup_environment=(obj); end
end
class Combustion::Application < Rails::Application
  def self.configure_for_combustion; end
end
class Combustion::Configurations::ActionController
  def self.call(config); end
end
class Combustion::Configurations::ActionMailer
  def self.call(config); end
end
class Combustion::Configurations::ActiveRecord
  def self.call(config); end
end
class Combustion::Databases::Base
  def base; end
  def configuration; end
  def connection(*args, &block); end
  def establish_connection(*args, &block); end
  def initialize(configuration); end
  def reset; end
end
class Combustion::Databases::Firebird < Combustion::Databases::Base
  def reset; end
end
class Combustion::Databases::MySQL < Combustion::Databases::Base
  def charset; end
  def charset_error; end
  def collation; end
  def create; end
  def create_as_root(error); end
  def creation_options; end
  def drop; end
  def error_class; end
  def grant_statement; end
  def request_password(error); end
  def rescue_create_from(error); end
  def reset; end
end
class Combustion::Databases::Oracle < Combustion::Databases::Base
  def reset; end
end
class Combustion::Databases::PostgreSQL < Combustion::Databases::Base
  def create; end
  def drop; end
  def encoding; end
  def postgres_configuration; end
  def reset; end
  def schema_search_path; end
end
class Combustion::Databases::SQLServer < Combustion::Databases::Base
  def reset; end
end
class Combustion::Databases::SQLite < Combustion::Databases::Base
  def create; end
  def drop; end
  def exists?; end
  def file; end
  def path; end
end
class Combustion::Database::LoadSchema
  def call; end
  def load_ruby_schema; end
  def load_sql_schema; end
  def schema_format; end
  def self.call; end
end
class Combustion::Database::LoadSchema::UnknownSchemaFormat < StandardError
end
class Combustion::Database::Migrate
  def base_migration_paths; end
  def call; end
  def engine_migration_paths; end
  def engine_path; end
  def engine_paths_exist_in?(paths); end
  def migration_context; end
  def migrator; end
  def paths; end
  def self.call; end
end
class Combustion::Database::Reset
  def call; end
  def database_yaml; end
  def initialize; end
  def operator_class(adapter); end
  def resettable_db_configs; end
  def self.call; end
end
class Combustion::Database::Reset::UnsupportedDatabase < StandardError
end
module Combustion::Databases
end
class Combustion::Database
  def self.setup(options = nil); end
end
module Combustion::Configurations
end
