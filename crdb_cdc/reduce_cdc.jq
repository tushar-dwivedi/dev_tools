# reduce_cdc.jq
def reduce_cdc:
  map(select(.TableName == "files_perf_test_only")) |
  map(
    if has("IsDeleted") then
      { Key: .Key, Timestamp: .Timestamp.WallTime, TableName: .TableName, EntryType: "data" }
    else
      { StartKey: .Span.Key, EndKey: .Span.EndKey, StartTS: .StartTS.WallTime, ResolvedTS: .ResolvedTS.WallTime, TableName: .TableName, EntryType: "checkpoint" }
    end
  );
