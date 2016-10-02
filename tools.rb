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

  def write(location)
    File.open(location,"w"){|f| f.write(@transactions.to_json)}
  end
end


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

def main()

  #file = './data/transaction.json'
  #file = './data/x.rb'
  #verifier = Verifier.new(file,{:file => true})
  x = Reporter.new()
  x.TrialCSV()

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
