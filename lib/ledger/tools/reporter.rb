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
    class Reporter
      #this obtains teh data from somerhwer and then can output a TB or GL Listing
      def initialize(location = "mongodb://btxledger:password@ds011705.mlab.com:11705/btxledger", options = {:file => false})
        if options[:file]
          file = File.read(location)
          @company = JSON.parse(file, :symbolize_names => true)
          @transactions = @company[:Transactions]
          @company.delete(:Transactions)
        else
          client = Mongo::Client.new(location)
          company = client[:ledger]
          transactions = client[:transactions]
          @transactions = []

          cursor = company.find
          cursor.each do |doc|
            @company = doc
          end

          cursor = transactions.find
          cursor.each do |doc|
            @transactions.push(doc)
          end

          client.close()
        end
      end

      def SaveToFile(location = "OutputCompany.dat")
        combined =  @company.merge({:Transactions => @transactions})
        File.open(location,"w"){|f| f.write(combined.to_json)}
      end

      def GeneralLedger(opts = {:Accounts => [], :OpeningDate => "2010-1-1", :ClosingDate => Date.today.to_s})
        tbOpening = self.TrialBalance({:BalanceDate => opts[:OpeningDate]})
        tbClosing = self.TrialBalance({:BalanceDate => opts[:ClosingDate]})
        openingDate = Chronic.parse(opts[:OpeningDate])
        closingDate = Chronic.parse(opts[:ClosingDate])
        glListing = {}
        tbClosing.each do |k, v|
          if (opts[:Accounts].empty? || opts[:Accounts].include?(k))
            glListing[k] ||= {}
            glListing[k][:ClosingBalance] = v
            glListing[k][:OpeningBalance] = tbOpening[k] || 0
          end
        end
        @transactions.each do |doc|
          date = Chronic.parse(doc[:Txn][:Date])
          if (date.between?(openingDate, closingDate))
            doc[:Txn][:Postings].each do |line|
              if (opts[:Accounts].empty? || opts[:Accounts].include?(line[:Account]))
                glListing[line[:Account].to_sym][:Txns] ||= []
                glListing[line[:Account].to_sym][:Txns].push({
                  :Date => date.strftime("%F"),
                  :Memo => doc[:Txn][:Payee],
                  :Amt  => line[:Amt][:Value]
                })
              end
            end
          end
        end
        return glListing
      end

      def TrialBalance(opts = {:BalanceDate => Date.today.to_s})
        accounts = {}
        @transactions.each do |doc|
          if (Chronic.parse(doc[:Txn][:Date], :context => :past) <= Chronic.parse(opts[:BalanceDate], :context => :past))
            doc[:Txn][:Postings].each do |line|
              accounts[line[:Account].to_sym] ||= 0
              accounts[line[:Account].to_sym] += line[:Amt][:Value].to_i
            end
          end
        end
        return accounts
      end

      def printLedger(opts = {})
        opts.empty? ? ledger = self.GeneralLedger() : ledger = self.GeneralLedger(opts)
        ledger.each do |k, v|
          puts "Account: " + k.to_s
          puts "Opening Balance: " + v[:OpeningBalance].to_s
          puts "---------------------------------"
          v[:Txns].each do |tx|
            print tx[:Date].to_s
            print "  "
            print tx[:Memo].to_s
            print "  "
            print tx[:Amt].to_s
            puts "  "
          end
          puts "---------------------------------"
          puts "Closing Balance: " + v[:ClosingBalance].to_s
          puts "---------------------------------"
          puts "---------------------------------"
        end

      end
      
      def printTB(opts = {})
        opts.empty? ? tb = self.TrialBalance() : tb = self.TrialBalance(opts)
        puts "---------------------------------"
        tb.each do |k, v|
          puts k.to_s + ": " + v.to_s
          puts "---------------------------------"
        end

      end

      def TrialCSV(opts = {})
        opts.empty? ? trialbal = self.TrialBalance() : trialbal = self.TrialBalance(opts)
        file = "output.csv"
        CSV.open( file, 'w' ) do |writer|
          trialbal.each do |k, v|
            writer << [k.to_s, v.to_s]
          end
        end
      end

      def ledgerToCSV(opts = {})
        opts.empty? ? ledger = self.GeneralLedger() : ledger = self.GeneralLedger(opts)
        file = "output.csv"
        CSV.open( file, 'w' ) do |writer|
          ledger.each do |k, v|
            v[:Txns].each do |tx|
              writer << [k.to_s, v[:OpeningBalance].to_s, v[:ClosingBalance].to_s, tx[:Date].to_s, tx[:Memo].to_s, tx[:Amt].to_s]
            end
          end
        end
      end

    end
  end
end
