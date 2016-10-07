require "mongo"

module Ledger
  module Storage
    class Mongo
      def initialize(uri)
        @uri = uri
        @client = client = ::Mongo::Client.new(uri)
        @company = client[:ledger]
        @transactions = client[:transactions]
      end
      def createNew(genosis)
        @company.insert_one(genosis)
      end

      def getCompany()
        cursor = @company.find
        company_file = {}
        cursor.each do |doc|
          company_file = doc
        end

        return company_file
      end

      def pushTransaction(transaction)
        @transactions.insert_one(transaction)
      end

      def drop()
        @company.drop()
        @transactions.drop()
      end

      def close()
        @client.close()
      end
    end
  end
end
