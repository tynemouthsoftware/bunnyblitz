;======================================================================================
; Defines
;======================================================================================

;======================================================================================
; Hardware addresses
;======================================================================================
VIC_VERTICAL_CENTRE = $9001 ;  

VIC_ADDRESSING      = $9005 ; 36869

VIC_OSC1_FREQ       = $900A ; 36874
VIC_OSC2_FREQ       = $900B ; 36875
VIC_NOISE_FREQ      = $900D ; 36877
VIC_VOLUME          = $900E ; 36878
VIC_BORDER          = $900F ; 36879

VIA1_TIMER2_LSB     = $9118
VIA1_TIMER2_MSB     = $9119

KERNAL_VIC_REGS_VC  = $EDE5 ; VIC register 9001 default value, 19 NTSC, 26 PAL

KERNAL_START        = $FD22 ; kernal start routine

LAST_KEY            = $C5

;======================================================================================
; Zero page Variables
;======================================================================================
; $00 and $01 get overwritten

TEMP                    = $02

SEED_LSB                = $07
SEED_MSB                = $08
SEED                    = SEED_LSB

SKIP_TITLE              = $10
PLANE_DELAY             = $11
BOMB_NOTE               = $12
COL                     = $13

SCORE                   = $20

BOMBS_UNITS             = $21
BOMBS_TENS              = $22

BUILDINGS_UNITS         = $23
BUILDINGS_TENS          = $24
BUILDINGS_HUNDREDS      = $25

BUILDINGS_STANDING      = $26

;--------------------------------------------------------------------------------------
; 16 bit Variables
;--------------------------------------------------------------------------------------

PLANE                   = $30
PLANE_LSB               = PLANE
PLANE_MSB               = PLANE + 1

PLANE_COLOUR            = $32
PLANE_COLOUR_LSB        = PLANE_COLOUR
PLANE_COLOUR_MSB        = PLANE_COLOUR + 1

BOMB                    = $34
BOMB_LSB                = BOMB
BOMB_MSB                = BOMB + 1

BOMB_COLOUR             = $36
BOMB_COLOUR_LSB         = BOMB_COLOUR
BOMB_COLOUR_MSB         = BOMB_COLOUR + 1

TEXT                    = $38
TEXT_LSB                = TEXT
TEXT_MSB                = TEXT+1

TEXT_POS                = $3A
TEXT_POS_LSB            = TEXT_POS
TEXT_POS_MSB            = TEXT_POS + 1

;======================================================================================
; Screen layout
;======================================================================================

SCREEN_RAM              = $1E00
SCREEN_RAM_PAGE0        = SCREEN_RAM + $0000
SCREEN_RAM_PAGE1        = SCREEN_RAM + $0100

COLOUR_RAM              = $9600
COLOUR_RAM_PAGE0        = COLOUR_RAM + $0000
COLOUR_RAM_PAGE1        = COLOUR_RAM + $0100

CHAR_RAM                = $1C00
CHAR_RAM_PAGE0          = CHAR_RAM + $0000
CHAR_RAM_PAGE1          = CHAR_RAM + $0100

CHAR_ROM                = $8000
CHAR_ROM_PAGE0          = CHAR_ROM + $0000
CHAR_ROM_PAGE1          = CHAR_ROM + $0100

SCREEN_WIDTH            = 22
SCREEN_HEIGHT           = 23

COLOUR_RAM_OFFSET       = COLOUR_RAM - SCREEN_RAM
COLOUR_RAM_OFFSET_MSB   = (>COLOUR_RAM) - (>SCREEN_RAM)

SCREEN_RAM_LINE_00      = SCREEN_RAM + (SCREEN_WIDTH *  0)
SCREEN_RAM_LINE_02      = SCREEN_RAM + (SCREEN_WIDTH *  2)
SCREEN_RAM_LINE_04      = SCREEN_RAM + (SCREEN_WIDTH *  4)
SCREEN_RAM_LINE_07      = SCREEN_RAM + (SCREEN_WIDTH *  7)
SCREEN_RAM_LINE_09      = SCREEN_RAM + (SCREEN_WIDTH *  9)
SCREEN_RAM_LINE_12      = SCREEN_RAM + (SCREEN_WIDTH * 12)
SCREEN_RAM_LINE_15      = SCREEN_RAM + (SCREEN_WIDTH * 15)
SCREEN_RAM_LINE_16      = SCREEN_RAM + (SCREEN_WIDTH * 16)
SCREEN_RAM_LINE_20      = SCREEN_RAM + (SCREEN_WIDTH * 20)
SCREEN_RAM_LINE_21      = SCREEN_RAM + (SCREEN_WIDTH * 21)

SKYLINE                 = SCREEN_RAM_LINE_09
SKYLINE_COL             = SKYLINE + COLOUR_RAM_OFFSET

; Stats line
; 0123456789012345678901
;   X 123   X 12   X 1

SCREEN_STATS_LINE       = SCREEN_RAM_LINE_21

SCREEN_TB_LOGO          = SCREEN_STATS_LINE +  2

SCREEN_TB_HUNDREDS      = SCREEN_STATS_LINE +  4
SCREEN_TB_TENS          = SCREEN_STATS_LINE +  5
SCREEN_TB_UNITS         = SCREEN_STATS_LINE +  6

SCREEN_B_LOGO           = SCREEN_STATS_LINE + 10

SCREEN_B_TENS           = SCREEN_STATS_LINE + 12
SCREEN_B_UNITS          = SCREEN_STATS_LINE + 13

SCREEN_SC_LOGO          = SCREEN_STATS_LINE + 17

SCREEN_SC_UNITS         = SCREEN_STATS_LINE + 19

GROUND_POS              = SCREEN_RAM_LINE_20
GROUND_COLOUR           = GROUND_POS + COLOUR_RAM_OFFSET

BUILDING_MAX_HEIGHT     = GROUND_POS - SKYLINE - SCREEN_WIDTH

;======================================================================================
; Characters
;======================================================================================

UDG_BASE                = $21
UDG_BUIDLING            = UDG_BASE + $00
UDG_PLANE               = UDG_BASE + $01
UDG_BOMB                = UDG_BASE + $02
UDG_GRASS               = UDG_BASE + $03
UDG_SKY                 = UDG_BASE + $04
UDG_ROOF                = UDG_BASE + $05

UDG_DATA                = CHAR_RAM + (8 * UDG_BASE)

CHAR_SPACE              = $20
CHAR_0                  = $30
CHAR_1                  = $31
CHAR_3                  = $33
CHAR_9                  = $39
CHAR_10                 = $3A

;======================================================================================
; Keys
;======================================================================================

KEY_N                   = $1C
KEY_Y                   = $0B
KEY_SPACE               = $20
KEY_UP_ARROW            = $36
KEY_NONE                = $40

;======================================================================================
; Colours
;======================================================================================
COLOUR_BLACK            = $00
COLOUR_WHITE            = $01
COLOUR_RED              = $02
COLOUR_CYAN             = $03
COLOUR_VIOLET           = $04
COLOUR_PURPLE           = $04 ; == VIOLET
COLOUR_GREEN            = $05
COLOUR_BLUE             = $06
COLOUR_YELLOW           = $07
COLOUR_ORANGE           = $08
COLOUR_BROWN            = $09
COLOUR_LIGHTRED         = $0A
COLOUR_GRAY1            = $0B
COLOUR_GRAY2            = $0C
COLOUR_LIGHTGREEN       = $0D
COLOUR_LIGHTBLUE        = $0E
COLOUR_GRAY3            = $0F

;======================================================================================
; BASIC Tokens
;======================================================================================
SYS                     = $9E

