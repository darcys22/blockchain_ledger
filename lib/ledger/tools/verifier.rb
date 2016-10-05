#!/usr/bin/env ruby

require 'json'
require 'pry'
require 'date'
require 'csv'

require 'openssl'
require 'base64'
require 'jwt'
require 'httparty'
require 'chronic'
require 'mongo'

module Ledger
  module Tools
    class Verifier
      def initialize(location, options = {:file => false})
        file = File.read('genosis.json')
        company = JSON.parse(file, :symbolize_names => true)
        if options[:file]
          @location = location
          txn_file = File.read(location)
          @transaction = JSON.parse(txn_file, :symbolize_names => true)
        else
          @transaction = location
        end
      end

      def sign()
        @transaction.delete(:Tkn)
        key2 = OpenSSL::PKey::RSA.new File.read './keys/test-private_key.pem'
        digest = OpenSSL::Digest::SHA256.new
        @signature = key2.sign digest, @transaction.to_json
        @tkn = JWT.encode({:Signature => Base64.encode64(@signature), :Date => Date.today}, nil, 'none')
        @transaction.merge!({:Tkn => @tkn})
        return @transaction
      end

      def send()
        url = 'http://localhost:4567/transaction'
        response = HTTParty.post(url,:body => @transaction.to_json,:headers => { 'Content-Type' => 'application/json' } )
        response.parsed_response
      end

      def write()
        File.open(@location,"w"){|f| f.write(@transaction.to_json)}
      end

    end
  end
end

