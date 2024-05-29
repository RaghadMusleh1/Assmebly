	.text
	.globl main  



##############Initialize the array by the char '0'###################
li $t0,300 # size of the calendar
li $t1,0
li $t2,'0'
la $a0, Calendar
LoopToIntilizeByZero:
    bge $t1,$t0,readTheFile # the array is initialized by zero, start reading the file   
    addi $t1,$t1,1      
    sb $t2,0($a0)
    li $v0,4
    addi $a0,$a0,1
    j LoopToIntilizeByZero
##############The array is initialized by zero###################




readTheFile:
#############Open The File##############################

    li $v0, 13  # to open the file
    la $a0, InputFile  # load address
    li $a1, 0    # read mode
    syscall # start the operation
    move $s0, $v0 # move the file discriptor to s0;
    
###########The File Is Opened#############################




###########Start Storing The data From The File To The array (Calendar)#####################
    la $a3, storingDayTemporary #Store the array address, which will read a  day temporary in a3;
ReadDaysLoop:     # start reading from the file 
    li $v0, 14   #to start reading ;
    move $a0, $s0  # store the file discriptor in a0;
    la $a1, readByte # Load the address of the string which will read one byte from the file;
    li $a2, 1 # the number of bytes will be read;
    syscall # execute (read one byte from file)
    beqz $v0, closeTheFile  # (If the program had read all the days, jump to ColseTheFile);
    lb $t0, readByte  # else, load the byte that was stored at (readByte) to the register t0
    beq $t0, '\n', addNewLine  # If the byte that was read is 10 ("/n"), then go to store the line in the array Calendar  
    
    sb $t0,0($a3) # else, store the char in the array (storingDayTemporary) which contains each day data from the file
    addi $a3,$a3,1 # Go to next byte in the array (storingDayTemporary) to store data in;
    j ReadDaysLoop# go back to the loop to read another day data; 
    
    addNewLine: # add ("\n") to the array  (storingDayTemporary), which will represend the end of the array.
        la $a2,newLine
        lb $t0,0($a2)
        sb $t0,0($a3)
        addi $a3,$a3,1
        sb $t0,0($a3)
        addi $a3,$a3,1
        sb $t0,0($a3)
        j aLineWasRead # go ans store the line in the Calendar
        
#######################The data is stored in the calendar###################################




aLineWasRead:# A function that is used to store each day's data in the array (calednar)

############################StoringEachDayInTheCalender#######################################
  
  #The first set of instruction will take the day number from the array (storingDayTemporary)and store it in register t6#
    	li $t7,0 # initialize by zero
    	li $t6,0 # initialize by zero
    	la $a0, storingDayTemporary # store the address of the array (storingDayTemporary) to start the operation
    	lb $t6,0($a0) # load the first number from the string 
 	addi $a0,$a0,1 # go to the next position (which might be a number if the day  >9, or':' if the day  <=9)
    	lb $t7,0($a0) # store the next value in register t7 (which might be number or ':') 
    	beq $t7,':', singleDigitCalculation #if the day is >9, then the register t6 itself can represent the day number
    	subi $t6,$t6,48# else the registers t6&t7 both represent the day number , sor first sub from t6 48 to get the hexa value
    	mul $t6,$t6,0xa #to get the tens value , multiply t6 by 10
    	subi $t7,$t7,48 # to get the hexa value, sub from t7 48
    	add $t6,$t6,$t7 # add the ones value to the tens value, and here the register t6 represnt the day number in hexa							
    	add $a0,$a0,3    # to skip the characters ':' and ' ' ans start pointing at the first appointment
    	j CalculateTheNextRow 
    singleDigitCalculation:
    	subi $t6,$t6,48  
    	add $a0,$a0,2 # to reach the next number : OH M L
    CalculateTheNextRow: 
    	subi $t6,$t6,1 # zero indexed
    	mul $t6,$t6,0x9 # to calculate at which row we are,mul t6 by 10 since we have 10 slots at max.
 # The day number is stored in the register t6#
 
 
 
 
 
 #Read the starting time from the appointment#
	#la $a1,storingDayTemporary
    move $t9,$t8
    saveTimes:  # this loop will iterate 3 times to store the L,OH,M times in the calendar; 
    	lb $t7,0($a0)
    	beq $t7,'\n',endSaveAppointments # if you saved the three appointments, then go and read new line
    	
    	lb $t4,0($a0) # load the first number to register t4
    	addi $a0,$a0,1 # go to the next position
    	lb $t5,0($a0) # store the second number (or it can be'-') in the register t5
    	beq $t5,'-', singleDigit1 # if the stating time is represented in one digit , then go and convert it to the hexa representatiom
    	subi $t4,$t4,48 # else, sub from t4 48 to get the hexa representation
    	mul $t4,$t4,0xa # mul it by 10 to get the tens value 						
    	subi $t5,$t5,48 # sub from t5 (ones) 48 
    	add $t4,$t4,$t5 # add the ones to the tens
    	add $a0,$a0,2  # skip the char '-' and go the next number   
    	j CalculateTheEndingTime
    singleDigit1: # get the hexa value for the starting time
    	subi $t4,$t4,48  # get the hexa value
    	add $a0,$a0,1 # to go to the next ending time for the appointement
 #The strating time is storted in t4#
 
 
 
 
 #Read the ending time from the appointment#
    CalculateTheEndingTime:    
    	lb $t5,0($a0) # same as above, read the first number
    	add $a0,$a0,1 # next pos
    	lb $t3,0($a0) # read the second number (if exist)
    	beq $t3,' ', singleDigit2 # if the second number is not exist, go and get the hexa value for the first number
    	subi $t5,$t5,48  # Get the hea value for the second digit                              		
    	mul $t5,$t5,0xa  # Mul it by ten to get the ones value
    	subi $t3,$t3,48  # Get the hea value for the first digit  
    	add $t5,$t5,$t3 #add the ones to the tens
    	add $a0,$a0,2   # Skip the space
    	j StartStoringAtTheArrayCalender
    
    singleDigit2: 
    	subi $t5,$t5,48   
    	addi $a0,$a0,1 
  #The ending time is storted in t5#
  
  
 
  # Start storing the appointment times in the array Calendar # 
    StartStoringAtTheArrayCalender:
    	li $t0,0 
    	lb $t0,0($a0) # load the type of the appointment at the register t0 (L,O,M)
    	bgt $t4,5,StartingTimeLessThan5 
    	addi $t4,$t4,0xc # add 12 to convert the time to 24hrs system
    StartingTimeLessThan5:
    	bgt $t5,5,EndingTimeLessThan5
    	addi $t5,$t5,0xc # add 12 to convert the time to 24hrs system
    EndingTimeLessThan5:
    	subi $t4,$t4,8 # To get zero indexed (so the 8 will 0 and 9 will be 1 ...)
    	subi $t5,$t5,8 # To get zero indexed   

    storingTheIndicesLoop:  
    	bge $t4,$t5,endStoringAppointmentTimes # if we finished storing the appointment times in the array then go to endloop
    	bne $t8,$t9,continue
    	addi $t8,$t8,1
    	continue:
    	la $a1,Calendar # else, load the calendar address
    	add $a1,$a1,$t6 # to calculate the row position
    	add $a1,$a1,$t4 # to calculate the column pos
    	addi $t4,$t4,1# go to the next hour
    	sb $t0,0($a1) #store the appointment type (O,M,L) in the array;
    	j storingTheIndicesLoop
   # The appointment times is stored int the array Calendar#   
   
   
   
    endStoringAppointmentTimes:
  	bne $t0,'O',Skip2pos 
  	addi $a0,$a0,4 # skip "H, " (3pos)
  	j AppointmentSaved
  	Skip2pos:
  	addi $a0,$a0,3 # skip", "(2pos)
    AppointmentSaved:
 	j saveTimes # goo back to the loop

    endSaveAppointments:  # the storing procces has ended.  
    	la $a3, storingDayTemporary #to strat storing the data at the start of the array;  
    	j ReadDaysLoop # Go and read new line

    	
############################A day data is stored in the calendar######################################    
    
    
    
closeTheFile: # to close the file 
    li $v0, 16
    move $a0, $s0
    syscall 

j main

#Third Function        
addAnAppointment:
    li $v0, 4
    la $a0, scanApointment
    syscall
    li $v0, 5
    syscall
    move $t0,$v0
    la $a1, storeDay # store the day
    sw $v0, 0($a1)
    
    li $v0, 5
    syscall
    move $t1,$v0
    la $a1, startingTime # store the Starting time
    sw $v0, 0($a1)
    
    li $v0, 5
    syscall
    move $t2,$v0
    la $a1, endingTime # store the ending time
    sw $v0, 0($a1)
    li $v0, 12
    syscall
    move $t6,$v0
    la $a1, appointmentType # store the appointment type
    sb $v0, 0($a1)
    # check if the interval for the appointment in free or not
    
    
    #lw $t0, storeDay # start calculating the index for the day was given by the user
    subi $t0,$t0,1
    mul $t0,$t0,0x9 
    la $a1, Calendar
    add $a1,$a1,$t0 #  the first index for the day was given by the user
    la $a0, storeDay
    sw $a1, 0($a0)
    
      
    #lw $t0, startingTime  # start calculating the index for the staring time was given by the user
    bgt $t1, 5,gt5
    addi $t1,$t1,0xc
    gt5:
    sub $t1,$t1,8
    add $a1,$a1, $t1 # the stating appointment address is stored in $a1
    la $a0, startingTime
    sw $a1, 0($a0)
    
    #lw $a2, endingTime
    bgt $t2, 5,gtFIVE
    addi $t2,$t2,0xc
    gtFIVE:
    subi $t2,$t2,8 #the stating appointment address is stored in $a2
    la $a0, Calendar
    add $a0,$a0, $t0
    add $a0, $a0, $t2
    la $a3,endingTime
    sw $a0, 0($a3)
    
    
    #la $a1,startingTime
    #la $a2,endingTime
    subi $a0,$a0,1
    
    
    move $a3,$a1
    move $a2,$a0
    startCheckingTheAppointment:
    
    bgt $a1,$a0,endCheckingFreeTime # iterate over the slots and check if they are free or not
        lb $t4, 0($a1)
        bne $t4, '0', theAppointmentIsNotAvailable
        addi $a1,$a1,1
        j startCheckingTheAppointment
        
    endCheckingFreeTime:
        li $v0, 4
        la $a0, Available
        syscall 
        
        lb $t1, appointmentType
        li $v0, 11

        startSavingTheAppointment:
        
            bgt $a3,$a2,endSavingAppointment # iterate over the slots and check if they are free or not
            sb $t6, 0($a3)
            addi $a3,$a3,1
            j startSavingTheAppointment
            endSavingAppointment:
                j main
                
    theAppointmentIsNotAvailable:
    li $v0, 4
    la $a0, notAvailable
    syscall 
    j main

  
  
  
  



#*************************************************option 2************************************************
# Function to calculate statistics when user chooses option 2 from the menu
CalculateStatistics:
    li $t0, 0          # Initialize counters for lectures, office hours, meetings, and days
    li $t1, 0
    li $t2, 0
    li $t3, 0
    li $t4, 0          # Counter for number of days
    la $t5, Calendar   # Load the base address of the Calendar array

    countLoop:
        lb $t6, 0($t5)  # Load byte from the Calendar array
        beqz $t6, endCount  # If end of array (null byte), exit loop

        
        # Check the type of appointment: 'L' (Lectures), 'OH' (Office Hours), 'M' (Meetings)
         li $t7, 'L'     # Check for 'L' (Lectures)
         beq $t6, $t7, incrementLectures

        li $t7, 'O'     # Check for 'O' (Office Hours)
        beq $t6, $t7, incrementOH

        li $t7, 'M'     # Check for 'M' (Meetings)
        beq $t6, $t7, incrementMeetings

        # If it's not one of the appointment types, move to the next byte
        addi $t5, $t5, 1
        j countLoop

    incrementLectures:
        addi $t0, $t0, 1  # Increment lectures counter
        addi $t5, $t5, 1  # Move to the next byte
        j countLoop

    incrementOH:
        addi $t1, $t1, 1  # Increment office hours counter
        addi $t5, $t5, 1  # Move to the next byte
        j countLoop

    incrementMeetings:
        addi $t2, $t2, 1  # Increment meetings counter
        addi $t5, $t5, 1  # Move to the next byte
        j countLoop

    endCount:
    
 # Calculate the ratio between lectures and office hours
        mtc1 $t0,$f0 
        mtc1 $t1,$f1
        div.s $f2,$f0,$f1
        
    # Print the calculated statistics
    # Print number of lectures
    li $v0, 4      # syscall for print string
    la $a0, LecturesCountMessage
    syscall

    li $v0, 1       # System call code for printing an integer
    move $a0, $t0   # Load the number of lectures to print
    syscall


    # Print number of office hours
    li $v0, 4      # syscall for print string
    la $a0, OHCountMessage
    syscall
        
    li $v0, 1       # System call code for printing an integer
    move $a0, $t1   # Load the number of office hours to print
    syscall


    # Print number of meetings
    li $v0, 4      # syscall for print string
    la $a0, MeetingsCountMessage
    syscall
        
    li $v0, 1       # System call code for printing an integer
    move $a0, $t2   # Load the number of meetings to print
    syscall

        
    # Print ratio between lectures and office hours
     li $v0, 4      # syscall for print string
    la $a0, RationBetweenLectureAndOH
    syscall
        
    li $v0,2  
    mov.s $f12, $f2 
    syscall


     move $t9,$t0
    li $t0, 0         
    li $t1, 0
    li $t2, 0
    li $t3, 0
    li $t4, 0 
    li $t5, 0    
    li $t6, 0    
    li $t7, 0            
    j CountDaysInCalendar
   
   AvarageOfLectureperDays:
      
     # Print the number of days
    li $v0, 4      # syscall for print string
    la $a0, NumberOfDays
    syscall  
    
    li $v0, 1       # System call code for printing an integer
    move $a0, $t8   # Load the number of days
    syscall  
    
        # Print average lectures per day
    li $v0, 4      # syscall for print string
    la $a0, AverageLecturesPerDayMessage
    syscall
        
    #AvarageOfLectureperDays:
        mtc1 $t9,$f3 
        mtc1 $t0,$f4
        div.s $f5,$f3,$f4
        
        li $v0,2  
        mov.s $f12, $f5 
        syscall
          
    
    li $v0, 11      # Print newline character
    li $a0, '\n'
    syscall
        

    # Return to the main menu after displaying statistics
    j main

#*****************************************************************************************************   


CountDaysInCalendar:
# Set up initial variables
li $t0, 0      # Counter for days
li $t1, 0      # Counter for checking appointments within a day
li $t2, 0      # Loop variable for traversing the Calendar array
li $t3, 0      # Flag to indicate if any appointment found for a day (0 means no, 1 means yes)

CountDaysLoop:
    bge $t2, 300, EndCountingDays   # If we reached the end of the Calendar array, exit the loop
    
    lb $t4, Calendar($t2)   # Load the value from Calendar array at index $t2

    # Check if the value is 'L', 'O', or 'M' (ASCII values)
    li $t5, 'L'
    li $t6, 'O'
    li $t7, 'M'

    beq $t4, $t5, AppointmentFound   # If 'L' is found, skip to AppointmentFound
    beq $t4, $t6, AppointmentFound   # If 'O' is found, skip to AppointmentFound
    beq $t4, $t7, AppointmentFound   # If 'M' is found, skip to AppointmentFound

    addi $t2, $t2, 1   # Move to the next index in the Calendar array
    j CountDaysLoop     # Continue looping

AppointmentFound:
    addi $t1, $t1, 1   # Increment the counter for appointments within a day
    li $t3, 1          # Set flag to indicate appointment found for a day

    addi $t2, $t2, 1   # Move to the next index in the Calendar array

    # Check if we have checked all 10 indexes for a day
    beq $t1, 5, CheckDayAppointment
    j CountDaysLoop     # Continue looping

CheckDayAppointment:
    beqz $t3, NoAppointmentForDay  # If no appointment found for a day, skip to NoAppointmentForDay
    addi $t0, $t0, 1   # Increment the counter for days
    li $t3, 0          # Reset the flag indicating appointment found for a day
    li $t1, 0          # Reset the counter for appointments within a day

    j CountDaysLoop     # Continue looping

NoAppointmentForDay:
    li $t3, 0          # Reset the flag indicating appointment found for a day
    li $t1, 0          # Reset the counter for appointments within a day

    j CountDaysLoop     # Continue looping

EndCountingDays:

    j AvarageOfLectureperDays


#*******************************************************
  
  
  
# Function to delete appointment
deleteAnAppointment:
        #messages to get user input for day number
        li $v0, 4       # Print string service code
        la $a0, Day     # load address of day message 
        syscall          
        # Read the number of day
        li $v0, 5  # Read integer service code
        syscall
         move $s0, $v0  # Store day number input in $s0

         li $v0, 4          # Print string service code
        la $a0, initialTime     # load address of initial time message 
        syscall   
        
      # Read user input for initial time
        li $v0, 5  # Read integer service code
        syscall
        move $s1, $v0  # Store initial time input in $s1

        # Read user input for initial time            
         li $v0, 4  # Print string service code
         la $a0, endTime  # Load address of end time prompt message
         syscall
         
         # Read user input for end time
         li $v0, 5  # Read integer service code
         syscall
         move $s2, $v0  # Store end time input in $s2
   
        la $a0, Calendar  # Load address of the Calendar array into $a0
        la $a1, Calendar  # Load address of the Calendar array into $a1
        subi $s0, $s0, 1   # Subtract 1 from day number
        mul $s0, $s0, 9    # Multiply by 9 to get the starting index
        add $a0, $a0, $s0 # Calculate indexfor initial time
        add $a1, $a1, $s0  # Calculate indexfor end time
        
       # Handle initial and end time values less than 6 by adding 12 to them
         bgt $s1, 5, GreaterThanFive 
         addi $s1, $s1, 0xc  # Adjust initial time if it's less than 6
         GreaterThanFive:
         bgt $s2, 5, GreaterThan5 
         addi $s2, $s2, 0xc  # Adjust end time if it's less than 6
        
        GreaterThan5:
        subi $s1, $s1, 8   # Subtract 8 from initial time (zero-based index)
        add $a0, $a0, $s1  # Load the initial time's index
        
        
        subi $s2, $s2, 8   # Subtract 8 from end time (zero-based index)
        add $a1, $a1, $s2  # Load the end time's index
        sub $a1, $a1, 1
        
        li $s4, '0'
        DeleteLoop:
        bgt $a0, $a1, EndDeleteLoop  # If initial time index > end time index, exit loop

    # Delete appointment by storing zero in the calendar array
    sb $s4, 0($a0)  # Store null character to delete appointment at the current index

    addi $a0, $a0, 1  # Move to the next index
    j DeleteLoop

EndDeleteLoop:  
    # Print "Deleted successfully" before exiting
    li $v0, 4
    la $a0, DeleteMessage
    syscall

     j main  # Go back to the main menu
 
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
    
        
#first Function.3       
printingLoop:
    li $v0, 4 
    la $a0, AtDay #printing the format
    syscall
    
    li $v0, 1
    move $a0, $t7
    syscall 

    li $v0, 4
    la $a0, YouHaveTheFollowing
    syscall
    subi $t7,$t7,1
    mul $t7,$t7,0x9 # calculate the row

    nineSlotsLoop: # loop which will iterate over nine slots at max
     
        bge $t0,$s3,goTorintMenuAgain # t0  represents the starting time ansd $s3 represents the ending time 
        la $a1,Calendar
        add $a1,$a1,$t7 #pointing at the row
        add $a1, $a1,$t0 #pointing at the first slot of time 
        lb $t1,0($a1) # load the appointment type to $t1
   
   
    
        move $t4,$t1 #to detect where to stop, move the appointment type that you are reading to t4 to copare it with the next appointments in the array
        li $t2,-1 # represents the starting time for the appointment
        li $t3,-1# represents the ending time for the appointment
    
    detectTheintervalForAnAppointment:
        bne $t4,$t1,printInterval # if the pointer points on a new appointment or at the end of the interval, go to start printing the appointment
        beq $t0,$s3,printInterval # if the pointer points on the slot of time, which is next to the highest that is available to read, go and print the interval
        
        bne $t2,0xFFFFFFFF, ThestartingTimeWasDetected
        move $t2,$t0 # save the starting time
        ThestartingTimeWasDetected:	
            move $t3,$t0 # save the ending time
            addi $t0,$t0,1 # go to the next address
            la $a1,Calendar
            add $a1,$a1,$t7 
            add $a1, $a1,$t0 # pointing on the next address
            lb $t1,0($a1) #load the appointment type of the next address to $t1
            j detectTheintervalForAnAppointment
    
    printInterval:         
           li $v0,4
	   la $a0,from # printing format
	   syscall
	   li $v0,1
	   addi $t2,$t2,8
	   ble $t2, 0xc, con
	   sub $t2,$t2,0xc
	   con:
	   move $a0,$t2
	   syscall
	   ble $t2,0x5, PM
	   li $v0,4
	   la $a0,am
	   j print1
	   PM:
	   li $v0,4
	   la $a0,pm
	   print1:
	   syscall
	   li $v0,4
	   la $a0,toTime
	   syscall
	   li $v0,1
	   addi $t3,$t3,9
	   ble $t3, 0xc,cont
	   subi $t3,$t3,0xc
	   cont:
	   move $a0,$t3
	   syscall
	   ble $t3,0x5, PM1
	   li $v0,4
	   la $a0,am
	   j print
	   PM1:
	   li $v0,4
	   la $a0,pm
	   print: # to detect which type of appointments to print
	   syscall
	   beq $t4, 'L', printLecture
	   beq $t4, 'M', printMeeting
	   beq $t4, 'O', printOfficeHour
	   beq $t4, '0', PrintFreeTime
	   
	   printLecture:
	   la $a0,lectureP # print "you have lecture"
	   syscall
	   j nineSlotsLoop
	   
	   printMeeting:
	   la $a0,meetingP# print "you have meeting"
	   syscall
	   j nineSlotsLoop
	   
	   printOfficeHour:
	   la $a0,OHP # print "you have office hours"
	   syscall
	   j nineSlotsLoop
	  
	    PrintFreeTime:
	   la $a0,freeTime# print "you have free time"
	   syscall
	   j nineSlotsLoop
    
    #endLoopNine:
    #addi $t0,$t0,1
    #j nineSlotsLoop
goTorintMenuAgain:
 jr $ra


printAday:
    li $v0, 4
    la $a0, choiseOne
    syscall
    li $v0, 5
    syscall
    move $t7,$v0# move the day that was read to t7
    li $t0, 0 # move 0 to t0 (starting time)
    li $s3, 9 # move 9 to s3 (ending time)
    move $s4,$ra
    jal printingLoop
    move $ra,$s4
    jr $ra
  
printDays:
    li $v0, 4
    la $a0, choiseTwo
    syscall
    li $v0, 5
    syscall
    move $s0, $v0
    li $v0, 5
    syscall
    move $s2, $v0
    
    startPrinting: # loop over the days you want to print 
        bgt $s0, $s2,endPrintngDays # if you finished printing the days then break the loop
        move $t7,$s0
        li $t0, 0
        li $s3, 9
        move $s4,$ra
        jal printingLoop
        move $ra,$s4
        addi $s0,$s0,1
        j startPrinting 
    endPrintngDays:
    jr $ra
 
    
printOneSlot:   
    li $v0, 4
    la $a0, choiseThree
    syscall
    
    li $v0, 5
    syscall
    move $t7 ,$v0 # move the day that was read to t7
    
    li $v0, 5
    syscall
    move $t0 ,$v0 
    bgt $t0,5,lesst0than5 # change the starting time to 24's 
    addi $t0,$t0,0xc
    lesst0than5:
    
    li $v0, 5
    syscall
    move $s3 ,$v0
    bgt $s3,5,lesss3than5  #change the ending time to 24's 
    addi $s3,$s3,0xc
    lesss3than5:
    subi $s3,$s3,8
    subi $t0,$t0,8
    move $s4,$ra
    jal printingLoop
    move $ra,$s4
    jr $ra
    
printTheCalenadar:
	li $v0, 4
	la $a0, printingChoises
	syscall
	
	li $v0,5 
	syscall
	beq $v0, 1, printDayss
	beq $v0, 2, printAday1
	beq $v0, 3, printSlot
	
	printAday1:
	 #move $s5,$ra
	 jal printAday
	 #move $ra,$s5
	 #jr $ra
	 j main
	 
	 printDayss:
	 #move $s5,$ra
	 jal printDays
	 #move $ra,$s5
	 #jr $ra
	 j main
	
	 printSlot:
	 #move $s5,$ra
	 jal printOneSlot
	 #move $ra,$s5
	 #jr $ra
	 j main



main:

    	li $v0, 4           
    	la $a0, Menu  # print the menu
    	syscall
    	li $v0, 5 # scan num , which represents the option will be executed  
    	syscall
    	move $t0, $v0 
    	PrintMenu:
    	
    	beq $t0,1,printingCalenadarr #if the user want to print the calendar, execute that option.---> jump to the function "printTheCalenadar"
    	beq $t0,2,CalculateStatistics #if the user want to view statistics, execute that option.---> jump to the function "viewStatistics"
    	beq $t0,3,addAnAppointment #if the user want to view statistics, execute that option.---> jump to the function "addAnAppointment"
    	beq $t0,4,deleteAnAppointment #if the user want to view statistics, execute that option.---> jump to the function "deleteAnAppointment"
    	beq $t0,5,endProgram # if the user inter 5 then colse the program;
        printingCalenadarr:
            j printTheCalenadar # jump to the function "printTheCalenadar"

    	#j PrintMenu
 endProgram:   

.data
	storeDay: .word 1
	startingTime: .word 1
	endingTime: .word 1  
	appointmentType: .space 1
	Available: .asciiz "\nThe appointment is available and stored.\n"
	notAvailable: .asciiz "\nThe appointment is not available.\n"
	readByte:   .space 1  # To read the data line by line from the file
	storingDayTemporary:   .space 100  # To read the data line by line from the file
	Calendar:    .space 9000
	InputFile:   .asciiz "mips.txt"
        Menu:   .asciiz "\nChoose one to execute:\n1-View the calendar.\n2-View Statistics.\n3-Add a new appointment.\n4-Delete an appointment.\n5-End the program\n"
       printingChoises: .asciiz "1- Print set of days appointments.\n2-Print a day appointments.\n3-Print a slot appointments in a day\n\n"
       choiseOne: .asciiz "Enter the day you want to print its appointments\n"
       choiseTwo: .asciiz "Enter the Starting and ending day, each on a line.\n"
       choiseThree: .asciiz "Enter the day you want to print its appointments, the starting and ending interval, each on a line.\n"
       newLine: .asciiz "\n"
       AtDay: .asciiz "\nAt Day "
       freeTime: .asciiz " free time\n" 
       YouHaveTheFollowing: .asciiz " You Have The Following:\n"
       from: .asciiz "From time: "
       lectureP: .asciiz " you have lecture\n"
       OHP: .asciiz " you have Office hours\n"
       meetingP: .asciiz " you have meeting\n"
       pm: .asciiz " PM"
       toTime: .asciiz" to time:"
       am: .asciiz " AM"
       LecturesCountMessage: .asciiz "\nNumber of lectures(in hours) is:\n"
       OHCountMessage: .asciiz "\nNumber of Office hours(in hours) is:\n"
       MeetingsCountMessage: .asciiz "\nNumber of meetings(in hours) is:\n"
       AverageLecturesPerDayMessage: .asciiz "\nNumber of average lectures per day is:\n"           
       NumberOfDays: .asciiz  "\nNumber of days is:\n"   
       RationBetweenLectureAndOH: .asciiz "\nThe ratio between total number of hours reserved for lectures and the total number of hours reserved OH is:\n"
       scanApointment: .asciiz "\nEnter the day you want to add an apointment to, the starting and ending time, and the type of the appointment, each on a line.\n"
       Day: .asciiz "Pleas enter the number of day that want to delete from:\n"
      initialTime: .asciiz "Pleas enter the ninitial time to start delete from (8-5):\n"
      endTime: .asciiz "Pleas enter the end time to stop delete on(8-5):\n"
       DeleteMessage: .asciiz "Deleted successfully\n"
