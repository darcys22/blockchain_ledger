#!/usr/bin/env ruby

require 'json'
require 'pry'
require 'date'

require 'openssl'
require 'base64'
require 'jwt'
require 'httparty'
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
      #TODO: Read in from file, populat @transactions & @company
      file = File.read(location)
      company = JSON.parse(file, :symbolize_names => true)
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

  def GeneralLedger(opts = {})
    return 0
  end

  def TrialBalance(opts = {})
    @accounts = {}
    @transactions.each do |doc|
      doc[:Txn][:Postings].each do |line|
        @accounts[line[:Account].to_sym] ||= 0
        @accounts[line[:Account].to_sym] += line[:Amt][:Value].to_i
      end
    end
    puts @accounts
  end

end

def main()

  #file = './data/transaction.json'
  #file = './data/x.rb'
  #verifier = Verifier.new(file,{:file => true})
  binding.pry
  x = Reporter.new()
  x.TrialBalance()

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
