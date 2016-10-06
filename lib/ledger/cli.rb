require 'highline'

module Ledger
  class CLI

    attr_reader :options, :config_store

    def initialize
      @cli = HighLine.new
    end

    def run(args = ARGV)
      @cli.choose do |menu|
        menu.prompt = "Please choose from the following:"
        menu.choice(:Webserver) { Webserver.run! }
        #menu.choice(:Test) {::Ledger.load_default_file() binding.pry}
        menu.choice(:Reporter) { 
          x = Tools::Reporter.new()
          @cli.choose do |menu2|
            menu2.prompt = "Please choose from the following:"
            menu2.choice(:TB) { x.TrialBalance() }
            menu2.choice(:Ledger) { x.printLedger() }
          end
        }
        menu.default = :Webserver
        #menu.default = :Test
      end
      return 0
    end
  end
end
