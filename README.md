# GOV.UK Registers Ruby Client

## Installation
In your Gemfile add:
```
gem 'registers-ruby-client', git: 'https://github.com/openregister/registers-ruby-client.git'
```
## Getting started 

```
require 'registers_client'

registers_client = RegistersClient::RegistersClientManager.new({ cache_duration: 3600 })
```

_Note: `cache_duration`  is the amount of time a register is cached in-memory, before being re-downloaded._

### Methods

#### `get_entries`

Get all entries from the register. For example, when changes have been made to the information in the `country` register.

Example usage:

```
register_data = registers_client.get_register 'country', 'beta'

register_data.get_entries.first[:item]
```

Expected output:

```
{"citizen-names"=>"Soviet citizen", "country"=>"SU", "end-date"=>"1991-12-25", "name"=>"USSR", "official-name"=>"Union of Soviet Socialist Republics"}
```

#### `get_records`

Get all records from the register. For example, all of the countries from the `country` register.

Example usage:

```
register_data = registers_client.get_register 'country', 'beta'

register_data.get_records.first[:item]
```

Expected output:

```
{"citizen-names"=>"Soviet citizen", "country"=>"SU", "end-date"=>"1991-12-25", "name"=>"USSR", "official-name"=>"Union of Soviet Socialist Republics"}
```

#### `get_metadata_records`

Example usage:

```
register_data = registers_client.get_register 'country', 'beta'

register_data.get_metadata_records.first[:item]
```

Expected output:

```
{"name"=>"country"}
```

#### `get_field_definitions`

Get definitions for the fields used in the register. For example, the `Country` field in the `country` register.

Example usage:

```
register_data = registers_client.get_register 'country', 'beta'

register_data.get_field_definitions.first[:item]
```

Expected output:

```
{"cardinality"=>"1", "datatype"=>"string", "field"=>"country", "phase"=>"beta", "register"=>"country", "text"=>"The country's 2-letter ISO 3166-2 alpha2 code."}
```

#### `get_register_definition`

Get the definition of the register. For example, the 

Example usage:

```
register_data = registers_client.get_register 'country', 'beta'

register_data.get_register_definition.to_json
```

Expected output:

```
{"key":"register:country","entry_number":229,"timestamp":"2016-08-04T14:45:41Z","hash":"sha-256:610bde42d3ae2ed3dd829263fe461542742a10ca33865d96d31ae043b242c300","item":{"fields":["country","name","official-name","citizen-names","start-date","end-date"],"phase":"beta","register":"country","registry":"foreign-commonwealth-office","text":"British English-language names and descriptive terms for countries"}}
```

#### `get_custodian`

Get the name of the current custodian for the register. For example, the name of the custodian for the `country` register.

Example usage:

```
register_data = registers_client.get_register 'country', 'beta'

register_data.get_custodian[:item]['custodian']
```

Expected output:

```
David de Silva
```

#### `get_records_with_history`

Get all records which have recorded changes from the register. For example, all of the countries with record changes in the `country` register. 

Example usage:

```
register_data = registers_client.get_register 'country', 'beta'

germany = register_data.get_records_with_history.find { |r|  r[:key] == 'DE'  }
puts germany.to_json
```

Expected output:

```
{"key":"DE","records":[{"key":"DE","entry_number":234,"timestamp":"2016-04-05T13:23:05Z","hash":"sha-256:e03f97c2806206cdc2cc0f393d09b18a28c6f3e6218fc8c6f3aa2fdd7ef9d625","item":{"citizen-names":"West German","country":"DE","end-date":"1990-10-02","name":"West Germany","official-name":"Federal Republic of Germany"}},{"key":"DE","entry_number":303,"timestamp":"2016-04-05T13:23:05Z","hash":"sha-256:747dbb718cb9f9799852e7bf698c499e6b83fb1a46ec06dbd6087f35c1e955cc","item":{"citizen-names":"German","country":"DE","name":"Germany","official-name":"The Federal Republic of Germany","start-date":"1990-10-03"}}]}
```

#### `get_current_records`

Get all current records from the register. For example, all of the current countries from the `country` register. 

Example usage:

```
register_data = registers_client.get_register 'country', 'beta'

register_data.get_current_records.first[:item]
```

Expected output:

```
{"citizen-names"=>"German", "country"=>"DE", "name"=>"Germany", "official-name"=>"The Federal Republic of Germany", "start-date"=>"1990-10-03"}
```

#### `get_expired_records`

Get all expired records from the register. For example, all of the former countries from the `country` register.

Example usage:

```
register_data = registers_client.get_register 'country', 'beta'

register_data.get_expired_records.first[:item]
```

Expected output:

```
{"citizen-names"=>"Soviet citizen", "country"=>"SU", "end-date"=>"1991-12-25", "name"=>"USSR", "official-name"=>"Union of Soviet Socialist Republics"}
```

#### `get_refresh_data`

Redownloads register data. Call this method when you want to refresh data immediately rather than waiting for the `cache_duration` to expire.






