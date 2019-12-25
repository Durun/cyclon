SCRIPT_DIR=`dirname $0`

for LANG in `ls` ; do
    bash $SCRIPT_DIR/merge.bash $LANG
done
