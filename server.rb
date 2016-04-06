#!/usr/bin/env ruby

#require 'sinatra'
require 'json'
require 'pry'
require 'date'


#binding.pry

#post '/transaction' do
  #content_type :json
  ##transaction = JSON.parse(params[:data],:symbolize_names => true)
  #request.body.rewind
  #transaction = JSON.parse(request.body.read, :symbolize_names => true)
  #binding.pry
  #transaction.to_json
#end
def main()
  file = File.read('genosis.json')
  company_file = JSON.parse(file, :symbolize_names => true)

  txn_file = File.read('transaction.json')
  transaction = JSON.parse(txn_file, :symbolize_names => true)

  token_info = parse_token(transaction[:Tkn])

  if (check_authorisation(token_info[:Public_Key]) == 0 && check_protocol(transaction[:Prot]) == 0) then
    execute_transaction(protocol(transaction[:Prot]), transaction[:txn], token_info)
  end

  binding.pry
end

# The protocol will actually be the thing executing the transaction in the end it is the program that we want to be editing our file
def protocol(prot)
  return 0
end

#if all is good, go ahead and process the transaction into the books
def execute_transaction(a,b,c)
  puts "Processing..."
  puts "Done."
end

# Will ensure that the protocol is authorised by the company
def check_protocol(proto)
  puts "Protocol Okay"
  return 0
end

# Will Check that the person posting the transaction has permission to do these things
def check_authorisation(requester)
  puts "Authorised"
  return 0
end

#Will Return the information from inside the token
def parse_token(toke)
  return {
    "Public Key" => "xyz",
    "Signature" => "abc",
    "Date" => Date.parse('2001-02-03')
  }
end

main()
