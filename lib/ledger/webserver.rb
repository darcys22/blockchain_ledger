#!/usr/bin/env ruby

#require './lib/ledger'
require 'sinatra/base'

module Ledger
  class Webserver < Sinatra::Base

    file = File.read('../genosis.json')
    company = JSON.parse(file, :symbolize_names => true)

    ledger = Ledger.new(company)

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

