#!/bin/bash
: ${SOMATIC_API_KEY?"Please set SOMATIC_API_KEY in the enviroment to make api calls."}
STYLES=('MZJNYmZY' 'Bka9oBkM' '8k8aLmnM' 'LnL71DkK' 'LnL7oLkK' '7ZxJo3k9')


transfer() { if [ $# -eq 0 ]; then echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi
tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; fi; cat $tmpfile; rm -f $tmpfile; }

if ! [ -d "$1/stylized_gallery" ] ; then
  mkdir "$1/stylized_gallery"
fi

if [ -d "$1" ] ; then
  cd $1
  for file in "$1"/*; do
    if [ -f "$file" ] ; then
      IMAGE="$(pwd -P)/${file##*/}"
      echo "$IMAGE is being processed..."
      IMAGE_URL="$(transfer $IMAGE)"
      RANDOM=$$$(date +%s)
      STYLE_ID=${STYLES[$RANDOM % ${#STYLES[@]}]}
      curl "http://convert.somatic.io/api/v1.2/cdn-query?id=$STYLE_ID&api_key=$SOMATIC_API_KEY&--input=$IMAGE_URL" > "$1/stylized_gallery/$RANDOM.jpg"
    fi
  done
else
  echo "Please pass a folder name."
fi
echo "Your gallery has been generated!"
