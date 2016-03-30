/*******************************************************************************
* File Name: Main.c
* Version 1.0
*
* Description:
* This file contains the main function for the USBUART example project for CY3214 PSoCEvalUSB Kit.
*
* Note:
*
********************************************************************************
* Copyright (2011), Cypress Semiconductor Corporation. All rights reserved.
********************************************************************************
* This software is owned by Cypress Semiconductor Corporation (Cypress) and is
* protected by and subject to worldwide patent protection (United States and
* foreign),United States copyright laws and international treaty provisions. 
* Cypress hereby grants to licensee a personal, non-exclusive, non-transferable
* license to copy, use, modify, create derivative works of, and compile the
* Cypress Source Code and derivative works for the sole purpose of creating 
* custom software in support of licensee product to be used only in conjunction
* with a Cypress integrated circuit as specified in the applicable agreement.
* Any reproduction, modification, translation, compilation, or representation of
* this software except as specified above is prohibited without the express
* written permission of Cypress.
*
* Disclaimer: CYPRESS MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, WITH
* REGARD TO THIS MATERIAL, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
* Cypress reserves the right to make changes without further notice to the
* materials described herein. Cypress does not assume any liability arising out
* of the application or use of any product or circuit described herein. Cypress 
* does not authorize its products for use as critical components in life-support
* systems where a malfunction or failure may reasonably be expected to result in 
* significant injury to the user. The inclusion of Cypress' product in a life-
* support systems application implies that the manufacturer assumes all risk of
* such use and in doing so indemnifies Cypress against all charges. Use may be
* limited by and subject to the applicable Cypress software license agreement. 
*******************************************************************************/

/*************************************************************************************
                                THEORY OF OPERATION
* This project demonstrates the use of USBUART user module using CY3214 PSoCEvalUSB Board.
* The USBUART user module is used to create a virtual RS232 port on PC using a USB port.
* The USBUART modules enumerates as a Comm Port device and data to and fro from the USb device is handled as a RS232 device data.

* This application demonstrates a simple data echo example. The data received from is transmitted back again.
* The application starts by executing "boot.asm". "boot.asm" does the
* hardware initialization and invokes the "main" function.  The "main"
* function completes the initialization of USBUART Module
* After initialization of the User Modules, the "main" enters into a loop
* which does the following:
*     -Checks if any data is received by looking at the count of received data
*     -Waits for transmit to be ready
*	  -the received data is transmitted back.
*     - Incase of reception of a Carraige Return, tha API to send CRLF is called.

* Hardware Connections
* Connect a USB cable from the board to a free USB port on PC
* On connecting for first time, wait for device to get installed.
* Ignore the Digital Signature warning when prompted. (Click on 'Continue Anyway')
* Check the Device Manager for the comm port number alloted for USBUART device
* Open Hyperterminal and connect to the required comm port
* Set the comm port settings as follows: 19200-N-8-1. FlowControl: None
* Now type any character and see the data being echoed back on the hyper terminal screen
* Note: By default, the local echo ing of characters is disabled in Hyperterminal.
*************************************************************************************/


#include <m8c.h>        /* part specific constants and macros */
#include "PSoCAPI.h"    /* PSoC API definitions for all User Modules */
#include <stdlib.h>

#define USB_STR_SIZE 		(3)

#define PERIOD  			(10)				// one measure period time
#define START_TEST_PERIOD 	(50000)				// delay before start measurement

#define DAC_VAL				(155)
#define PERCENTEG			(20)       			// shparyvatist
#define ANALOG_OFSET		(5)
#define ANALOG_SIZE  		(95+ANALOG_OFSET)

BYTE analog[ANALOG_SIZE];
BYTE measure_analog[ANALOG_SIZE];

char pTemp[USB_STR_SIZE] = "";

void load_analog_data(void)
{
	BYTE i;
	for (i=0; i<ANALOG_SIZE; i++)
	{
		if ((i>ANALOG_OFSET)&&(i<ANALOG_OFSET+PERCENTEG))
		{
			analog[i] = DAC_VAL;
		}
		else
		{
			analog[i] = 0;
		}
	}
}

void delay(int count)
{
	int i;
	for (i=count; i; i--)		// 10000 = Delay about 0.1 seccond
	{
		asm("nop");
	}
}

void clear_pTemp(void)
{
	BYTE i;
	for (i=0; i<USB_STR_SIZE; i++)
	{
		if (pTemp[i]==0)
		{
			pTemp[i] = 0x20;
		}
	}
}

void main(void)
{
	BYTE i;
	BYTE index=0;
	BYTE current_adc_data;
	M8C_EnableGInt; 							/* Enable Global Interrupts */
	USBUART_1_Start(USBUART_1_5V_OPERATION); 	/*Start USBUART 5V operation */
	while(!USBUART_1_Init()); 					/* Wait for Device to initialize */
	for (i=20; i; i--)
	{
		delay(START_TEST_PERIOD);
	}
	USBUART_1_CPutString("Start Test");
	USBUART_1_PutCRLF();
	DAC8_1_Start(DAC8_1_HIGHPOWER);        		/* start the DAC8_1  */
	DAC8_1_WriteBlind(0);
	ADC_Start(ADC_HIGHPOWER);
	ADC_GetSamples(0);
	delay(START_TEST_PERIOD);
	// Start measurement
	load_analog_data();
	for (index=0; index<ANALOG_SIZE; index++)
	{
		DAC8_1_WriteBlind(analog[index]);
		delay(PERIOD);
		while(ADC_fIsDataAvailable() == 0);   	// Loop until value ready 
		current_adc_data = ADC_bClearFlagGetData();
		measure_analog[index] = current_adc_data;
	}
	//Send measured data
	USBUART_1_CPutString("i,  input,  output");
	USBUART_1_PutCRLF();
	for (index=0; index<ANALOG_SIZE; index++)
	{
		ltoa(pTemp, index, 10);
		clear_pTemp();
		USBUART_1_Write(pTemp, USB_STR_SIZE); /* Else, send back the received data */
		USBUART_1_CPutString(",  ");
		ltoa(pTemp, analog[index], 10);
		clear_pTemp();
		USBUART_1_Write(pTemp, USB_STR_SIZE); /* Else, send back the received data */
		USBUART_1_CPutString(",  ");
		ltoa(pTemp, measure_analog[index], 10);
		clear_pTemp();
		USBUART_1_Write(pTemp, USB_STR_SIZE); /* Else, send back the received data */
		USBUART_1_PutCRLF();
	}
	USBUART_1_CPutString("End of Test");		
	while(1)
	{
		// End
	}
}

