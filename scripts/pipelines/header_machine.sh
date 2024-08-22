#!/bin/bash

keepIntermediate=false # Default value

usage() {
cat <<EOF
Usage: $(basename "$0") [-h] -i INPUT_DIRECTORY -o OUTPUT_DIRECTORY -t TEMPLATE_DIRECTORY [-k]

Uses janus to translate header files, embed them in a vector db, and then feed them as context during translation of .cpp files.
Specific to python.

Options:
   -h       Show this message and exit.
   -i       Specify an existing input directory.
   -o       Specify an output directory that may or may not exist yet. It will be created if needed.
   -t       Specify an existing template directory.
   -k       Keep intermediate products. Optional.
EOF
}

while getopts 'hi:o:t:k' OPTION; do
    case "$OPTION" in
        h)
            usage
            exit 0
            ;;
        i)
            srcDir=$OPTARG
            ;;
        o)
            dstDir=$OPTARG
            ;;
        t)
            tmpltDir=$OPTARG
            ;;
        k)
            keepIntermediate=true
            ;;
        ?)
            usage >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND -1))"

# Checking whether all required parameters are provided
if [ -z "${srcDir}" ] || [ -z "${dstDir}" ] || [ -z "${tmpltDir}" ]; then
    echo "Error: Input directory (-i), Output directory (-o), Template directory (-t) must be specified." >&2
    usage >&2
    exit 1
fi

# Checking whether source & template directories actually exists
for dir in ${srcDir} ${tmpltDir}; do
    if [ ! -d ${dir} ]; then
        echo "Error: Directory ${dir} doesn't exist!" >&2
        exit 1
    fi
done


convertHeaders (){
    srcDirectory=$1
    dstDirectory=$2
    mkdir -p "$dstDirectory"

    find "$srcDirectory" -type f -name *.h | while read hFile;do
        relPath=${hFile##*$srcDirectory};relPath=/${relPath%%.*}; dstFile="${dstDirectory}${relPath}.cpp"
        dstFolder=$(dirname "$dstFile"); mkdir -p "$dstFolder"
        cp "$hFile" "$dstFile"
    done
}

# Generate a uid for the temp directory
masterTemp="$(uuidgen)"
convertHeaders "$srcDir" "$masterTemp/header-temp"
mkdir "$masterTemp/cpp-temp"

# continue processing .cpp files
find "$srcDir" -type f -name '*.cpp' -print0 | while read -d $'\0' file
do
    cp "$file" "$masterTemp/cpp-temp/"
done

# ask janus to tanslate headers in the temp dirs
janus translate --input-dir "$masterTemp/header-temp" --output-dir "$masterTemp/first-translation" --target-lang python --source-lang cpp --prompt-template "$tmpltDir/simple/" 

janus db init
# embed the translations
janus db add "$masterTemp" --input-dir "$masterTemp/first-translation" --input-lang python

# ask janus to translate everything with that embedding
janus translate --input-dir "$srcDir" --output-dir "$dstDir" --target-lang python --source-lang cpp --prompt-template "$tmpltDir/simple-rag-headers/" --in-collection "$masterTemp" --n-db-results 3

if [ "$keepIntermediate" = "false" ]; then
	rm -r "$masterTemp"
	janus db rm "$masterTemp"
fi



