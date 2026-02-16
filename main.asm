#Raseel Jafar 1220724
#Basmalah Abuhakma 1220184
#Section 3

#C:\\Users\\Admin\\Desktop\\project1\\input.txt
#C:\\Users\\Asus\\OneDrive\\Desktop\\ArcPro\\ArcInputFile.txt

.data
.align 2  # Ensure 4-byte alignment

# ------------------- Menu & User Interface -------------------
menuTitle:        .asciiz "************ bin packing problem ************\n\n"
option1:          .asciiz "1) please enter the input file name\n"
option2:          .asciiz "2) choose the heuristic: FF\n"
option3:          .asciiz "3) choose the heuristic: BF\n"
option4:          .asciiz "4) print the output file\n"
enter:            .asciiz "Enter a number corresponding to one of the options or 'q'/'Q' to quit\n"
wrong_option:     .asciiz "Enter a number from 1 to 5 only.\n"
newline:          .asciiz "\n"
quitmsg:          .asciiz "Exiting program. Goodbye!\n"
enterQ:           .asciiz "Enter 'q' or 'Q'!\n"
msg1:             .asciiz "please enter the input file name or location\n"

# ------------------- Error Messages -------------------
openErrorMsg:     .asciiz "\nError in opening file\n"
readErrorMsg:     .asciiz "\nError in reading file\n"
invalid_size_msg: .asciiz "\nInvalid item\n"
no_items_msg:     .asciiz "\nError: No items loaded. Please load items first (option 1).\n"
no_algorithm_run: .asciiz "\nError: No algorithm has been run yet. Please run FF or BF first (option 2 or 3).\n"
output_write_error:.asciiz "\nError writing output file\n"

# ------------------- File & Buffer -------------------
.align 2
file_loc:         .space 100      # Input file path
.align 2
buffer:           .space 100      # Input buffer
.align 2
temp_buffer:      .space 8        # Temporary small buffer
# ------------------- Item Data -------------------
.align 2
items:            .space 400      # Parsed float items (max 100 items)
.align 2
item_sizes:       .space 400      # Copy of item sizes for output
.align 2
item_to_bin:      .space 400      # Which bin each item is assigned to
.align 2
item_count:       .word 0         # Number of parsed items
item_index:       .asciiz "Item index: "
floatLabel:       .asciiz "  Item: "
item_label:       .asciiz "Item: "
assigned_label:   .asciiz "Assigned to bin: "
.align 2
zero_float:       .float 0.0
.align 2
epsilon:          .float 0.00001
number_of_items: .asciiz "number of items: "


# ------------------- Bin Data -------------------
.align 2
bins:             .space 400      # Remaining capacity for each bin
.align 2
bin_remaining:    .space 400      # Alternate/remnant bin space
.align 2
bin_count:        .word 0         # Number of bins used
.align 2
bin_capacity:     .float 1.0      # Default bin size
bin_label:        .asciiz "  Bin #"
bin_prefix:       .asciiz "  Bin "
item_indent:      .asciiz "    - "
colon:            .asciiz ": "
bin_count_label:  .asciiz "Number of bins used: "
bin_count_str:    .asciiz "Number of bins: "
total_bins:       .asciiz "\ntotal number of bins: "
tab:              .asciiz "\t"
decimal_point:    .asciiz "."

# ------------------- Algorithm Execution -------------------
.align 2
algorithm_run:    .word 0         # 0 = none, 1 = FF, 2 = BF
ff_header:        .asciiz "\n------ First Fit Solution ------\n"
bf_header:        .asciiz "\n------ Best Fit Solution ------\n"

# ------------------- Output -------------------
output_filename:      .asciiz "output.txt"
output_write_success: .asciiz "\nOutput successfully written to output.txt\n"



.macro print_string (%string)
	li $v0, 4
	la $a0, %string
	syscall
.end_macro


.text
main:
    loop_menu:
        jal showMenu
        
        # Read input character first to check for q/Q
        li $v0, 12       # Read character
        syscall
        
        # Check if user entered q or Q to quit
        beq $v0, 'q', endProgram
        beq $v0, 'Q', endProgram
        
        # If it's a digit, convert to integer
        blt $v0, '0', not_a_digit
        bgt $v0, '9', not_a_digit
        
        # Convert ASCII digit to integer
        subi $v0, $v0, '0'
        j process_menu_option
        
    not_a_digit:
        print_string(wrong_option)
        j loop_menu
        
    process_menu_option:
        beq $v0, 1, case1
        beq $v0, 2, case2
        beq $v0, 3, case3
        beq $v0, 4, case4
        j default
        
        case1:
            print_string (newline)
            print_string (msg1)
            
            #read file name
            li $v0, 8
            la $a0, file_loc
            li $a1, 100
            syscall
            
            # Explicitly null-terminate the string
            la $t0, file_loc
            add_null_loop:
                lb $t1, 0($t0)
                beqz $t1, null_done
                li $t2, 10  # Newline
                bne $t1, $t2, next_char
                sb $zero, 0($t0)  # Replace newline with null
                j null_done
            next_char:
                addi $t0, $t0, 1
                j add_null_loop
            null_done:
    
            jal fileRead
            print_string (newline)
            j loop_menu


        case2:
            # Reset bin count
            la $t0, bin_count
            sw $zero, 0($t0)
            
            jal first_fit
            
            # Set algorithm_run flag to 1 (FF)
            la $t0, algorithm_run
            li $t1, 1
            sw $t1, 0($t0)
            
            print_string(newline)
            j loop_menu
            
        case3:
            # Reset bin count
            la $t0, bin_count
            sw $zero, 0($t0)
            
            jal best_fit
            
            # Set algorithm_run flag to 2 (BF)
            la $t0, algorithm_run
            li $t1, 2
            sw $t1, 0($t0)
            
            print_string(newline)
            j loop_menu
            
        case4:
            jal print_to_file
            print_string(newline)
            j loop_menu
            
        default: 
            print_string(wrong_option)
            j loop_menu 


#-------------------------------------------------------------------------------------	
showMenu :
	print_string (newline)
	print_string (menuTitle)
	print_string (option1)
	print_string (option2)
	print_string (option3)
	print_string (option4)
	print_string (enter)
	jr $ra
#-------------------------------------------------------------------------------------
openError:
	la $a0, openErrorMsg
	li $v0, 4
	syscall
	j endProgram	
#-------------------------------------------------------------------------------------
readError:
	la $a0, readErrorMsg
	li $v0, 4
	syscall
	j endProgram	
#-------------------------------------------------------------------------------------
endProgram:
	print_string (newline)
	li $v0, 4
    	la $a0, quitmsg
    	syscall
	li $v0, 10
	syscall	
#-------------------------------------------------------------------------------------
fileRead:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    # Clean newline from file_loc
    la $t0, file_loc
clean_filename_loop:
    lb $t1, 0($t0)
    beqz $t1, done_clean
    li $t2, 10
    beq $t1, $t2, replace_with_null
    li $t2, 13
    beq $t1, $t2, replace_with_null
    addi $t0, $t0, 1
    j clean_filename_loop

replace_with_null:
    sb $zero, 0($t0)
    #null-terminate any following bytes to be safe
    addi $t0, $t0, 1
    sb $zero, 0($t0)
done_clean:

    # Open file for reading
    li   $v0, 13
    la   $a0, file_loc
    li   $a1, 0
    syscall
    move $s0, $v0
    bltz $s0, openError

    # Read from file
    li   $v0, 14
    move $a0, $s0
    la   $a1, buffer
    li   $a2, 1024
    syscall
    bltz $v0, readError

    # Print file content
    print_string(buffer)

    # Close file
    li $v0, 16
    move $a0, $s0
    syscall

    jal parse_floats
    jal print_items
    
    # Print the item count
    print_string(number_of_items)
    la $t0, item_count
    lw $a0, 0($t0)     # Load item_count into $a0
    li $v0, 1
    syscall            # Print the item count
    
    # Restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
#-------------------------------------------------------------------------------------
parse_floats:
    la $t0, buffer       # pointer to buffer
    la $t1, items        # pointer to items array
    li $t2, 0            # item counter

parse_loop:
    lb $t3, 0($t0)       # load current character
    beqz $t3, done_parse # end of string
    
    # Skip whitespace
    li $t4, ' '
    beq $t3, $t4, skip_char
    li $t4, '\n'
    beq $t3, $t4, skip_char
    li $t4, '\t'
    beq $t3, $t4, skip_char
    
    #Check if this character is a digit or decimal point
    li $t4, '0'
    blt $t3, $t4, not_numeric
    li $t4, '9'
    ble $t3, $t4, is_numeric
    li $t4, '.'
    bne $t3, $t4, not_numeric
    j not_numeric
    
is_numeric:
    li $t5, 0            # integer part accumulator
    mtc1 $t5, $f0        # clear floating point register
    cvt.s.w $f0, $f0     # convert to float format
    j parse_int_part
    
not_numeric:
    print_string(invalid_size_msg)
    print_string(item_label)
    
    # Print the invalid token 
    li $t7, 0  # Counter to prevent infinite loop
not_numeric_print_loop:
    lb $t8, 0($t0)
    beqz $t8, end_not_numeric
    li $t9, ' '
    beq $t8, $t9, end_not_numeric
    li $t9, '\n'
    beq $t8, $t9, end_not_numeric
    li $t9, '\t'
    beq $t8, $t9, end_not_numeric
    
    # Print the character
    li $v0, 11
    move $a0, $t8
    syscall
    
    addi $t0, $t0, 1
    addi $t7, $t7, 1
    blt $t7, 10, not_numeric_print_loop  # Limit to 10 chars
    
end_not_numeric:
    print_string(newline)
    j skip_to_whitespace

    # Initialize for number parsing
    li $t5, 0            # integer part accumulator
    mtc1 $t5, $f0        # clear floating point register
    cvt.s.w $f0, $f0     # convert to float format
    
    # Parse integer part
parse_int_part:
    lb $t3, 0($t0)       # current character
    
    # Check if it's a digit
    li $t4, '0'
    blt $t3, $t4, check_decimal
    li $t4, '9'
    bgt $t3, $t4, check_decimal
    
    # Convert to digit and accumulate
    subi $t3, $t3, 48    # ASCII '0' is 48
    mul $t5, $t5, 10     # multiply by 10
    add $t5, $t5, $t3    # add new digit
    
    addi $t0, $t0, 1     # next character
    j parse_int_part
    
check_decimal:
    # Convert integer part to float
    mtc1 $t5, $f0
    cvt.s.w $f0, $f0
    
    # Check if we have a decimal point
    li $t4, '.'
    bne $t3, $t4, validate_float
    
    # Process decimal part
    addi $t0, $t0, 1     # skip decimal point
    li $t5, 10           # divisor for place value
    mtc1 $t5, $f2
    cvt.s.w $f2, $f2     # $f2 = 10.0
    
parse_decimal:
    lb $t3, 0($t0)  # Load next character (after '.')
    
    # Check if it's a digit
    li $t4, '0'
    blt $t3, $t4, validate_float
    li $t4, '9'
    bgt $t3, $t4, validate_float
    
    # Convert to digit
    subi $t3, $t3, 48    # ASCII '0' is 48
    mtc1 $t3, $f4
    cvt.s.w $f4, $f4     # $f4 = digit as float
    
    # Calculate place value
    div.s $f4, $f4, $f2  # $f4 = digit/10^place
    add.s $f0, $f0, $f4  # add to result
    
    # Next place
    li $t5, 10
    mtc1 $t5, $f3
    cvt.s.w $f3, $f3
    mul.s $f2, $f2, $f3  # $f2 *= 10 for next decimal place
    
    addi $t0, $t0, 1     # next character
    j parse_decimal
    
validate_float:
    # Check if value is between 0 and 1
    l.s $f1, bin_capacity  # Load 1.0
    mtc1 $zero, $f2      # Load 0.0
    
    # Check if value <= 1.0
    c.le.s $f0, $f1
    bc1f invalid_item    # If not <= 1.0, skip this item
    
    # Check if value >= 0.0
    c.lt.s $f0, $f2
    bc1t invalid_item    # If < 0.0, skip this item
    
    # Item is valid, store it
    s.s $f0, 0($t1)
    addi $t1, $t1, 4     # next item slot
    addi $t2, $t2, 1     # increment count
    j skip_to_whitespace
    
invalid_item:
    print_string(invalid_size_msg)
    print_string(item_label)
    mov.s $f12, $f0      # Item value that failed validation
    li $v0, 2            # Syscall number for printing float
    syscall
    print_string(newline)

    
skip_to_whitespace:
    lb $t3, 0($t0)
    beqz $t3, done_parse
    
    li $t4, ' '
    beq $t3, $t4, skip_char
    li $t4, '\n'
    beq $t3, $t4, skip_char
    li $t4, '\t'
    beq $t3, $t4, skip_char
    
    addi $t0, $t0, 1
    j skip_to_whitespace
    
skip_char:
    addi $t0, $t0, 1
    j parse_loop
    
done_parse:
    la $t3, item_count
    sw $t2, 0($t3)       # store total number of items
    jr $ra
############################################################################
print_items:
    la $t0, items             # pointer to items array
    lw $t1, item_count        # total number of items
    li $t2, 0                 # item index for debugging

print_loop:
    beqz $t1, done_print      # if we reach zero, we're done printing

    print_string(newline)
        
    # Debugging: Print item index
    print_string(item_index)
    move $a0, $t2  # item index
    li $v0, 1      # syscall for printing integer
    syscall
    
    # Print item
    print_string(floatLabel)
    l.s $f12, 0($t0)  # load the float
    li $v0, 2         # syscall for printing float
    syscall

    # Print a newline after each item
    print_string(newline)

    addi $t0, $t0, 4      # move to next item (each float is 4 bytes)
    subi $t1, $t1, 1      # decrement item count
    addi $t2, $t2, 1      # increment index for debugging
    j print_loop

done_print:
    jr $ra
    
    
#---------------------------------------------------------------------------------------------------------------    

no_items_error:
    print_string(no_items_msg)
    j loop_menu

#---------------------------------------------------------------------------------------------------------------
# ############################### First Fit algorithm implementation #############################################
first_fit:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Check if any items are loaded
    la $t0, item_count
    lw $t1, 0($t0)      # t1 = number of items
    beqz $t1, no_items_error  # If item_count is 0, jump to error handler
    
    # Print header
    print_string(ff_header)
    
    # Initialize bin count to 0
    la $t0, bin_count
    sw $zero, 0($t0)
    
    # Get item count
    la $t0, item_count
    lw $t1, 0($t0)      # t1 = number of items
    
    # Initialize all bins with capacity = 0 (no bins yet)
    la $t2, bins
    li $t3, 0
clear_bins:
    mtc1 $zero, $f0
    s.s $f0, 0($t2)
    addi $t2, $t2, 4
    addi $t3, $t3, 1
    blt $t3, 100, clear_bins  # Clear space for 100 potential bins
    
    # Get default bin capacity
    l.s $f8, bin_capacity  # f8 = 1.0 (default bin capacity)
    
    # Create arrays to track which items go into which bins
    
    # Process each item using First Fit
    la $t2, items       # pointer to items array
    li $t3, 0           # item index counter
    
process_items:
    beq $t3, $t1, ff_done  # if processed all items, we're done
    
    # Load current item size
    l.s $f0, 0($t2)     # f0 = current item size
    
    # try to fit in existing bins
    la $t4, bins        # pointer to bins array
    la $t5, bin_count
    lw $t6, 0($t5)      # t6 = current bin count
    li $t7, 0           # bin index counter
    
try_bins:
    beq $t7, $t6, create_new_bin  # if checked all bins -> need a new one
    
    # Load bin's remaining capacity
    l.s $f2, 0($t4)     # f2 = bin's remaining capacity
    
    # Check if item fits
    c.lt.s $f0, $f2     #  is the item size < remaining capacity
    bc1f next_bin       # if not, check next bin
    
    # Item fits in this bin, update capacity
    sub.s $f2, $f2, $f0  # reduce capacity
    s.s $f2, 0($t4)      # store updated capacity
    
    # Track which bin this item was assigned to
    la $t9, item_to_bin
    sll $s1, $t3, 2        # item_index * 4
    add $t9, $t9, $s1
    sw $t7, 0($t9)         # item_to_bin[item_index] = bin_index
    
    # Store item size for later reference
    la $s2, item_sizes
    add $s2, $s2, $s1
    s.s $f0, 0($s2)

    
    # Print assignment -debug 
    print_string(newline)
    print_string(item_index)
    move $a0, $t3       # item index
    li $v0, 1
    syscall
    print_string(colon)
    l.s $f12, 0($t2)    # item size
    li $v0, 2
    syscall
    print_string(bin_label)
    move $a0, $t7       # bin index
    li $v0, 1
    syscall
    
    j next_item      
    
next_bin:
    addi $t4, $t4, 4    # move to next bin
    addi $t7, $t7, 1    # increment bin counter
    j try_bins
    
create_new_bin:
    # Create a new bin with full capacity
    la $t4, bins
    sll $t8, $t6, 2     # t8 = bin_count * 4
    add $t4, $t4, $t8   # t4 points to new bin
    
    # Set new bin's capacity to full capacity - item size
    sub.s $f2, $f8, $f0  # f2 = full capacity - item size
    s.s $f2, 0($t4)      # store remaining capacity
    
    # Track which bin this item was assigned to
    la $t9, item_to_bin
    sll $s1, $t3, 2        # item_index * 4
    add $t9, $t9, $s1
    sw $t7, 0($t9)         # item_to_bin[item_index] = bin_index
    
    # Store item size for later reference
    la $s2, item_sizes
    add $s2, $s2, $s1
    s.s $f0, 0($s2)
    
    # Increment bin count
    addi $t6, $t6, 1
    sw $t6, 0($t5)      # update bin_count
    
    print_string(newline)
    print_string(item_index)
    move $a0, $t3       # item index
    li $v0, 1
    syscall
    print_string(colon)
    l.s $f12, 0($t2)    # item size
    li $v0, 2
    syscall
    print_string(bin_label)
    move $a0, $t7       # bin index (equal to old bin count)
    li $v0, 1
    syscall
    
next_item:
    addi $t2, $t2, 4    # move to next item
    addi $t3, $t3, 1    # increment item counter
    j process_items
    
ff_done:
    print_string(newline)
    print_string(bin_count)
    print_string(total_bins)
    la $t0, bin_count
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    print_string(newline)
    
    # Restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

    
#---------------------------------------------------------------------------------------------------------------
# ############################### Best Fit algorithm implementation ############################################# 
best_fit:

    # Save return address (like in first_fit)
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Check if any items are loaded
    la $t0, item_count
    lw $t1, 0($t0)      # t1 = number of items
    beqz $t1, no_items_error  # If item_count is 0, jump to error handler
    
    # Print the Best Fit header
    print_string(bf_header)
    
    
    # Load the number of items
    lw $t0, item_count          # $t0 = item_count
    li $t1, 0                   # i = 0
    li $t2, 0                   # bin_count = 0
    sw $t2, bin_count

    # Initialize bin_remaining to 0.0 for safety
    li $t9, 0
    la $t8, bin_remaining
    li $t7, 100                 # assume max 100 bins
    
    # Track which bin this item was assigned to
    la $s3, item_to_bin
    sll $s4, $t1, 2        # item_index * 4
    add $s3, $s3, $s4
    sw $t5, 0($s3)         # item_to_bin[item_index] = bin_index
    
    # Store item size for later reference
    la $s5, item_sizes
    add $s5, $s5, $s4
    s.s $f2, 0($s5)
    
init_bins_loop:
    bge $t9, $t7, continue_bf
    sll $t6, $t9, 2
    add $t6, $t6, $t8
    l.s $f20, zero_float
    s.s $f20, 0($t6)
    addi $t9, $t9, 1
    j init_bins_loop

continue_bf:

loop_bf_items:
    bge $t1, $t0, end_best_fit  # while i < item_count

    # Load current item weight
    la $t3, items
    sll $t4, $t1, 2             # offset = i * 4
    add $t3, $t3, $t4
    l.s $f2, 0($t3)             # f2 = current item

    # Initialize best bin search
    li $t5, -1                  # best_bin_index = -1
    l.s $f4, bin_capacity       # f4 = smallest remaining space (init to bin capacity)
    li $t6, 0                   # j = 0
    lw $t7, bin_count           # t7 = total bins

loop_bf_bins:
    bge $t6, $t7, assign_bf     # while j < bin_count

    la $t8, bin_remaining       # base address of bin_remaining
    sll $t9, $t6, 2             # offset = j * 4
    add $s0, $t8, $t9           # s0 = &bin_remaining[j]
    l.s $f6, 0($s0)             # f6 = bin_remaining[j]

    # Add epsilon to handle floating-point precision issues
    l.s $f22, epsilon           # epsilon
    add.s $f6, $f6, $f22        # f6 += epsilon

    # Check if bin can fit the item
    c.le.s $f2, $f6
    bc1f next_bf_bin

    # Compute remaining space after placing the item
    sub.s $f8, $f6, $f2         # f8 = bin_remaining[j] - item

    # If remaining_space < current smallest, update best fit
    c.lt.s $f8, $f4
    bc1f next_bf_bin

    mov.s $f4, $f8              # update smallest remaining space
    move $t5, $t6               # update best_bin_index

next_bf_bin:
    addi $t6, $t6, 1 #j++
    j loop_bf_bins

assign_bf:
    bgez $t5, use_existing_bin

    # No fitting bin found -> open new bin
    lw $t5, bin_count           # t5 = bin_index

    la $t3, bin_remaining
    sll $t4, $t5, 2
    add $s0, $t3, $t4
    l.s $f10, bin_capacity
    sub.s $f10, $f10, $f2       # bin_remaining[bin_index] = capacity - item
    s.s $f10, 0($s0)

    addi $t7, $t5, 1            # bin_count++
    sw $t7, bin_count
    j print_bf_bin

use_existing_bin:
    la $t3, bin_remaining
    sll $t4, $t5, 2
    add $s0, $t3, $t4
    l.s $f10, 0($s0)
    sub.s $f10, $f10, $f2
    s.s $f10, 0($s0)

print_bf_bin:
    print_string(newline)
    print_string(item_index)  # Print "Item index: "
    move $a0, $t1           # item index
    li $v0, 1
    syscall
    print_string(colon)     # Print ": "
    
    # Print item size
    mov.s $f12, $f2         # item size already in f2
    li $v0, 2
    syscall
    
    # Print bin assignment
    print_string(bin_label) # Print "  Bin #"
    move $a0, $t5           # bin index 
    li $v0, 1
    syscall
    
    # Store the bin assignment in item_to_bin array
    la $t3, item_to_bin
    sll $t4, $t1, 2         # t4 = item_index * 4
    add $t3, $t3, $t4       # t3 = &item_to_bin[item_index]
    sw $t5, 0($t3)          # item_to_bin[item_index] = bin_index
    
    # Store the item size in item_sizes array
    la $t3, item_sizes
    add $t3, $t3, $t4       # t3 = &item_sizes[item_index]
    s.s $f2, 0($t3)         # item_sizes[item_index] = item_size
    
    addi $t1, $t1, 1        # i++
    j loop_bf_items
    
end_best_fit:
    print_string(newline)
    
    li $v0, 4
    la $a0, total_bins
    syscall

    lw $a0, bin_count
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    
    # Restore return address
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

#--------------------------------------------------------------------------------------------------------------- 
print_to_file:
    # Check if an algorithm has been run
    la $t0, algorithm_run
    lw $t1, 0($t0)
    beqz $t1, no_algorithm_ran

    # Open output file for writing
    li $v0, 13             # syscall to open file
    la $a0, output_filename
    li $a1, 1              # flag = write mode
    li $a2, 0              # mode = ignored
    syscall
    move $s0, $v0          # file descriptor
    bltz $s0, write_error  # check for error

    # Write header depending on algorithm
    li $v0, 15             # syscall to write to file
    move $a0, $s0          # file descriptor
    beq $t1, 1, ff_header_write
    beq $t1, 2, bf_header_write

ff_header_write:
    la $a1, ff_header
    li $a2, 34             # Length of header
    syscall
    j write_bin_count

bf_header_write:
    la $a1, bf_header
    li $a2, 34
    syscall

write_bin_count:
    # Write newline after header
    li $v0, 15
    move $a0, $s0
    la $a1, newline
    li $a2, 1
    syscall
    
    # Write "Number of bins: "
    li $v0, 15
    move $a0, $s0
    la $a1, bin_count_str
    li $a2, 16            # Length of "Number of bins: "
    syscall
    
    # Get bin count and convert to string (simplified for 1-digit count)
    la $t0, bin_count
    lw $t1, 0($t0)        # t1 = bin count
    addi $t1, $t1, '0'    # Convert to ASCII (works for 0-9 only)
    
    # Store the digit in a small buffer
    la $t2, temp_buffer
    sb $t1, 0($t2)        # Store the digit
    li $t1, 0
    sb $t1, 1($t2)        # Null terminate
    
    # Write bin count
    li $v0, 15
    move $a0, $s0
    la $a1, temp_buffer
    li $a2, 1             # Just writing one digit
    syscall
    
    # Write newline
    li $v0, 15
    move $a0, $s0
    la $a1, newline
    li $a2, 1
    syscall
    
    # Process each bin
    la $t0, bin_count
    lw $t1, 0($t0)        # t1 = bin count
    li $t2, 0             # t2 = current bin index
    
bin_loop:
    beq $t2, $t1, close_file  # If done with all bins, close file
    
    # Write "  Bin X:"
    li $v0, 15
    move $a0, $s0
    la $a1, bin_prefix
    li $a2, 6             # Length of "  Bin "
    syscall
    
    # Convert bin number to ASCII (simplified for 0-9)
    addi $t3, $t2, '0'    # Convert to ASCII
    la $t4, temp_buffer
    sb $t3, 0($t4)        # Store in buffer
    
    # Write bin number
    li $v0, 15
    move $a0, $s0
    la $a1, temp_buffer
    li $a2, 1
    syscall
    
    # Write ":"
    li $v0, 15
    move $a0, $s0
    la $a1, colon
    li $a2, 1
    syscall
    
    # Write newline
    li $v0, 15
    move $a0, $s0
    la $a1, newline
    li $a2, 1
    syscall
    
    # Now find items in this bin
    la $t3, item_to_bin    # Base of item_to_bin array
    la $t4, item_sizes     # Base of item_sizes array
    lw $t5, item_count     # Total number of items
    li $t6, 0              # Current item index
    
find_items:
    beq $t6, $t5, next_bin2  # If checked all items, go to next bin
    
    # Check if this item is in the current bin
    sll $t7, $t6, 2         # t7 = item_index * 4
    add $t8, $t3, $t7       # t8 = &item_to_bin[item_index]
    lw $t9, 0($t8)          # t9 = item_to_bin[item_index]
    
    bne $t9, $t2, next_item2 # If not in current bin, check next item
    
    # Item is in this bin, write "    - " (indent)
    li $v0, 15
    move $a0, $s0
    la $a1, item_indent
    li $a2, 6              # Length of "    - "
    syscall
    
    # Get item size
    add $t8, $t4, $t7       # t8 = &item_sizes[item_index]
    l.s $f0, 0($t8)         # f0 = item size
    
    # For simplicity, we'll just print sizes as "0.X" for single digit values
    # Convert the first decimal place (tenths)
    li $t8, 10
    mtc1 $t8, $f1
    cvt.s.w $f1, $f1        # f1 = 10.0
    
    mul.s $f0, $f0, $f1     # f0 *= 10
    cvt.w.s $f0, $f0        # Convert to integer (truncate)
    mfc1 $t8, $f0           # t8 = int(item_size * 10)
    
    # Extract whole digit and decimal
    div $t8, $t8, 10
    mflo $t9                # t9 = whole digit
    mfhi $s1                # s1 = first decimal place
    
    # Write whole digit
    addi $t9, $t9, '0'      # Convert to ASCII
    la $s2, temp_buffer
    sb $t9, 0($s2)          # Store in buffer
    
    # Write to file
    li $v0, 15
    move $a0, $s0
    la $a1, temp_buffer
    li $a2, 1
    syscall
    
    # Write decimal point
    li $v0, 15
    move $a0, $s0
    la $a1, decimal_point
    li $a2, 1
    syscall
    
    # Write decimal digit
    addi $s1, $s1, '0'      # Convert to ASCII
    sb $s1, 0($s2)          # Store in buffer
    
    li $v0, 15
    move $a0, $s0
    la $a1, temp_buffer
    li $a2, 1
    syscall
    
    # Write newline
    li $v0, 15
    move $a0, $s0
    la $a1, newline
    li $a2, 1
    syscall
    
next_item2:
    addi $t6, $t6, 1        # Increment item index
    j find_items
    
next_bin2:
    addi $t2, $t2, 1        # Increment bin index
    j bin_loop

close_file:
    # Close file
    li $v0, 16
    move $a0, $s0
    syscall

    print_string(output_write_success)
    jr $ra

write_error:
    print_string(output_write_error)
    jr $ra

no_algorithm_ran:
    print_string(no_algorithm_run)
    jr $ra
