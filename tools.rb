#!/usr/bin/env ruby

require 'json'
require 'pry'
require 'date'

require 'openssl'
require 'base64'
require 'jwt'

class Verifier
  def initialize(location)
    file = File.read('genosis.json')
    company = JSON.parse(file, :symbolize_names => true)
    @location = location
    txn_file = File.read(location)
    @transaction = JSON.parse(txn_file, :symbolize_names => true)
  end

  def sign()
    @transaction.delete(:Tkn)
    key2 = OpenSSL::PKey::RSA.new File.read './keys/test-private_key.pem'
    digest = OpenSSL::Digest::SHA256.new
    @signature = key2.sign digest, @transaction.to_json
    @tkn = JWT.encode({:Signature => Base64.encode64(@signature), :Date => Date.today}, nil, 'none')
    @transaction.merge!({:Tkn => @tkn})
  end

  def write()
    File.open(@location,"w"){|f| f.write(@transaction.to_json)}
  end
end



def main()

  file = './data/transaction.json'
  verifier = Verifier.new(file)
  binding.pry

  #txn_file = File.read('./data/transaction.json')
  #transaction = JSON.parse(txn_file, :symbolize_names => true)
  ##transaction.merge!({:Tkn => "123"})
  #digest = OpenSSL::Digest::SHA256.new
  #key = OpenSSL::PKey::RSA.new Base64.decode64 company[:Authorised][0][:Public_Key]
  #key.verify digest, signature, transaction.to_json
  #Tkn = JWT.encode({:Signature => Base64.encode64(signature), :Date => Date.today}, nil, 'none')
  #transaction.merge!({:Tkn => Tkn})
  #token_info = parse_token(transaction[:Tkn])
  #transaction.delete(:Tkn)
  #File.open("transaction.json","w"){|f| f.write(transaction.to_json)}
end


main()
