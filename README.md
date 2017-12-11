# GOV.UK Registers Ruby Client

## Installation
In your Gemfile add:
```
gem 'registers-ruby-client', git: 'https://github.com/openregister/registers-ruby-client.git'
```
## Getting started

```
require 'register_client_manager'

registers_client = RegistersClient::RegisterClientManager.new({ cache_duration: 3600 })
```

_Note: `cache_duration`  is the amount of time a register is cached in-memory, before being re-downloaded._

## Accessing methods

_Note: All examples use the `country` register._

### `get_entries`

Get all entries from the register.

<details>
<summary>
Example usage (click here to expand):
</summary>

```

register_data = registers_client.get_register 'country', 'beta'

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

### `get_records`

Get all records from the register.

<details>
<summary>
Example usage (click here to expand):
</summary>


```

register_data = registers_client.get_register 'country', 'beta'

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

### `get_metadata_records`

Get all metadata records of the register. This includes the register definition, field definitions and custodian.

<details>
<summary>
Example usage (click here to expand):
</summary>


```

register_data = registers_client.get_register 'country', 'beta'

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

### `get_field_definitions`

Get definitions for the fields used in the register.

<details>
<summary>
Example usage (click here to expand):
</summary>


```

register_data = registers_client.get_register 'country', 'beta'

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

### `get_register_definition`

Get the definition of the register.

<details>
<summary>
Example usage (click here to expand):
 </summary>


```

register_data = registers_client.get_register 'country', 'beta'

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

### `get_custodian`

Get the name of the current custodian for the register.

<details>
<summary>
Example usage (click here to expand):
</summary>


```

register_data = registers_client.get_register 'country', 'beta'

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

### `get_records_with_history`

Get current and previous versions of records in the register.

<details>
<summary>
Example usage (click here to expand):
</summary>

```

register_data = registers_client.get_register 'country', 'beta'

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

### `get_current_records`

Get all current records from the register.

<details>
<summary>
Example usage (click here to expand):
</summary>

```

register_data = registers_client.get_register 'country', 'beta'

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

### `get_expired_records`

Get all expired records from the register.

<details>
<summary>
Example usage (click here to expand)
</summary>

```

register_data = registers_client.get_register 'country', 'beta'

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

### `get_refresh_data`

Redownloads register data. Call this method when you want to refresh data immediately rather than waiting for the `cache_duration` to expire.
