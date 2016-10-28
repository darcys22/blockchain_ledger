module Ledger
  module Tools
    class Creator
      #Creates a new company file and saves to storage
      def initialize()
        ::Ledger.initialise_config()
        @config = ::Ledger.config
        @storage = Storage.const_get(@config[:company].capitalize()).new(@config[:company_loc])
        @company = {}
      end

      def saveToStorage()
        @storage.createNew(@company)
      end

      def reset()
        @storage.drop()
      end

      def addCompany(genosis)
        @company = genosis
        reset()
        saveToStorage()
      end

      def walkthrough(opts = {})
        puts "Get info from them make company"
      end
      
    end
  end
end
