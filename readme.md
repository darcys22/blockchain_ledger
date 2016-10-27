# blockchain_ledger

Just run the binary (/bin/ledger) to start the CLI. The webserver opens a port on localhost:4567 with a single endpoint "transaction" post a json transaction to localhost:4567/transaction to append a transaction to a company

reporter will generate a TB or a GL Listing
transactioner will create a transaction
verifier will sign a transaction with key

transaction examples in data
curl -v -X POST -d @./data/transaction.json localhost:4567/transaction --header "Content-Type:text/json"    


TODO
make the gemfile and basic info 
make the core.yaml file complete and update shit
read the protocol from the company file and make it accept external locations
create the full payrun protocol
Make the TBimporter program more general
actually figure out how to save on blockchain

