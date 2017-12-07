# GOV.UK Registers Ruby Client

This documentation is for developers interested in using this Ruby client to integrate their service with GOV.UK Registers. 

## Installation
In your Gemfile add:
```
gem 'registers-ruby-client', git: 'https://github.com/openregister/registers-ruby-client.git'
```
## Usage

_Note: examples use the `country` register_

```
require 'registers_client'

registers_client = RegistersClient::RegistersClientManager.new({ cache_duration: 3600 })


register_data = registers_client.get_register 'country', 'beta'
```

### Methods

#### `get_entries`

Example usage:

`register_data.get_entries.first[:item]`

Expected output:

```
{"citizen-names"=>"Soviet citizen", "country"=>"SU", "end-date"=>"1991-12-25", "name"=>"USSR", "official-name"=>"Union of Soviet Socialist Republics"}
get_records
```

#### `get_records`

Example usage:

`register_data.get_records.first[:item]`

Expected output:

```
{"citizen-names"=>"Soviet citizen", "country"=>"SU", "end-date"=>"1991-12-25", "name"=>"USSR", "official-name"=>"Union of Soviet Socialist Republics"}
```

#### `get_metadata_records`

Example usage:

`register_data.get_metadata_records.first[:item]`

Expected output:

`{"name"=>"country"}`

#### `get_field_definitions`

Example usage:

`register_data.get_field_definitions.first[:item]`

Expected output:

```
{"cardinality"=>"1", "datatype"=>"string", "field"=>"country", "phase"=>"beta", "register"=>"country", "text"=>"The country's 2-letter ISO 3166-2 alpha2 code."}
```

#### `get_register_definition`

Example usage:

`register_data.get_register_definition.to_json`

Expected output:

```
"{\"key\":\"register:country\",\"entry_number\":229,\"timestamp\":\"2016-08-04T14:45:41Z\",\"hash\":\"sha-256:610bde42d3ae2ed3dd829263fe461542742a10ca33865d96d31ae043b242c300\",\"item\":{\"fields\":[\"country\",\"name\",\"official-name\",\"citizen-names\",\"start-date\",\"end-date\"],\"phase\":\"beta\",\"register\":\"country\",\"registry\":\"foreign-commonwealth-office\",\"text\":\"British English-language names and descriptive terms for countries\"}}"
```

#### `get_custodian`

Example usage:

`register_data.get_custodian.to_json`

Expected output:

`"{\"key\":\"custodian\",\"entry_number\":232,\"timestamp\":\"2017-11-02T11:18:00Z\",\"hash\":\"sha-256:aa98858fc2a8a9fae068c44908932d24b207defe526bdf75e3f6c049bb352927\",\"item\":{\"custodian\":\"David de Silva\"}}"`

#### `get_records_with_history`

Example usage:

```
germany = register_data.get_records_with_history.find { |r|  r[:key] == 'DE'  }
puts germany.to_json
```

Expected output:

```
{"key":"DE","records":[{"key":"DE","entry_number":234,"timestamp":"2016-04-05T13:23:05Z","hash":"sha-256:e03f97c2806206cdc2cc0f393d09b18a28c6f3e6218fc8c6f3aa2fdd7ef9d625","item":{"citizen-names":"West German","country":"DE","end-date":"1990-10-02","name":"West Germany","official-name":"Federal Republic of Germany"}},{"key":"DE","entry_number":303,"timestamp":"2016-04-05T13:23:05Z","hash":"sha-256:747dbb718cb9f9799852e7bf698c499e6b83fb1a46ec06dbd6087f35c1e955cc","item":{"citizen-names":"German","country":"DE","name":"Germany","official-name":"The Federal Republic of Germany","start-date":"1990-10-03"}}]}
```

#### `get_current_records`

Example usage:

`register_data.get_current_records.first[:item]`

Expected output:

`{"citizen-names"=>"German", "country"=>"DE", "name"=>"Germany", "official-name"=>"The Federal Republic of Germany", "start-date"=>"1990-10-03"}`

#### `get_expired_records`

Example usage:

`register_data.get_expired_records.first[:item]`

Expected output:

```
{"citizen-names"=>"Soviet citizen", "country"=>"SU", "end-date"=>"1991-12-25", "name"=>"USSR", "official-name"=>"Union of Soviet Socialist Republics"}
```

#### `get_refresh_data`

Redownloads register data. 






