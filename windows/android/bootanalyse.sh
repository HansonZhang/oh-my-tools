#!/bin/bash
# This script is used to retrieve a bootchart log generated by init.
# All options are passed to adb, for better or for worse.
# See the readme in this directory for more on bootcharting.

TMPDIR=/tmp/android-bootchart
WIN_TMPDIR=`cygpath -awl /tmp/android-bootchart`

rm -rf $TMPDIR
mkdir -p $TMPDIR

LOGROOT=/data/bootchart
TARBALL=bootchart.tgz
BOOTCHART=pybootchartgui.exe
#BOOTCHART=/d/MyRepo/bootchart/pybootchartgui.py
BOOTGRAPH=`which bootgraph.pl`

FILES="header proc_stat.log proc_ps.log proc_diskstats.log kernel_pacct"

for f in $FILES; do
    adb "${@}" pull $LOGROOT/$f $WIN_TMPDIR/$f 2>&1 > /dev/null
done
(cd $TMPDIR && tar -czf $TARBALL $FILES)
$BOOTCHART -f svg ${WIN_TMPDIR}/${TARBALL}
mv ${TARBALL%.tgz}.svg ${TARBALL%.tgz}-svg.html
explorer ${TARBALL%.tgz}-svg.html
#echo "Clean up ${TMPDIR}/ and ./${TARBALL%.tgz}.png when done"

KLOG=/data/logs/.kmsg
adb "${@}" root
adb "${@}" wait-for-device
adb "${@}" pull $KLOG $WIN_TMPDIR/kmsg 2>&1 > /dev/null
cat $WIN_TMPDIR/kmsg | perl $BOOTGRAPH -header > ./kernel-svg.html
explorer kernel-svg.html