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
        menu.choice(:Webserver) { Webserver.run!() }
        menu.choice(:Reporter) { reporter() }
        menu.choice(:New_Transaction) { transacter()}
        menu.choice(:Verify_Transaction) { importer(@cli.ask("Location: "))}
        menu.choice(:New_Company) { creator(@cli.ask("Location: "))}
        menu.choice(:Exit) {}
        menu.default = :Webserver
      end
      return 0
    end

    def reporter()
      x = Tools::Reporter.new()
      @cli.choose do |menu2|
        menu2.prompt = "Please choose from the following:"
        menu2.choice(:TB) { x.printTB() }
        menu2.choice(:Ledger) { x.printLedger() }
      end
    end

    def importer(location)
      file = File.read(location)
      data = JSON.parse(file, {:symbolize_names => true})
      x = Tools::Verifier.new(data)
      x.signMultiple()
      x.write(location + "_signed")
    end

    def creator(location)
      file = File.read(location)
      data = JSON.parse(file, {:symbolize_names => true})
      x = Tools::Creator.new().addCompany(data)
    end
    
    def transacter()
      x = Tools::Transactioner.new().writeDefault()
    end

  end
end
