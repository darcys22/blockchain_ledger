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

      def sign(x)
        x.delete(:Tkn)
        digest = OpenSSL::Digest::SHA256.new
        @signature = @private_key.sign digest, x.to_json
        @tkn = JWT.encode({:Signature => Base64.encode64(@signature), :Date => Date.today}, nil, 'none')
        x.merge!({:Tkn => @tkn})
        return x
      end

      def signMultiple()
        multiple = []
        @transaction.each do |x|
          x.delete(:Tkn)
          digest = OpenSSL::Digest::SHA256.new
          @signature = @private_key.sign digest, x.to_json
          @tkn = JWT.encode({:Signature => Base64.encode64(@signature), :Date => Date.today}, nil, 'none')
          x[:Tkn] = @tkn
          multiple << x
        end
        @transaction = multiple
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

