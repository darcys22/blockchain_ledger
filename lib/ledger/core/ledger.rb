#!/usr/bin/env ruby

require 'json'
require 'pry'
require 'date'
require 'openssl'
require 'base64'
require 'jwt'

module Ledger
  class Ledger

    def initialize()
      ::Ledger.initialise_config()
      @config = ::Ledger.config
      @storage = Storage.const_get(@config[:company].capitalize()).new(@config[:company_loc])
      @company = @storage.getCompany()
      for protocol in @company[:Protocols]
        require '../protocols/' + protocol[:Name].downcase()
      end
    end

    def getCompany()
      return @company
    end

    def getPrivateKey()
      return @config[:private_key]
    end

    def getPublicKey()
      return @config[:public_key]
    end

    def parse_transactions(transactions)
      for transaction in transactions
        token_info = parse_token!(transaction)
        if ( author = precheck(transaction, token_info, @company)) then
          execute_transaction(transaction, @company, author)
        end
      end
    end

    #Will Return the information from inside the token
    def parse_token!(transaction)
      return JWT.decode transaction[:Tkn], nil, false
    end

    # Checking the authorisationa nd the protocols are allowed
    def precheck(transaction, token, company)
      authN = get_protocol_auth_level(transaction[:Prot], company)
      return check_authorisation(token[0]["Signature"], transaction, company, authN)
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

    # Will Check that the person posting the transaction has permission to do these things
    def check_authorisation(signature, transaction, company, required_privilege)
      digest = OpenSSL::Digest::SHA256.new
      begin 
        author = company[:Authorised].find do |authN| 
          key = OpenSSL::PKey::RSA.new Base64.decode64 authN[:Public_Key] 
          key.verify digest, Base64.decode64(signature), transaction.tap{ |h| h.delete(:Tkn) }.to_json
        end
        raise "Requester Not Authorised" if (!required_privilege.include?(author[:Role]))
      rescue 
        raise "Requester Not Authorised"
      end
      return author
    end


    #if all is good, go ahead and process the transaction into the books
    def execute_transaction(transaction, company, author)
      puts "Processing..."
      check_balances(transaction)
      check_date(transaction, company)
      #done by protocol
      eval(transaction[:Prot]).execute(company,transaction)
      transaction_details = {:Created => DateTime.now(), :Author => author[:Public_Key] }
      save_to_backend(transaction.merge(transaction_details))
      puts "Done."
    end

    #Make sure that all the amounts in the transaction balance to zero
    def check_balances(transaction)
      unless ( transaction[:Txn][:Postings].reduce(0) { |sum,x| sum +x[:Amt][:Value].to_i } == 0 )
        raise "Unbalanced Transaction"
      end
    end

    #Make sure that the transaction date is not before cutoff/balance date
    def check_date(transaction, company)
      if [Date.parse(company[:Information][:Cutoff]), Date.parse(company[:Information][:Balance])].any? do |x| 
        x > Date.parse(transaction[:Txn][:Date]) 
      end
        raise "Pre Cutoff Date"
      end
    end

    #save the information to the backend
    def save_to_backend(transaction)
      @storage.pushTransaction(transaction)
    end

  end
end

