authors=("shubham.tagra" "naman.jain" "akshay.agrawal" "roshan.jarupla" "shubham.jadhav" "tushar.dwivedi" "disha.singla")

authorAndDiffs="$(pwd)/recent_changes_by_callisto_team_1.tmp"
rm -f "$authorAndDiffs"

#for author in "${authors[@]}"
#do
#	#git log master ^origin/b9.1 --oneline --author=$author >> $tmpFile
##	git log "$newBranch" ^"$oldBranch" --oneline --author="$author" >> $tmpFile
#	git log --author="$author" >> "$authorAndDiffs"
#done

git log --perl-regexp \
--author='(shubham.tagra|naman.jain|akshay.agrawal|roshan.jarupla|shubham.jadhav|tushar.dwivedi|disha.singla)' > "$authorAndDiffs"


echo "authorAndDiffs: $authorAndDiffs"