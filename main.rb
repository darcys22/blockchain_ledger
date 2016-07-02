#!/usr/bin/env ruby

require './btxledger/ledger'
require 'sinatra'

file = File.read('genosis.json')
company = JSON.parse(file, :symbolize_names => true)

ledger = Btxledger::Ledger.new(company)

post '/transaction' do
  content_type :json
  request.body.rewind
  transaction = JSON.parse(request.body.read, :symbolize_names => true)
  token_info = ledger.parse_token!(transaction)

  if ( author = ledger.precheck(transaction, token_info, company)) then
    ledger.execute_transaction(transaction, company, author)
  end

  binding.pry

end

