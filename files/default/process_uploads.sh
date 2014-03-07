#!/bin/bash

#
# Getting ingestion mode from ET.Importer.IngestionMode dna
#
unset a i

cd /

while IFS= read -r -u3 file
do
  gunzip $file
done 3< <(/bin/find /usr/chroot/home/* -iname *.gz)

while IFS= read -r -u3 file
do
  unzip -o -d `dirname $file` $file
  if [[ $? == 0 ]]; then
    rm -f $file
  fi
done 3< <(/bin/find /usr/chroot/home/* -iname *.zip)

while IFS= read -r -u3 file
do
    oid=`echo $file | perl -pe 's|/usr/chroot/home/(.*?)\d+/.*$|\1|'`
    filename=`echo $file | perl -pe 's|/usr/chroot/home/(.*?)\d+/(uploads/)*(.*)$|\3|'`
    echo "Found file $file for $oid ... uploading to importer $(date)"
    dna=`curl "https://api.evertrue.com/1.0/$oid/dna/ET.Importer.IngestionMode"`
    auto=`echo $dna | grep AutoIngest`
    if [[ $auto ]]; then
        haseof=`grep EVERTRUE-EOF $file`
        if [[ $haseof ]]; then
            lower=`echo $file | tr [:upper:] [:lower:]`
            if [[ $lower = *.full.* ]]; then
                response=`curl -i -F upload="@$file;type=text/csv" -F type=file -F prune=prune "https://api.evertrue.com/1.0/$oid/importjob"`
                echo $response
                statusIsOk=`echo $response | grep ok`
                if [[ $statusIsOk ]]; then
                    mv "$file" /var/evertrue/uploads/
                    chown root:root /var/evertrue/uploads/$filename
                    chmod 700 /var/evertrue/uploads/$filename
                    gzip -9 /var/evertrue/uploads/$filename
                fi

            else
                response=`curl -i -F upload="@$file;type=text/csv" -F type=file "https://api.evertrue.com/1.0/$oid/importjob"`
                echo $response
                statusIsOk=`echo $response | grep ok`
                if [[ $statusIsOk ]]; then
                    mv "$file" /var/evertrue/uploads/
                    chown root:root /var/evertrue/uploads/$filename
                    chmod 700 /var/evertrue/uploads/$filename
                    gzip -9 /var/evertrue/uploads/$filename
                fi
            fi
        else
            echo "Missing EOF marker";
        fi
    else
        echo "Ignoring autoprocessing...";
    fi
    echo ""
done 3< <(/bin/find /usr/chroot/home/* -iname *.csv)

exit;
