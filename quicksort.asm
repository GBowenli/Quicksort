.data
#any any data you need be after this line 

header:	.asciiz	"Welcome to QuickSort\n"
output1:.asciiz "\nThe array is re-initialized\n"
output2:.asciiz "\nThe sorted array is: "
output3:.asciiz "\n<program ends>" 

array: 	.space 100	# array used to sort (used due to the fact that if the elements have not been cleared, elements of array inputed from user is combined)
newArray:	.space 100	# array inputed from user
formattedArray:	.space 500	# array converted back to ascii characters to print

	.text
	.globl main

main:	la $s0, header
	
writeHeader:	lb $a0, 0($s0)	# output Header
		addi $s0, $s0, 1
		jal write
		bne $a0, $zero, writeHeader
		
		la $s0, array
		li $s3, -1
		sb $s3, 0($s0)	# store -1 as the first byte of array (indicate it is empty)
		
continueExecution:	la $s0, newArray
		li $s1, 96	# ascii for ` everything greater is lowercase letter
		li $s2, 32	# ascii for space
		li $s3, -1	# used to represent open register
		
		li $s4, -1	# registers containing the integers to store
		li $s5, -1
		
		li $s6, 10	# used to multiply by the tens digit when storing
		
		li $s7, 10	# ascii for newline
		
readAndWriteArray:	jal read	# read user input and echo everything until the command character
			beq $v0, $s7, doNothing	# if output is newline do nothing
			bgt $v0, $s1, noOutput1	# if output is a letter do not output or store
			
			beq $v0, $s2, storeArray
			j storeRegisters
			
storeArray:		beq $s5, $s3, storeSingleDigit	# if s5 is -1, means it is single digit number
			j storeDoubleDigit
			
storeSingleDigit:	sb $s4, 0($s0)	# store single digit number from s4 in newArray
			j skipStoreDoubleDigit
			
storeDoubleDigit:	mult $s4, $s6	# calculate 2 digit number and store in newArray
			mflo $s4
			add $s4, $s4, $s5
			sb $s4, 0($s0)

skipStoreDoubleDigit:	addi $s0, $s0, 1# advance pointer to newArray to next byte
			move $s4, $s3	# reset registers
			move $s5, $s3
			j skipStore

storeRegisters:		beq $s4, $s3, storeInS4	# if s4 register is -1, store in s4 register, if not store in s5 register
			j storeInS5

storeInS4:		move $s4, $v0
			andi $s4, 0x0f	# take out the 0011 bits from the ascii portion of the number
			j skipStore
			
storeInS5:		move $s5, $v0
			andi $s5, 0x0f	# take out the 0011 bits from the ascii portion of the number

skipStore:		move $a0, $v0
			jal write
			j readAndWriteArray
			
doNothing:	j readAndWriteArray

noOutput1:	sb $s3, 0($s0)	# store -1 to the end of newArray

		li $s1, 99	# ascii for c
		beq $v0, $s1, cCommand
		
		li $s1, 115	# ascii for s
		beq $v0, $s1, sCommand
		
		li $s1, 113	# ascii for q
		beq $v0, $s1, qCommand
		
cCommand:	la $s0, array
		li $s1, -1

reset1:		lb $s2, 0($s0)	# clear all content from array
		sb $zero, 0($s0)
		addi $s0, $s0, 1
		bne $s2, $s1, reset1

		la $s0, array
		li $s1, -1
		la $s3, newArray
		
reinitialize:	lb $s2, 0($s3)	# set newArray as array
		sb $s2, 0($s0)
		addi $s3, $s3, 1
		addi $s0, $s0, 1
		bne $s2, $s1, reinitialize
		
		la $s0, output1
		
writeOutput1:	lb $a0, 0($s0)	# output output1
		addi $s0, $s0, 1
		jal write
		bne $a0, $zero, writeOutput1
		
		la $s0, newArray
		li $s1, -1

reset2:		lb $s2, 0($s0)	# clear all content from newArray
		sb $zero, 0($s0)
		addi $s0, $s0, 1
		bne $s2, $s1, reset2
		
		j continueExecution

sCommand:	la $s0, array
		li $s2, -1
						
findArrayEnd:	lb $s1, 0($s0)	# loop array to the byte after the byte holding -1
		addi $s0, $s0, 1
		bne $s1, $s2, findArrayEnd
		
		subi $s0, $s0, 1	# subtract pointer by 1 to go back to the byte holding -1
		
		la $s3, newArray
		
copyNewArray:	lb $s1, 0($s3)	# copy all contents of newArray in array
		sb $s1, 0($s0)
		addi $s3, $s3, 1
		addi $s0, $s0, 1
		bne $s1, $s2, copyNewArray
		
		la $s0, array ################### THIS IS WHERE QUICK SORT STARTS
		li $s2, -1	# represents end of array
		li $s3, -1	# counter
		
findLastElement:lb $s1, 0($s0)	# find the index of the last element in the array (byte before -1)
		addi $s0, $s0, 1 
		addi $s3, $s3, 1
		bne $s1, $s2, findLastElement
	
		subi $s3, $s3, 1	# subtract by 1 to account for -1
	
		la $a0, array
		move $a1, $zero
		move $a2, $s3
		jal quickSort	# perform quickSort
		
		la $a0, array
		la $a1, formattedArray
		jal formatArray
		
		la $s0, output2
		
writeOutput2:	lb $a0, 0($s0)	# output output2
		addi $s0, $s0, 1
		jal write
		bne $a0, $zero, writeOutput2
		
		la $s0, formattedArray
		
writeFormattedArray:	lb $a0, 0($s0)	# output formattedArray
			addi $s0, $s0, 1
			jal write
			bne $a0, $zero, writeFormattedArray
		
		la $s0, newArray
		li $s1, -1

reset3:		lb $s2, 0($s0)	# clear all content from newArray
		sb $zero, 0($s0)
		addi $s0, $s0, 1
		bne $s2, $s1, reset3
		
		la $s0, formattedArray
		li $s1, 10

reset4:		lb $s2, 0($s0)	# clear all content from formattedArray
		sb $zero, 0($s0)
		addi $s0, $s0, 1
		bne $s2, $s1, reset4

		j continueExecution

qCommand:	la $s0, output3
		
writeOutput3:	lb $a0, 0($s0)	# output output3
		addi $s0, $s0, 1
		jal write
		bne $a0, $zero, writeOutput3

		li $v0, 10	# end program
		syscall		

# all subroutines you create must come below "main"

read:  	lui $t0, 0xffff 	#ffff0000
loop1:	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,loop1
	lw $v0, 4($t0) 		#data	
	jr $ra

write:  lui $t0, 0xffff 	#ffff0000
loop2: 	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,loop2
	sw $a0, 12($t0) 	#data	
	jr $ra

formatArray:	li $t1, -1	
		li $t2, 10
		
convert:	lb $t0, 0($a0)
		addi $a0, $a0, 1
		
		beq $t0, $t1, skipConvert	# if character is -1 do not convert to ascii
		
		bge $t0, $t2, convertTwoDigits	# if t0 is greater than or equal to 10 convert the 2 digit number to ascii
		
		ori $t0, 0x30	# convert single digit number to ascii
		sb $t0, 0($a1)
		addi $a1, $a1, 1
		j skipConvertTwoDigits	
			
convertTwoDigits:	div $t0, $t2	# divide by 10 to find ones and tens digit
			mflo $t3	# quotient is the tens digit
			mfhi $t4	# remainder is the ones digit
			
			ori $t3, 0x30	# convert quotient to ascii
			sb $t3, 0($a1)
			ori $t4, 0x30	# convert remainder to ascii
			sb $t4, 1($a1)
			addi $a1, $a1, 2
			
skipConvertTwoDigits:	li $t3, 32	# ascii for space
			sb $t3, 0($a1)
			addi $a1, $a1, 1
				
skipConvert:		bne $t0, $t1, convert	# continue converting if character is not -1

			li $t3, 10	# ascii for newline
			sb $t3, 0($a1)
			
			jr $ra
			
# $a0 address of array
# $a1 begin index
# $a2 end index		
quickSort:	addi $sp, $sp, -16	# space on stack
		sw $ra, 0($sp)		# save return address
		sw $s5, 4($sp)		
		sw $s6, 8($sp)		
		sw $s7, 12($sp)
		
		move $s6, $a1	# save begin and end indices
		move $s7, $a2
		
		bge $s6, $s7, exitQuickSort	# if begin index is greater than or equal to end index. exit
		
		la $a0, array
		move $a1, $s6
		move $a2, $s7
		jal partition	
		
		move $s5, $v0
		
		la $a0, array
		move $a1, $s6
		subi $a2, $s5, 1# a0 is still begin index, a2 is partition index - 1
		jal quickSort
		
		la $a0, array
		addi $a1, $s5, 1# a0 is partition index + 1, a2 is still end index
		move $a2, $s7
		jal quickSort
		
exitQuickSort:	lw $ra, 0($sp)		# restore return address
		lw $s5, 4($sp)
		lw $s6, 8($sp)
		lw $s7, 12($sp)
		addi $sp, $sp, 16	# restore stack
		jr $ra									
		
		
# CHECK REGISTERS IF THEY ARE CHANGED IN SUB ROUTINES		
# $a0 address of array
# $a1 begin index
# a2 end index
partition:	addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		li $t0, -1	# counter for checking character is end character
		move $t4, $a1	# store a1 and a2	
		move $t5, $a2

findEndElement:	lb $t6, 0($a0)	# t6 will contain element at end index (pivot)
		addi $a0, $a0, 1
		addi $t0, $t0, 1
		bne $t0, $t5, findEndElement
		
		subi $t7, $a1, 1	# t7 = begin index - 1 (i)				
		
		move $t8, $t4	# save t8 as begin index
		
performSwaps:	la $t0, array
		li $t1, -1	# reset counter
		
findStart:	lb $t2, 0($t0)	
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		bne $t1, $t8, findStart
		
		beq $t8, $t5, endSwap
		
		bgt $t2, $t6, skipSwap	# if loaded byte is greater than pivot do not swap with i'th element
		
		addi $t7, $t7, 1	# i++
		
		la $a0, array	# swap elements at i and current position of array in loop
		move $a1, $t7
		move $a2, $t8
		jal swap
		
skipSwap:	addi $t8, $t8, 1
		j performSwaps
		
endSwap:	la $a0, array
		addi $t7, $t7, 1	# i++
		move $a1, $t7
		move $a2, $t5
		jal swap	# swap elements at i+1 and end index
		
		move $v0, $t7
		
		lw $ra, 0($sp)	# get return address
		addi $sp, $sp, 4# restore stack
		jr $ra		
					
# a0, address of array
# a1, index of first swap element
# a2, index of second swap element		
swap:	la $t0, array	# use another pointer to array to swap faster
	li $t1, -1	# counter for checking if the character is first or second swap element
		
findFirst:	lb $t2, 0($a0)		# t2 will contain element at a1 index by the end of findFIrst
		addi $a0, $a0, 1	# move pointer to next byte
		addi $t1, $t1, 1	# increment counter
		bne $t1, $a1, findFirst	# if not at index of first swap continue looping
		
		subi $a0, $a0, 1	# move pointer back by 1
		
		li $t1, -1	# reset counter
	
findSecond:	lb $t3, 0($t0)		# t3 will contain element at a2 index by the end of findSecond
		addi $t0, $t0, 1	# move second pointer to next byte
		addi $t1, $t1, 1	# increment counter
		bne $t1, $a2, findSecond# if not at the index of second swap continue looping
		
		subi $t0, $t0, 1	# move pointer back by 1
		
		sb $t3, 0($a0)	# perform swap
		sb $t2, 0($t0)

		jr $ra
