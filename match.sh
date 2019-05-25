#!/bin/bash
#
# Michael Nov 2016 Postcode Sorter v2.0
#
echo 'postcode sorter'
echo "Welcome to the postcode batch sorter program, this will take a Hotspot CSV file, extract the postcodes, organise them and then match these to the longitude and latitude"
echo "Please enter the source directory of CSV files to which have to be sorted: "
read source
echo "Please enter the destination directory to send the CSV files below, this is a list of the current directories: " && ls -ld -- */ 
read dest
echo "$source" "is the source filepath"
echo "$dest" "is the destination filepath"

# Filepath exception handling

if [[ -z "$source" ]]; then
        echo "You didn’t enter a SOURCE path for your images try again with a source path"
        echo "use the format /something/somthing/something/ file paths are case sensitive"
        exit
        else

if [[ -z "$dest" ]]; then
        echo "You didn’t enter a DESTINATION path to place your images please try again"
        echo "HINT.... use the format /something/somthing/something/ file paths are case sensitive" 
        exit
        fi
fi

# Check filepaths are vaild

if [[ -d "$source" && -f "$dest" ]]; then 

echo "$1 is valid"

else
    if [[ ! -f "$source" && ! -d "$dest" ]]; then
    echo "$source is not a valid file or directory, please try again with a valid path";
    exit 1
    fi
fi

for file in "$source"/*

do

echo "$file"

#remove all the lines from the postcode column and pass to new file

cat "$file" | cut -d ',' -f19 | sort | tr -d '"' > postcode_column_only.tmp

#remove all lines starting with a number

grep -E -v ^[0-9] postcode_column_only.tmp > nonum.tmp

#remove anything more than 10 characters

grep -E -v '^..........*$' nonum.tmp > under10.tmp

#remove anything that has zero characters

grep -E -v '^$' under10.tmp > nonzero.tmp

#convert all characters to upper case

tr a-z A-Z < nonzero.tmp > uppercase_postcodes.tmp

#delete the exception handling temp files

rm postcode_column_only.tmp
rm nonum.tmp
rm under10.tmp
rm nonzero.tmp
# run the file through the postcode regex and pass out to final file
cat uppercase_postcodes.tmp | grep -E '^(([gG][iI][rR] {0,}0[aA]{2})|((([a-pr-uwyzA-PR-UWYZ][a-hk-yA-HK-Y]?[0-9][0-9]?)|(([a-pr-uwyzA-PR-UWYZ][0-9][a-hjkstuwA-HJKSTUW])|([a-pr-uwyzA-PR-UWYZ][a-hk-yA-HK-Y][0-9][abehmnprv-yABEHMNPRV-Y]))) {0,}[0-9][abd-hjlnp-uw-zABD-HJLNP-UW-Z]{2}))$' >  only_postcodes.tmp
#
# compare the file against the uk database with spaces in the postcode
#
grep -Ff only_postcodes.tmp /home/michael/inkspotwifi/pcs2/ukpostcodes.csv > final.tmp
#
# chop out the number column from the csv
#
cut -d, -f2,3,4 final.tmp > final2.tmp
#
# compare the file against uk post codes without spaces in them
#
grep -Ff only_postcodes.tmp /home/michael/inkspotwifi/pcs2/ukpostcodes_rem2.csv > final3.tmp
#
# pass all of the codes into new files and then sort them
#
cat final2.tmp final3.tmp > final4.tmp

sort final4.tmp > organised_codes.csv
#
# clean up the temp files
#
rm final.tmp
rm final2.tmp
rm final3.tmp
rm final4.tmp
rm only_postcodes.tmp
rm uppercase_postcodes.tmp
filename=`basename "$file"`
echo finished
echo $filename
cp organised_codes.csv "$dest"
mv "$dest"/organised_codes.csv "$dest"/postcodes_"$filename"
cp "$dest"/postcodes_"$filename" "$dest" 2>/dev/null


# no errors to here


rm -f postcodes_sorted
rm -f organised_codes.csv
rm -f postcodes_$filename
rm -f "$dest"/postcodes_sorted

done
