.data
    .align 2  # Align to 4-byte boundary for 32-bit architecture
    input_start:  .word 0x2a0    # Start address of input list
    input_end:    .word 0xda220  # End address of input list (892,788 bytes)
    output_start: .word 0xda230  # Start address for output (after 16-byte separator)
    output_end:   .word 0x113230  # End address for output (1KB space)
    top10_start:  .word 0x113260  # Start address for top 10 (after another 16-byte separator)

.text
.globl main

main:
    lw s0, input_start
    lw s1, input_end
    lw s2, output_start
    lw s3, output_end
    li s4, 16            # Offset between words in output (12 bytes word + 4 bytes counter)

    mv t0, s0            # Current input pointer
    mv t1, s2            # Current output pointer

process_words:
    bgeu t0, s1, find_top10
    
    # Check if current word is empty (starts with zero)
    lbu t2, 0(t0)
    beqz t2, next_input_word

    # Check if word already exists in output
    mv a0, t0
    mv a1, s2
    mv a2, t1
    jal ra, find_duplicate

    bnez a0, update_count
    j copy_new_word

update_count:
    lw t2, 12(a0)
    addi t2, t2, 1
    sw t2, 12(a0)
    j next_input_word

copy_new_word:
    mv t2, t0
    mv t3, t1
    li t4, 11

copy_loop:
    lbu t5, 0(t2)
    sb t5, 0(t3)
    addi t2, t2, 1
    addi t3, t3, 1
    addi t4, t4, -1
    beqz t5, end_copy
    beqz t4, force_end
    j copy_loop

force_end:
    sb zero, 0(t3)

end_copy:
    sb zero, 11(t1)
    li t5, 1
    sw t5, 12(t1)
    addi t1, t1, 16
    bgeu t1, s3, done

next_input_word:
    addi t0, t0, 1
    lbu t2, 0(t0)
    bnez t2, next_input_word
    addi t0, t0, 1
    j process_words

done:
    li a7, 10
    ecall

# Function to find duplicate word
# a0: address of current word
# a1: start of output
# a2: current end of output
# Returns: a0 = address of duplicate word if found, 0 if not
find_duplicate:
    mv t5, a1

find_loop:
    bgeu t5, a2, not_found
    mv t6, t5
    mv a3, a0

compare_loop:
    lbu t2, 0(t6)
    lbu t3, 0(a3)
    bne t2, t3, next_word
    beqz t2, found
    addi t6, t6, 1
    addi a3, a3, 1
    j compare_loop

next_word:
    addi t5, t5, 16
    j find_loop

found:
    mv a0, t5
    ret

not_found:
    li a0, 0
    ret

find_top10:
    lw a0, output_start
    mv a1, t1
    lw a2, top10_start
    jal ra, get_top10

    li a7, 10
    ecall

# Function to get top 10 most frequent words
# a0: start of word list
# a1: end of word list
# a2: address to store top 10
get_top10:
    mv t0, a0
    mv s5, a2
    li t2, 10

top10_loop:
    beqz t2, top10_done
    li t3, 0
    mv t4, a0
    mv t5, zero

find_max:
    bgeu t4, a1, max_found
    # Ensure aligned load
    andi t6, t4, -4
    lw t6, 12(t6)
    bleu t6, t3, next_max_word
    mv t3, t6
    mv t5, t4

next_max_word:
    addi t4, t4, 16
    j find_max

max_found:
    beqz t5, top10_done

    mv t4, t5
    li t6, 16

copy_top_word:
    lbu a3, 0(t4)
    sb a3, 0(s5)
    addi t4, t4, 1
    addi s5, s5, 1
    addi t6, t6, -1
    bnez t6, copy_top_word

    sw zero, 12(t5)
    addi t2, t2, -1
    j top10_loop

top10_done:
    ret