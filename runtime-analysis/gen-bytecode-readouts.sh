#!/bin/bash

# Create directories for bytecode files from Lua source repos
# Bytecode generated for two runtimes
# (1) Lua 5.1 -- compiler installed as luac-5.1 on my system
# (2) LuaJIT

# Get name and source of module
echo -e "Enter module name: "
read NAME
echo -e "Enter module source: "
read SOURCE

# Make directory to store results
DIR="bytecode_$NAME"
mkdir $DIR

# Start log
touch $DIR/overview.txt
touch $DIR/bytecode-5_1.txt
touch $DIR/bytecode-jit.txt
echo "$NAME, accessed from $SOURCE" > $DIR/overview.txt
echo "$NAME, accessed from $SOURCE" > $DIR/bytecode-5_1.txt
echo "$NAME, accessed from $SOURCE" > $DIR/bytecode-jit.txt

LOC=0
# Iterate through every file to create bytecode
FILES=$(find . | grep ".*.lua$")
for f in $FILES
do
	echo "Processing $f..."
	FNAME=$(echo $f | awk -F/ '{print $NF}' | awk -F. '{print $1}')
	LINES=$(wc -l $f | grep -o -E "\d+ " | tr -d " ")
	LOC=$(( LOC + LINES))
	echo "lines of code: $LINES, LOC total: $LOC"
	echo "$FNAME.lua : $LINES lines of code" >> $DIR/overview.txt

	touch $DIR/$FNAME-5_1.txt
	luac-5.1 $f
	luac-5.1 -l $f > $DIR/$FNAME-5_1.txt
	echo "-----------------------" >> $DIR/bytecode-5_1.txt
	luac-5.1 -l $f >> $DIR/bytecode-5_1.txt

	touch $DIR/$FNAME-jit.txt
	luajit $f
	luajit -bl $f > $DIR/$FNAME-jit.txt
	echo "-----------------------" >> $DIR/bytecode-jit.txt
	luajit -bl $f >> $DIR/bytecode-jit.txt
done

echo "Total lines of code: $LOC" >> $DIR/overview.txt
rm luac.out
