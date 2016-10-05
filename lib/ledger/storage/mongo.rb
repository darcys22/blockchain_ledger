require "mongo"

module Ledger
  module Storage
    class MongoBackend
      def initialize(uri)
        @uri = uri
        @client = client = Mongo::Client.new(uri)
        @company = client[:ledger]
        @transactions = client[:transactions]
      end
      def createNew(genosis)
        @company.insert_one(genosis)
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
