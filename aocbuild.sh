#!/bin/bash

# Check if the parameter x is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <x>"
  exit 1
fi

# Assign the parameter to x
x="$1"

# Pad x to 3 digits
filenameMain=$(printf "day_%02d.jl" "$x")
filenameTest=$(printf "test/tst_d%02d.dat" "$x")
filenameInput=$(printf "input/inp_d%02d.dat" "$x")

# Check if the file already exists
if [ ! -e "$filenameMain" ]; then
  # Create the file and write the message in it
  echo "include(\"aoc_utils.jl\")" > "$filenameMain"
  echo "aocbuild($x, rebuild = false)" >> "$filenameMain"
  echo "data = aocload($x, test = true)" >> "$filenameMain"
  echo "File '$filenameMain' created with content."
else
  echo "File '$filenameMain' already exists."
fi

# Check if the file already exists
if [ ! -e "$filenameTest" ]; then
  # Create the file and write the message in it
  echo "Paste test data for day $x here." > "$filenameTest"
  echo "File '$filenameTest' created with content."
else
  echo "File '$filenameTest' already exists."
fi

# Check if the file already exists
if [ ! -e "$filenameInput" ]; then
  # Create the file and write the message in it
  echo "Paste input data for day $x here." > "$filenameInput"
  echo "File '$filenameInput' created with content."
else
  echo "File '$filenameInput' already exists."
fi

code -r "aoc_utils.jl"
code -r "$filenameMain"
code -r "$filenameInput"
code -r "$filenameTest"