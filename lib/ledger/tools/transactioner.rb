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
    class Transactioner
      #Creates Transaction JSON Journals that can be submitted to the webserver
      def initialize
        repeat = true
        @transactions = []
        while repeat do
          puts "Date:"
          date = Date.parse gets.strip
          puts "Desc:"
          desc = gets.strip
          lineItems = getLines()
          transaction = {"Prot"=>"Journal", "Txn" => {"Desc" => desc, "Date"=>date, "Postings"=>lineItems}}

          @transactions << Verifier.new(transaction).sign()

          puts "Exit?"
          exi = gets
          repeat = false if (exi[0].downcase() == "y")

        end
      end

      def to_hash
        return @transactions
      end

      def getLines()
        balance = 0
        repeat = true
        lines = []
        while repeat do
          puts "Account:"
          account = gets.strip
          puts "amount"
          amount = gets.chomp
          balance += amount.to_i
          lines << {"Account" => account, "Amt" => {"Value" => amount, "Cur" => "AUD"}}
          puts "Balance: #{balance}"
          puts "Exit?"
          exi = gets
          repeat = false if (exi[0].downcase() == "y")

        end
        return lines
      end

      def writeDefault()
        File.open("../data/"+ @transactions[0]["Txn"]["Desc"],"w"){|f| f.write(@transactions.to_json)}
      end

      def write(location)
        File.open(location,"w"){|f| f.write(@transactions.to_json)}
      end
    end
  end
end
