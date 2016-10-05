# blockchain_ledger

just run main.rb to get to the webserver running. post a transaction to localhost:4567/transaction to get to binding.pry. That will leave you in the position wehre you can view the company file. it will have a transactions array with the recent transaction.

transaction examples in data
curl -v -X POST -d @./data/transaction.json localhost:4567/transaction --header "Content-Type:text/json"    

in tools you can use Transactioner.new() to create a new file (For a transaction)

tools.rb signs transactions with the test keys
tools.rb also includes a reporter for TB and GL Listing

TODO
Make the command line work
clean up the directory now you messed it up
Tools make a big file of transactions, test all the new things with bigger files. Make the current generator better and document it cause you keep forgetting
Make a separate protocol that works (Employees?)
download GL listing from QB Online and convert into this
actually figure out how to save on blockchain

