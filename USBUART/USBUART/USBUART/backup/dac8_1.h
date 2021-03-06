//*****************************************************************************
//*****************************************************************************
//  FILENAME: DAC8_1.h
//   Version: 2.2, Updated on 2011/3/29 at 14:30:9
//  Generated by PSoC Designer 5.1.2110.0
//
//  DESCRIPTION:  DAC8 User Module C language interface file.
//-----------------------------------------------------------------------------
//      Copyright (c) Cypress Semiconductor 2011. All Rights Reserved.
//*****************************************************************************
//*****************************************************************************
#ifndef DAC8_1_INCLUDE
#define DAC8_1_INCLUDE

#include <m8c.h>

//-------------------------------------------------
// Defines for DAC8_1 API's.
//-------------------------------------------------
// Power Setting Defines
#define DAC8_1_OFF                 0
#define DAC8_1_LOWPOWER            1
#define DAC8_1_MEDPOWER            2
#define DAC8_1_HIGHPOWER           3
#define DAC8_1_FULLPOWER           3

// Define constants for declaring function prototypes based on DataFormat parameter
#define DAC8_1_OffsetBinary            0x04
#define DAC8_1_TwosComplement          0x02
#define DAC8_1_SignAndMagnitude        0x01
#define DAC8_1_RawRegister             0x00
#define DAC8_1_DATAFORMAT          0x7
#define DAC8_1_OFFSETBINARY        DAC8_1_DATAFORMAT & DAC8_1_OffsetBinary
#define DAC8_1_TWOSCOMPLEMENT      DAC8_1_DATAFORMAT & DAC8_1_TwosComplement
#define DAC8_1_SIGNANDMAGNITUDE    DAC8_1_DATAFORMAT & DAC8_1_SignAndMagnitude

// Declare function fastcall16 pragmas
#pragma fastcall16 DAC8_1_Start
#pragma fastcall16 DAC8_1_SetPower
#pragma fastcall16 DAC8_1_Stop

//-------------------------------------------------
// Prototypes of the DAC8_1 API.
//-------------------------------------------------
extern void  DAC8_1_Start(BYTE bPowerSetting);
extern void  DAC8_1_SetPower(BYTE bPowerSetting);
extern void  DAC8_1_Stop(void);

// Declare overloaded functions based on DataForamt parameter selected
#if DAC8_1_OFFSETBINARY
   #pragma fastcall16 DAC8_1_WriteBlind
   #pragma fastcall16 DAC8_1_WriteStall
   extern void  DAC8_1_WriteBlind(BYTE bOutputValue);
   extern void  DAC8_1_WriteStall(BYTE bOutputValue);
#else
   #if DAC8_1_TWOSCOMPLEMENT
      #pragma fastcall16 DAC8_1_WriteBlind
      #pragma fastcall16 DAC8_1_WriteStall
      extern void  DAC8_1_WriteBlind(CHAR cOutputValue);
      extern void  DAC8_1_WriteStall(CHAR cOutputValue);
   #else    //DAC8_1_SIGNANDMAGNITUDE
      #pragma fastcall16 DAC8_1_WriteBlind2B
      #pragma fastcall16 DAC8_1_WriteStall2B
      extern void  DAC8_1_WriteBlind2B(BYTE bLSB, BYTE bMSB);
      extern void  DAC8_1_WriteStall2B(BYTE bLSB, BYTE bMSB);
   #endif
#endif

//-------------------------------------------------
// Hardware Register Definitions
//-------------------------------------------------

#pragma ioport  DAC8_1_LSB_CR0: 0x090                      // LSB Analog control register 0
BYTE            DAC8_1_LSB_CR0;
#pragma ioport  DAC8_1_LSB_CR1: 0x091                      // LSB Analog control register 1
BYTE            DAC8_1_LSB_CR1;
#pragma ioport  DAC8_1_LSB_CR2: 0x092                      // LSB Analog control register 2
BYTE            DAC8_1_LSB_CR2;
#pragma ioport  DAC8_1_LSB_CR3: 0x093                      // LSB Analog control register 3
BYTE            DAC8_1_LSB_CR3;

#pragma ioport  DAC8_1_MSB_CR0: 0x080                      // MSB Analog control register 0
BYTE            DAC8_1_MSB_CR0;
#pragma ioport  DAC8_1_MSB_CR1: 0x081                      // MSB Analog control register 1
BYTE            DAC8_1_MSB_CR1;
#pragma ioport  DAC8_1_MSB_CR2: 0x082                      // MSB Analog control register 2
BYTE            DAC8_1_MSB_CR2;
#pragma ioport  DAC8_1_MSB_CR3: 0x083                      // MSB Analog control register 3
BYTE            DAC8_1_MSB_CR3;

#endif
// end of file DAC8_1.h
