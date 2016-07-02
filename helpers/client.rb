#!/usr/bin/env ruby

require 'json'
require 'pry'
require 'date'

require 'openssl'
require 'base64'
require 'jwt'




def main()
  file = File.read('genosis.json')
  company = JSON.parse(file, :symbolize_names => true)

  txn_file = File.read('transaction.json')
  transaction = JSON.parse(txn_file, :symbolize_names => true)
  #transaction.merge!({:Tkn => "123"})
  digest = OpenSSL::Digest::SHA256.new
  key = OpenSSL::PKey::RSA.new Base64.decode64 company[:Authorised][0][:Public_Key]
  key2 = OpenSSL::PKey::RSA.new File.read 'test-private_key.pem'
  signature = key2.sign digest, transaction.to_json
  key.verify digest, signature, transaction.to_json
  Tkn = JWT.encode({:Signature => Base64.encode64(signature), :Date => Date.today}, nil, 'none')
  transaction.merge!({:Tkn => Tkn})

  #token_info = parse_token(transaction[:Tkn])
  binding.pry
  #transaction.delete(:Tkn)
  #File.open("transaction.json","w"){|f| f.write(transaction.to_json)}
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
