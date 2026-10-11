;===================================================================================================
; Bunny Blitz
; Based on Rabbit Blitz by C.Simun
; Dave Curran 2026-10-08
;===================================================================================================

; ACME bunnyblitz.asm
; or
; ACME -r bunnyblitz.lst bunnyblitz.asm

!to "bunnyblitz.prg",cbm

!source "defines.asm"

; BASIC loader stub
; 6502 SYS 4109
*=$1001
    !word end_of_stub                   ; link to next line (end of BASIC stub)
    !word 6502                          ; line number (can be anything, so why not)
    !byte SYS                           ; SYS token
    !text "4109"                        ; start of init code ($100D)
    !byte 0                             ; end of line
end_of_stub
    !word 0                             ; end of BASIC stub

;===================================================================================================
; Initialise once only
;===================================================================================================
    ldy #0                              ; always leave Y as 0
    sty SKIP_TITLE                      ; do not skip title the first time

    lda VIA1_TIMER2_LSB                 ; seed RND from the VIA timer
    sta SEED_LSB
    lda VIA1_TIMER2_MSB
    sta SEED_MSB

-   lda CHAR_ROM_PAGE0,y                ; copy character ROM
    sta CHAR_RAM_PAGE0,y                ; into character RAM
    lda CHAR_ROM_PAGE1,y
    sta CHAR_RAM_PAGE1,y
    iny
    bne -

    ldx #0                              ; copy user defined characters
-   lda CharacterData,x
    sta UDG_DATA,x                      ; into character RAM
    inx
    cpx #6 * 8                          ; 6 characters, 8 bytes per character
    bne -

    lda #$FF                            ; character memory $1C00, screen $1E00
    sta VIC_ADDRESSING

;===================================================================================================
; Start / restart game
;===================================================================================================
start:

    lda #CHAR_0                         ; initialise stats variables
    sta SCORE
    sta BOMBS_UNITS
    sta BOMBS_TENS
    sta BUILDINGS_UNITS
    sta BUILDINGS_TENS
    sta BUILDINGS_HUNDREDS

    lda #20                             ; set inital speed
    sta PLANE_DELAY

    lda #$FE                            ; reset bomb sound
    sta BOMB_NOTE

    lda #15                             ; maximum power!
    sta VIC_VOLUME

-   lda LAST_KEY                        ; wait for key release
    cmp #KEY_NONE
    bne -

    lda SKIP_TITLE                      ; skip the title if not the first time
    bne NEW_LEVEL

    jsr SUB_TITLE                       ; show the title screen
    inc SKIP_TITLE                      ; skip it next time

;===================================================================================================
; Start a new level
;===================================================================================================
NEW_LEVEL:
    lda #>SCREEN_RAM                    ; reset plane position
    sta PLANE_MSB
    lda #>COLOUR_RAM
    sta PLANE_COLOUR_MSB
    sty PLANE_LSB
    sty PLANE_COLOUR_LSB

    jsr SUB_CLS                         ; clear the screen

    lda #25                             ; white border and background
    sta VIC_BORDER

    dec PLANE_DELAY                     ; increase the plane speed each level

    lda #CHAR_0                         ; reset bombs count
    sta BOMBS_UNITS
    sta BOMBS_TENS

    ; draw the grass on the bottom three rows
    ldx #3 * SCREEN_WIDTH
-
    lda #UDG_GRASS                      ; grass is apparently just a solid square
    sta GROUND_POS,x
    lda #COLOUR_GREEN                   ; at least it is green
    sta GROUND_COLOUR,x
    dex
    bpl -

    ; setup stats display
    lda #UDG_BUIDLING
    sta SCREEN_TB_LOGO

    lda #UDG_BOMB
    sta SCREEN_B_LOGO

    lda #UDG_PLANE
    sta SCREEN_SC_LOGO

    lda #CHAR_SPACE
    sta SCREEN_TB_LOGO+1
    sta SCREEN_B_LOGO+1
    sta SCREEN_SC_LOGO+1

    lda #CHAR_0
    sta SCREEN_TB_HUNDREDS
    sta SCREEN_TB_TENS
    sta SCREEN_TB_UNITS
    sta SCREEN_B_TENS
    sta SCREEN_B_UNITS
    sta SCREEN_SC_UNITS

    lda #COLOUR_RED
    sta SCREEN_B_LOGO + COLOUR_RAM_OFFSET

    lda #COLOUR_BLUE
    sta SCREEN_SC_LOGO + COLOUR_RAM_OFFSET

    lda #COLOUR_BLACK
    sta SCREEN_TB_LOGO + COLOUR_RAM_OFFSET
    sta SCREEN_TB_HUNDREDS + COLOUR_RAM_OFFSET
    sta SCREEN_TB_TENS + COLOUR_RAM_OFFSET
    sta SCREEN_TB_UNITS + COLOUR_RAM_OFFSET
    sta SCREEN_B_TENS + COLOUR_RAM_OFFSET
    sta SCREEN_B_UNITS + COLOUR_RAM_OFFSET
    sta SCREEN_SC_UNITS + COLOUR_RAM_OFFSET

    ; add the buildings
    sty COL                             ; start in column 0
    sty BUILDINGS_STANDING              ; no buildings so far

buildloop:
    ldx #6                              ; get random number from 0-5
    jsr RND                             ;

    cmp #4                              ; check value, >= 4?
    bcs nextcol                         ; skip building

    inc BUILDINGS_STANDING              ; we have a new building

    tax                                 ; X = number of storeys

    lda COL                             ; offset starts as column

    inx                                 ; 0-3 -> 1-4
    clc
offsetloop:
    adc #2 * SCREEN_WIDTH               ; add 2 lines at a time
    dex
    bne offsetloop

    tax                                 ; X = offset
    lda #UDG_ROOF                       ; draw the roof
    sta SKYLINE,x                       ;
    tya                                 ; set the roof colour to black (0)
    sta SKYLINE_COL,x                   ;

    clc
drawloop:
    txa                                 ; X = X + 22
    adc #SCREEN_WIDTH                   ;
    tax                                 ;

    lda #UDG_BUIDLING                   ; draw the building
    sta SKYLINE,x                       ;
    lda #COLOUR_BLACK                   ; set the building colour
    sta SKYLINE_COL,x                   ;
    cpx #BUILDING_MAX_HEIGHT            ; reached the limit?
    bcc drawloop

nextcol:
    inc COL                             ; move to the next column
    lda COL                             ; check < 22 columns
    cmp #SCREEN_WIDTH
    bne buildloop

    ; drop through

;======================================================================================
; The main game loop
;======================================================================================
MAIN_LOOP:
    ; draw the plane
    lda #UDG_PLANE
    sta (PLANE),y
    lda #COLOUR_BLUE
    sta (PLANE_COLOUR),y

    ; plane flight delay
    lda PLANE_DELAY
    jsr DELAY

    ; print stats
    lda BOMBS_UNITS
    sta SCREEN_B_UNITS
    lda BOMBS_TENS
    sta SCREEN_B_TENS

    lda BUILDINGS_HUNDREDS
    sta SCREEN_TB_HUNDREDS
    lda BUILDINGS_TENS
    sta SCREEN_TB_TENS
    lda BUILDINGS_UNITS
    sta SCREEN_TB_UNITS

    lda SCORE
    sta SCREEN_SC_UNITS

-   lda LAST_KEY                        ; check last key pressed
    cmp #KEY_SPACE                      ; was it SPACE ?
    bne +
    JSR DROP_BOMB                       ; yes, drop a bomb

+   iny                                 ; no, check if we hit anything
    lda (PLANE),y                       ; Y=1, check next character
    dey                                 ; Y back to zero, phew
    cmp #UDG_ROOF                       ; was it a bit of building?
    beq CRASHED                         ; yes
    cmp #UDG_BUIDLING
    beq CRASHED                         ; also yes

    ldy #SCREEN_WIDTH                   ; no, so check below for ground
    lda (PLANE),y
    ldy #0
    cmp #UDG_GRASS                      ; have we landed?
    beq TAXI_HOME                       ; yes

    ; not landed yet

    ; the ↑ key is pause - who knew?
    lda LAST_KEY
    cmp #KEY_UP_ARROW
    bne +
    jsr SUB_PAUSE

+   lda #UDG_SKY                        ; hide the old plane position
    sta (PLANE),y

    lda #1                              ; move 1 square to the right
    ldx BUILDINGS_STANDING              ; check if all the buildings are gone?
    bne +
    lda #SCREEN_WIDTH + 1               ; yes, start to descend, 1 right, 1 down

+   clc                                 ; add 1 or 23 to the plane position
    adc PLANE_LSB
    sta PLANE_LSB                       ; update postition and colour
    sta PLANE_COLOUR_LSB
    bcc +
    inc PLANE_MSB
    inc PLANE_COLOUR_MSB

+   lda #$F5                            ; make the noise
    sta VIC_NOISE_FREQ

    jmp MAIN_LOOP                       ; and repeat until we hit something or land


;======================================================================================
; Taxi the plane to the right hand edge
;======================================================================================
TAXI_HOME:
    sty VIC_NOISE_FREQ                  ; kill the noise
    sty VIC_OSC1_FREQ                   ; sound off

-
    lda #UDG_PLANE                      ; draw the plane
    sta (PLANE),y
    lda #COLOUR_BLUE
    sta (PLANE_COLOUR),y

    lda #50                             ; taxing slowly
    jsr DELAY

    lda #UDG_SKY                        ; hide the old plane position
    sta (PLANE),y

    inc PLANE_LSB                       ; move along one square
    inc PLANE_COLOUR_LSB
    bne +
    inc PLANE_MSB
    inc PLANE_COLOUR_MSB

+   lda PLANE_MSB                       ; has the plane reached the far right edge?
    cmp #>GROUND_POS                    ;
    bne +                               ; different, so no need to check LSB
    lda PLANE_LSB                       ; compare LSB instead
    cmp #<GROUND_POS                    ;
+   bcc -                               ; no keep looping

    ; Plane has landed safely
    inc SCORE                           ; increase score

    lda SCORE                           ; has the user scored 10 landings?
    cmp #CHAR_10
    bne +
    jmp LANDED_10                       ; yes, celebrate
+
    jmp NEW_LEVEL                       ; start the next level


;======================================================================================
; oh, now we hit someone, Mrs Webb
;======================================================================================
CRASHED:
    lda #$96
    sta VIC_NOISE_FREQ

    ; shake the screen 10 times
    lda #10
    sta TEMP

-   lda #50
    sta VIC_VERTICAL_CENTRE

    lda #25                             ; delay for 25
    jsr DELAY

    lda #30
    sta VIC_VERTICAL_CENTRE

    lda #25                             ; delay for 25
    jsr DELAY

    dec TEMP
    bne -

    lda KERNAL_VIC_REGS_VC              ; restore the original value of vertical centering
    sta VIC_VERTICAL_CENTRE

    ; flash the border
    sty TEMP

-   lda TEMP
    sta VIC_BORDER

    lda #50
    jsr DELAY
    lda #50
    jsr DELAY

    lda TEMP
    clc
    adc #22
    sta TEMP
    bcc -

    sty VIC_NOISE_FREQ                  ; stop the noise

    jmp YOU_CRASHED

;======================================================================================
; Drop a bomb
;======================================================================================
DROP_BOMB:
    lda BOMBS_TENS                      ; check bomb count
    cmp #CHAR_3                         ; max is 30
    bcc +
    rts                                 ; max bombs used, do nothing

    ; drop the bomb
+   lda PLANE_LSB                       ; bomb starts at plane position
    sta BOMB_LSB
    sta BOMB_COLOUR_LSB

    lda PLANE_MSB
    sta BOMB_MSB
    lda PLANE_COLOUR_MSB
    sta BOMB_COLOUR_MSB

bombloop:
    lda #UDG_BOMB                       ; draw the bomb
    sta (BOMB),y
    lda #COLOUR_RED                     ; colour the bomb
    sta (BOMB_COLOUR),y                
    lda BOMB_NOTE
    sta VIC_OSC1_FREQ                   ; bomb in flight

    lda #10                             ; delay for 10
    jsr DELAY

    lda #UDG_SKY                        ; hide the bomb
    sta (BOMB),y

    dec BOMB_NOTE                       ; change the bomb note
    dec BOMB_NOTE

    ldy #SCREEN_WIDTH                   ; check the line below
    lda (BOMB),y
    tax
    cmp #UDG_BUIDLING                   ; is it a building?
    bne +
    ldy #SCREEN_WIDTH*2                 ; check 2 lines below
    lda (BOMB),y
    cmp #UDG_GRASS                      ; grass below?
    bne +

    dec BUILDINGS_STANDING              ; reduce the count of buildings
    inc BUILDINGS_UNITS                 ; increase count of toppled buildings
    lda BUILDINGS_UNITS                 ; check for rollovers
    cmp #CHAR_10
    bne +
    lda #CHAR_0                         ; 10, so units to 0 and increment 10s
    sta BUILDINGS_UNITS
    inc BUILDINGS_TENS
    lda BUILDINGS_TENS                  ; check for rollovers
    cmp #CHAR_10
    bne +
    lda #CHAR_0                         ; 100 so tens to 0 and increment 100s
    sta BUILDINGS_TENS
    inc BUILDINGS_HUNDREDS              ; no I am not checking for 1000.

+   ldy #0                              ; restore order to the universe
    cpx #UDG_ROOF                       ; is there a roof below us?
    bne +
    lda #$82                            ; make the crunching noise
    sta VIC_NOISE_FREQ

+   lda BOMB_LSB                        ; move bomb down 1 line
    clc
    adc #SCREEN_WIDTH
    sta BOMB_LSB
    sta BOMB_COLOUR_LSB
    bcc +
    inc BOMB_MSB
    inc BOMB_COLOUR_MSB

+   lda BOMB_MSB                        ; check if it is at ground level
    cmp #>GROUND_POS                    ;
    bne +                               ; different, so no need to check LSB
    lda BOMB_LSB                        ; compare LSB instead
    cmp #<GROUND_POS                    ;
+   bcc bombloop                        ; no, keep moving down

    ; bomb landed
    ldx #3                              ; get a random number from 0 to 2
    jsr RND

    clc                                 ; move plane by that amount
    adc PLANE_LSB
    sta PLANE_LSB
    sta PLANE_COLOUR_LSB
    bcc +
    inc PLANE_MSB
    inc PLANE_COLOUR_MSB
+

    inc BOMBS_UNITS                     ; bombs used count++
    lda BOMBS_UNITS                     ; check for rollovers
    cmp #CHAR_10
    bne +
    lda #CHAR_0                         ; 10, so units to 0 and increment 10s
    sta BOMBS_UNITS
    inc BOMBS_TENS                      ; max is 30, so no rollover to check
    lda BOMBS_TENS                      ; check bomb count
    cmp #CHAR_3                         ; max is 30
    bcc +
    lda #COLOUR_RED                     ; max bombs used, set the display red
    sta SCREEN_B_TENS + COLOUR_RAM_OFFSET
    sta SCREEN_B_UNITS + COLOUR_RAM_OFFSET

+   lda #$FE                            ; reset bomb note
    sta BOMB_NOTE

    sty VIC_OSC1_FREQ                   ; sound off
    sty VIC_NOISE_FREQ                  ; noise off

    rts

;======================================================================================
; Tell the pilot how bad they really are
;======================================================================================
YOU_CRASHED:
    jsr SUB_START_TEXT_SCREEN

    lda #>TEXT_CRASHED
    sta TEXT_MSB
    lda #<TEXT_CRASHED
    sta TEXT_LSB

    lda #>SCREEN_RAM_LINE_00
    ldx #<SCREEN_RAM_LINE_00
    jsr SUB_PRINT_STRING

    jsr SUB_SHOW_STATS

    jmp ANOTHER_GO

;======================================================================================
; 10 landings, well done
;======================================================================================
LANDED_10:
    jsr SUB_START_TEXT_SCREEN

    lda #>TEXT_LANDED
    sta TEXT_MSB
    lda #<TEXT_LANDED
    sta TEXT_LSB

    lda #>SCREEN_RAM_LINE_00
    ldx #<SCREEN_RAM_LINE_00
    jsr SUB_PRINT_STRING

    jsr SUB_SHOW_STATS

    ; fix the score
    lda #CHAR_1
    sta SCREEN_RAM_LINE_09 + 2
    lda #CHAR_0
    sta SCREEN_RAM_LINE_09 + 3

    ; drop through

;======================================================================================
; Another go, start or go to READY prompt
;======================================================================================
ANOTHER_GO:
    ; another go?
    lda #>TEXT_ANOTHER_GO
    sta TEXT_MSB
    lda #<TEXT_ANOTHER_GO
    sta TEXT_LSB

    lda #>SCREEN_RAM_LINE_20 + 2
    ldx #<SCREEN_RAM_LINE_20 + 2
    jsr SUB_PRINT_STRING

-   lda LAST_KEY                        ; wait for key press
    cmp #KEY_NONE
    beq -

    cmp #KEY_Y                          ; was it Y ?
    beq RESTART

    cmp #KEY_N                          ; was it N?
    bne -                               ; no, keep checking

    jmp KERNAL_START                    ; N = reset VIC to READY prompt

RESTART:
    jmp start                           ; Y = start again


;======================================================================================
; Pause
;======================================================================================
SUB_PAUSE:
    sty VIC_NOISE_FREQ                  ; kill the noise
    sty VIC_OSC1_FREQ                   ;

-   lda LAST_KEY                        ; wait for key release
    cmp #KEY_NONE
    bne -

-   lda LAST_KEY                        ; wait for key press
    cmp #KEY_NONE
    beq -

-   lda LAST_KEY                        ; wait for key release
    cmp #KEY_NONE
    bne -

    lda #$F5                            ; make the noise
    sty VIC_NOISE_FREQ

    rts


;======================================================================================
; Show the title page
;======================================================================================
SUB_TITLE:
    jsr SUB_START_TEXT_SCREEN

    lda #>TEXT_BUNNY_BLITZ
    sta TEXT_MSB
    lda #<TEXT_BUNNY_BLITZ
    sta TEXT_LSB

    lda #>SCREEN_RAM_LINE_00 + 5
    ldx #<SCREEN_RAM_LINE_00 + 5
    jsr SUB_PRINT_STRING

    lda #>TEXT_BY_ME
    sta TEXT_MSB
    lda #<TEXT_BY_ME
    sta TEXT_LSB

    lda #>SCREEN_RAM_LINE_02 + 3
    ldx #<SCREEN_RAM_LINE_02 + 3
    jsr SUB_PRINT_STRING

    lda #>TEXT_BASED_ON
    sta TEXT_MSB
    lda #<TEXT_BASED_ON
    sta TEXT_LSB

    lda #>SCREEN_RAM_LINE_04
    ldx #<SCREEN_RAM_LINE_04
    jsr SUB_PRINT_STRING

    jsr SUB_SHOW_STATS

    ; press the any key
    lda #>TEXT_PRESS_A_KEY
    sta TEXT_MSB
    lda #<TEXT_PRESS_A_KEY
    sta TEXT_LSB

    lda #>SCREEN_RAM_LINE_20 + 6
    ldx #<SCREEN_RAM_LINE_20 + 6
    jsr SUB_PRINT_STRING

-   lda LAST_KEY                        ; wait for key press
    cmp #KEY_NONE
    beq -

-   lda LAST_KEY                        ; wait for key release
    cmp #KEY_NONE
    bne -

    rts


;======================================================================================
; Start a text screen, black background, white text
;======================================================================================
SUB_START_TEXT_SCREEN:
    lda #KEY_NONE                       ; clear last keypress
    sta LAST_KEY

    jsr SUB_CLS                         ; clear the screen

    lda #8                              ; black border and background
    sta VIC_BORDER

    sty VIC_OSC1_FREQ                   ; sound off
    sty VIC_NOISE_FREQ                  ; noise off

    rts

;======================================================================================
; Show the user stats on a text page
;======================================================================================
SUB_SHOW_STATS:
    ; planes landed
    lda #>TEXT_PLANES
    sta TEXT_MSB
    lda #<TEXT_PLANES
    sta TEXT_LSB

    lda #>SCREEN_RAM_LINE_09
    ldx #<SCREEN_RAM_LINE_09
    jsr SUB_PRINT_STRING

    lda #COLOUR_BLUE
    sta SCREEN_RAM_LINE_09 + COLOUR_RAM_OFFSET

    lda SCORE
    sta SCREEN_RAM_LINE_09 + 2

    ; bombs dropped
    lda #>TEXT_BOMBS
    sta TEXT_MSB
    lda #<TEXT_BOMBS
    sta TEXT_LSB

    lda #>SCREEN_RAM_LINE_12
    ldx #<SCREEN_RAM_LINE_12
    jsr SUB_PRINT_STRING

    lda #COLOUR_RED
    sta SCREEN_RAM_LINE_12 + COLOUR_RAM_OFFSET

    lda BOMBS_TENS
    sta SCREEN_RAM_LINE_12 + 2
    lda BOMBS_UNITS
    sta SCREEN_RAM_LINE_12 + 3

    ; buildings flattened
    lda #>TEXT_BUILDINGS
    sta TEXT_MSB
    lda #<TEXT_BUILDINGS
    sta TEXT_LSB

    lda #>SCREEN_RAM_LINE_15
    ldx #<SCREEN_RAM_LINE_15
    jsr SUB_PRINT_STRING

    lda BUILDINGS_HUNDREDS
    sta SCREEN_RAM_LINE_16 + 2
    lda BUILDINGS_TENS
    sta SCREEN_RAM_LINE_16 + 3
    lda BUILDINGS_UNITS
    sta SCREEN_RAM_LINE_16 + 4

    rts

;======================================================================================
; Clear the screen
;======================================================================================
SUB_CLS:
    lda #CHAR_SPACE                     ; clear screen
-   sta SCREEN_RAM_PAGE0,y
    sta SCREEN_RAM_PAGE1,y
    iny
    bne -

    lda #COLOUR_WHITE                   ; clear colour RAM
-   sta COLOUR_RAM_PAGE0,y
    sta COLOUR_RAM_PAGE1,y
    iny
    bne -

    rts

;======================================================================================
; Print a string
; string pointed to by TEXT_MSB & TEXT_LSB
; location A=MSB, X=LSB, (and Y=0 as is the law)
;======================================================================================
SUB_PRINT_STRING:
    sta TEXT_POS_MSB
    stx TEXT_POS_LSB

-   lda (TEXT),y                        ; load the next character
    beq +                               ; exit if 0
    sta (TEXT_POS),y                    ; display the character
    iny                                 ; next character
    bne -                               ; loop back (will stop after 256 chars in no 0)

+   ldy #0                              ; reset y
    rts

;======================================================================================
; Delay the equivalent of FOR N=1 TO A : NEXT N
; For 0<A<63
; Clears X and Y
;======================================================================================
DELAY:
    asl                                 ; loop A*4*256
    asl                                 ;
    tax                                 ;
-   dey                                 ;
    bne -                               ;
    dex                                 ;
    bne -                               ;
    rts                                 ;

;======================================================================================
; Return a random number from 0 to X-1 in A
; Where 0 < X < 8
; Start at 0 and add 1 for each 1 in X bits of the 8 bit random number
;======================================================================================
RND:
    jsr RAND16                          ; get a random number in A
    sta TEMP                            ; store in temporary location
    tya                                 ; A=0
-   lsr TEMP                            ; 0 -> TEMP -> carry
    adc #0                              ; A=A+0+carry
    dex                                 ;
    bne -                               ; loop back
    rts                                 ; return with value in A

;======================================================================================
; Pseudo-random-number generator. You can get 8-bit random numbers in A
; or 16-bit numbers from the zero page addresses. Leaves X/Y unchanged.
;
; (36 clock cycles)
;
; See
; https://web.archive.org/web/20250328001550/https://codebase64.org/doku.php?id=base:16bit_xorshift_random_generator
; and
; https://github.com/markgbeckett/pet/tree/main/examples
;======================================================================================
RAND16:
    lda SEED_MSB                        ; (3)
    lsr			                        ; (2)
    lda SEED_LSB	                    ; (3)
    ror			                        ; (2)
    eor SEED_MSB	                    ; (3)
    sta SEED_MSB	                    ; (3) high part of x ^= x << 7 done
    ror             	                ; (2) A has now x >> 9 and high bit comes from low byte
    eor SEED_LSB	                    ; (3)
    sta SEED_LSB	                    ; (3) x ^= x >> 9 and the low part of x ^= x << 7 done
    eor SEED_MSB	                    ; (3)
    sta SEED_MSB	                    ; (3) x ^= x << 8 done

    rts			                        ; (6)

;======================================================================================
; Character Data
;======================================================================================

CharacterData:
; Building
!byte 255,255,219,219,255,255,219,219

; Plane
!byte 16,24,156,255,255,156,24,16

; Bomb
!byte 60,60,24,60,60,60,60,24

; Grass (solid square)
!byte 255,255,255,255,255,255,255,255

; Sky (empty square)
!byte 0,0,0,0,0,0,0,0

; Roof (triangle)
!byte 0,0,0,0,24,60,126,255

;======================================================================================
; Strings
;======================================================================================
TEXT_BUNNY_BLITZ:
    !scr    "bunny blitz"
    !byte 0

TEXT_BY_ME:
    !scr    "dave curran 2026"
    !byte 0

;            0123456789012345678901
TEXT_BASED_ON:
    !scr    "based on rabbit blitz "
    !scr    "      by c.simun"
    !byte 0

TEXT_PRESS_A_KEY:
    !scr    "press a key"
    !byte 0

TEXT_ANOTHER_GO:
    !scr    "another go? (y/n)"
    !byte 0

;            0123456789012345678901
TEXT_BUILDINGS:
    !scr    "&     old buildings   "
    !scr    "! 000 now happy bunny "
    !scr    "!     playgrounds"
    !byte 0

;            0123456789012345678901
TEXT_BOMBS:
    !scr    "# 00  lemon-scented   "
    !scr    "      bombettes used"
    !byte 0

;            0123456789012345678901
TEXT_PLANES:
    !scr    "\" 0   plane loads of  "
    !scr    "      bunnies landed"
    !byte 0

;            0123456789012345678901
TEXT_CRASHED:
    !scr    "oh dear, you crashed  "
    !scr    "and wiped out a whole "
    !scr    "plane full of lovely  "
    !scr    "fluffy bunnies.       "
    !scr    "                      "
    !scr    "you must try harder to"
    !scr    "land safely next time."
    !byte 0

;            0123456789012345678901
TEXT_LANDED:
    !scr    " well done, you have  "
    !scr    "  landed perfectly.   "
    !scr    "                      "
    !scr    "the fluffy bunnies are"
    !scr    " very happy in their  "
    !scr    " nice new playground."
    !byte 0

