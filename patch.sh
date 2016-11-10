#!/bin/sh

#功能：判断某个目录下特定文件，并且生成patch。
#功能：每个文件都会生成一个patch并且最后生成一个总的patch。
#功能：所有的patch文件都会放到一个目录中保存。
#功能：保存所有patch的文件夹在$2目录中被创建。

#example : patch.sh HEAD ./project/DIR

#types
TYPE=("c" "h" "uni" "dsc")

if [ $# -ne 2 ]
then
  echo "Usage: $0 [branch | commit] [dir]"
  exit 1
fi

#$2 must be a directory.
if [ ! -d $2 ]
then
  echo "Invalid Parameter: $2 is not a directory!"
  exit 1
fi

SHELL_DIR=`pwd`

cd $2
WORK_DIR=`pwd`
PATCH_FILE=${WORK_DIR##*/}.patch
PATCH_DIR=${WORK_DIR##*/}_patch

if [ -d "$PATCH_DIR" ]
then
  echo "Error: $PATCH_DIR exists!"
  exit 1
fi
mkdir $PATCH_DIR

if [ -e "$PATCH_FILE" ]
then
  echo "Error: $PATCH_FILE exists!"
  exit 1
fi
touch $PATCH_FILE

for type in ${TYPE[@]}
do
  ret=`ls | grep "\.$type$"`      #get files by file type.
  for file in $ret                #each file will generated a patch.
  do
    git diff $1 $file > $$.tmp.patch
    
    if [ -s "$$.tmp.patch" ]
    then
      #remove ^M from patch.
      tr -d "\015" < $$.tmp.patch > ${PATCH_DIR}/${file}.patch
    fi
    rm $$.tmp.patch
  done
done

count=`ls $PATCH_DIR | grep patch`
if [ "$count" == "" ]
then
  rmdir $PATCH_DIR
  rm -rf $PATCH_FILE
  exit 1
fi

for file in `ls $PATCH_DIR`
do
	cat ${PATCH_DIR}/${file} >> $PATCH_FILE
done
mv $PATCH_FILE $PATCH_DIR

cd $SHELL_DIR
