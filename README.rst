x2050 Overview
==============

Verilog implementation of the logic in the IBM 2050.

Synopsis
--------
Emulate the control logic necesary to implement the IBM 2050 CPU.

What is it?
-----------
The IBM 2050 is the cpu for the IBM system 360 model 50.  This is
a 32-bit version of the 360 architecture.  Like most members of the
360 architecture, it was microcoded, in this case, with a 100 bit wide
microcode word.  About a douzen bits are not normally used,
so the microcode word size is actually nominally 90 bits wide.

The 2050 CPU includes the universal instruction set, 3 selector channels
and one multiplexor channel.  The CPU proper runs with a 500 nanosecond
cycle time, and main memory runs with a 2 microsecond cycle time.
The CPU includes a small number of hard-wired registers, most of which
are not visible to the 360 programmer.  One 360 register, the PSW,
is actually implemented as a series of separate registers in the hardware.

The 2050 could be optionally ordered to emulate either the 7070/7074 or
the 1401 family.  These added extra microcode, plus extra hardware logic
to ease emulation of various aspects of the instrunction set,
including I/O characteristics.

Local storage
-------------

A small amount of "local storage" is provided which
can be accessed in 1 machine cycle.  Local storage
consists of 64 words of storage, and is used to store
the s/360 general purpose registers, floating point
registers, and is also used to provide temporary storage
for some CPU instructions as well as for channel logic.

Main Memory
-----------
Main storage is used to store most 360 programs and data.  Up to 512K of
core storage could be attached.  It is implemented as core memory, which
means all reads are destructive.  There is no difference between a read,
read-modify write, or write operation as far as the core is concerned.
Memory is 36-bits wide, and in normal operation, the 4 extra bits are
used to parity-check memory byte-wise.  In addition to the regular
memory, an extra 4 bits is stored per 2K page to control page access
("storage protection"), and a small amount of extra memory (1k words)
is provided for multiplexor channel state information (unit control
words, or bump storage).

In addition to the real main storage, the address space of the machine
could be further expanded with additional "LCS" memory.  This was larger
but slower, and could be shared with certain other 360 mainframes.

Read only storage
-----------------

The microcode was stored in special read-only memory.
It has a 13-bit address which reads out one 100 bit word.
The top bit selects between emulator (1401 or 7070) and regular
operation.  The top 5 and next to lowest bit index one dimension
of the storage.  The 5 bits inbetwen select one of 20 lines (note
that's 20 not 32).  The bottom-most bit is available later in
the machine cycle and selects 1/2 of the 200 bits that come
out of the storage.  Usually, each microinstruction
contains the address of the next microinstruction to be
executed, and the ROAR (read only address register) which
addresses each microinstruction is not a counter and does
not step.  The 90 bits of each regular microcode instruction
are parity checked, using 3 bits.  Microcode instructions
come in two major flavors: CPU mode and I/O mode.  There is
no physical bit in the microcode word to set this; it was
determined by a mode bit in the CPU.  S/360 code also ran
in CPU mode, chanenl logic usually ran in I/O mode.

Channels
--------

The channels are implemented using "break-out" logic in the microcode,
plus hardware assist.  The selector channels are only capable of executing
one channel program at a time, but can transfer up to 4 bytes a time to
or from main storage.  Selector channels were typically for mass storage
devices, such as disk or tape.  The multiplexor channel can execute up
to 200 or more simultaneous channel programs, but can only transfer one
byte at a time.  The multiplexor channel was used for slower devices,
such as printers, card equipment, or the console typewriter.

front panel
-----------
One interesting part of the 2050 is the front panel.  This is the part
that is most commonly found in presevation today.  The front panel
includes hundreds of incandescent light bulbs, and many dozens of lever
switches, plus a small assortment of push buttons and knobs.  All of the
internal registers of the CPU could be viewed on the front panel, mostly
on a sset of 4 rows or "roller" indicators.  Each roller had 8 positions
and would label the current value of an accompaning set of 36 indicators.
Additional indicators and switches could be used to examine or change
main memory, local storage, bump storage, or certain CPU registers.
Provision was made to stop the cpu when executing or accesing any
memory location, and to step one instruction or machine cycle at a time.

It should be noted that the front panel was not purely a hardware
feature.  Many functions of the front panel, including viewing or
changing storage, actually depended on companion microcode logic to
implement.  

Only a tiny set of the front panel was actually used by the computer
operators in normal operation.  The rest were reserved for debugging
hardware faults if something failed.  The main tasks the operator
would have used the front panel for, would have been to set the
IPL device and perform the initial boot.

fault/diagnostic modes
----------------------

The 2050 CPU included a lot of diagnostic capability.
To facilitate finding faults, the diagnostic capability
is designed around a notion of establishing a small
kernel of working hardware, then working outwards from
that to establish more and more functionality.
One of the components of that was a series of disk packs
or tapes that contained diagnostics.  If found,
those could be useful.  The diagnostic capability
is also directly implemented as the "diagnose" instruction.

In support of all that, the CPU is capable of executing
in several modes.  A "Sequence counter" mode, which does
very basic hard-wired sequences, a "main store" mode which
supports a small number of hard-wired op codes, and a
"ros mode" where it runs microcode at full speed.

An interesting feature of the flt logic is that
the parity bits of the main memory data path lose
their special sigificance and memory is simply treated
as a 36-bit data word.

As part of the S/360 architecture, if the CPU encouters
a variety of fatal errors, it is supposed to execute
a "log out" operation in which various bits of machine
state get written out to a defined area of memory.
Exactly what gets written out is model specific.
For the model 50, the logic to write stuff out is
implemented in all 3 modes, so even if there's no
intention to implement all of the flt / diagnostic
logic, a subset would still be needed to make
"log out" work.

implementation
--------------

Timing is simplified relative to the real x2050.
Each machine cycle is one clock cycle, there is no
"early" or "late" reg pulse etc.

Microcode is in "data.bin", and is read in using "$readmemb".
Underscores are used to logically separate fields, and CPU
mode and I/O instructions can be identified by different field
dimensions.  Most lines in data.bin are identified by the
ald# and cld.  Cld is a coordinate system within each
ald page, which addreses one specific microcode word.
The field separateors and ald descriptor is not visible
to the verilog logic, and has (and should have) no meaning to it.

Main memory is implemented as wishbone memory.
Eventually (XXX not yet done), the storage key and parity
logic ought to be stored and retrieved as additional wishbone tags.

State of this code
-----------------

This code is about half-way complete.

My goal is to have a fairly complete system that can
do simple I/O, including booting from a card reader,
printing on a line printer, or using the console typewriter.
Eventually I hope it can also support disk and tape.

Most of the cpu logic is present, also much of the multiplexor.

Lots of crucial bits to actually execute one machine cycle are not
yet present.

My plan going forward is to implement the remaining logic that
can be discovered, including the selector channels.  Then provide
reasonable gueses for missing logic, and provide dummy values
for anything that is not obvious or appears to not be relevant.
Then, debug debug debug...  This is the same process I used for
the x2150 and x2821, so I believe it will work here too.

There are some unit tests here already, but during the course
of the debug process, it will likely be possible if not necessary
to write more unit tests and test beds.

? split roar logic into 4 pieces

! ros should be registered.

References
----------
... Sorry not yet
