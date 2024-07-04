# This scripts finds CDC related changes in newBranch which are not there in old branch and
# prints the files changed outside of publisher specific packages. Typically publisher specific
# packages are trivial to port back hence this prints out the other changes to give an idea about
# work involved in porting back the changes

newBranch=$1
oldBranch=$2


authors=("shubham.tagra" "naman.jain" "akshay.agrawal" "roshan.jarupla" "shubham.jadhav" "tushar.dwivedi" "Disha.Singla")
tmpFile="/tmp/files_changed_between_branches.tmp"
tmpFile2="/tmp/files_changed_between_branches.tmp2"
changedFiles="/tmp/files_changed_between_branches_changed_files.tmp"
authorAndDiffs="/tmp/files_changed_between_branches_diffs.tmp"
changedFilesFiltered="/tmp/files_changed_between_branches_changed_files_filtered.tmp"

# Commits not related to CDC but by above authors
#blacklistedCommits=("3cf59e02fa4daab591330b1292cccaccbc5c6a5a" "71bc82ec155116e5ddfa2b75e7abcacd1be78431")
#blacklistedCommits=()

declare -A blacklistedCommits=(
    ["3cf59e02fa4daab591330b1292cccaccbc5c6a5a"]="Shubham Jadhav: Clean up libJVM ptr in schStack struct"
    ["71bc82ec155116e5ddfa2b75e7abcacd1be78431"]="Shubham Jadhav: Fix metadata gen script imports"
    ["0d9a9605bb9a97b2008008524fcc9d79aaf397d3"]="Disha: Add logz aws endpoint for dev"
    ["63345fe7a72d0ddd7bc95eec0712843092124350"]="Disha: Revert logz aws endpoint for dev"
    ["2b0d0eb718c372327e4f743ec6c9e69197e7d5f4"]="Disha: Modify api urls for logz aws migration"
    ["8f0b3da6c600f501aade08d6721eade8658c3f1d"]="Disha: logs aws migration shipper url changes"
)

echo "Finding changes by ${authors[@]} in $newBranch absent in $oldBranch"

rm -f $tmpFile
rm -f $tmpFile2
rm -f $authorAndDiffs
rm -f $changedFiles
for author in "${authors[@]}"
do
	#git log master ^origin/b9.1 --oneline --author=$author >> $tmpFile
	git log "$newBranch" ^"$oldBranch" --oneline --author="$author" >> $tmpFile
	git log "$newBranch" ^"$oldBranch" --author="$author" >> $authorAndDiffs
done

# sloppy way to remove blacklisted commits
#for commit in "${blacklistedCommits[@]}"
for commit in "${!blacklistedCommits[@]}"
do
	grep -v "${commit:0:12}" $tmpFile > $tmpFile2
	mv $tmpFile2 $tmpFile
done

echo "tmpFile: $tmpFile"

for commit in $(cat $tmpFile | cut -d ' ' -f 1)
do
	git show --name-only --oneline "$commit"  >> $tmpFile2 # for debug
#	git show --name-only "$commit" | grep 'Differential Revision\|Date:\|Author:' >> $changedFiles
#	git show --name-only "$commit" | grep 'Differential Revision\|Date:\|Author:' >> $authorAndDiffs
	git show --name-only --oneline "$commit" | tail -n +2 >> $changedFiles
#	echo '' >> $changedFiles
done

echo "changedFiles: $changedFiles"
echo "authorAndDiffs: $authorAndDiffs"
echo "Files changed outside of cdc/publisher, callisto/config, callisto/election:"
echo
#cat "$changedFiles" | sort | uniq > $changedFiles
#cat "$changedFiles" | sort | uniq | grep -v 'src/go/src/rubrik/callisto/cdc/publisher' | grep -v 'src/go/src/rubrik/callisto/config' | grep -v 'src/go/src/rubrik/callisto/election'
cat "$changedFiles" | sort | uniq | grep -v 'src/go/src/rubrik/callisto/cdc/publisher' | grep -v 'src/go/src/rubrik/callisto/config' | grep -v 'src/go/src/rubrik/callisto/election' > $changedFilesFiltered

echo "changedFiles: $changedFiles"
echo "changedFilesFiltered: $changedFilesFiltered"
