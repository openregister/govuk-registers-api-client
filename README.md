# GOV.UK Registers Ruby Client

You can use this Ruby client to integrate your service with [GOV.UK Registers](https://registers.cloudapps.digital/).

Registers are authoritative lists of information. The data is owned by [custodians](https://www.gov.uk/government/collections/registers-guidance#creating-and-managing-registers) inside departments and services. For example, the [Country register](https://country.register.gov.uk/) is maintained by a custodian in the Foreign and Commonwealth Office (FCO). 

## Table of Contents

- [Installation](#installation)
- [Get started](#get-started)
- [Reference](#reference)
  * [`RegisterClientManager`](#registerclientmanager)
  * [`RegisterClient`](#registerclient) 
  * [Collections](#collections)  

## Installation

In your Gemfile, add:
```
gem 'registers-ruby-client', git: 'https://github.com/openregister/registers-ruby-client.git'
```

## Get started 

The `RegisterClientManager` is the entry point of Registers Ruby client: 

```
require 'register_client_manager'

registers_client = RegistersClient::RegisterClientManager.new({
  cache_duration: 3600,
  page_size: 10
})
```

The `RegisterClientManager` maintains individual instances of [`RegisterClient`](#registerclient) for each register you access via the [`get_register`](#getregister) method. 

When creating a new `RegisterClientManager`, you can pass a configuration object to specify the following:
- `cache_duration`: time, in seconds, register data is cached in-memory before any updates are retrieved - default is `3600`
- `page_size`: number of results returned per page when using the `page` method of any of the collection classes (see below for more information) - default is `100`

## Reference

### <a id="registerclientmanager"></a>`RegisterClientManager`

##### <a id="getregister"></a>`get_register(register, phase, data_store = nil)`

Gets the `RegisterClient` instance for the given `register` name and `phase`.

The `data_store` parameter specifies the data store to use accessing a particular register. You can omit this parameter, which will make it default to the `InMemoryDataStore` value. You can also create a custom data store to include the `DataStore` module and to implement the methods it defines. For example, to insert register data directly into your Postgres database. 

<details>
<summary>
Example use (click here to expand):
</summary>

```

registers_client.get_register('country', 'beta', nil)

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```

A RegisterClient instance e.g. #<RegistersClient::RegisterClient:0x00007f893c55f740>

```
</details>

### <a id="registerclient"></a>`RegisterClient` 

_Note: All examples use the [Country register](https://country.register.gov.uk/)._

#### `get_entries`

Get all entries from the register.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

register_data.get_entries.first.item_hash

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```

sha-256:a074752a77011b18447401652029a9129c53b4ee35e1d99e6dec8b42ff4a0103

```
</details>

#### `get_records`

Get all records from the register.

<details>
<summary>
Example use (click here to expand):
</summary>


```

register_data = registers_client.get_register('country', 'beta')

register_data.get_records.first.item.value

```
</details>
<details>

<summary>
Expected output (click here to expand):
</summary>

```

{"citizen-names"=>"Soviet citizen", "country"=>"SU", "end-date"=>"1991-12-25", "name"=>"USSR", "official-name"=>"Union of Soviet Socialist Republics"}

```

</details>

#### `get_metadata_records`

Get all metadata records of the register. This includes the register definition, field definitions and custodian.

<details>
<summary>
Example use (click here to expand):
</summary>


```

register_data = registers_client.get_register('country', 'beta')

register_data.get_metadata_records.first.item.value

```
</details>
<details>

<summary>
Expected output (click here to expand):
</summary>

```

{"name"=>"country"}

```
</details>

#### `get_field_definitions`

Get definitions for the fields used in the register.

<details>
<summary>
Example use (click here to expand):
</summary>


```

register_data = registers_client.get_register('country', 'beta')

register_data.get_field_definitions.first.item.value

```

</details>
<details>

<summary>
Expected output (click here to expand):
</summary>

```

{"cardinality"=>"1", "datatype"=>"string", "field"=>"country", "phase"=>"beta", "register"=>"country", "text"=>"The country's 2-letter ISO 3166-2 alpha2 code."}

```

</details>

#### `get_register_definition`

Get the definition of the register.

<details>
<summary>
Example use (click here to expand):
 </summary>


```

register_data = registers_client.get_register('country', 'beta')

register_data.get_register_definition.item.value

```
</details>
<details>
<summary>
Expected output (click here to expand):
</summary>

```

{"fields":["country","name","official-name","citizen-names","start-date","end-date"],"phase":"beta","register":"country","registry":"foreign-commonwealth-office","text":"British English-language names and descriptive terms for countries"}

```

</details>

#### `get_custodian`

Get the name of the current custodian for the register.

<details>
<summary>
Example use (click here to expand):
</summary>


```

register_data = registers_client.get_register('country', 'beta')

register_data.get_custodian.item.value['custodian']

```

</details>
<details>

<summary>
Expected output (click here to expand):
</summary>

```

David de Silva

```

</details>

#### `get_records_with_history`

Get current and previous versions of records in the register.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

germany = register_data.get_records_with_history.get_records_for_key('DE').first
puts germany.to_json

```

</details>

<details>
<summary>
Expected output (click here to expand):
</summary>

```

{"key":"DE","records":[{"key":"DE","entry_number":234,"timestamp":"2016-04-05T13:23:05Z","hash":"sha-256:e03f97c2806206cdc2cc0f393d09b18a28c6f3e6218fc8c6f3aa2fdd7ef9d625","item":{"citizen-names":"West German","country":"DE","end-date":"1990-10-02","name":"West Germany","official-name":"Federal Republic of Germany"}}

```

</details>

#### `get_current_records`

Get all current records from the register.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

register_data.get_current_records.first.item

```
</details>
<details>
<summary>
Expected output (click here to expand):
</summary>

```

{"citizen-names"=>"German", "country"=>"DE", "name"=>"Germany", "official-name"=>"The Federal Republic of Germany", "start-date"=>"1990-10-03"}

```

</details>

#### `get_expired_records`

Get all expired records from the register.

<details>
<summary>
Example use (click here to expand)
</summary>

```

register_data = registers_client.get_register('country', 'beta')

register_data.get_expired_records.first.item

```
</details>
<details>
<summary>
Expected output (click here to expand)
</summary>

```

{"citizen-names"=>"Soviet citizen", "country"=>"SU", "end-date"=>"1991-12-25", "name"=>"USSR", "official-name"=>"Union of Soviet Socialist Republics"}

```

</details>

#### `refresh_data`

Downloads register data. Call this method when you want to refresh data immediately rather than waiting for the `cache_duration` to expire.

## Collections

The majority of the methods available in the `RegisterClient` return one of three types of collection object. These collections all include `Enumerable` and implement the `each` method.

[`ItemCollection`](https://github.com/openregister/registers-ruby-client/blob/master/lib/item_collection.rb), [`EntryCollection`](https://github.com/openregister/registers-ruby-client/blob/master/lib/entry_collection.rb) and [`RecordCollection`](https://github.com/openregister/registers-ruby-client/blob/master/lib/record_collection.rb) are all `Enumerable` and implement the same [Collections](#collections) interface.

### EntryCollection

A collection of `Entry` objects.

#### `each`

Yields each `Entry` object in the collection.

#### `page(int page=1)`

Returns all `Entry` objects in the collection, according to the specified `page` number (defaults to `1`).

If there are fewer results than the current `page_size`, all results are returned.

### RecordCollection

A collection of `Record` objects.

#### `each`

Yields each `Record` object in the collection.

#### `page(int page=1)`

Returns `Record` objects in the collection, according to the specified `page` number (defaults to `1`).

If there are fewer results than the current `page_size`, all results are returned.

### RecordMapCollection

A map of record key to list of both the current and historical `Record` objects for each key.

#### `each`

Yields each record key to list of current and historical `Record` objects in the collection, in the following format:

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

register_data.get_records_with_history.each do |result|
  puts result.to_json
end

```
</details>
<details>
<summary>
Expected output for the first `result` (click here to expand):
 </summary>

```

"{"key":"SU","records":[{"entry":{"rsf_line":null,"entry_number":1,"parsed_entry":{"key":"SU","timestamp":"2016-04-05T13:23:05Z","item_hash":"sha-256:e94c4a9ab00d951dadde848ee2c9fe51628b22ff2e0a88bff4cca6e4e6086d7a"}},"item":{"item_json":"{\"citizen-names\":\"Soviet citizen\",\"country\":\"SU\",\"end-date\":\"1991-12-25\",\"name\":\"USSR\",\"official-name\":\"Union of Soviet Socialist Republics\"}","item_hash":"sha-256:e94c4a9ab00d951dadde848ee2c9fe51628b22ff2e0a88bff4cca6e4e6086d7a","parsed_item":null}}]}"

```
</details>

#### `get_records_for_key(string key)`

Returns both the current and historical `Record` objects for a given key, or raises a `KeyError` if no records exist for the given key.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

register_data.get_records_with_history.get_records_for_key('SU')

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```

"{[{"entry":{"rsf_line":null,"entry_number":1,"parsed_entry":{"key":"SU","timestamp":"2016-04-05T13:23:05Z","item_hash":"sha-256:e94c4a9ab00d951dadde848ee2c9fe51628b22ff2e0a88bff4cca6e4e6086d7a"}},"item":{"item_json":"{\"citizen-names\":\"Soviet citizen\",\"country\":\"SU\",\"end-date\":\"1991-12-25\",\"name\":\"USSR\",\"official-name\":\"Union of Soviet Socialist Republics\"}","item_hash":"sha-256:e94c4a9ab00d951dadde848ee2c9fe51628b22ff2e0a88bff4cca6e4e6086d7a","parsed_item":null}}]}"

```
</details>

#### `paginator`

Returns an enumerator of a map of record key to list of current and historical `Record` objects in the collection, in slices specified by `page_size` (defined when creating the `RegisterClientManager`).

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

enumerator = register_data.get_records_with_history.paginator
enumerator.next.to_json

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```

[["SU",[{"entry":{"rsf_line":null,"entry_number":1,"parsed_entry":{"key":"SU","timestamp":"2016-04-05T13:23:05Z","item_hash":"sha-256:e94c4a9ab00d951dadde848ee2c9fe51628b22ff2e0a88bff4cca6e4e6086d7a"}},"item":{"item_json":"{\"citizen-names\":\"Soviet citizen\",\"country\":\"SU\",\"end-date\":\"1991-12-25\",\"name\":\"USSR\",\"official-name\":\"Union of Soviet Socialist Republics\"}","item_hash":"sha-256:e94c4a9ab00d951dadde848ee2c9fe51628b22ff2e0a88bff4cca6e4e6086d7a","parsed_item":null}}]],["DE",[{"entry":{"rsf_line":null,"entry_number":2,"parsed_entry":{"key":"DE","timestamp":"2016-04-05T13:23:05Z","item_hash":"sha-256:e03f97c2806206cdc2cc0f393d09b18a28c6f3e6218fc8c6f3aa2fdd7ef9d625"}},"item":{"item_json":"{\"citizen-names\":\"West German\",\"country\":\"DE\",\"end-date\":\"1990-10-02\",\"name\":\"West Germany\",\"official-name\":\"Federal Republic of Germany\"}","item_hash":"sha-256:e03f97c2806206cdc2cc0f393d09b18a28c6f3e6218fc8c6f3aa2fdd7ef9d625","parsed_item":null}},{"entry":{"rsf_line":null,"entry_number":71,"parsed_entry":{"key":"DE","timestamp":"2016-04-05T13:23:05Z","item_hash":"sha-256:747dbb718cb9f9799852e7bf698c499e6b83fb1a46ec06dbd6087f35c1e955cc"}},"item":{"item_json":"{\"citizen-names\":\"German\",\"country\":\"DE\",\"name\":\"Germany\",\"official-name\":\"The Federal Republic of Germany\",\"start-date\":\"1990-10-03\"}","item_hash":"sha-256:747dbb718cb9f9799852e7bf698c499e6b83fb1a46ec06dbd6087f35c1e955cc","parsed_item":n
ull}}]],

...

["AD",[{"entry":{"rsf_line":null,"entry_number":10,"parsed_entry":{"key":"AD","timestamp":"2016-04-05T13:23:05Z","item_hash":"sha-256:14fcb5099f0eff4c40d5a85b0e3c2f1a04337dc69dace1fc5c64ec9758a19b13"}},"item":{"item_json":"{\"citizen-names\":\"Andorran\",\"country\":\"AD\",\"name\":\"Andorra\",\"official-name\":\"The Principality of Andorra\"}","item_hash":"sha-256:14fcb5099f0eff4c40d5a85b0e3c2f1a04337dc69dace1fc5c64ec9758a19b13","parsed_item":null}}]]]"

```
</details>

### `Item`

#### `hash`

Returns the SHA-256 hash of the item.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')
item = register_data.get_records.select {|record| record.entry.key == 'SU'}.first.item
item.hash

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```

"sha-256:e94c4a9ab00d951dadde848ee2c9fe51628b22ff2e0a88bff4cca6e4e6086d7a"

```
</details>

#### `value`

Returns the key-value pairs represented by the item in a `JSON` object.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

item = register_data.get_records.select {|record| record.entry.key == 'SU'}.first.item
item.value

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```

{"item_json":"{\"citizen-names\":\"Soviet citizen\",\"country\":\"SU\",\"end-date\":\"1991-12-25\",\"name\":\"USSR\",\"official-name\":\"Union of Soviet Socialist Republics\"}","item_hash":"sha-256:e94c4a9ab00d951dadde848ee2c9fe51628b22ff2e0a88bff4cca6e4e6086d7a","parsed_item":null}

```
</details>

#### `has_end_date`

Returns a boolean to describe whether the item contains a key-value pair for the `end-date` field.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

item = register_data.get_records.select {|record| record.entry.key == 'SU'}.first.item
item.has_end_date

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```
true
```
</details>

### `Entry`

#### `entry_number`

Gets the entry number of the entry.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

entry = register_data.get_entries.select {|entry| entry.key == 'CZ'}.first
entry.entry_number

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```
52
```
</details>

#### `key`

Gets the key of the entry.

<details>
<summary>
Example use (click here to expand):
</summary>

```
register_data = registers_client.get_register('country', 'beta')

entry = register_data.get_entries.select {|entry| entry.key == 'CZ'}.first
entry.key

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```
CZ
```
</details>

#### `timestamp`

Gets the timestamp of when the entry was appended to the register.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

entry = register_data.get_entries.select {|entry| entry.key == 'CZ'}.first
entry.timestamp

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```
2016-04-05T13:23:05Z
```
</details>

#### `item_hash`

Gets the SHA-256 hash of the item which the entry points to.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

entry = register_data.get_entries.select {|entry| entry.key == 'CZ'}.first
entry.item_hash

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```
sha-256:c45bd0b4785680534e07c627a5eea0d2f065f0a4184a02ba2c1e643672c3f2ed
```
</details>

#### `value`

Returns the entry as a hash.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

entry = register_data.get_entries.select {|entry| entry.key == 'CZ'}.first
entry.value.to_json

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```
"{"key":"CZ","timestamp":"2016-04-05T13:23:05Z","item_hash":"sha-256:c45bd0b4785680534e07c627a5eea0d2f065f0a4184a02ba2c1e643672c3f2ed"}"
```
</details>

### `Record`

#### `entry`

Gets the `Entry` object associated with the record.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

record = register_data.get_records.select {|record| record.entry.key == 'CZ'}.first
record.entry.to_json

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```
"{"entry_number":205,"parsed_entry":{"key":"CZ","timestamp":"2016-11-11T16:25:07Z","item_hash":"sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720"}}"
```
</details>

#### `item`

Gets the `Item` object associated with the record.

<details>
<summary>
Example use (click here to expand):
</summary>

```

register_data = registers_client.get_register('country', 'beta')

record = register_data.get_records.select {|record| record.entry.key == 'CZ'}.first
record.item.to_json

```
</details>
<details>
<summary>
Expected output (click here to expand):
 </summary>

```
"{"item_json":"{\"citizen-names\":\"Czech\",\"country\":\"CZ\",\"name\":\"Czechia\",\"official-name\":\"The Czech Republic\",\"start-date\":\"1993-01-01\"}","item_hash":"sha-256:c69c04fff98c59aabd739d43018e87a25fd51a00c37d100721cc68fa9003a720","parsed_item":null}"
```
</details>
