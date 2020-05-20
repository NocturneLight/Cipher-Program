# Name: Antonio Luis Rios
# Email: alr150630@utdallas.edu

# Vigenere Cipher:
#	Encryption:
#		Step 1: Take key and convert each character to 0-25 format.
#		Step 2: Take message and convert it to 0-25 format.
#		Step 3: Use the equation "C_i = E_K * M_i = (M_i + K_i) Mod 26" to encrypt the message.
#		Step 4:	Succesfully display the encrypted message to the user.
#	Decryption:
#		Step 1: Take key and convert it to 0-25 format.
#		Step 2: Take cipher and convert it to 0-25 format.
#		Step 3: Use the equation "M_i = D_K * C_i = (C_i - K_i) Mod 26" to decrypt the message.
#		Step 4: Succesfully display the encrypted message to the user.

.data
	tabulaRasa:
		.word 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
		      'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
		      'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
	encryptionFile:
		.asciiz "encrypted.txt"
	decryptionFile:
		.asciiz "decrypted.txt"
	encryptionDialog:
		.asciiz "Do you wish to encrypt a file's text?"
	decryptionDialog:
		.asciiz "Do you wish to decrypt a file's text?"
	keyDialog:
		.asciiz "What is your key for the Vigenere Cipher?"
	fileNameDialog:
		.asciiz "Type in the name of the text file you wish to encrypt:"
	fileNameDialog2:
		.asciiz "Type in the name of the text file you wish to decrypt:"
	finishedEncryptionDialog:
		.asciiz "Encryption finished. Check the folder that MARS is in for \"encrypted.txt\"."
	finishedDecryptionDialog:
		.asciiz "Decryption finished. Check the folder that MARS is in for \"decrypted.txt\"."
	exceededLimitDialog:
		.asciiz "You've exceeded the character limit. Some characters will be missing."
	noFileMessage:
		.asciiz "Could not find the text file. Make sure it is in the same place as this program."
	impossibleErrorMessage:
		.asciiz "You shouldn't be seeing this. Some strange error has occurred."
	key:
		.space 1000
	message:
		.space 100000
	cipherText:
		.space 1000
	fileName:
		.space 1000
	encryptedKey:
		.space 1000
	newMessage:
		.space 100000
		
.text
	main:
		# Jump to encryptFile, decryptFile, or exit depending on user's decision.
		la $a0, encryptionDialog
		la $a1, 1
		li $v0, 50
		syscall
		
		# Exit if the user clicks "cancel", or jump to encryption if they click "yes"
		beq $a0, 0, encryption
		beq $a0, 2, exit
		
		la $a0, decryptionDialog
		la $a1, 1
		li $v0, 50
		syscall
		
		# If "yes" is chosen, jump to decrypt. If "no" is chosen, jump to the top of main. Exit if "cancel" is picked.
		beq $a0, 0, decryption
		beq $a0, 1, main
		beq $a0, 2, exit

	encryption:
		# Jump to the getKey function.
		jal getKey
	
		# Jump to the keyToUpper function.
		jal keyToUpper
		
		# Jump to the getFileName1 function.
		jal getFileName1
		
		# Jump to the formatName function
		jal formatName
		
		# Jump to the getMessage function.
		jal getMessage
		
		# Jump to the messageToUpper function.
		jal messageToUpper
	
		# Jump to the convertKey function.
		jal convertKey
		
		# Jump to the convertMessage function.
		jal convertMessage
		
		# Jump to the encryptText function.
		jal encryptText
		
		# Jump to the displayEncryption function.
		jal encryptionToFile
		
		# Jump to the finishedEncryption function.
		jal finishedEncryption
		
		# Jump to the exit function.
		j exit
	
	decryption:
		# Jump to the getKey function.
		jal getKey
	
		# Jump to the keyToUpper function.
		jal keyToUpper
		
		# Jump to the getFileName1 function.
		jal getFileName2
		
		# Jump to the formatName function
		jal formatName
		
		# Jump to the getMessage function.
		jal getMessage
		
		# Jump to the messageToUpper function.
		jal messageToUpper
		
		# Jump to the convertKey function.
		jal convertKey
		
		# Jump to the convertCipher function.
		jal convertMessage
		
		# Jump to the saveSpot function.
		jal saveSpot
		
		# Jump to the displayDecryption function.
		jal decryptionToFile
		
		# Jump to the finishedDecryption function.
		jal finishedDecryption
		
		# Jump to the exit function.
		j exit
	
	exit:
		# Exit the program.
		la $v0, 10
		syscall
	
	finishedEncryption:
		# Inform the user that the encryption was completed.
		la $a0, finishedEncryptionDialog
		la $a1, 1
		li $v0, 55
		syscall
		
		# Return to where we were in the encryption function.
		jr $ra
	
	finishedDecryption:
		# Inform the user that the encryption was completed.
		la $a0, finishedDecryptionDialog
		la $a1, 1
		li $v0, 55
		syscall
		
		# Return to where we were in the encryption function.
		jr $ra
	
	saveSpot:
		# Save the return address we just made.
		add $sp, $sp, -4
		sw $ra, 0($sp)
		
		# Jump to the decryptText function.
		j decryptText
	
	getMessage:
		# Open the textfile.
		la $a0, fileName
		la $a1, 0
		la $a2, 0
		li $v0, 13
		syscall
		
		# If the file does not exist, jump to the noFileFound function.
		bltz $v0, noFileFound
		
		# Read the textfile and store it in the buffer.
		move $a0, $v0
		la $a1, message
		la $a2, 100000
		li $v0, 14
		syscall
		
		# If the file does not exist, jump to the impossibleError function.
		bltz $v0, impossibleError
		
		# Close the file now that we're done with it.
		li $v0, 16
		syscall
		
		# Return to the encryption function.
		jr $ra
	
	formatName:
		# Load up the first character of the user's file's name.
		lb $t0, fileName($t1)
		
		# If we reach the newline character, jump to the switchChar function.
		beq $t0, '\n', switchChar
		
		# Increment the address by 1 so we can go to the next character.
		add $t1, $t1, 1
		
		# Jump to the top of the formatName function.
		j formatName
	
	switchChar:
		# Switch the ascii code for newline to the ascii code for NULL.
		move $t0, $0
		
		# Save the change to the character.
		sb $t0, fileName($t1)
		
		# Jump to the returnToMain function.
		j returnToMain
	
	getFileName1:
		# Ask the user for a file name and save what they typed in the fileName variable.
		la $a0, fileNameDialog
		la $a1, fileName
		la $a2, 100
		li $v0, 54
		syscall
		
		# If register a1 has any of these numbers, jump to the appropriate function.
		beq $a1, -2, exit
		beq $a1, -3, getFileName1
		beq $a1, -4, exceededLimit
		
		# Jump back to the encryption function.
		jr $ra
	
	getFileName2:
		# Ask the user for a file name and save what they typed in the fileName variable.
		la $a0, fileNameDialog2
		la $a1, fileName
		la $a2, 100
		li $v0, 54
		syscall
		
		# If register a1 has any of these numbers, jump to the appropriate function.
		beq $a1, -2, exit
		beq $a1, -3, getFileName1
		beq $a1, -4, exceededLimit
		
		# Jump back to the encryption function.
		jr $ra
	
	getKey:
		# Ask the user for a key and save what they type in in the key variable.
		la $a0, keyDialog
		la $a1, key
		la $a2, 1000
		li $v0, 54
		syscall
		
		# If register a1 has any of these numbers, jump to the appropriate function.
		beq $a1, -2, exit
		beq $a1, -3, getKey
		beq $a1, -4, exceededLimit
		
		# Jump to where we were in either the encryption or decryption functions.
		jr $ra
	
	decryptionToFile:
		# Open the file we want to store the decryption in.
		la $a0, decryptionFile
		la $a1, 1
		la $a2, 0
		li $v0, 13
		syscall
		
		# Write the encryption to that file.
		move $a0, $v0
		la $a1, newMessage
		la $a2, ($s0) # Register s0 contains the character count of the message.
		li $v0, 15
		syscall
		
		# Close the file now that we've finished.
		li $v0, 16
		syscall
		
		# Jump back to the encryption function.
		jr $ra
	
	encryptionToFile:
		# Open the file we want to store the encryption in.
		la $a0, encryptionFile
		la $a1, 1
		la $a2, 0
		li $v0, 13
		syscall
		
		# Write the encryption to that file.
		move $a0, $v0
		la $a1, newMessage
		la $a2, ($s0) # Register s0 contains the character count of the message.
		li $v0, 15
		syscall
		
		# Close the file now that we've finished.
		li $v0, 16
		syscall
		
		# Jump back to the encryption function.
		jr $ra
	
	decryptText:
		# Load an individual character from the decryptedCipher and encryptedKey variable.
		lb $t0, newMessage($t1)
		lb $t2, encryptedKey($t3)
		
		# If we reach the end the end of the cipher text, jump to the finalConversion2 function.
		beq $t0, 26, finalConversion2
		beq $t0, 27, carriageConversion2
		beq $t0, 28, newlineConversion2
		beq $t0, 29, tabConversion2
		
		# If we reach the end of the key, jump to the clearKey2 function.
		beq $t2, 26, clearKey2
		
		# If the ASCII code is higher than 26, jump to the noConversionC or no ConversionK1.
		bgt $t0, 26, noConversionC
		bltz $t0, noConversionC
		bgt $t2, 26, noConversionK1
		bltz $t2, noConversionK1
		
		
		#	VIGENERE DECRYPTION ALGORITHM: 	M_i = D_K * C_i = (C_i - K_i) Mod 26	#
		
		# Get the difference between the cipher text and key's character and store it in register t0.
		sub $t0, $t0, $t2
		
		# Divide that difference by 26 and store it in register t0.
		div $t0, $t0, 26
		
		# Get the modulus answer from HI and store it in register t0.
		mfhi $t0
		
		# If our answer is negative, jump to the getEndLetter function.
		bltzal $t0, getEndLetter
		
		
		
		# Multiply that number by 4 to get the address of the letter in the tabulaRasa array and put it in register t0.
		mul $t5, $t0, 4
		
		# Load up the corresponding letter in the tabulaRasa array.
		lb $t4, tabulaRasa($t5)
		
		# Move that letter to the decryptedCipher variable.
		move $t0, $t4
		
		# Save the changes we made to the decryptedCipher variable.
		sb $t0, newMessage($t1)
		
		# Increment the addresses of the cipher text and the key by 1.
		add $t1, $t1, 1
		add $t3, $t3, 1
		
		# Jump to the decryptText function.
		j decryptText
	
	getEndLetter:
		# Subtract 26 from the negative number we got to get the actual number.
		add $t0, $t0, 26
		
		# Jump back to where we were in the decryptText function.
		jr $ra
				
	encryptText:
		# Load in a character from the newMessage and encryptedKey variables respectively.
		lb $t0, newMessage($t1)
		lb $t2, encryptedKey($t3)
		
		# Depending on which non-letter we encounter, apply the appropriate conversion.
		beq $t0, 26, finalConversion1
		beq $t0, 27, carriageConversion1
		beq $t0, 28, newlineConversion1
		beq $t0, 29, tabConversion1
		
		# If we reach the end of the encryptedKey variable, jump to the clearKey variable.
		beq $t2, 26, clearKey1
		
		# If the newMessage or encryptedKey variable's ASCII code is higher than 25 or lower than 0, 
		# it's not a converted letter, so jump to the noConversionM or noConversionK function.
		bgt $t0, 25, noConversionM
		bltz $t0, noConversionM
		bgt $t2, 25, noConversionK
		bltz $t2, noConversionK
		
		
		#	VIGENERE ENCRYPTION ALGORITHM:	C_i = E_K * M_i = (M_i + K_i) Mod 26	#
		
		# Get the sum of the message and key's letters while they are in 0-25 format and store it in register t0.
		add $t0, $t0, $t2
		
		# Set register t0 to the quotient of 26 and the previously found sum.
		div $t0, $t0, 26
		
		# Move the contents of HI to register t0. This achieves the same effect as modulus. 
		mfhi $t0
		
		
		
		# Multiply the previous number by 4 to get the address of the corresponding letter in the tabulaRasa array.
		mul $t0, $t0, 4
		
		# Move that address into register t5.
		move $t5, $t0
		
		# Load up the character associated with that address.
		lb $t4, tabulaRasa($t5)
		
		# Move that letter into the newMessage variable.
		move $t0, $t4
		
		# Save the changes we made to the newMessage variable.
		sb $t0, newMessage($t1)
		
		# Increment the addresses of newMessage and encryptedKey by 1.
		add $t1, $t1, 1
		add $t3, $t3, 1
		
		# Jump back up to the top of the encryptText variable.
		j encryptText
	
	finalConversion1:
		# Change 26 back to the ASCII code for NULL in the newMessage variable.
		move $t0, $0
		
		# Save the changes made to the newMessage variable.
		sb $t0, newMessage($t1)
		
		# Jump to the returnToMain function.
		j returnToMain
	
	finalConversion2:
		# Change the character in decryptedCipher back to NULL.
		move $t0, $0
		
		# Save the changes we made to the decryptedCipher variable.
		sb $t0, newMessage($t1)
		
		# Get the old return address for the decryption function back.
		lw $ra, 0($sp)
		add $sp, $sp, 4
		
		# Jump to the returnToMain function.
		j returnToMain
	
	tabConversion1:
		# Set register t0 to the horizontal tab character.
		add $t0, $0, '\t'
		
		# Save the changes made to the newMessage variable.
		sb $t0, newMessage($t1)
		
		# Increment the address of newMessage by 1 to go to the next character.
		add $t1, $t1, 1
		
		# Jump to the encryptText function.
		j encryptText
		
	tabConversion2:
		# Set register t0 to the horizontal tab character.
		add $t0, $0, '\t'
		
		# Save the changes made to the decryptedCipher variable.
		sb $t0, newMessage($t1)
		
		# Increment the address of decryptedCipher by 1 to go to the next character.
		add $t1, $t1, 1
		
		# Jump to the decryptText function.
		j decryptText
	
	carriageConversion1:
		# Set register t0 to the carriage return character.
		add $t0, $0, '\r'
		
		# Save the changes made to the newMessage variable.
		sb $t0, newMessage($t1)
		
		# Increment the address of newMessage by 1 to go to the next character.
		add $t1, $t1, 1
		
		# Jump to the encryptText function.
		j encryptText
		
	carriageConversion2:
		# Set register t0 to the carriage return character.
		add $t0, $0, '\r'
		
		# Save the changes made to the decryptedCipher variable.
		sb $t0, newMessage($t1)
		
		# Increment the address of decryptedCipher by 1 to go to the next character.
		add $t1, $t1, 1
		
		# Jump to the decryptText function.
		j decryptText
		
	newlineConversion1:
		# Set register t0 to the newline character.
		add $t0, $0, '\n'
		
		# Save the changes made to the newMessage variable.
		sb $t0, newMessage($t1)
		
		# Increment the address of newMessage by 1 to go to the next character.
		add $t1, $t1, 1
		
		# Jump to the encryptText function.
		j encryptText
	
	newlineConversion2:
		# Set register t0 to the newline return character.
		add $t0, $0, '\n'
		
		# Save the changes made to the decryptedCipher variable.
		sb $t0, newMessage($t1)
		
		# Increment the address of decryptedCipher by 1 to go to the next character.
		add $t1, $t1, 1
		
		# Jump to the decryptText function.
		j decryptText
	
	clearKey1:
		# Clear the address of the encryptedKey to start over from the beginning.
		move $t3, $0
		
		# Jump back up to the top of the encryptText variable.
		j encryptText
	
	clearKey2:
		# Clear register t3 to start the key back over from the beginning.
		move $t3, $0
		
		# Jump to the decryptText function.
		j decryptText
	
	noConversionM:
		# Increment the address of the newMessage variable by 1.
		add $t1, $t1, 1
		
		# Jump back up to the top of the encryptText variable.
		j encryptText
		
	noConversionK:
		# Increment the address of the encryptedKey variable by 1.
		add $t3, $t3, 1
		
		# Jump back up to the top of the encryptText variable.
		j encryptText
	
	noConversionC:
		# Add 1 to register t1 to go on to the next character.
		add $t1, $t1, 1
		
		# Jump to the decryptText function.
		j decryptText
	
	noConversionK1:
		# Increment the address of t3 by 1 to go to the next character.
		add $t3, $t3, 1
		
		# Jump to the decryptText function.
		j decryptText
																												
	messageToUpper:
		# Load the first character into register t1.
		lb $t0, message($t1)
		
		# If we reach the end, jump to the returnToMain function.
		beqz $t0, returnToMain
		
		# Increment our character counter by 1 if we're not at the end.
		add $s0, $s0, 1
		
		# If the character is less than "a (97)" or greater than "z (122)", it's not a character with a capital form. Jump to the noConversion4 function.
		blt $t0, 'a', noConversion4
		bgt $t0, 'z', noConversion4
		
		# Subtract 32 from the t0 register to make the lowercase letter capital.
		sub $t0, $t0, 32
		
		# Save the change to the character to the message variable.
		sb $t0, message($t1)
		
		# Increment the address by 1 to go to the next character in the message variable.
		add $t1, $t1, 1
		
		# Jump to the messageToUpper function.
		j messageToUpper
	
	keyToUpper:
		# Load the first character into register t1.
		lb $t0, key($t1)
		
		# If we reach the end, jump to the returnToMain function.
		beqz, $t0, returnToMain
		
		# If the character is less than "a (97)" or greater than "z (122)", it's not a character with a capital form. Jump to the noConversion3 function.
		blt $t0, 'a', noConversion3
		bgt $t0, 'z', noConversion3
		
		# Subtract 32 from the t0 register to make the lowercase letter capital.
		sub $t0, $t0, 32
		
		# Save the change to the character to the key variable.
		sb $t0, key($t1)
		
		# Increment the address by 1 to go to the next character in the key variable.
		add $t1, $t1, 1
		
		# Jump to the keyToUpper function.
		j keyToUpper
	
	convertMessage:
		# Load in the characters for the message and tabulaRasa variables respectively.
		lb $t0, message($t1)
		lb $t2, tabulaRasa($t3)
		
		# If we reach the end of the message string, jump to the endConversion2 function.
		beqz $t0, endConversion2
		
		# Depending on the character, apply the appropriate conversion.
		beq $t0, '\r', changeCarriage2
		beq $t0, '\n', changeNewline2
		beq $t0, '\t', changeTab2
		
		# If the character in the message variable is not a capital letter, jump to the noConversion2 function.
		blt $t0, 'A', noConversion2
		bgt $t0, 'Z', noConversion2
		
		# If the character for the message and tabulaRasa variables are equal, jump to the storeToVariable2 function.
		beq $t0, $t2, storeToVariable2
		
		# Increment register t3 by 4 to go to the next character in the tabulaRasa array.
		add $t3, $t3, 4
		
		# Jump to the convertMessage function.
		j convertMessage
	
	convertKey:
		# Load in the characters for the key and tabulaRasa variables respectively.
		lb $t0, key($t1)
		lb $t2, tabulaRasa($t3)
		
		# If we reach the end of the key string, jump to the endConversion1 function.
		beqz $t0, endConversion1
		
		# Depending on the character, apply the appropriate conversion.
		beq $t0, '\r', changeCarriage1
		beq $t0, '\n', changeNewline1
		beq $t0, '\t', changeTab1
		
		# If the character in the key variable is not a capital letter, jump to the noConversion1 function.
		blt $t0, 'A', noConversion1
		bgt $t0, 'Z', noConversion1
		
		# If the character for the key and tabulaRasa variables are equal, jump to the storeToVariable1 function.
		beq $t0, $t2, storeToVariable1
		
		# Increment register t3 by 4 to go to the next character in the tabulaRasa array.
		add $t3, $t3, 4
		
		# Jump to the convertKey function.
		j convertKey
	
	changeTab1:
		# Load up a character of the encryptedKey variable.
		lb $t4, encryptedKey($t5)
		
		# Set register t4 to 29; our number that will represent tab.
		add $t4, $0, 29
		
		# Save the changes made to the encryptedKey variable.
		sb $t4, encryptedKey($t5)
		
		# Increment the addresses of the key and the encryptedKey variables.
		add $t1, $t1, 1
		add $t5, $t5, 1
		
		# Jump back to the top of the convertKey variable.
		j convertKey
	
	changeTab2:
		# Load up a character of the newMessage variable.
		lb $t4, newMessage($t5)
		
		# Set register t4 to 29; our number that will represent tab.
		add $t4, $0, 29
		
		# Save the changes made to the newMessage variable.
		sb $t4, newMessage($t5)
		
		# Increment the addresses of the message and the newMessage variables.
		add $t1, $t1, 1
		add $t5, $t5, 1
		
		# Jump back to the top of the convertMessage variable.
		j convertMessage
	
	changeCarriage1:
		# Load up a character of the encryptedKey variable.
		lb $t4, encryptedKey($t5)
		
		# Set register t4 to 27; our number that will represent carriage return.
		add $t4, $0, 27
		
		# Save the changes made to the encryptedKey variable.
		sb $t4, encryptedKey($t5)
		
		# Increment the addresses of the key and the encryptedKey variables.
		add $t1, $t1, 1
		add $t5, $t5, 1
		
		# Jump back to the top of the convertKey variable.
		j convertKey
	
	changeCarriage2:
		# Load up a character of the newMessage variable.
		lb $t4, newMessage($t5)
		
		# Set register t4 to 27; our number that will represent carriage return.
		add $t4, $0, 27
		
		# Save the changes made to the newMessage variable.
		sb $t4, newMessage($t5)
		
		# Increment the addresses of the message and the newMessage variables.
		add $t1, $t1, 1
		add $t5, $t5, 1
		
		# Jump back to the top of the convertMessage variable.
		j convertMessage
							
	changeNewline1:
		# Load up a character of the encryptedKey variable.
		lb $t4, encryptedKey($t5)
		
		# Set register t4 to 28; our number that will represent newline.
		add $t4, $0, 28
		
		# Save the changes made to the encryptedKey variable.
		sb $t4, encryptedKey($t5)
		
		# Increment the addresses of the key and the encryptedKey variables.
		add $t1, $t1, 1
		add $t5, $t5, 1
		
		# Jump back to the top of the convertKey variable.
		j convertKey
		
	changeNewline2:
		# Load up a character of the newMessage variable.
		lb $t4, newMessage($t5)
		
		# Set register t4 to 28; our number that will represent newline.
		add $t4, $0, 28
		
		# Save the changes made to the newMessage variable.
		sb $t4, newMessage($t5)
		
		# Increment the addresses of the message and the newMessage variables.
		add $t1, $t1, 1
		add $t5, $t5, 1
		
		# Jump back to the top of the convertMessage variable.
		j convertMessage
										
	storeToVariable1:
		# Load up the character in the encryptedKey variable.
		lb $t4, encryptedKey($t5)
		
		# Set that character to be the address of key's letter in the tabulaRasa array.
		div $t4, $t3, 4
		
		# Save the changes made to the encryptedKey variable.
		sb $t4, encryptedKey($t5)
		
		# Clear register t3 of it's contents.
		move $t3, $0
		
		# Increment the addresses of key and encryptedKey by 1.
		add $t1, $t1, 1
		add $t5, $t5, 1
		
		# Jump to the top of the convertKey function.
		j convertKey
		
	storeToVariable2:
		# Load up the character in the newMessage variable.
		lb $t4, newMessage($t5)
		
		# Set that character to be the address of message's letter in the tabulaRasa array.
		div $t4, $t3, 4
		
		# Save the changes made to the newMessage variable.
		sb $t4, newMessage($t5)
		
		# Clear register t3 of it's contents.
		move $t3, $0
		
		# Increment the addresses of message and newMessage by 1.
		add $t1, $t1, 1
		add $t5, $t5, 1
		
		# Jump to the top of the convertMessage function.
		j convertMessage
				
	noConversion1:
		# Load up the character in the encryptedKey variable.
		lb $t4, encryptedKey($t5)
		
		# Move key's character to the encryptedKey variable as is.
		move $t4, $t0
		
		# Save the changes made to the encryptedKey variable.
		sb $t4, encryptedKey($t5)
		
		# Increment the addresses of key and encryptedKey by 1.
		add $t1, $t1, 1
		add $t5, $t5, 1
		
		# Jump to the top of the convertKey function.
		j convertKey
		
	noConversion2:
		# Load up the character in the newMessage variable.
		lb $t4, newMessage($t5)
		
		# Move message's character to the newMessage variable as is.
		move $t4, $t0
		
		# Save the changes made to the newMessage variable.
		sb $t4, newMessage($t5)
		
		# Increment the addresses of message and newMessage by 1.
		add $t1, $t1, 1
		add $t5, $t5, 1
		
		# Jump to the top of the convertMessage function.
		j convertMessage
	
	noConversion3:
		# Increment the t1 register by 1 so we go to the next letter.
		add $t1, $t1, 1
		
		# Jump back up to the keyToUpper function.
		j keyToUpper
	
	noConversion4:
		# Increment the t1 register by 1 so we go to the next letter.
		add $t1, $t1, 1
		
		# Jump back up to the keyToUpper function.
		j messageToUpper
										
	endConversion1:
		# Load into register t9 our number that will represent the end of a string.
		la $t9, 26
	
		# Load up the character in the encryptedKey variable.
		lb $t4, encryptedKey($t5)
		
		# Move 26 into the encryptedKey variable.
		move $t4, $t9
		
		# Save the changes made to the encryptedKey variable.
		sb $t4, encryptedKey($t5)
		
		# Jump to the returnToMain function.
		j returnToMain
	
	endConversion2:
		# Load into register t9 our number that will represent the end of a string.
		la $t9, 26
	
		# Load up the character in the newMessage variable.
		lb $t4, newMessage($t5)
		
		# Move 26 into the newMessage variable.
		move $t4, $t9
		
		# Save the changes made to the newMessage variable.
		sb $t4, newMessage($t5)
		
		# Jump to the returnToMain function.
		j returnToMain
			
	returnToMain:
		# Clear all the odd registers to prevent errors when loading characters after this.
		move $t1, $0
		move $t3, $0
		move $t5, $0
		move $t7, $0
		move $t9, $0
		
		# Return to whatever function we may be coming from.
		jr $ra
		
	exceededLimit:
		# Display message to the user telling them the file exceeded the character limit.
		la $a0, exceededLimitDialog
		la $a1, 2
		li $v0, 55
		syscall
		
		# Jump back to where we were in the main function.
		jr $ra
		
	noFileFound:
		# Display message to the user telling them the file could not be found.
		la $a0, noFileMessage
		la $a1, 2
		li $v0, 55
		syscall
		
		# Jump to the exit function.
		j exit
		
	impossibleError:
		# Display message to the user telling them an error that shouldn't have happened somehow happened.
		la $a0, impossibleErrorMessage
		la $a1, 2
		li $v0, 55
		syscall
		
		# Jump to the exit function.
		j exit
