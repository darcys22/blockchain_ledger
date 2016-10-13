#require 'json'
#require 'pry'
#require 'date'
#require 'csv'

#require 'openssl'
#require 'base64'
#require 'jwt'
#require 'httparty'
#require 'chronic'
#require 'mongo'

module Ledger
  module Tools
    class Verifier
      def initialize(location)
        ::Ledger.initialise_config()
        @ledger = Ledger.new
        @transaction = location
        @private_key = @ledger.getPrivateKey()
        @public_key = @ledger.getPublicKey()
      end

      def sign()
        @transaction.delete(:Tkn)
        digest = OpenSSL::Digest::SHA256.new
        @signature = @private_key.sign digest, @transaction.to_json
        @tkn = JWT.encode({:Signature => Base64.encode64(@signature), :Date => Date.today}, nil, 'none')
        @transaction.merge!({:Tkn => @tkn})
        return @transaction
      end

      def send()
        url = 'http://localhost:4567/transaction'
        response = HTTParty.post(url,:body => @transaction.to_json,:headers => { 'Content-Type' => 'application/json' } )
        response.parsed_response
      end

      def write(location)
        File.open(location,"w"){|f| f.write(@transaction.to_json)}
      end

    end
  end
end

