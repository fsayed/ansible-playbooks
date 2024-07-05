#/bin/bash

DESTDIR=/opt/home/nmon/data
ARCHIVE=$DESTDIR/ARCHIVE

[ -d $ARCHIVE ] || mkdir -p $ARCHIVE

for i in `find $DESTDIR -type f -mtime +7 -name '*.nmon'`
do
    DIR=$ARCHIVE/$(echo $i| perl -n -e '~/_(\d{6})_/; print "$1"')
    [ -d $DIR ] || mkdir $DIR
    gzip $i && mv $i.gz $DIR
done

