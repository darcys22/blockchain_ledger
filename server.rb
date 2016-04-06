#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require 'pry'

file = File.read('genosis.json')
company_file = JSON.parse(file)

#binding.pry

get '/transaction' do
  "Hello World"
end
