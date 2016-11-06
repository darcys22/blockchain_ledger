require File.expand_path("../lib/ledger/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'ledger'
  gem.version = Ledger::VERSION
  gem.date    = Date.today.to_s

  gem.summary = "General Purpose Financial Information Backend"
  gem.description = "Provides a framework for all financial information to be saved in a consistent and sane way"

  gem.authors  = 'Sean Darcy'
  gem.email    = 'darcys22@gmail.com'
  gem.homepage = 'https://github.com/darcys22/blockchain_ledger.git'

  gem.add_dependency('rake')
  gem.add_development_dependency('rspec', [">= 2.0.0"])

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
end


