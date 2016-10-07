require 'sinatra/base'

module Ledger
  class Webserver < Sinatra::Base
    def self.run!
      @@ledger = Ledger.new()
      super
    end

    post '/transaction' do
      content_type :json
      request.body.rewind
      transactions = JSON.parse(request.body.read, :symbolize_names => true)
      @@ledger.parse_transactions(transactions)
      return 200
    end
  end
end

