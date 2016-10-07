require 'yaml'
require 'openssl'

#Config File defaults to ~/.ledger/config
#:company -> how the company file is retrieved
#- "file" for manual file
#- "mongo" for mongodb company file
#if file :company_file_loc required
#:company_file_loc -> where the file is located

module Ledger
    #:mongo_uri => "mongodb://btxledger:password@ds011705.mlab.com:11705/btxledger",
  @config = {
    :config_dir => Dir.home() + "/.ledger",
    :config_file => Dir.home() + "/.ledger/config",
    :keys_loc => Dir.home() + "/.ledger/keys",
    :public_key_loc => Dir.home() + "/.ledger/keys/test-public_key.pem",
    :private_key_loc => Dir.home() + "/.ledger/keys/test-private_key.pem",
    :company => "file",
    :company_loc => "../data/company.json"
  }

  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v}
  end

  def self.load_keys()
    @config[:public_key] = OpenSSL::PKey::RSA.new File.read @config[:public_key_loc]
    @config[:private_key] = OpenSSL::PKey::RSA.new File.read @config[:private_key_loc]
  end

  def self.configure_with(path_to_yaml_file)
    begin
      config = YAML::load(IO.read(path_to_yaml_file))
    rescue Errno::ENOENT
      log(:warning, "YAML configuration file couldn't be found. Using defaults."); return
    rescue Psych::SyntaxError
      log(:warning, "YAML configuration file contains invalid syntax. Using defaults."); return
    end

    configure(config)
  end

  def self.config
    @config
  end

  def self.load_default_file()
    configure_with(@config[:config_file])
  end

  def self.initialise_config
    load_keys()
    load_default_file()
  end


end
