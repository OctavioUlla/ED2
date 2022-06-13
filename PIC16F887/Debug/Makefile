###############################################################################
# Makefile for project 
###############################################################################

## General options
PROJECT = 
MCU = PIC16F877
COMPILER = "MPASM (Proteus)"
TARGET = Debug
SHELL = C:\WINDOWS\system32\cmd.exe

## Tools general options
ASMFLAGS=/q+ /p16f877
LDFLAGS=/x /p16f877

## Processing Tools
ASM=MPASMWIN.exe
LD=mplink.exe
LIB=mplib.exe
#  D:/Documentos/ED2/PIC16F887/Debug/Debug.cof: TOOL=LD
#     D:/Documentos/ED2/PIC16F887/Debug/main.o: TOOL=ASM
#        D:/Documentos/ED2/PIC16F887/main.asm

# Build tree:
all:	Debug

Debug:	Debug.cof

Debug.cof:	main.o 
	$(LD) $(LDFLAGS) /o "./Debug.cof" 16f877_g.lkr "main.o"

main.o:	../main.asm 
	$(ASM) /e"./main.err" /l"./main.lst" /o"main.o" $(ASMFLAGS)  "..\main.asm"

# tidy - delete all temporary files which are not involved in the target generation
tidy:
	rm -rf ./main.err
	rm -rf ./main.hex
	rm -rf ./main.lst

# cleanup - delete all generated files
clean:	tidy
	rm -rf Debug.cof
	rm -rf main.o

