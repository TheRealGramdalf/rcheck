# rcheck

`rcheck` is a fairly simple bash script which will take an input directory, find everything with the type of `file` (Note: This does not include symlinks, since it uses `find -type f`), and create a log with the hash and path to each file.

The main reason for this was that when simply doing a recursive checksum and piping the output to a file, it would get corrupted. rcheck will instead manage everything in configurable chunks, so that files only ever reach a given number of lines.

This script is just something I wrote up, so be warned- it requires fairly specific inputs, otherwise it won't work correctly! I wrote this to use for one thing, and while I may use it later on, it doesn't have the usual safeguards in place- such as checking the users input to make sure it is valid. 

In general, however, this should be safe to use, as there are no destructive actions- the only way I can forsee it deleting something is if you have a file named the same as the output log is (default is `masterlist.hash`, in the same folder as the output log. In this case it may overwrite that file.

Here is a simple oneliner you can use to run the script (Note that it requires user input in order to actually run)
```
wget -q https://raw.githubusercontent.com/TheRealGramdalf/rcheck/main/rcheck.sh && chmod +x ./rcheck.sh && bash rcheck.sh
```
