#!/bin/bash

if [ "$1" != -s ]; then
        read -r -p "Enter the path to the source directory [must have trailing '/' ]: " sourcedir_path
    else
        sourcedir_path=$(echo "$2")
fi 
if [ "$3" != -l ]; then
        read -r -p "Enter the path where logs should be saved [must have trailing '/' ]: " logout_path
    else
        logout_path=$(echo "$4")
fi

# Number of lines to split files into
splitcount=15000
findsplit=$(echo "$logout_path""workdir/findsplit")
workdir=$(echo "$logout_path""workdir/")
hashLog(){
    # 'cat' the logfile in question, outputting it to an array
    curlog=$(echo "$1")
    hasharr -h "$curlog" catarray
    source "$curlog".array
    chunk=$(echo "$curlog" | sed "s/.*findsplit//g" | sed 's/.fs//g')
    echo "Working on chunk #$chunk"
    for l in "${catarray[@]}"; do
        sha1sum "$l" >> "$curlog".hash
    done
    # empty the temporary '$catarray'
    catarray=()
}
mkarr(){
    name=$(echo "$2")
    arrname=$(echo "$3")
    if [ "$1" == "-c" ]; then
        {
        echo "#!/bin/bash"
        echo "$arrname""=("
        find "$workdir" -type f -name "*.fs" | sed "s/^/'/" | sed "s/$/'/"
        echo ")" 
        } >> "$workdir""$name"
    fi
}
hasharr(){
    if [ "$1" == "-h" ]; then
        hashname=$(echo "$2")
        hasharrname=$(echo "$3")
        {
        echo "#!/bin/bash"
        echo "$hasharrname""=("
        cat "$hashname" | sed "s/^/'/" | sed "s/$/'/"
        echo ")"
        } >> "$hashname".array
    fi
}

mkdir -p "$workdir"
echo "Getting file list..."
# Find files with type of 'f' (file, not directory/link) and split output to multiple files of $splitcount lines
find "$sourcedir_path" -type f | split --lines=$splitcount --numeric-suffixes --additional-suffix=.fs - "$findsplit"

# Make an array off all the named output logs
mkarr -c log.array logarray 
source "$workdir"log.array
echo "Calculating hashes..."
for i in "${logarray[@]}"; do
    hashLog "$i"
done

echo "Cleaning up..."
for f in "${logarray[@]}"; do
    unset dest
    unset src
    src=$(echo "$f.hash")
    dest=$(echo "$src" | sed "s/\.fs//g"  | sed "s/findsplit/hashlog/g")
    mv "$src" "$dest"
    cat "$dest" >> "$logout_path"masterlist.hash
done
