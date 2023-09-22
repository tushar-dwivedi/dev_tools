
# converts crdb --format=records output to json

#sudo zcat 1687213200_2_1_data.json.gz  | jq -r 'select(.TableName == "files_perf_test_only" and has("IsDeleted")) | {Key: .Key, Timestamp: .Timestamp.WallTime, TableName: .TableName}' > /tmp/data_entries.json
#sudo zcat 1687213200_2_1_data.json.gz  | jq -r 'select(.TableName == "files_perf_test_only" and (has("IsDeleted") | not)) | {StartKey: .Span.Key, EndKey: .Span.EndKey, StartTS: .StartTS.WallTime, ResolvedTS: .ResolvedTS.WallTime, TableName: .TableName}' > /tmp/checkpoint_entries.json

#combined_entries_file="/tmp/combined_entries.json"

#sudo zcat "$1" | jq --slurp 'map(select(.TableName == "files_perf_test_only")) | map(if has("IsDeleted") then {Key: .Key, Timestamp: .Timestamp.WallTime, TableName: .TableName, EntryType: "data"} else {StartKey: .Span.Key, EndKey: .Span.EndKey, StartTS: .StartTS.WallTime, ResolvedTS: .ResolvedTS.WallTime, TableName: .TableName, EntryType: "checkpoint"} end)' > "$combined_entries_file"

# Declare an empty object to store the checkpoints
def init_checkpoints:
  {} ;

# Function to check if a timestamp falls within a range
def check_timestamp_range($start_ts; $resolved_ts; $check_ts):
  $start_ts <= $check_ts and $check_ts < $resolved_ts ;

# Function to check if a key falls within a range
def check_key_range($start_key; $end_key; $check_key):
  def truncate_key($key): substr(0, length($start_key)) ;

  def key_decimal($key): tonumber("0x" + $key) ;

  def start_key_decimal: key_decimal($start_key) ;
  def end_key_decimal: key_decimal($end_key) ;
  def check_key_decimal: key_decimal(truncate_key($check_key)) ;

  start_key_decimal <= check_key_decimal and check_key_decimal < end_key_decimal ;

# Process the combined entries
def process_entries($input):
  init_checkpoints;
  # Read the combined entries JSON file
  $input | .[] |
  foreach . as $entry (
    if $entry.EntryType == "checkpoint" then
      # Add the checkpoint entry to the checkpoints map
      .[$entry.TableName] += [$entry]
    else
      # Check if the data entry matches any of the checkpoints
      . as $data_entry |
      .[$entry.TableName] | map(
        select(
          check_key_range(.StartKey, .EndKey, $data_entry.Key) and
          check_timestamp_range(.StartTS, .ResolvedTS, $data_entry.Timestamp)
        )
      ) | if length == 0 then $data_entry else empty end
    end
  ) ;

# Usage
process_entries("$1")
