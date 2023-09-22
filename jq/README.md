

Print pretty:   jq '.'






## `jq` Cheat Sheet for Debugging JSON Logs

```bash
1. Filter logs based on a specific field value:
   jq 'select(.field == "value")' logfile.json

2. Extract a specific field from logs:
    {
    "name": "apple",
    "color": "green",
    "price": 1.2
    }
    
   jq '.field' logfile.json
   
3. JSON array parsing: 
    [
        {
        "name": "apple",
        "color": "green",
        "price": 1.2
        }, {
        "name": "banana",
        "color": "yellow",
        "price": 0.5
        }, {
        "name": "kiwi",
        "color": "green",
        "price": 1.25
        }
    ]
    Iterate & stream each entry : jq '.[]'

    Consume each value we iterate on:

    jq '.[] | .name'

4. Filter logs based on the presence of a field:
   jq 'select(has("field"))' logfile.json

5. Count occurrences of unique field values:
   cat file.json | jq -s | jq '[.[] | .Key] | unique | length'
   cat logfile.json | jq '.field | unique | length'

6. Group logs by a specific field value and count occurrences:
   jq 'group_by(.field) | map({field: .[0].field, count: length})' logfile.json

7. Sort logs based on a specific field:
   jq 'sort_by(.field)' logfile.json

8. Filter logs based on multiple conditions (logical "and" operator):
   jq 'select(.field1 == "value1" and .field2 == "value2")' logfile.json

9. Filter logs based on multiple conditions (logical "or" operator):
   jq 'select(.field1 == "value1" or .field2 == "value2")' logfile.json

10. Extract logs within a specific date range (assuming a timestamp field):
   jq 'select(.timestamp >= "2023-01-01T00:00:00" and .timestamp < "2023-01-02T00:00:00")' logfile.json

11. Calculate statistics on numeric fields (e.g., average, minimum, maximum):
    jq '[.field] | add / length' logfile.json  # Average
    jq '[.field] | min' logfile.json  # Minimum
    jq '[.field] | max' logfile.json  # Maximum

12. Filter logs based on regular expressions:
    jq 'select(.field | test("regex_pattern"))' logfile.json

13. Extract specific fields and format output as CSV:
    jq -r '[.field1, .field2] | @csv' logfile.json
