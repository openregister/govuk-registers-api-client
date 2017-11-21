# Registers Ruby Client
## Installation
In your Gemfile add:
```
gem 'registers-ruby-client', git: 'https://github.com/openregister/registers-ruby-client.git'
```
## Usage
```
require 'registers_client'

registers_client = RegistersClient::RegistersClientManager.new({ cache_duration: 3600 })
register_data = registers_client.get_register 'country', 'beta'
register_data.get_records[0][:item]
 => {"citizen-names"=>"Soviet citizen", "country"=>"SU", "end-date"=>"1991-12-25", "name"=>"USSR", "official-name"=>"Union of Soviet Socialist Republics"} 
 ```

## License

Unless stated otherwise, this codebase is released under [the MIT
license](./LICENSE).
