#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require 'pry'

file = File.read('genosis.json')
company_file = JSON.parse(file, :symbolize_names => true)

#binding.pry

#post '/transaction' do
  #content_type :json
  ##transaction = JSON.parse(params[:data],:symbolize_names => true)
  #request.body.rewind
  #transaction = JSON.parse(request.body.read, :symbolize_names => true)
  #binding.pry
  #transaction.to_json
#end

txn_file = File.read('transaction.json')
transaction = JSON.parse(txn_file, :symbolize_names => true)
binding.pry
