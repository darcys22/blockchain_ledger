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

      def walkthrough()
        puts "Company Name:"
        name = gets.strip
        puts "Date:"
        date = Chronic.parse(gets.strip, :context => :past)
        puts "Roles:"
        roles = gets..gsub(/\s+/m, ' ').strip.split(" ")
        #TODO Protocols
        #company = {"Information"=> {"Name" => name, "Cutoff" => date, "Balance"=> date},{"Desc" => desc, "Date"=>date, "Postings"=>lineItems}}
      end
      
    end
  end
end
