module Ledger
  class CLI

    attr_reader :options, :config_store

    def initialize
      @options = {}
      #TODO get configstore working
      #@config_store = ConfigStore.new
    end

    def run(args = ARGV)
    end
  end
end
