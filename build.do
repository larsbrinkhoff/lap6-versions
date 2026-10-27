cd %~p0

set crt disabled
set dpy text
attach tape0 clobbered.linc
attach tape1 "%1"

# PRINT MS has an undefined symbol 5T.
expect -p "ERRORS" send "\r"; continue

expect "1"
boot tape0

call am "MSDISPLY"
call cv
call cp 10 blocks 340 300
call am "ADDMS LO"
call cv
call cp 1 block 343 324
call restart
call am "FILECOMS"
call cv
call cp 4 blocks 340 320
call restart
call am "COPYFILE"
call cv
call cp 3 blocks 340 314
call restart
call am "COPY"
call cv
call cp 2 blocks 340 336
call restart
call am "CONVERT"
call cv
call cp 3 blocks 340 330
call restart
call am "CV DIS"
call cv
call cp 2 blocks 340 310
call restart
call am "DISX PX"
call am "TELETYPE"
call cv
call cp 2 blocks 340 325
call restart
call am "PRINT MS"
call am "TELETYPE"
call cv
call cp 1 block 342 322
call restart
call am "LIST"
call am "TELETYPE"
call cv
call cp 1 block 341 333
call cp 1 block 342 327
call cp 1 block 343 335
call cp 2 blocks 346 312
call cp 1 block 346 317
quit

:am
echo !Read manuscript %1
send "\eAM "
expect "-/AM"
continue
send "%1,0"
expect "%1,0"
continue
send "\r"
expect "_"
continue
return

:cv
echo !Assembling
send "\eCV"
expect "-/CV"
continue
send "\r"
expect "MEMORY ALLOCATION"
continue
send "\r"
expect "SYMBOLS"
continue
send "\r"
expect "_"
continue
return

:cp
echo !Copy %1 %2 from %3 to %4
send "\eCP"
expect "-/CP"
continue
send "\r"
expect "COPY"
continue
send "%1\r"
expect "%1 BLOCKS"
continue
send "%3\r"
expect "FROM BLOCK %3"
continue
send "0\r"
expect "UNIT 0,"
continue
send "%4\r"
expect "TO BLOCK %4"
continue
send "1"
expect "UNIT 1"
continue
send "\r"
expect "_"
continue
return

:restart
echo !Reset current manuscript
expect "1"
go 20
return
