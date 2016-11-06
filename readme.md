# blockchain_ledger

Just run the binary (/bin/ledger) to start the CLI. The webserver opens a port on localhost:4567 with a single endpoint "transaction" post a json transaction to localhost:4567/transaction to append a transaction to a company

reporter will generate a TB or a GL Listing
transactioner will create a transaction
verifier will sign a transaction with key

transaction examples in data
curl -v -X POST -d @./data/transaction.json localhost:4567/transaction --header "Content-Type:text/json"    


TODO
create a tool that create a company from scratch with prompts
graceful fail if there is no public key in the .ledger file
create the full payrun protocol
Make the TBimporter program more general
actually figure out how to save on blockchain

