#!/usr/bin/env ruby

#require './lib/ledger'
require 'sinatra/base'

module Ledger
  class Webserver < Sinatra::Base

    def self.get_company_file()
      file = File.read('../genosis.json')
      return JSON.parse(file, :symbolize_names => true)
    end

    ledger = Ledger.new(get_company_file())

    post '/transaction' do
      content_type :json
      request.body.rewind
      transactions = JSON.parse(request.body.read, :symbolize_names => true)
      for transaction in transactions
        token_info = ledger.parse_token!(transaction)

        if ( author = ledger.precheck(transaction, token_info, company)) then
          ledger.execute_transaction(transaction, company, author)
        end
      end
      

      binding.pry

    end

  end
end

