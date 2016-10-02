# blockchain_ledger

just run main.rb to get to the webserver running. post a transaction to localhost:4567/transaction to get to binding.pry. That will leave you in the position wehre you can view the company file. it will have a transactions array with the recent transaction.

transaction examples in data
curl -v -X POST -d @./data/transaction.json localhost:4567/transaction --header "Content-Type:text/json"    

in tools you can use Transactioner.new() to create a new file (For a transaction)

tools.rb signs transactions with the test keys

TODO
create the toolset for viewing TB and shit
  output GL Listing
Tools make a big file of transactions
