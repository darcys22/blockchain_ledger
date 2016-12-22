require 'uri'
require 'openssl'

module Ledger
  module Tools
    class Creator
      #Creates a new company file and saves to storage
      def initialize()
        ::Ledger.initialise_config()
        @config = ::Ledger.config
        @storage = Storage.const_get(@config[:company].capitalize()).new(@config[:company_loc])
        @company = {}
      end

      def saveToStorage()
        @storage.createNew(@company)
      end

      def reset()
        @storage.drop()
      end

      def addCompany(genosis)
        @company = genosis
        reset()
        saveToStorage()
      end

      def walkthrough()
        prompt = "> "
        puts "Company Name:"
				print prompt
        name = gets.strip
        puts "Date:"
				print prompt
        date = Chronic.parse(gets.strip, :context => :past)
        puts "Roles:"
				print prompt
        roles = gets..gsub(/\s+/m, ' ').strip.split(" ")

        users = []
        puts "Enter a User? (Y/N)"
        print prompt

        while user_input = gets.chomp.upcase[0] # loop while getting user input
          case user_input
          when "Y"
            puts "Enter Username:"
            print prompt
            user = gets..gsub(/\s+/m, ' ').strip.split(" ")[0]
            puts "Enter Roles for User:"
            print prompt
            r = gets..gsub(/\s+/m, ' ').strip.split(" ")
            rsa_key = OpenSSL::PKey::RSA.new(2048)
            private_key = rsa_key
            public_key = rsa_key.public_key
            users.push({user => {:Roles => r, :SKey => private_key, :PKey => public_key})
            puts "Enter another user? (Y/N)"
            print prompt

          else
            break # make sure to break so you don't ask again
          end
        end

        protocols = []
        puts "Enter a protocol? (Y/N)"
        print prompt

        while user_input = gets.chomp.upcase[0] # loop while getting user input
          case user_input
          when "Y"
            puts "Enter protocol address:"
            print prompt
            p = URI.parse(gets.chomp)
            puts "Roles authorised to use protocol:"
            print prompt
            r = gets..gsub(/\s+/m, ' ').strip.split(" ")
            protocols.push({p => r})
            puts "Enter another protocol? (Y/N)"
            print prompt
          else
            break # make sure to break so you don't ask again
          end
        end
        protocols = protocols.map { |x| {"Address" => x.key.path, "Name" => File.basename(x.key.path).split(".")[0], "Privilege" => x.value} }
        users = users.map { |x| {"Name" => x.key, "Role" => x.value[:Roles], "Public_Key" => Base64.encode64(x.value[:PKey] } }
        #key = OpenSSL::PKey::RSA.new Base64.decode64 authN[:Public_Key
        company = {"Information"=> {"Name" => name, "Cutoff" => date, "Balance"=> date}, "Protocols" => protocols, "Authorised" => users }
      end
      
    end
  end
end
