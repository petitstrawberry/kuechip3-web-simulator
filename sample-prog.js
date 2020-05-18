var samplePrograms = {}

samplePrograms['default'] = `
0000: 00C0       #  EOR ACC, ACC
0002: 00C9       #  EOR IX,  IX
0004: 00BA 0010  #  ADD IX,  10H
0008: 00B2 0003  #  ADD ACC, 03H
000C: 00AA 0001  #  SUB IX,  1
0010: 0031 0008  #  BNZ 08H
0014: 0074 0020  #  ST  ACC, [20H]
0018: 000F       #  HLT
`


// 0080: 000A
// 0080:            # N:    EQU 80H
// 0082:            # SUM:  EQU 82H
samplePrograms['4.1'] = `
                 # N:    EQU      80H
                 # SUM:  EQU      82H
                 #       LOC      80H
0080: 000A       #       DAT      AH
0000: 006C 0080  #       LD  IX,  [N]
0004: 0062 0000  #       LD  ACC, 0
0008: 00B1       # LOOP: ADD ACC, IX
000A: 00AA 0001  #       SUB IX,  1
000E: 0033 0008  #       BP       LOOP
0012: 0074 0082  #       ST  ACC, [SUM]
0016: 000F       #       HLT
`

// 00C0:            # N:     EQU C0H
// 0080:            # DATA1: EQU 80H
// 0090:            # DATA2: EQU 90H
// 00A0:            # ANS:   EQU A0H
samplePrograms['4.2'] = `
                 # N:     EQU      C0H
                 # DATA1: EQU      80H
                 # DATA2: EQU      90H
                 # ANS:   EQU      A0H
                 #        LOC      80H
0080: 0000       #        DAT      0H
0082: 0001       #        DAT      1H
                 #        LOC      90H
0090: 1FFF       #        DAT      1FFFH
0092: FFFF       #        DAT      FFFFH
                 #        LOC      C0H
00C0: 0004       #        DAT      4H
0000: 006C 00C0  #        LD  IX,  [N]
0004: 0020       #        RCF
0006: 0066 007E  # LOOP:  LD  ACC, [IX+DATA1-2]
000A: 0096 008E  #        ADC ACC, [IX+DATA2-2]
000E: 0076 009E  #        ST  ACC, [IX+ANS-2]
0012: 00AA 0002  #        SUB IX,  2
0016: 0033 0006  #        BP  LOOP
001A: 000F       #        HLT
`

// 0080:            # A:    EQU 80H
// 0082:            # B:    EQU 82H
// 0084:            # GCD:  EQU 84H
samplePrograms['4.3'] = `
                 # A:    EQU      80H
                 # B:    EQU      82H
                 # GCD:  EQU      84H
                 #       LOC      80H
0080: 0060       #       DAT      60H
0082: 0040       #       DAT      40H
0000: 0064 0080  #       LD  ACC, [A]
0004: 006C 0082  #       LD  IX,  [B]
0008: 00A1       # LOOP: SUB ACC, IX
000A: 0032 0008  #       BZP      LOOP
000E: 00B1       #       ADD ACC, IX
0010: 00C8       #       EOR IX,  ACC
0012: 00C1       #       EOR ACC, IX
0014: 00C8       #       EOR IX,  ACC
0016: 0031 0008  #       BNZ      LOOP
001A: 0074 0084  #       ST  ACC, [GCD]
001E: 000F       #       HLT
`

samplePrograms['4.4'] = `
                 # DATA:  EQU     0100H
                 # N:     EQU     80H
                 # WORK1: EQU     90H
                 # WORK2: EQU     92H
                 #        LOC     80H
0080: 0008       #        DAT     08H
                 #        LOC     100H
0100: 1000       #        DAT     1000H
0102: FFFF       #        DAT     FFFFH
0104: 0040       #        DAT     0040H
0106: 808E       #        DAT     808EH
0108: C0A0       #        DAT     C0A0H
010A: D008       #        DAT     D008H
010C: 7FFF       #        DAT     7FFFH
010E: CD00       #        DAT     CD00H
0000: 006C 0080  #        LD  IX, [N]
0004: 00B9       #        ADD IX, IX
0006: 00AA 0002  #        SUB IX, 2
000A: 007C 0090  #        ST  IX, [WORK1]
000E: 00C9       # LP1:   EOR IX, IX
0010: 0020       #        RCF
0012: 0066 0100  # LP2:   LD  ACC, [IX+DATA]
0016: 00F6 0102  #        CMP ACC, [IX+DATA+2]
001A: 003F 0034  #        BLE      SKIP
001E: 0074 0092  #        ST  ACC, [WORK2]
0022: 0066 0102  #        LD  ACC, [IX+DATA+2]
0026: 0076 0100  #        ST  ACC, [IX+DATA]
002A: 0064 0092  #        LD  ACC, [WORK2]
002E: 0076 0102  #        ST  ACC, [IX+DATA+2]
0032: 0028       #        SCF
0034: 00BA 0002  # SKIP:  ADD IX,  2
0038: 00FC 0090  #        CMP IX,  [WORK1]
003C: 0031 0012  #        BNZ      LP2
0040: 0035 0054  #        BNC      FIN
0044: 006C 0090  #        LD  IX,  [WORK1]
0048: 00AA 0002  #        SUB IX,  2
004C: 007C 0090  #        ST  IX,  [WORK1]
0050: 0031 000E  #        BNZ      LP1
0054: 000F       # FIN:   HLT
`

samplePrograms['4.5'] = `
                 # DATA: EQU 100H
                 #       LOC 100H
0100: 0062       #       DAT 62H
                 #       LOC 102H
0102: 00FF       #       DAT FFH
                 #       LOC 104H
0104: 0075       #       DAT 75H
                 #       LOC 106H
0106: 00C0       #       DAT C0H
                 #       LOC 108H
0108: 0075       #       DAT 75H
                 #       LOC 10AH
010A: 00C1       #       DAT C1H
                 #       LOC 10CH
010C: 00C9       #       DAT C9H
                 #       LOC 10EH
010E: 007D       #       DAT 7DH
                 # N:    EQU 120H
                 #       LOC 120H
0120: 0008       #       DAT 08H
                 # CRC:  EQU 80H
                 # WORK: EQU F0H
                 # TMP:  EQU F2H
0000: 0062 FFFF  #       LD  ACC, FFFFH
0004: 0074 0080  #       ST  ACC, [CRC]
0008: 00C9       #       EOR IX,  IX
000A: 007C 00F0  #       ST  IX,  [WORK]
000E: 007C 00F2  # LP1:  ST  IX,  [TMP]
0012: 00B9       #       ADD IX,  IX
0014: 0066 0100  #       LD  ACC, [IX+DATA]
0018: 006C 00F2  #       LD  IX,  [TMP]
001C: 0043       #       SLL ACC
001E: 0043       #       SLL ACC
0020: 0043       #       SLL ACC
0022: 0043       #       SLL ACC
0024: 0043       #       SLL ACC
0026: 0043       #       SLL ACC
0028: 0043       #       SLL ACC
002A: 0043       #       SLL ACC
002C: 00C4 0080  #       EOR ACC, [CRC]
0030: 0074 0080  #       ST  ACC, [CRC]
0034: 006A 0010  #       LD  IX,  16
0038: 0064 0080  # LP2:  LD  ACC, [CRC]
003C: 0043       #       SLL ACC
003E: 0074 0080  #       ST  ACC, [CRC]
0042: 0035 004E  #       BNC      SKIP
0046: 00C4 0078  #       EOR ACC, [POLY]
004A: 0074 0080  #       ST  ACC, [CRC]
004E: 00AA 0002  # SKIP: SUB IX,  2
0052: 0033 0038  #       BP       LP2
0056: 006C 00F0  #       LD  IX,  [WORK]
005A: 00BA 0001  #       ADD IX,  1
005E: 00FC 0120  #       CMP IX   [N]
0062: 007C 00F0  #       ST  IX,  [WORK]
0066: 0031 000E  #       BNZ      LP1
006A: 0064 0080  #       LD  ACC, [CRC]
006E: 00C2 FFFF  #       EOR ACC, FFFFH
0072: 0074 0080  #       ST  ACC, [CRC]
0076: 000F       #       HLT
                 # POLY: EQU 90H
                 #       LOC 90H
0090: 1021       #       DAT 1021H
`

samplePrograms['4.6'] = `
                 # DATA1: EQU 80H
                 # DATA2: EQU 82H
                 # ANS:   EQU 60H
                 # WORK:  EQU 90H
                 #        LOC 80H
0080: 0555       #        DAT 555H
                 #        LOC 82H
0082: 0FFF       #        DAT FFFH
0000: 00C0       #        EOR ACC, ACC
0002: 0074 0060  #        ST  ACC, [ANS]
0006: 0074 0062  #        ST  ACC, [ANS+2]
000A: 0074 0090  #        ST  ACC, [WORK]
000E: 0064 0082  #        LD  ACC, [DATA2]
0012: 0074 0092  #        ST  ACC, [WORK+2]
0016: 006C 0080  #        LD  IX,  [DATA1]
001A: 004A       # LOOP:  SRL IX
001C: 0035 003A  #        BNC      SKIP
0020: 0020       #        RCF
0022: 0064 0062  #        LD  ACC, [ANS+2]
0026: 0094 0092  #        ADC ACC, [WORK+2]
002A: 0074 0062  #        ST  ACC, [ANS+2]
002E: 0064 0060  #        LD  ACC, [ANS]
0032: 0094 0090  #        ADC ACC, [WORK]
0036: 0074 0060  #        ST  ACC, [ANS]
003A: 00FA 0000  # SKIP:  CMP IX,  0
003E: 0039 005A  #        BZ       FIN
0042: 0064 0092  #        LD  ACC, [WORK+2]
0046: 0041       #        SLA ACC
0048: 0074 0092  #        ST  ACC, [WORK+2]
004C: 0064 0090  #        LD  ACC, [WORK]
0050: 0045       #        RLA ACC
0052: 0074 0090  #        ST  ACC, [WORK]
0056: 0030 001A  #        BA       LOOP
005A: 000F       # FIN:   HLT
`

samplePrograms['4.7'] = `
                 # DATA1:  EQU A0H
                 #         LOC A0H
00A0: 0000       #         DAT 0000H
                 #         LOC A2H
00A2: 0000       #         DAT 0000H
                 #         LOC A4H
00A4: 8888       #         DAT 8888H
                 #         LOC A6H
00A6: 8888       #         DAT 8888H
                 # DATA2:  EQU B0H
                 #         LOC B0H
00B0: 0000       #         DAT 0000H
                 #         LOC B2H
00B2: 0000       #         DAT 0000H
                 #         LOC B4H
00B4: 2222       #         DAT 2222H
                 #         LOC B6H
00B6: 2222       #         DAT 2222H
                 # COUNT:  EQU C0H
                 # WORK:   EQU D0H
                 # RESULT: EQU E0H
0000: 0062 0040  #         LD  ACC, 64
0004: 0074 00C0  #         ST  ACC, [COUNT]
0008: 006A 0008  #         LD  IX,  8
000C: 00C0       # LP1:    EOR ACC, ACC
000E: 0076 00CE  #         ST  ACC, [IX+WORK-2]
0012: 0076 00DE  #         ST  ACC, [IX+RESULT-2]
0016: 0076 00E6  #         ST  ACC, [IX+RESULT+8-2]
001A: 0066 00AE  #         LD  ACC, [IX+DATA2-2]
001E: 0076 00D6  #         ST  ACC, [IX+WORK+8-2]
0022: 00AA 0002  #         SUB IX,  2
0026: 0031 000C  #         BNZ      LP1
002A: 0064 00A6  # LP2:    LD  ACC, [DATA1+6]
002E: 0042       #         SRL ACC
0030: 006A FFF8  #         LD  IX,  FFF8H
0034: 0066 00A8  # LP3:    LD  ACC, [IX+DATA1+8]
0038: 0044       #         RRA ACC
003A: 0076 00A8  #         ST  ACC, [IX+DATA1+8]
003E: 00BA 0002  #         ADD IX,  2
0042: 0031 0034  #         BNZ      LP3
0046: 0035 0064  #         BNC      LP5
004A: 006A 0010  #         LD  IX,  16
004E: 0020       #         RCF
0050: 0066 00DE  # LP4:    LD  ACC, [IX+RESULT-2]
0054: 0096 00CE  #         ADC ACC, [IX+WORK-2]
0058: 0076 00DE  #         ST  ACC, [IX+RESULT-2]
005C: 00AA 0002  #         SUB IX,  2
0060: 0031 0050  #         BNZ      LP4
0064: 006A 0010  # LP5:    LD  IX,  16
0068: 0020       #         RCF
006A: 0066 00CE  # LP6:    LD  ACC, [IX+WORK-2]
006E: 0045       #         RLA ACC
0070: 0076 00CE  #         ST  ACC, [IX+WORK-2]
0074: 00AA 0002  #         SUB IX,  2
0078: 0031 006A  #         BNZ      LP6
007C: 0064 00C0  #         LD  ACC, [COUNT]
0080: 00A2 0002  #         SUB ACC, 2
0084: 0074 00C0  #         ST  ACC, [COUNT]
0088: 0031 002A  #         BNZ      LP2
008C: 000F       #         HLT
`

samplePrograms['4.8'] = `
                 # DVD:  EQU 80H
                 # DVS:  EQU 82H
                 # QOT:  EQU 84H
                 # RMD:  EQU 86H
                 # WORK: EQU 90H
                 #       LOC 80H
0080: F0F0       #       DAT F0F0H
                 #       LOC 82H
0082: 3F3F       #       DAT 3F3FH
0000: 00C0       #       EOR ACC, ACC
0002: 0074 0084  #       ST  ACC, [QOT]
0006: 0074 0086  #       ST  ACC, [RMD]
000A: 0064 0080  #       LD  ACC, [DVD]
000E: 0074 0090  #       ST  ACC, [WORK]
0012: 006A 0010  #       LD  IX,  10H
0016: 0064 0090  # LOOP: LD  ACC, [WORK]
001A: 0041       #       SLA ACC
001C: 0074 0090  #       ST  ACC, [WORK]
0020: 0064 0086  #       LD  ACC, [RMD]
0024: 0045       #       RLA ACC
0026: 0020       #       RCF
0028: 0084 0082  #       SBC ACC, [DVS]
002C: 003D 0036  #       BC       SP1
0030: 0028       #       SCF
0032: 0030 003C  #       BA       SP2
0036: 00B4 0082  # SP1:  ADD ACC, [DVS]
003A: 0020       #       RCF
003C: 0074 0086  # SP2:  ST  ACC, [RMD]
0040: 0064 0084  #       LD  ACC, [QOT]
0044: 0045       #       RLA ACC
0046: 0074 0084  #       ST  ACC, [QOT]
004A: 00AA 0001  #       SUB IX,  1
004E: 0033 0016  #       BP       LOOP
0052: 000F       #       HLT
`

samplePrograms['4.9'] = `
                 # PROG:   EQU  0
                 # CA:     EQU  PROG
0000: 00C0       #         EOR  ACC, ACC
0002: 006A 0056  #         LD   IX,  TEST
0006: 0076 0000  # LP0:    ST   ACC, [IX]
000A: 00BA 0002  #         ADD  IX,  2
000E: 00FA 0000  #         CMP  IX,  PROG
0012: 0031 0006  #         BNZ       LP0
0016: 00C9       #         EOR  IX,  IX
0018: 006A 0056  # LP2:    LD   IX,  TEST
001C: 00F6 0000  # LP3:    CMP  ACC, [IX]
0020: 0031 0054  #         BNZ       ERR
0024: 00C2 8000  #         EOR  ACC, 8000H
0028: 0047       #         RLL  ACC
002A: 0076 0000  #         ST   ACC, [IX]
002E: 0039 003A  #         BZ        NX3
0032: 00F2 FFFF  #         CMP  ACC, FFFFH
0036: 0031 001C  #         BNZ       LP3
003A: 00C2 FFFF  # NX3:    EOR  ACC, FFFFH
003E: 00BA 0002  #         ADD  IX,  2
0042: 00FA 0000  #         CMP  IX,  PROG
0046: 0031 001C  #         BNZ       LP3
004A: 00C2 FFFF  #         EOR  ACC, FFFFH
004E: 0010       #         OUT
0050: 0030 0018  #         BA        LP2
0054: 000F       # ERR:    HLT  
                 # TEST:   EQU  CA
`
samplePrograms['4.10'] = `
                # DATA: EQU 100H
                #       LOC 100H
0100: 0062      #       DAT 62H
                #       LOC 102H
0102: 00FF      #       DAT FFH
                #       LOC 104H
0104: 0075      #       DAT 75H
                #       LOC 106H
0106: 00C0      #       DAT C0H
                #       LOC 108H
0108: 0075      #       DAT 75H
                #       LOC 10AH
010A: 00C1      #       DAT C1H
                #       LOC 10CH
010C: 00C9      #       DAT C9H
                #       LOC 10EH
010E: 007D      #       DAT 7DH
                # N:    EQU 120H
                #       LOC 120H
0120: 0008      #       DAT 08H
                # CRC:  EQU 80H
                # WORK: EQU F0H
                # TMP:  EQU F2H
0000: 0062 FFFF #       LD ACC, FFFFH
0004: 0074 0080 #       ST ACC, [CRC]
0008: 00C9      #       EOR IX, IX
000A: 007C 00F0 #       ST IX, [WORK]
000E: 007C 00F2 # LP1:  ST IX, [TMP]
0012: 00B9      #       ADD IX, IX
0014: 0066 0100 #       LD ACC, [IX+DATA]
0018: 006C 00F2 #       LD IX, [TMP]
001C: 0043      #       SLL ACC
001E: 0043      #       SLL ACC
0020: 0043      #       SLL ACC
0022: 0043      #       SLL ACC
0024: 0043      #       SLL ACC
0026: 0043      #       SLL ACC
0028: 0043      #       SLL ACC
002A: 0043      #       SLL ACC
002C: 00C4 0080 #       EOR ACC, [CRC]
0030: 0074 0080 #       ST ACC, [CRC]
0034: 006A 0010 #       LD IX, 16
0038: 0064 0080 # LP2:  LD ACC, [CRC]
003C: 0043      #       SLL ACC
003E: 0074 0080 #       ST ACC, [CRC]
0042: 0035 004E #       BNC SKIP
0046: 00C4 0078 #       EOR ACC, [POLY]
004A: 0074 0080 #       ST ACC, [CRC]
004E: 00AA 0002 # SKIP: SUB IX,  2
0052: 0033 0038 #       BP LP2
0056: 006C 00F0 #       LD IX, [WORK]
005A: 00BA 0001 #       ADD IX, 1
005E: 00FC 0120 #       CMP IX, [N]
0062: 007C 00F0 #       ST IX, [WORK]
0066: 0031 000E #       BNZ LP1
006A: 0064 0080 #       LD ACC, [CRC]
006E: 00C2 FFFF #       EOR ACC, FFFFH
0072: 0074 0080 #       ST ACC, [CRC]
0076: 000F      #       HLT
0078: 1021      # POLY: PROG 1021H
`

$('#select-program-id').on('change', () => {
    var programId = $('#select-program-id').val()

    if ( samplePrograms[programId] ) {
        logger.info(`Set sample program '${programId}'`)
    }
    else {
        logger.error(`Sample program '${programId}' is not found.`)
    }

    $('#inst').val( samplePrograms[programId].replace(/^\n+/, '') )
})
