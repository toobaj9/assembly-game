##################################################################### 
#  
# CSCB58 Winter 2025 Assembly Final Project  
# University of Toronto, Scarborough  
#  
# Student: Tooba Jalal, 1010493789, jalaltoo, tooba.jalal@mail.utoronto.ca
#  
# Bitmap Display Configuration:  
# - Unit width in pixels: 4 (update this as needed)  
# - Unit height in pixels: 4 (update this as needed)  
# - Display width in pixels: 256 (update this as needed) 
# - Display height in pixels: 256 (update this as needed)  
# - Base Address for Display: 0x10008000 ($gp)  
#  
# Which milestoneshave been reached in this submission?  
# (See the assignment handout for descriptions of the milestones)  
# - Milestone 3 (all milestones met)
#  
# Which approved features have been implemented for milestone 3?  
# (See the assignment handout for the list of additional features)  
# 1. Moving Objects
# 2. Shoot enemies
# 3. Double Jump
# 4. WIN/FAIL condition met when strength of enemy is destroyed
# 5. Health bars shown
# ... (add more if necessary)  
#  
# Link to video demonstration for final submission:  
# - https://drive.google.com/file/d/1JFqbndVH7fUuCTdmoHiWgzI_Q9eHj6Qd/view?usp=sharing
#  
# Are you OK with us sharing the video with people outside course staff?  
# - yes
#  
# Any additional information that the TA needs to know:  
# -  pressing the q key displays a black screen, end screen
# - if a bullet is active, you can't shoot another bullet unless it disapears or collides
# - Single strenght bar for enemy's health is shown where half the health corresponds to each enemy. if 8-9 bullets are shot then that enemy is killed.
#####################################################################  
# ALL constant values declared
.eqv BASE_ADDRESS	0x10008000  
.eqv UPPER_COLOUR	0x2c0a50
.eqv HEIGHT		64
.eqv WIDTH		64
.eqv PLATFORM_HEIGHT	1
.eqv PLATFORM_WIDTH	16
.eqv PLATFORM_COLOUR	0xf9a90e
.eqv BLACK		0x000000
.eqv PLAYER_X_INI_POS  0
.eqv PLAYER_Y_INI_POS  56
.eqv PLAYER_HEIGHT	8
.eqv PLAYER_WIDTH	7
.eqv PLATFORM_1_X_POS	20
.eqv PLATFORM_1_Y_POS	54
.eqv PLATFORM_2_X_POS	44
.eqv PLATFORM_2_Y_POS	45
.eqv PLATFORM_3_X_POS	20
.eqv PLATFORM_3_Y_POS	35
.eqv PLATFORM_4_X_POS	44
.eqv PLATFORM_4_Y_POS	25
.eqv PLATFORM_5_X_POS	20
.eqv PLATFORM_5_Y_POS	15
.eqv WHITE		0xffffff
.eqv BULLET_COLOUR	0x2594ad
.eqv PLAYER_STRENGTH_COLOUR	0x39bd0a
.eqv ENEMY_STRENGTH_COLOUR	0xea1d1d
.eqv STRENGTH_WIDTH	16
.eqv TOTAL_PLATFORMS	5
.eqv BOX_COLOUR		0xcf9dcf
.data
	PLATFORM_1: .word	PLATFORM_1_X_POS, PLATFORM_1_Y_POS, 36		# Platform X, Y Width
	PLATFORM_2: .word	PLATFORM_2_X_POS, PLATFORM_2_Y_POS, 60	
	PLATFORM_3: .word	PLATFORM_3_X_POS, PLATFORM_3_Y_POS, 36
	PLATFORM_4: .word	PLATFORM_4_X_POS, PLATFORM_4_Y_POS, 60
	PLATFORM_5: .word	PLATFORM_5_X_POS, PLATFORM_5_Y_POS, 36
	PLAYER_COLOUR:	 .word	0xe35f01					# Player Colours
	PLAYER_COLOUR2: .word	0x464646
	ENEMY_1_COLOUR_1: .word 0x946bf8					# Enemy Colours
	ENEMY_1_COLOUR_2: .word 0xed3615
	ENEMY_1_COLOUR_3: .word 0xffc20e
	ENEMY_2_COLOUR_1: .word 0x73246a
	ENEMY_2_COLOUR_2: .word 0x0e7371
	ENEMY_1_HITS:	.word 0							# Total Enemy 1 Hits
	ENEMY_2_HITS:	.word 0							# Total Enemy 2 Hits
	PLAYER_STRENGTH_BAR_Y:	.word 2						# Player Strength Bars
	PLAYER_STRENGTH_BAR_X:	.word 11
	ENEMY_STRENGTH_BAR_Y:	.word 2
	ENEMY_STRENGTH_BAR_X:	.word 36
	PLAYER_X: .word PLAYER_X_INI_POS					# Player X starting position
	PLAYER_Y: .word PLAYER_Y_INI_POS					# Player Y ending position
	ENEMY_1_X:  .word 55
	ENEMY_1_Y:  .word 58
	ENEMY_2_X:  .word 54
	ENEMY_2_Y:  .word 18
	PLAYER_X_PREV: .word PLAYER_X_INI_POS 
	PLAYER_Y_PREV: .word PLAYER_Y_INI_POS
	FRAME_COUNTER: .word 0 						# Counter to control player damage on collision
	BULLET_X:      .word 0        						# Current X position
    	BULLET_Y:      .word 0        						# Current Y position
    	BULLET_ACTIVE:	.word 0							# Flags
	GROUND_POS:    .word 64
	ON_GROUND:	.word 1
	NUM_JUMPS:	.word 2
	JUMP_COUNTER:	.word 0
.text
	
.globl main
main:
	jal clear_screen							# Clear the screen
	jal initialize_game_state						# Reset states
    	jal coloured_bar							# display bar with both strengths
    	jal draw_player_strength
    	jal draw_enemy_strength
    	li $t5, 52								# New Enemy Strength Position after drawing
	sw $t5, ENEMY_STRENGTH_BAR_X
    	jal draw_player								# Draw Player, Platforms, Enemies
	jal draw_platforms
	jal draw_enemy_1
	jal draw_enemy_2
	j loop_game
	
loop_game:
	lw $t9, FRAME_COUNTER							# Load and initialize counter value
    	addi $t9, $t9, 11
    	sw $t9, FRAME_COUNTER							# Store the counter value
	jal erase_player							# Erase the player
	jal apply_gravity							# adjust player gravity / fall down
	jal check_enemy_1_collision						# Check enemy collisions with player
	jal check_enemy_2_collision
	jal check_bullet_enemy_1						# Check enemy bullet collisions
	jal check_bullet_enemy_2
	jal set_key_presses							# Set and enable key press functionality
	jal draw_platforms							# Draw Platforms, Players
	jal draw_player
	jal move_enemy_1							# Constantly move enemies unless died
	jal move_enemy_2
	jal move_bullet								# Move the bullet
	li $v0, 32
    	li $a0, 100								# Add a delay and continue next iteration
    	syscall
	j loop_game

clear_screen:
	li $t0, BASE_ADDRESS							# Clear the screen, remove everything
	li $t1, WIDTH
	li $t2, BLACK
	li $t3, 4
	mul $t1, $t1, $t1
	mul $t1, $t3, $t1
	add $t1, $t0, $t1
	
clear_loop:
	bgt $t0, $t1, exit_clear						# Loop clearning the screen by applying default colour black
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j clear_loop
	
exit_clear:
	jr $ra

initialize_game_state:								# Initialize Enemies
	li $t0, 55
	sw $t0, ENEMY_1_X
	li $t0, 58
	sw $t0, ENEMY_1_Y
	li $t0, 54
	sw $t0, ENEMY_2_X
	li $t0, 18
	sw $t0, ENEMY_2_Y

reset_colours:									# Initialize Colours
	li $t0, 0xe35f01
	sw $t0, PLAYER_COLOUR
	li $t0, 0x464646
	sw $t0, PLAYER_COLOUR2
	li $t0, 0x946bf8
	sw $t0, ENEMY_1_COLOUR_1
	li $t0, 0xed3615
	sw $t0, ENEMY_1_COLOUR_2
	li $t0, 0xffc20e
	sw $t0, ENEMY_1_COLOUR_3
	li $t0, 0x73246a
	sw $t0, ENEMY_2_COLOUR_1
	li $t0, 0x0e7371
	sw $t0, ENEMY_2_COLOUR_2

reset_flags:									# Reset all flags
	sw $zero, FRAME_COUNTER
	sw $zero, BULLET_X
	sw $zero, BULLET_Y
	sw $zero, BULLET_ACTIVE
	sw $zero, JUMP_COUNTER
	sw $zero, ENEMY_1_HITS
	sw $zero, ENEMY_2_HITS
	li $t0, 1
	sw $t0, ON_GROUND
	li $t0, 64
	sw $t0, GROUND_POS
	li $t0, 2
	sw $t0, NUM_JUMPS	

reset_player_positions:							# Reset Player positions
	li $t0, PLAYER_X_INI_POS
	sw $t0, PLAYER_X
	sw $t0, PLAYER_X_PREV
	li $t0, PLAYER_Y_INI_POS
	sw $t0, PLAYER_Y
	sw $t0, PLAYER_Y_PREV

reset_strengths:								# Reset Strengths
	li $t0, 2
	sw $t0, PLAYER_STRENGTH_BAR_Y
	sw $t0, ENEMY_STRENGTH_BAR_Y
	li $t0, 11
	sw $t0, PLAYER_STRENGTH_BAR_X
	li $t0, 36
	sw $t0, ENEMY_STRENGTH_BAR_X

reset_exit:
	jr $ra
	
coloured_bar:
	li $t0, BASE_ADDRESS      						# $t0 stores the base address
    	li $t1, UPPER_COLOUR							# Dark purple colour hex code
    	li $t4, 1280								# colour first 6 rows

draw_coloured_bar:
    	beqz $t4, end_bar
    	sw $t1, 0($t0)            						# Colour the pixel
    	addi $t0, $t0, 4          						# Move to the next pixel
    	addi $t4, $t4, -4         						# Decrement the counter until all pixels are coloured
    	j draw_coloured_bar           						# Repeat the loop until the background applied

end_bar:
	jr $ra									# Exit (bar created)
	
draw_enemy_strength:
	li $t0, BASE_ADDRESS
	lw $t1, ENEMY_STRENGTH_BAR_Y
	addi $t1, $t1, -1							# Outer box Y position
	lw $t2, ENEMY_STRENGTH_BAR_X
	addi $t2, $t2, -1							# Outer box X position
	li $t4, ENEMY_STRENGTH_COLOUR						# Load colour
	j draw_strength


draw_player_strength:
	li $t0, BASE_ADDRESS
	lw $t1, PLAYER_STRENGTH_BAR_Y
	addi $t1, $t1, -1							# Outer box Y position
	lw $t2, PLAYER_STRENGTH_BAR_X
	addi $t2, $t2, -1							# Outer box X position
	li $t4, PLAYER_STRENGTH_COLOUR
	j draw_strength

draw_strength:
	mul $t3, $t1, WIDTH							# y * 64
	add $t3, $t3, $t2							# y * width + x
	mul $t3, $t3, 4								# (y * width + x) * 4
	add $t3, $t3, $t0							# BASE_ADDRESS + (y * width + x) * 4
	li $t8, 0								# counter
	li $t6, BOX_COLOUR
	move $t7, $t6								# Save this colour in some other register temporarily

colour_strength:
	sw $t7, 0($t3)
	sw $t6, 4($t3)
	sw $t6, 8($t3)
	sw $t6, 12($t3)
	sw $t6, 16($t3)
	sw $t6, 20($t3)
	sw $t6, 24($t3)
	sw $t6, 28($t3)
	sw $t6, 32($t3)
	sw $t6, 36($t3)
	sw $t6, 40($t3)
	sw $t6, 44($t3)
	sw $t6, 48($t3)
	sw $t6, 52($t3)
	sw $t6, 56($t3)
	sw $t6, 60($t3)
	sw $t6, 64($t3)
	sw $t7, 68($t3)

	beq $t8, 2, draw_box_exit						# Once drawn we exit
	
	addi $t8, $t8, 1
	move $t6, $t4								# Change colour
	addi $t3, $t3, 256							# Move to next row
	beq $t8, 2, reset_colour
	j colour_strength
	
reset_colour:
	move $t6, $t7
	j colour_strength
	
draw_box_exit:
	li $t5, 27
	sw $t5, PLAYER_STRENGTH_BAR_X
	jr $ra

draw_player:
	lw $t5, PLAYER_X           						# Load current X position
	lw $t2, PLAYER_Y	     						# Load current Y position
    
	lw $t1, PLAYER_COLOUR							# Load Player Colour
	lw $t0, PLAYER_COLOUR2
	li $t6, BLACK
	li $t4, BASE_ADDRESS
    										# Calculate the address (4 lines below)
	mul $t3, $t2, WIDTH
	add $t3, $t3, $t5
	mul $t3, $t3, 4
	add $t4, $t4, $t3
    										# Colour the intended pixel in each row
    	sw $t1, 8($t4)  
    	sw $t1, 12($t4) 
    	sw $t1, 16($t4) 
										# Draw each row  below(8 rows)
    	addi $t4, $t4, 256

   	sw $t1, 4($t4)								# Colour each intended pixel
   	sw $t0, 8($t4)
   	sw $t0, 12($t4)
   	sw $t0, 16($t4)
    	sw $t1, 20($t4) 

    	addi $t4, $t4, 256
    	sw $t1, 0($t4)
    	sw $t0, 4($t4)
    	sw $t6, 8($t4)
    	sw $t0, 12($t4)  
    	sw $t6, 16($t4)  
    	sw $t0, 20($t4)
    	sw $t1, 24($t4)

    	addi $t4, $t4, 256
    	sw $t1, 0($t4)
    	sw $t0, 4($t4)
    	sw $t6, 8($t4)
    	sw $t0, 12($t4)  
    	sw $t6, 16($t4)  
    	sw $t0, 20($t4)
    	sw $t1, 24($t4)

    	addi $t4, $t4, 256
    	sw $t1, 4($t4)
    	sw $t0, 8($t4)
    	sw $t0, 12($t4)
    	sw $t0, 16($t4)
    	sw $t1, 20($t4)

    	addi $t4, $t4, 256
    	sw $t1, 8($t4)  
    	sw $t1, 12($t4)
    	sw $t1, 16($t4)

    	addi $t4, $t4, 256
    	sw $t1, 4($t4)
    	sw $t1, 8($t4)  
    	sw $t6, 12($t4)  
    	sw $t1, 16($t4)  
    	sw $t1, 20($t4)  
    	 

    	addi $t4, $t4, 256
    	sw $t1, 8($t4)  
    	sw $t6, 12($t4)  
    	sw $t1, 16($t4) 
    	jr $ra

draw_platforms:
    	addi $sp, $sp, -4							# Save $ra in a stack since used twice( so it doesnt overwrites)
    	sw $ra, 0($sp)
    	li $t1, PLATFORM_COLOUR
	
	li $t2, BASE_ADDRESS    						# Load base address of the bitmap
	
	li $t3, PLATFORM_1_X_POS						# Load the Platform positions
	li $t4, PLATFORM_1_Y_POS
	jal draw_platform							# Draw each platform
	
	li $t3, PLATFORM_2_X_POS
	li $t4, PLATFORM_2_Y_POS
	jal draw_platform
	
	li $t3, PLATFORM_3_X_POS
	li $t4, PLATFORM_3_Y_POS
	jal draw_platform
	
	li $t3, PLATFORM_4_X_POS
	li $t4, PLATFORM_4_Y_POS
	jal draw_platform
	
	li $t3, PLATFORM_5_X_POS
	li $t4, PLATFORM_5_Y_POS
	jal draw_platform
	
    	lw $ra, 0($sp)								# Restore $ra of the prev main call
    	addi $sp, $sp, 4
	jr $ra
	
draw_platform:
    										# Calculate BASE_ADDRESS + (y * width + x) * 4) (4 lines) the same way
    	mul $t4, $t4, WIDTH
    	add $t4, $t4, $t3
    	mul $t4, $t4, 4
    	add $t4, $t4, $t2
    	li $t0, PLATFORM_WIDTH
    	
loop:
	beqz $t0, draw_platform_exit						# Check if the platform is drawn then exit
    	sw $t1, 0($t4)								# Colour that pixel
    	addi $t4, $t4, 4
    	subi $t0, $t0, 1
	j loop
	
draw_platform_exit:								# Exit when platform is drawn
	jr $ra
	
set_key_presses:
	li $t9, 0xffff0000							# Set $t9 to the address
	lw $t8, 0($t9)  							# Load the value to $t8 present at the address
	beq $t8, 1, keypress_happened 
	jr $ra
keypress_happened:
	lw $t2, 4($t9)
	
    	lw $t0, PLAYER_X							# Update player's current pos as the prev position
    	sw $t0, PLAYER_X_PREV
    	lw $t0, PLAYER_Y
    	sw $t0, PLAYER_Y_PREV
	beq $t2, 0x61, respond_to_a  						# Move left
	beq $t2, 0x64, respond_to_d						# Move right
	beq $t2, 0x77, respond_to_w						# Move up
	beq $t2, 0x73, respond_to_s           					# Move down
	beq $t2, 0x72, respond_to_r						# restart game
	beq $t2, 0x71, respond_to_q						# quit game
	beq $t2, 0x20, respond_to_space					# Shoot bullet
	jr $ra
	
respond_to_r:
	j main
	
respond_to_q:
	j Exit
	
respond_to_a:
	lw $t0, PLAYER_X							# Load current X
	ble $t0, 0, no_move							# If off the screen then no move
	addi $t0, $t0, -3							# Decrement x position by 1 unit
	sw $t0, PLAYER_X							# Store new X position
	jr $ra
	
respond_to_d:
	lw $t0, PLAYER_X							# Load current X
	bge $t0, 56, no_move							# 56 is the max end point in x axis as 64 - 8 = 56
	addi $t0, $t0, 3							# Increment the x position by 1 unit
	sw $t0, PLAYER_X							# Store new X position
	jr $ra
	
respond_to_w:
    	lw $t0, PLAYER_Y							# Load the current y position of player
    	ble $t0, 4, no_move							# You cannot make a move and pass through the strengths displayed
    	lw $t1, NUM_JUMPS
    	lw $t2, JUMP_COUNTER
    	lw $t3, ON_GROUND
    	bnez $t3, reset_jump							# If player is on ground/platform then reset jump counts
    	blt $t2, $t1, double_jump						# Double jump allowed if counter is less than 2
	jr $ra
	
reset_jump:
	li $t5, 0
	sw $t5, JUMP_COUNTER
	
double_jump:
	bge $t2, $t1, no_move							# No move if counter greater than max jumps
	addi $t0, $t0, -12							# Decrement the y position by 1 unit
	ble $t0, 4, no_move
	addi $t2, $t2, 1
	sw $t2, JUMP_COUNTER
	sw $t0, PLAYER_Y							# Store new Y position
	jr $ra
	
respond_to_s:
	lw $t0, PLAYER_Y							# Load the current y position of player
	bge $t0, 56, no_move							# 56 is the max end point as 64 - 8 = 56 where 8 is players height
	addi $t0, $t0, 1							# Increment the y position by 1 unit
	sw $t0, PLAYER_Y							# Store the new Y position
	jr $ra
	
respond_to_space:
	lw $t3, BULLET_ACTIVE							# Check If the bullet is active
    	bnez $t3, no_move 							# If already active so no move made
	lw $t2, PLAYER_Y
	addi $t2, $t2, 6
	lw $t1, PLAYER_X
	addi $t1, $t1, 6							# Switch to the arm position where bullet should be fired from
	sw $t2, BULLET_Y							# Store the bullet Y position
	sw $t1, BULLET_X							# Store the bullet X position
	li $t3, 1
	sw $t3, BULLET_ACTIVE							# If we reach here, then Bullet is active
	jr $ra
	
no_move:
	jr $ra

move_bullet:
	lw $t2, BULLET_X
	lw $t1, BULLET_Y
	lw $t5, BULLET_ACTIVE
	beqz $t5, deactivate_bullet
	bge $t2, 64, deactivate_bullet						# If bullet goes off the screen then deactivate
										# Calculate the address based on bullet position
	li $t4, BASE_ADDRESS
	mul $t3, $t1, WIDTH	
	add $t3, $t3, $t2
	mul $t3, $t3, 4
	add $t4, $t4, $t3
	
	lw $t6, 0($t4)  							# Load pixel colour at bullet position
	li $t7, PLATFORM_COLOUR
	beq $t6, $t7, deactivate_bullet
										# Erase Bullet
	li $t0, BLACK
	sw $t0, 0($t4)
	addi $t2, $t2, 1
	sw $t2, BULLET_X 							# Store new position of Bullet
	
	blt $t2, 64, draw_bullet						# Draw bullet if not off the screen, move the bullet
	jr $ra

deactivate_bullet:
    	li $t0, 0
    	sw $t0, BULLET_ACTIVE  						# Deactivate the bullet (set flag to 0)
    	jr $ra
    	
draw_bullet:
	lw $t2, BULLET_X
	lw $t1, BULLET_Y
	
	li $t4, BASE_ADDRESS							# Calculate Address
	mul $t3, $t1, WIDTH	
	add $t3, $t3, $t2
	mul $t3, $t3, 4
	add $t4, $t4, $t3
	
	li $t5, BULLET_COLOUR
	sw $t5, 0($t4)								# Apply Colour
	jr $ra

check_bullet_enemy_1:
	lw $t0, BULLET_ACTIVE
	beqz $t0, skip_bullet_collision					# If bullet is not active,then skip checking collision
	lw $t3, ENEMY_1_X
	lw $t4, ENEMY_1_Y
	addi $t5, $t3, 8							# Enemy End X (WIDTH - 1)
	addi $t6, $t4, 5							# Enemy End Y (HEIGHT - 1)
	li $s3, 1								# Store in save register about which enemy
	j check_bullet_collision						# Check collision

check_bullet_enemy_2:
	lw $t0, BULLET_ACTIVE
	beqz $t0, skip_bullet_collision
	lw $t3, ENEMY_2_X
	lw $t4, ENEMY_2_Y
	addi $t5, $t3, 9							# Enemy_2 End X (WIDTH - 1)
	addi $t6, $t4, 5							# Enemy_2 END Y	 (HEIGHT - 1)
	li $s3, 2								# Store in save register about which enemy

check_bullet_collision:
	lw $t0, BULLET_ACTIVE
	beqz $t0, skip_bullet_collision
	lw $t1, BULLET_X
	lw $t2, BULLET_Y
										# Detect collision for enemy
	bgt $t2, $t6, skip_bullet_collision					# Bullet Y is greater than Enemy End Y
	blt $t2, $t4, skip_bullet_collision					# Bullet Y end is smaller than Enemy start Y
	bgt $t1, $t5, skip_bullet_collision					# Bullet start X greater than Enemy End X
	blt $t1, $t3, skip_bullet_collision					# Bullet End X is smaller than Enemy start X

handle_bullet_collision:
	sw $zero, BULLET_ACTIVE						
	beq $s3, 1, enemy_1_hit						# Check collision with which enemy should be done
	beq $s3, 2, enemy_2_hit

enemy_1_hit:	
	lw $t0, ENEMY_1_HITS							# Load total number of hits
	addi $t0, $t0, 1							# Increment num hits at the collision
	sw $t0, ENEMY_1_HITS
										# Change colour of the enemy
										# Change the player colour momentarily
	lw $s0, ENEMY_1_COLOUR_1
	lw $s1, ENEMY_1_COLOUR_2
	lw $s2, ENEMY_1_COLOUR_3	
    	
	bgt $t0, 8, move_enemy_1						# If an enemy has been shot 8 times then erase it, it dies
	
	li $t8, 0xFF0000        						# Red colour to indicate enemy strength is reduced
	sw $t8, ENEMY_1_COLOUR_1						# Draw enemy with new colour
    	sw $t8, ENEMY_1_COLOUR_2
	sw $t8, ENEMY_1_COLOUR_3

	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	jal draw_enemy_1       						# Change colour for a certain time, since function called within function, store the return address
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	j restore_colour_enemy_1						# Restore colour and redraw with old colour

enemy_2_hit:
	lw $t0, ENEMY_2_HITS							# Load total number of hits
	lw $s0, ENEMY_2_COLOUR_1						# Increment num hits at the collision
	lw $s1, ENEMY_2_COLOUR_2	
    										# Change colour of the enemy
										# Change the player colour momentarily
    	addi $t0, $t0, 1
	sw $t0, ENEMY_2_HITS
	bgt $t0, 8, move_enemy_2
	li $t8, 0xFF0000        						# Red colour to indicate enemy strength is reduced
	sw $t8, ENEMY_2_COLOUR_1						# Draw enemy with new colour
    	sw $t8, ENEMY_2_COLOUR_2

	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	jal draw_enemy_2       						# Change colour for a certain time, since function called within function, store the return address
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	j restore_colour_enemy_2
	

restore_colour_enemy_1:
	li $v0, 32								# Add a bit delay to see a visible change
    	li $a0, 100
    	syscall

	sw $s0, ENEMY_1_COLOUR_1						# Restore original colours and store in memory
	sw $s1, ENEMY_1_COLOUR_2
	sw $s2, ENEMY_1_COLOUR_3

	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	jal draw_enemy_1          						# Redraw it with original colour
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	j reduce_enemy_strength

restore_colour_enemy_2:
	li $v0, 32								# Add a bit delay to see a visible change
    	li $a0, 100
    	syscall

	sw $s0, ENEMY_2_COLOUR_1
	sw $s1, ENEMY_2_COLOUR_2

	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	jal draw_enemy_2         						# Redraw it with original colour
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4

reduce_enemy_strength:
	lw $t0, ENEMY_STRENGTH_BAR_X
	lw $t1, ENEMY_STRENGTH_BAR_Y
	li $t2, BASE_ADDRESS
	li $t4, WHITE

										# Calculate address
	mul $t3, $t1, WIDTH							# y * 64
	add $t3, $t3, $t0							# y * width + x
	mul $t3, $t3, 4								# (y * width + x) * 4
	add $t3, $t3, $t2							# BASE_ADDRESS + (y * width + x) * 4

	sw $t4, 0($t3)
	addi $t0, $t0, -1
	sw $t0, ENEMY_STRENGTH_BAR_X						# Reduce strength by 1 pixel
	ble $t0, 35, draw_win_loose_screen					# If strength fully gone then display win/loose screen
	jr $ra
	

skip_bullet_collision:
	jr $ra
	
check_enemy_1_collision:
	lw $t2, ENEMY_1_X
	lw $t3, ENEMY_1_Y
	addi $t4, $t2, 8							# Enemy_1 End X (WIDTH - 1)
	addi $t5, $t3, 5							# Enemy_1 End Y	 (HEIGHT - 1)
	j check_player_collision_enemy

check_enemy_2_collision:
	lw $t2, ENEMY_2_X
	lw $t3, ENEMY_2_Y
	addi $t4, $t2, 9							# Enemy_2 End X	 (WIDTH - 1)
	addi $t5, $t3, 5							# Enemy_2 END Y (HEIGHT - 1)
	j check_player_collision_enemy

check_player_collision_enemy:
	lw $t0, PLAYER_X
	lw $t1, PLAYER_Y
	
	bgt $t1, $t5, no_enemy_collision					# Player y start greater than enemy end y
	addi $t1, $t1, PLAYER_HEIGHT						# Player y end
	blt $t1, $t3, no_enemy_collision					# Player y end smaller than enemy start y
	bgt $t0, $t4, no_enemy_collision					# Player start x greater than enemy end so no collision
	addi $t0, $t0, PLAYER_WIDTH						# Player x end		
	blt $t0, $t2, no_enemy_collision					# Player end x less than  enemy start position
	
handle_player_collision_with_enemy:
	lw $s0, PLAYER_COLOUR							# Change the player colour momentarily
    	lw $s1, PLAYER_COLOUR2
    	
	lw $t9, FRAME_COUNTER
    	andi $t9, $t9, 5       		
    	bnez $t9, no_enemy_collision
    	
	li $t8, 0xFF0000        						# Red colour for showing enemy damage
    	li $t9, 0x990000        						# Dark red colour for showing enemy damage
    	sw $t8, PLAYER_COLOUR
    	sw $t9, PLAYER_COLOUR2

	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	jal draw_player          						# Change colour for a certain time, since function called within function, store the return address
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4

	sw $s0, PLAYER_COLOUR							# Restore colour back
	sw $s1, PLAYER_COLOUR2
	
	li $v0, 32								# Add a bit delay to see a visible change
    	li $a0, 200
    	syscall

	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	jal draw_player          						# Redraw it with original colour
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	
reduce_player_health:
	lw $t0, PLAYER_STRENGTH_BAR_X
	lw $t1, PLAYER_STRENGTH_BAR_Y
	li $t2, BASE_ADDRESS
	li $t4, WHITE
										# Calculate address
	mul $t3, $t1, WIDTH							# y * 64
	add $t3, $t3, $t0							# y * width + x
	mul $t3, $t3, 4								# (y * width + x) * 4
	add $t3, $t3, $t2							# BASE_ADDRESS + (y * width + x) * 4

	sw $t4, 0($t3)
										# If player health equals 11 then show player lose game screen
	addi $t0, $t0, -1
	sw $t0, PLAYER_STRENGTH_BAR_X	
	ble $t0, 10, draw_win_loose_screen
	jr $ra
	
no_enemy_collision:
	jr $ra
	
	
apply_gravity:
    	addi $sp, $sp, -4							# Since we calling another function (function calling another function), so we need to store the 							return address on stack
    	sw $ra, 0($sp)
    	lw $t0, PLAYER_X
    	sw $t0, PLAYER_X_PREV
    	lw $t0, PLAYER_Y							# We updated the Prev_Y position of the player
    	sw $t0, PLAYER_Y_PREV
    	jal erase_player							# Call erase_player to erase the prev position of player
    	jal check_all_platform_collisions					# Now Check all the platforms for collision
    	lw $t1, ON_GROUND							# If player is on ground or platform then call skip_gravity
    	bnez $t1, skip_gravity
    	lw $t0, PLAYER_Y							# Otherwise make the player fall down at a constant speed
    	addi $t0, $t0, 1
    	sw $t0, PLAYER_Y
    	
skip_gravity:
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra

check_all_platform_collisions:
    	addi $sp, $sp, -4							# Since we calling another function, so we need to store the return address on stack
    	sw $ra, 0($sp)
    	li $t3, 0								# Initializations
    	sw $t3, ON_GROUND
    
    	lw $t0, PLAYER_Y
    	lw $t1, PLAYER_X
    	addi $t7, $t0, PLAYER_HEIGHT  						# Player feet
    	addi $t8, $t1, PLAYER_WIDTH   						# Player rightmost position
    
    	lw $t2, GROUND_POS							# Ground check
    	beq $t7, $t2, ground_collision
    
    	la $t6, PLATFORM_1							# check collision with each single platform
    	jal check_single_collision
    	beq $v0, 1, collisions_done
    
    	la $t6, PLATFORM_2
    	jal check_single_collision
    	beq $v0, 1, collisions_done
    
    	la $t6, PLATFORM_3
    	jal check_single_collision
    	beq $v0, 1, collisions_done
    
    	la $t6, PLATFORM_4
    	jal check_single_collision
    	beq $v0, 1, collisions_done
    
    	la $t6, PLATFORM_5
    	jal check_single_collision
    
collisions_done:
    	lw $ra, 0($sp)								# After checking the platforms reset the stack and return
    	addi $sp, $sp, 4
    	jr $ra

ground_collision:
	li $t3, 1								# If player is already on the ground, then update the y position of the player
    	sw $t3, ON_GROUND
    	sw $zero, JUMP_COUNTER
    	sub $t0, $t2, PLAYER_HEIGHT
    	sw $t0, PLAYER_Y
    	jr $ra

check_single_collision:
    	lw $a1, 0($t6)     							# Platform Start X
    	lw $a2, 4($t6)     							# Y
    	lw $a3, 8($t6)     							# End X (X + Width)
    	bne $t7, $a2, done_platform						# Check if the players's y position against platforms position
    	blt $t8, $a1, done_platform						# If players y position matches then check if the player is standing within the platform's x 								position
    	bgt $t1, $a3, done_platform
    										# If we get here, it means there is a collision
    	li $t3, 1
    	sw $t3, ON_GROUND							# Update the ON_GROUND flag, reset JUMP_COUNTER and store the y position of the player
    	sw $zero, JUMP_COUNTER
    	sub $t0, $a2, PLAYER_HEIGHT
    	sw $t0, PLAYER_Y
    	li $v0, 1								# The return value is 1 indicating no other platforms need to be checked
    	jr $ra

done_platform:
    	li $v0, 0								# If no collsion detected yet, move to the next platform
    	jr $ra
    	
    	
erase_player:
	lw $t5, PLAYER_X_PREV							# Load previous player position
    	lw $t2, PLAYER_Y_PREV
										# Calculate the address based on prev player positions
	li $t4, BASE_ADDRESS
	mul $t3, $t2, WIDTH	
	add $t3, $t3, $t5
	mul $t3, $t3, 4
	add $t4, $t4, $t3
	
	li $t1, BLACK								# Default background
	sw $t1, 8($t4)  
    	sw $t1, 12($t4) 
    	sw $t1, 16($t4) 
										# Draw each row  below(8 rows)
    	addi $t4, $t4, 256

   	sw $t1, 4($t4)  
   	sw $t1, 8($t4)
   	sw $t1, 12($t4)
   	sw $t1, 16($t4)
    	sw $t1, 20($t4) 

    	addi $t4, $t4, 256
    	sw $t1, 0($t4)
    	sw $t1, 4($t4)
    	sw $t1, 8($t4)
    	sw $t1, 12($t4)  
    	sw $t1, 16($t4)  
    	sw $t1, 20($t4)
    	sw $t1, 24($t4)

    	addi $t4, $t4, 256
    	sw $t1, 0($t4)
    	sw $t1, 4($t4)
    	sw $t1, 8($t4)
    	sw $t1, 12($t4)  
    	sw $t1, 16($t4)  
    	sw $t1, 20($t4)
    	sw $t1, 24($t4)

    	addi $t4, $t4, 256
    	sw $t1, 4($t4)
    	sw $t1, 8($t4)
    	sw $t1, 12($t4)
    	sw $t1, 16($t4)
    	sw $t1, 20($t4)

    	addi $t4, $t4, 256
    	sw $t1, 8($t4)  
    	sw $t1, 12($t4)
    	sw $t1, 16($t4)

    	addi $t4, $t4, 256
    	sw $t1, 4($t4)
    	sw $t1, 8($t4)  
    	sw $t1, 12($t4)  
    	sw $t1, 16($t4)  
    	sw $t1, 20($t4)  
    	 

    	addi $t4, $t4, 256
    	sw $t1, 8($t4)  
    	sw $t1, 12($t4)  
    	sw $t1, 16($t4) 
    	jr $ra

	
move_enemy_1:									# Erase prev position of the enemy
	lw $t2, ENEMY_1_X
	li $t0, -100
	beq $t2, $t0, exit_moving_1
	lw $t1, ENEMY_1_Y
										# Calculate the address based on enemy position
	li $t4, BASE_ADDRESS
	mul $t3, $t1, WIDTH	
	add $t3, $t3, $t2
	mul $t3, $t3, 4
	add $t4, $t4, $t3

	li $t0, BLACK
	sw $t0, 8($t4)
	sw $t0, 12($t4)
	sw $t0, 16($t4)
	sw $t0, 20($t4)
	sw $t0, 24($t4)
	
	addi $t4, $t4, 256
	sw $t0, 4($t4)
	sw $t0, 8($t4)
	sw $t0, 12($t4)
	sw $t0, 16($t4)
	sw $t0, 20($t4)
	sw $t0, 24($t4)
	sw $t0, 28($t4)
	
	addi $t4, $t4, 256
	sw $t0, 0($t4)
	sw $t0, 4($t4)
	sw $t0, 8($t4)
	sw $t0, 12($t4)
	sw $t0, 16($t4)
	sw $t0, 20($t4)
	sw $t0, 24($t4)
	sw $t0, 28($t4)
	sw $t0, 32($t4)
	
	addi $t4, $t4, 256
	sw $t0, 0($t4)
	sw $t0, 4($t4)
	sw $t0, 8($t4)
	sw $t0, 12($t4)
	sw $t0, 16($t4)
	sw $t0, 20($t4)
	sw $t0, 24($t4)
	sw $t0, 28($t4)
	sw $t0, 32($t4)
	
	addi $t4, $t4, 256
	sw $t0, 0($t4)
	sw $t0, 4($t4)
	sw $t0, 8($t4)
	sw $t0, 12($t4)
	sw $t0, 16($t4)
	sw $t0, 20($t4)
	sw $t0, 24($t4)
	sw $t0, 28($t4)
	sw $t0, 32($t4)
	
	addi $t4, $t4, 256
	sw $t0, 4($t4)
	sw $t0, 8($t4)
	sw $t0, 12($t4)
	sw $t0, 16($t4)
	sw $t0, 20($t4)
	sw $t0, 24($t4)
	sw $t0, 28($t4)
	
	lw $t0, ENEMY_1_HITS
	bgt $t0, 8, return_moving_1
	addi $t2, $t2, -1
	sw $t2, ENEMY_1_X 							# Store new position of enemy
	bgez $t2, draw_enemy_1
	li $t2, 55 								# Reset x to the initial position
	sw $t2, ENEMY_1_X
	
exit_moving_1:
	jr $ra
	
return_moving_1:
	li $t0, -100
	sw $t0, ENEMY_1_X
	sw $t0, ENEMY_1_Y
	j reduce_enemy_strength
	
draw_enemy_1:
	lw $t2, ENEMY_1_X
	lw $t1, ENEMY_1_Y
										# Calculate the address based on enemy position
	li $t4, BASE_ADDRESS
	mul $t3, $t1, WIDTH	
	add $t3, $t3, $t2
	mul $t3, $t3, 4
	add $t4, $t4, $t3
	
	lw $t5, ENEMY_1_COLOUR_1
	lw $t6, ENEMY_1_COLOUR_2
	lw $t7, ENEMY_1_COLOUR_3
	li $t8, WHITE
	li $t0, BLACK
	sw $t5, 8($t4)
	sw $t6, 12($t4)
	sw $t6, 16($t4)
	sw $t6, 20($t4)
	sw $t5, 24($t4)
	
	addi $t4, $t4, 256
	sw $t5, 4($t4)
	sw $t8, 8($t4)
	sw $t5, 12($t4)
	sw $t5, 16($t4)
	sw $t5, 20($t4)
	sw $t8, 24($t4)
	sw $t5, 28($t4)
	
	addi $t4, $t4, 256
	sw $t5, 0($t4)
	sw $t6, 4($t4)
	sw $t8, 8($t4)
	sw $t8, 12($t4)
	sw $t6, 16($t4)
	sw $t8, 20($t4)
	sw $t8, 24($t4)
	sw $t6, 28($t4)
	sw $t5, 32($t4)
	
	addi $t4, $t4, 256
	sw $t5, 0($t4)
	sw $t6, 4($t4)
	sw $t8, 8($t4)
	sw $t0, 12($t4)
	sw $t6, 16($t4)
	sw $t0, 20($t4)
	sw $t8, 24($t4)
	sw $t6, 28($t4)
	sw $t5, 32($t4)
	
	addi $t4, $t4, 256
	sw $t7, 0($t4)
	sw $t6, 4($t4)
	sw $t6, 8($t4)
	sw $t6, 12($t4)
	sw $t6, 16($t4)
	sw $t6, 20($t4)
	sw $t6, 24($t4)
	sw $t7, 28($t4)
	sw $t7, 32($t4)
	
	addi $t4, $t4, 256
	sw $t5, 4($t4)
	sw $t7, 8($t4)
	sw $t5, 12($t4)
	sw $t5, 16($t4)
	sw $t5, 20($t4)
	sw $t7, 24($t4)
	sw $t5, 28($t4)
	
	jr $ra

move_enemy_2:
										# Erase prev position of the enemy
	lw $t2, ENEMY_2_X
	li $t0, -100
	beq $t2, $t0, exit_moving_2
	lw $t1, ENEMY_2_Y
										# Calculate the address based on enemy position
	li $t4, BASE_ADDRESS
	mul $t3, $t1, WIDTH	
	add $t3, $t3, $t2
	mul $t3, $t3, 4
	add $t4, $t4, $t3
	
										# Colour all pixels black
	li $t5, BLACK
	sw $t5, 28($t4)
	addi $t4, $t4, 256
	sw $t5, 8($t4)
	sw $t5, 12($t4)
	sw $t5, 16($t4)
	sw $t5, 24($t4)
	sw $t5, 28($t4)
	sw $t5, 32($t4)
	addi $t4, $t4, 256
	
	sw $t5, 4($t4)
	sw $t5, 8($t4)
	sw $t5, 12($t4)
	sw $t5, 16($t4)
	sw $t5, 20($t4)
	sw $t5, 24($t4)
	sw $t5, 28($t4)
	sw $t5, 32($t4)
	sw $t5, 36($t4)
	addi $t4, $t4, 256
	
	sw $t5, 0($t4)
	sw $t5, 4($t4)
	sw $t5, 8($t4)
	sw $t5, 12($t4)
	sw $t5, 16($t4)
	sw $t5, 20($t4)
	sw $t5, 24($t4)
	sw $t5, 28($t4)
	sw $t5, 32($t4)
	addi $t4, $t4, 256
	
	sw $t5, 0($t4)
	sw $t5, 4($t4)
	sw $t5, 8($t4)
	sw $t5, 12($t4)
	sw $t5, 16($t4)
	sw $t5, 20($t4)
	sw $t5, 24($t4)
	addi $t4, $t4, 256
	
	sw $t5, 4($t4)
	sw $t5, 8($t4)
	sw $t5, 12($t4)
	sw $t5, 16($t4)
	sw $t5, 20($t4)
	lw $t0, ENEMY_2_HITS
	bgt $t0, 8, return_moving_2
	addi $t2, $t2, -1
	sw $t2, ENEMY_2_X 							# Store new position of enemy
	bgez $t2, draw_enemy_2
	li $t2, 54								# Reset x to the initial position
	sw $t2, ENEMY_2_X
	
exit_moving_2:
	jr $ra
return_moving_2:
	li $t0, -100
	sw $t0, ENEMY_2_X
	sw $t0, ENEMY_2_Y
	j reduce_enemy_strength
	
draw_enemy_2:
	lw $t2, ENEMY_2_X
	lw $t1, ENEMY_2_Y
										# Calculate the address based on enemy position
	li $t4, BASE_ADDRESS
	mul $t3, $t1, WIDTH	
	add $t3, $t3, $t2
	mul $t3, $t3, 4
	add $t4, $t4, $t3
	
	lw $t5, ENEMY_2_COLOUR_1						# Load the enemy colours
	lw $t6, ENEMY_2_COLOUR_2
	li $t7, WHITE
	
	sw $t6, 28($t4)								# Draw each row for the enemy
	addi $t4, $t4, 256
	sw $t6, 8($t4)
	sw $t6, 12($t4)
	sw $t6, 16($t4)
	sw $t6, 24($t4)
	sw $t5, 28($t4)
	sw $t6, 32($t4)
	addi $t4, $t4, 256
	
	sw $t6, 4($t4)
	sw $t5, 8($t4)
	sw $t5, 12($t4)
	sw $t5, 16($t4)
	sw $t6, 20($t4)
	sw $t5, 24($t4)
	sw $t5, 28($t4)
	sw $t5, 32($t4)
	sw $t6, 36($t4)
	addi $t4, $t4, 256
	
	sw $t6, 0($t4)
	sw $t5, 4($t4)
	sw $t5, 8($t4)
	sw $t5, 12($t4)
	sw $t5, 16($t4)
	sw $t5, 20($t4)
	sw $t6, 24($t4)
	sw $t6, 28($t4)
	sw $t6, 32($t4)
	addi $t4, $t4, 256

	sw $t6, 0($t4)
	sw $t7, 4($t4)
	sw $t5, 8($t4)
	sw $t7, 12($t4)
	sw $t5, 16($t4)
	sw $t5, 20($t4)
	sw $t6, 24($t4)
	addi $t4, $t4, 256
	
	sw $t6, 4($t4)
	sw $t6, 8($t4)
	sw $t6, 12($t4)
	sw $t6, 16($t4)
	sw $t6, 20($t4)
	jr $ra

draw_win_loose_screen:
	li $t0, BASE_ADDRESS      						# $t0 stores the base address
    	li $t1, BLACK								# Apply Black colour
    	addi $t0, $t0, 3072							# Skip first 6 rows since health should be displayed on game over screen
    	li $t4, 13456								# Whole screensize. except the first 6 rows

loop_black_screen:
    	beqz $t4, display_screen_text
    	sw $t1, 0($t0)            						# Colour each pixel
    	addi $t0, $t0, 4          						# Move to the next pixel
    	addi $t4, $t4, -4         						# Decrease the remaining memory size left to be colored
    	j loop_black_screen      						# Repeat the loop until the background applied

display_screen_text:
	lw $t0, PLAYER_STRENGTH_BAR_X						# Load Player Strength Bar
	lw $t1, ENEMY_STRENGTH_BAR_X						# Load Enemy Strength Bar
	blt $t1, 36, display_win_screen_text					# Display Win Screen if enemy's health reduced
	ble $t0, 11, display_loose_screen_text					# Display Loose Screen if player lost its health

display_win_screen_text:
	li $t2, BASE_ADDRESS
	li $t3, 27
	li $t4, 19
	li $t5, 0xa9429f
										# Calculate the address (4 lines below)
	mul $t3, $t3, WIDTH
	add $t3, $t3, $t4
	mul $t3, $t3, 4
	add $t2, $t2, $t3
	
										# Draw Four rows to display text YOU WIN
	sw $t5, 0($t2)
	sw $t5, 8($t2)
	sw $t5, 20($t2)
	sw $t5, 24($t2)
	sw $t5, 36($t2)
	sw $t5, 44($t2)
	sw $t5, 56($t2)
	sw $t5, 72($t2)
	sw $t5, 80($t2)
	sw $t5, 88($t2)
	sw $t5, 92($t2)
	sw $t5, 104($t2)
	
	addi $t2, $t2, 256
	sw $t5, 0($t2)
	sw $t5, 4($t2)
	sw $t5, 8($t2)
	sw $t5, 16($t2)
	sw $t5, 28($t2)
	sw $t5, 36($t2)
	sw $t5, 44($t2)
	sw $t5, 56($t2)
	sw $t5, 72($t2)
	sw $t5, 80($t2)
	sw $t5, 88($t2)
	sw $t5, 96($t2)
	sw $t5, 104($t2)
	
	addi $t2, $t2, 256
	sw $t5, 8($t2)
	sw $t5, 16($t2)
	sw $t5, 28($t2)
	sw $t5, 36($t2)
	sw $t5, 44($t2)
	sw $t5, 56($t2)
	sw $t5, 64($t2)
	sw $t5, 72($t2)
	sw $t5, 80($t2)
	sw $t5, 88($t2)
	sw $t5, 100($t2)
	sw $t5, 104($t2)
	
	addi $t2, $t2, 256
	sw $t5, 0($t2)
	sw $t5, 4($t2)
	sw $t5, 8($t2)
	sw $t5, 20($t2)
	sw $t5, 24($t2)
	sw $t5, 36($t2)
	sw $t5, 40($t2)
	sw $t5, 44($t2)
	sw $t5, 56($t2)
	sw $t5, 60($t2)
	sw $t5, 68($t2)
	sw $t5, 72($t2)
	sw $t5, 80($t2)
	sw $t5, 88($t2)
	sw $t5, 104($t2)
	j display_press_p
	
display_loose_screen_text:
	li $t2, BASE_ADDRESS
	li $t3, 27
	li $t4, 19
	li $t5, 0xa9429f
										# Calculate the address (4 lines below)
	mul $t3, $t3, WIDTH
	add $t3, $t3, $t4
	mul $t3, $t3, 4
	add $t2, $t2, $t3
										# Draw Four rows to display text YOU LOOSE
	sw $t5, 0($t2)
	sw $t5, 8($t2)
	sw $t5, 20($t2)
	sw $t5, 24($t2)
	sw $t5, 36($t2)
	sw $t5, 44($t2)
	sw $t5, 56($t2)
	sw $t5, 72($t2)
	sw $t5, 76($t2)
	sw $t5, 88($t2)
	sw $t5, 92($t2)
	sw $t5, 96($t2)
	sw $t5, 104($t2)
	sw $t5, 108($t2)
	sw $t5, 112($t2)
	
	addi $t2, $t2, 256
	sw $t5, 0($t2)
	sw $t5, 4($t2)
	sw $t5, 8($t2)
	sw $t5, 16($t2)
	sw $t5, 28($t2)
	sw $t5, 36($t2)
	sw $t5, 44($t2)
	sw $t5, 56($t2)
	sw $t5, 68($t2)
	sw $t5, 80($t2)
	sw $t5, 88($t2)
	sw $t5, 108($t2)
	
	addi $t2, $t2, 256
	sw $t5, 8($t2)
	sw $t5, 16($t2)
	sw $t5, 28($t2)
	sw $t5, 36($t2)
	sw $t5, 44($t2)
	sw $t5, 56($t2)
	sw $t5, 68($t2)
	sw $t5, 80($t2)
	sw $t5, 96($t2)
	sw $t5, 108($t2)
	
	addi $t2, $t2, 256
	sw $t5, 0($t2)
	sw $t5, 4($t2)
	sw $t5, 8($t2)
	sw $t5, 20($t2)
	sw $t5, 24($t2)
	sw $t5, 36($t2)
	sw $t5, 40($t2)
	sw $t5, 44($t2)
	sw $t5, 56($t2)
	sw $t5, 60($t2)
	sw $t5, 64($t2)
	sw $t5, 72($t2)
	sw $t5, 76($t2)
	sw $t5, 88($t2)
	sw $t5, 92($t2)
	sw $t5, 96($t2)
	sw $t5, 108($t2)

display_press_p:
	li $t2, BASE_ADDRESS
	li $t3, 33
	li $t4, 20
	li $t5, 0xffffff
										# Calculate the address (4 lines below)
	mul $t3, $t3, WIDTH
	add $t3, $t3, $t4
	mul $t3, $t3, 4
	add $t2, $t2, $t3
										# Four rows to display 'Press P'
	sw $t5, 0($t2)
	sw $t5, 4($t2)
	sw $t5, 8($t2)
	sw $t5, 16($t2)
	sw $t5, 20($t2)
	sw $t5, 24($t2)
	sw $t5, 32($t2)
	sw $t5, 36($t2)
	sw $t5, 40($t2)
	sw $t5, 48($t2)
	sw $t5, 52($t2)
	sw $t5, 56($t2)
	sw $t5, 64($t2)
	sw $t5, 68($t2)
	sw $t5, 72($t2)
	sw $t5, 84($t2)
	sw $t5, 88($t2)
	sw $t5, 92($t2)
	addi $t2, $t2, 256
	
	sw $t5, 0($t2)
	sw $t5, 8($t2)
	sw $t5, 16($t2)
	sw $t5, 32($t2)
	sw $t5, 36($t2)
	sw $t5, 40($t2)
	sw $t5, 48($t2)
	sw $t5, 64($t2)
	sw $t5, 84($t2)
	sw $t5, 92($t2)
	addi $t2, $t2, 256
	
	sw $t5, 0($t2)
	sw $t5, 4($t2)
	sw $t5, 8($t2)
	sw $t5, 16($t2)
	sw $t5, 32($t2)
	sw $t5, 56($t2)
	sw $t5, 72($t2)
	sw $t5, 84($t2)
	sw $t5, 88($t2)
	sw $t5, 92($t2)
	addi $t2, $t2, 256
	
	sw $t5, 0($t2)
	sw $t5, 16($t2)
	sw $t5, 32($t2)
	sw $t5, 36($t2)
	sw $t5, 40($t2)
	sw $t5, 48($t2)
	sw $t5, 52($t2)
	sw $t5, 56($t2)
	sw $t5, 64($t2)
	sw $t5, 68($t2)
	sw $t5, 72($t2)
	sw $t5, 84($t2)

exit_screen:
	li $t9, 0xffff0000							# Set $t9 to the address
	lw $t8, 0($t9)  							# Load the value to $t8 present at the address
	beq $t8, 1, key_press
	j exit_screen
	
key_press:
	lw $t2, 4($t9)
	beq $t2, 0x70, respond_to_p
	beq $t2, 0x71, respond_to_q						# quit game at any point
	j exit_screen
	
respond_to_p:
	j main									# Press p to exit win/lose screen
Exit:
	jal clear_screen
	li $v0, 10
	syscall
