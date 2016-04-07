#!/usr/bin/env ruby

#require 'sinatra'
require 'json'
require 'pry'
require 'date'



#post '/transaction' do
  #content_type :json
  ##transaction = JSON.parse(params[:data],:symbolize_names => true)
  #request.body.rewind
  #transaction = JSON.parse(request.body.read, :symbolize_names => true)
  #transaction.to_json
#end
def main()
  file = File.read('genosis.json')
  company = JSON.parse(file, :symbolize_names => true)

  txn_file = File.read('transaction.json')
  transaction = JSON.parse(txn_file, :symbolize_names => true)

  token_info = parse_token(transaction[:Tkn])

  if (precheck(transaction, token_info, company)) then
    execute_transaction(protocol(transaction[:Prot]), transaction[:txn], token_info)
  end

  binding.pry
end

# Checking the authorisationa nd the protocols are allowed
def precheck(transaction, token, company)
  check_signature(token[:Signature], transaction[:Txn])
  authN = get_protocol_auth_level(transaction[:Prot], company)
  return check_authorisation(token[:Public_Key], company, authN)
end

def check_signature(signature, transaction)
  return 0
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

# Will Check that the person posting the transaction has permission to do these things
def check_authorisation(requester, company, required_privilege)
  begin 
    authN = required_privilege.include?(company[:Authorised].find {|authN| authN[:Public_Key] == requester}[:Role])
  rescue 
    raise "Requester Not Authorised"
  end
  return authN
end

# Will ensure that the protocol is authorised by the company
def get_protocol_auth_level(proto, company)
  begin 
    authN = company[:Protocols].find {|protocol| protocol[:Name] == proto}[:Privilege]
  rescue 
    raise "Protocol Not Authorised"
  end
  return authN
end


#Will Return the information from inside the token
def parse_token(toke)
  return {
    :Public_Key => "Xhife7i43",
    :Signature => "abc",
    :Date => Date.parse('2001-02-03')
  }
end

main()