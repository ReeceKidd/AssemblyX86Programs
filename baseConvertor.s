*----------------------------------------------------------------------
* Programmer:Reece Kidd
* Class Account:cssc0215
* Assignment or Title: Base Convertor
* Filename: baseConvertor.s
* Date completed:04/26/2017
*----------------------------------------------------------------------
*Problem statement:
* Write a program that takes three inputs from the keyboard:
* A source base, a number in that base and a base to convert to. The program will then convert the source base to the destination base and will
* print the converted number to the screen. 
*  
* Input:
* Base of number to convert - Integer.
* The number to convert - Integer.
* The base to convert to - Integer.
*
* Output: 
* "The number is" + Converted number. 
* "Do you want to convert another number? (Y/N)".
*
* Error conditions tested:
* --Base checks--
* 1) Checks is base is empty. 
* 2) Checks that base entered is between 2-16
* 3) Checks for invalid ASCII characters. 
* 4) Checks that number entered is not negative. 
*
*--Number to be converted checks--
* 1) Checks that number to be converted is not greater than $FFFF. 
* 2) Checks that number entered is not empty. 
* 3) Checks that the number is valid for the base it is in. 
* 4) Checks for invalid ASCII characters. 
* 5) Checks that the number is not negative. 
*
* Included files:prog3.s
*
* Method and/or pseudocode: 
*
* My process for coming up with the solution to this code was to first write out the entire problem in text, where I attempted. 
* to predict what I would need to test for and edge cases that would pass these cases. 
*
* From there I took this document and made it pseudocode for java. With this pseudocode I then created the java program. However, the java 
* program didn't accurately portray the difficulty, as it was much easier to catch errors. But it gave me a firm understanding of the problem.
*
* My approach to get the assembly code complete was as follows. Firstly I decided I would focus on getting the valid numbers for the base values.
* and the number to be converted. To do this there where a variety of checks that needed to be completed. As the base checks where much easier. 
* I completed the base checks first. I first checked for empty, then if it was one or two digits, as this was the best way I found to deal with the 
* ASCII characters between the numeric values and the letters that proved to be problematic. 
* 
* For every check that I completed I would test them as I go to ensure one check was fully working as it should before I moved onto the next. 
*
* At this stage I stored all my error labels and code at the bottom of the program, in order to keep everything organized, as I didn't know if more
* assembly code would be needed. 
*
* I then moved onto the number to be converted checks. This is where the majority of my time was spent. I first established if all the digits where * valid in the base. Once that was completed, I moved onto the decimal conversion. 

* I converted to decimal for two reasons, to check if the number is larger than ffff hex. Secondly, I needed it in decimal in order for the my
* conversion to work. I ran into a variety of overflow issues at 
* this point as I wasn't checking the exponent value was greater than ffff hex. 
* 
* Once I was certain the user could only enter valid data, I moved onto the conversion algorithm from decimal. I tested a variety of inputs to
* ensure it was the correct base 10 conversion stored in hex. Once that was complete, I then reversed the output in order to get the correct answer.
*
* With a working program I implemented the part where the user can convert another number if they wish, I then placed the error messages close to
* where the error is prompted, which decreased the distance for the branch instructions. 
* 
* Finally, I tested every edge case I could think off, attempting to break the program in every way I could. I then opened up an online base 
* base convertor calculaor, and converted a different value from every base into every other base. Once I had covered all edge cases, had the 
* correct answer and couldn't cause the program to fail. I decided the program was complete. 
* 
* References:I/O Macro Documentation, Alan Riggins, 2005
*
*----------------------------------------------------------------------
*
        ORG     $0
        DC.L    $3000           * Stack pointer value after a reset
        DC.L    start           * Program counter value after a reset
        ORG     $3000           * Start at location 3000 Hex
*
*----------------------------------------------------------------------
*
#minclude /home/cs/faculty/riggins/bsvc/macros/iomacs.s
#minclude /home/cs/faculty/riggins/bsvc/macros/evtmacs.s
*
*----------------------------------------------------------------------
*
* Register use
*
*----------------------------------------------------------------------
*
start:	initIO			*Initalize input output field.
	setEVT			*Error handling routines
	
	lineout 	title		*Displays program information.
PB1:	lineout 	base 		*Prompt user for the base of the number being converted. 
	linein 		buffer		*Read in base value of number to be converted.
	stripp		buffer,D0	*Removes the leading zeros on user input. 
	tst.w		D0  		*Tests to see if users input is empty. 
	beq		EPB1		*Go to empty base one error. 
	move.w		D0,D1		*Stores the number of digits entered for the base. 
	cmpi.w		#2,D1		*Compares the length of the number entered. 
	bgt		PBE1		*Goes to error if the base is longer than two digits.
	cmpi.w		#0,D1		*Checks if the digit is one number in length.
	blt		PBE1		*Checks to make sure it is not empty.  
	cmpi.w		#1,D1           *If user input is one digit
	beq		B1              *Go to one digit base check. 
	cmpi.w		#2,D1		*If user input is two digits.
	beq		B2		*Go to two digit check. 
		
EPB1:	lineout		emER		*Prompt them to empter a number and not a blank space.
	bra		PB1		*Go back to base one entry. 
	
B1:     cvta2		buffer,D0	*Converts to 2's complement for checks.
	cmpi.w		#2,D0		*If D0 is less than 2 go to Base 1 error message. 
	blt		PBE1		*Go to first base error message.
	cmpi.w		#9,D0	 	*If the single digit is greater than nine. 
	bgt		PBE1		*Go to Prompt Branch Error Block. 
	bra		STR1		*If base is valid prompt user for the number they want to convert. 
	
B2:     cvta2		buffer,D0	*Converts to 2's complement for checks. 
	cmpi.b		#2,D0		*If number is less than 2. 
	blt		PBE1		*Prompt error message. 
	cmpi.b		#16,D0		*If number is greater than 16. 
	bgt		PBE1		*Prompt if number is greater. 
	bra 		STR1		*If base is valid prompt user for the number they want to convert.
PBE1:   lineout		bain		*Base invalid error. 
	lineout         bErr  	        *Prompts current base of number error.
        bra	        PB1		*Ask user for another base. 
	 		
STR1:	move.b		D0,D1		*Stores valid base.  
		
PNUM:	lineout 	num		*Prompt user for number they want to convert.
	linein 		buffer		*Reads number that the user wants to convert. 
	stripp		buffer,D0	*Removes leading zereos from users input.
	clr.l		D2		*Initilises D2 to 0 to store the decimal sum of the digits. 
	clr.l		D3		*Clears the exponent sum storage. 
	clr.l		D4		*Clears users input. 
	clr.l		D5		*Initilises counter for decimal conversion. 
	move.w		D0,D7		*Gets number of digits of number to be converted. 
	move.w		D0,D6		*Second copy of the number of digits. 
	subq.w		#1,D7		*Minus 1 from the length of digits to use with DBRA. 	
	tst.w		D6  		*Tests to see if users input is empty. 
	beq		EERR		*Go to Empty Error Block. 				
	lea		buffer,A0	*Loads buffer into A0.
	lea 		result,A1	*Loads result into A1
	lea		buffer2,A2	*Loads buffer2 into A2. 
	add.w		D7,A0		*Starts A0 at the back of the number.  
	bra		FOR		*Skips over the empty error message. 
EERR:	lineout		emEr		*Prompts empty entry error.
	bra		PNUM		*Go to the start of requesting a number for the user to convert. 
	
					*Checks for (0-9)
		
FOR:	move.b		(A0),D4		*Loops to get current digit.
        cmpi.b          #'0',D4	        *Compare that digits are entered are numeric and greater than 0.
        blt		HEX		*Redirects to invalid hex digit entered.
	cmpi.b		#'9',D4  	*Checks for letter characters.
	bhi		LCHA		*If it's higher than nine go to (a-f) checks. 	
        cvta2		(A0),#1		*Converts to two's complement.
        cmp.b		D1,D0           *Checks validity of digit against the base.  
	bhs		BINV		*Digit is invalid for the base error. 
	sub.b		#$30,D4  	*Subtracts 30 to get the decimal value. 
	bra		EXP		*Go to decimal conversion. 
	
					*Checks for(A-F)

LCHA:	ori.b		#$20,D4 	*Lower cases character.
        cmpi.b		#'a',D4 	*Checks if ASCII value is < 'a' which would make it invalid.
	blo		HEX		*Prompts invalid hex character error.
	cmpi.b		#'f',D4 	*If digit is higher than ASCII value of 'f'.
	bhi		HEX		*Prompts invalid hex character error.
	sub.b		#$57,D4 	*Subtracts 57 from A0 to get Hex value.		
        cmp.b		D1,D4	        *Compares current hex character to base. 
	bhs		BINV		*Character is invalid for the base error.
	bra		EXP		*Go to decimal conversion.
HEX:	lineout		hexE		*Prompts invalid hex characters.
	bra		PNUM		*Go back to PNum
BINV:	lineout 	bOut		*Prompts number is valid for the base. 
	bra		PNUM		*Go back to PNum.
	
					*Decimal conversion. 
					
EXP:    cmpi.b		#0,D5		*Compares counter to 0, if 0 it means exponenent is 0.  
	beq		EXP0		*Go to EXP0 because no multiplication is necessary.
	cmpi.b		#1,D5		*Compares counter to 1, if counter is one it means the exponent is one. 
	beq		EXPB		*Go to EXPB.
	cmpi.l		#$0000FFFF,D3	*Checks for exponent against maximum number.
	bhi		LAR		*Go to number too large message. 
	muls		D3,D4		*If exponent is greater than one, multiply the digit by the exponent value. Store valid digit in D4.
	add.l		D4,D2		*Adds decimal value to the sum. 
	muls		D1,D3		*Stores the next exponent value for use with the next digit, multiplies current value by base. 
	bra		SIZE		*Branch to VAL to  convert next digit.
EXPB:	muls	        D3,D4		*Multiplies current digit by exponent 1. 
	add.l		D4,D2		*Adds decimal value to sum. 
	muls		D1,D3		*Stores exponent 2 value. 
	bra		SIZE		*Branch to VAL to convert next digit.
EXP0:	add.l		D4,D2		*Adds the value of digit to the sum.
	move.w		D1,D3		*Moves D1 into D3 for the multiplication for exponent 1.

SIZE:	cmpi.l		#$0000FFFF,D2	*Compares the maximum word value in decimal to D2. 
        bhi		LAR		*If 65535 is greater, it means the number is too large for a word and it cannot be converted. 
	bra		VAL		*Skip over large error message. 
LAR:	lineout		sErr		*Prompts number entered is too large for conversion 
	bra		PNUM		*Go back to PNUM.	
	
VAL:    add.w	        #1,D5		*Increases the counter variable by one in order to convert current base to decimal value. 
        sub.w           #1,A0		*If a valid integer is entered, A0--
	clr.l		D4		*Clears D4. 
        dbra		D7,FOR		*Loop to next digit. 
	clr.l		D3		*Clears D3.
														
PB2:	lineout 	base 		*Prompt user for the base of the number being converted. 
	linein 		buffer		*Read in base value of number to be converted.
	stripp		buffer,D0	*Removes the leading zeros on user input. 
	tst.w		D0  		*Tests to see if users input is empty. 
	beq		EPB2		*Go to empty base one error. 
	move.w		D0,D4		*Stores the number of digits entered for the base. 
	cmpi.w		#2,D4		*Compares the length of the number entered. 
	bgt		PBE2		*Goes to error if the base is longer than two digits.
	cmpi.w		#0,D4		*Checks if the digit is one number in length.
	blt		PBE2		*Checks to make sure it is not empty.  
	cmpi.w		#1,D4           *If user input is one digit
	beq		B21             *Go to one digit base check. 
	cmpi.w		#2,D4		*If user input is two digits.
	beq		B22		*Go to two digit base check. 
	
EPB2:	lineout		emER		*Prompt USER to empter a number and not a blank space.
	bra		PB2		*Go back to base two entry. 
	
B21:    cvta2		buffer,D0	*Converts to 2's complement for checks.
	cmpi.w		#2,D0		*If D0 is less than 2 go to Base 1 error message. 
	blt		PBE2		*Assess NSVC number. Send to first base error message.
	cmpi.w		#9,D0	 	*If the single digit is greater than nine. 
	bgt		PBE2		*Go to Prompt Branch Error Block. 
	bra		STR2		*If base is valid prompt user for the number they want to convert. 
	
B22:    cvta2		buffer,D0	*Converts to 2's complement for checks. 
	cmpi.b		#2,D0		*If number is less than 2. 
	blt		PBE2		*Prompt error message. 
	cmpi.b		#16,D0		*If number is greater than 16. 
	bgt		PBE2		*Prompt if number is greater. 
	bra 		STR2		*If base is valid prompt user for the number they want to convert. 
	
PBE2:   lineout		bain		*Base invalid error.
	lineout 	bErr		*Prompts Base to be converted error. 	        	    		
	bra		PB2		*Asks user to enter second base again. 
			
STR2:	move.b		D0,D3		*Stores valid base.

	clr.l		D6		*Initiliases D6 to act as a counter.  
	move.w		D2,D7		*Makes copy of decimal value which is stored in hex.  
	adda.l	        #1,A0		*Increases A0 by one. 	

DIV:	andi.l		#$0000FFFF,D7	*Clears first four digits of the register.  
        divu		D3,D7		*Number/base to be converted to. 
	swap		D7		*Swaps the contents of D7.
	cmpi.b		#10,D7		*Checks to see if D7 is a number or a letter. 
	bhs		LETR		*If the contents are greater than 10 go to Letter.
	addi.b		#$30,D7	  	*If it is a number add 30 hex to ASCII.
	bra		NUMB		*It's a number skip letter addition. 
LETR:   addi.b		#55,D7		*If it is a letter add 55 for some reason. 
NUMB:	move.b		D7,(A2)+	*Increments A1.
	swap		D7		*Swaps contents of D7. 
	addi.b		#1,D6		*Incremements counter by one.
        cmpi.b		#0,D7		*Quotient == 0, stop. 
	bhi		DIV		*Go back to Div if it's not 0. 
	sub.w		#1,D6		*Subtract 1 from result of division for use in DBRA. 
REV:	move.b		-(A2),(A1)+	*Switch digits. 
 	dbra		D6,REV		*Loops until finished. 
	clr.b		(A1)            *Null terminate anwer.  
	lineout		answer		*Prompts the answer.

FIN:	lineout		ask		*Asks user if they would like to use the program again. 
	linein		buffer		*Get's users response.
	cmpi.w		#1,D0		*Makes sure users response is just one digit. 
	bne		ASER		*Go to this error if they enter more or less than one digit.
	ori.b		#$20,buffer	*Lowercases users input.
	cmpi.b		#'y',buffer	*Checks if users answer was 'Y'.
	beq		CLR 		*Go to clear and restart. 
	lineout		finish		*Print program will now end. 
	bra		END		*Close program.              
	
ASER:	lineout		askE		*Inform user they can only enter 'Y' or 'N'.
	bra		FIN
CLR:	clr.l		D0		*Clears all registers for new run through that aren't cleared within program. 
	clr.l		D1
	clr.l		D6
	clr.l		D7	
	bra		PB1		*Branch back to the start of the program. 
        	
END	break			*Terminate Program
*
*----------------------------------------------------------------------
*       Storage declarations
title:	dc.b	'Program #3, Reece Kidd, cssc0215',0
base:	dc.b	'Enter the base of the number to convert (2..16):',0
num:	dc.b	'Enter the number to convert:',0
CTo:	dc.b	'Enter the base to convert to:',0
bain:	dc.b	'Base is invalid.',0
bErr: 	dc.b	'Please enter an integer (2..16) for base conversion.',0
emEr:	dc.b	'Please enter an integer not a blank space.',0
hexE:	dc.b	'You cannot convert a number that contains digits other than (0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F).',0
bOut:	dc.b	'This number is not valid for your chosen base.',0
sErr:	dc.b	'Number entered is too large to convert.',0
ask: 	dc.b	'Do you want to convert another number? (Y/N)',0 
askE:	dc.b	'Please only enter Y or N',0    
finish:	dc.b	'The program will now end.',0
answer:	dc.b	'The number is '
result: ds.b	32
buffer:	ds.b	82
buffer2:ds.b	82

	end				

