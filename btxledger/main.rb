require './btxledger/base'
require 'sinatra'

module Btxledger
  class Application < Base
      file = File.read('genosis.json')
      company = JSON.parse(file, :symbolize_names => true)
      load_protocols(company)

      Sinatra::Application.post '/transaction' do
        content_type :json
        request.body.rewind
        transaction = JSON.parse(request.body.read, :symbolize_names => true)
        token_info = parse_token!(transaction)

        if ( author = precheck(transaction, token_info, company)) then
          execute_transaction(transaction, company, author)
        end
        binding.pry

      end

  end
end
