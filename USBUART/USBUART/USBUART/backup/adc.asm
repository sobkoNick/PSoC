;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME: ADC.asm
;;   Version: 1.1, Updated on 2011/3/29 at 14:28:42
;;  Generated by PSoC Designer 5.1.2110.0
;;
;;  DESCRIPTION: Assembler source for the ADCINC A/D Converter
;;               User Module with 1st-order modulator.
;;
;;  NOTE: User Module APIs conform to the fastcall16 convention for marshalling
;;        arguments and observe the associated "Registers are volatile" policy.
;;        This means it is the caller's responsibility to preserve any values
;;        in the X and A registers that are still needed after the API
;;        function returns. Even though these registers may be preserved now,
;;        there is no guarantee they will be preserved in future releases.
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2011. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************

include "m8c.inc"
include "memory.inc"

include "ADC.inc"


;-----------------------------------------------
;  Global Symbols
;-----------------------------------------------
export  ADC_Start
export _ADC_Start
export  ADC_SetPower
export _ADC_SetPower
export  ADC_Stop
export _ADC_Stop
export  ADC_GetSamples
export _ADC_GetSamples
export  ADC_StopADC
export _ADC_StopADC
export  ADC_fIsDataAvailable
export _ADC_fIsDataAvailable
export  ADC_iClearFlagGetData
export _ADC_iClearFlagGetData
export  ADC_wClearFlagGetData
export _ADC_wClearFlagGetData
export  ADC_cClearFlagGetData
export _ADC_cClearFlagGetData
export  ADC_bClearFlagGetData
export _ADC_bClearFlagGetData
export  ADC_iGetData
export _ADC_iGetData
export  ADC_wGetData
export _ADC_wGetData
export  ADC_bGetData
export _ADC_bGetData
export  ADC_cGetData
export _ADC_cGetData
export  ADC_fClearFlag
export _ADC_fClearFlag
export  ADC_WritePulseWidth
export _ADC_WritePulseWidth


AREA bss (RAM,REL)

;-----------------------------------------------
;  Constant Definitions
;-----------------------------------------------

;-----------------------------------------------
; Variable Allocation
;-----------------------------------------------


AREA UserModules (ROM, REL)

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: ADC_Start
;
;  DESCRIPTION: Applies power setting to the module's analog PSoc block.
;               and starts the PWM
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    The A register contains the power setting.
;  RETURNS:      Nothing.
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 ADC_Start:
_ADC_Start:
   RAM_PROLOGUE RAM_USE_CLASS_1
   call  ADC_SetPower
   ADC_RESET_INTEGRATOR_M
   mov   reg[ADC_PWMdr1],ffh
   or    reg[ADC_PWMcr0],01h                         ; start PWM
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret
.ENDSECTION

   
.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: ADC_SetPower
;
;  DESCRIPTION: Applies power setting to the module's analog PSoc block.
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    The A register contains the power setting.
;  RETURNS:      Nothing.
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 ADC_SetPower:
_ADC_SetPower:
   RAM_PROLOGUE RAM_USE_CLASS_2
   mov  X,SP                                     ; Set up Stack frame
   and  A,03h                                    ; Ensure value is legal
   push A
   mov  A,reg[ADC_AtoDcr3]                       ; First SC block:
   and  A,~03h                                   ;   clear power bits to zero
   or   A,[ X ]                                  ;   establish new value
   mov  reg[ADC_AtoDcr3],A                       ;   change the actual setting
   pop  A
   RAM_EPILOGUE RAM_USE_CLASS_2
   ret
.ENDSECTION

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: ADC_Stop
;
;  DESCRIPTION:   Removes power from the module's analog PSoc block.
;                 and turns off PWM
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:     None.
;  RETURNS:       Nothing.
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 ADC_Stop:
_ADC_Stop:
   RAM_PROLOGUE RAM_USE_CLASS_1
   ADC_STOPADC_M
   and  reg[ADC_AtoDcr3], ~03h
   and  reg[ADC_PWMcr0], ~01h ; stop PWM
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret
.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: ADC_GetSamples
;
;  DESCRIPTION: Activates interrupts for this user module and begins sampling.
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    A register contain number of samples
;  RETURNS:      Nothing.
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;          
;    Currently only the page pointer registers listed below are modified: 
;          CUR_PP
;
 ADC_GetSamples:
_ADC_GetSamples:
   RAM_PROLOGUE RAM_USE_CLASS_4
   RAM_SETPAGE_CUR >ADC_fMode
   ADC_ENABLE_INTEGRATOR_M
   mov [ADC_fMode],0
   mov [ADC_bState],0
   mov [ADC_bNumSamples],A
   mov A, reg[ADC_PWMdr2]
   jnz  .SkipPulseWrite
   mov reg[ADC_PWMdr2], 1
.SkipPulseWrite:

   M8C_SetBank1
   and reg[E7h], 3Fh             ; if we are in 29xxx or 24x94   
   or  reg[E7h], 40h             ; then set to incremental Mode
   M8C_SetBank0

   ADC_STARTADC_M  ;enable interrupt 
   RAM_EPILOGUE RAM_USE_CLASS_4 
   ret
.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: ADC_StopADC
;
;  DESCRIPTION: Shuts down the A/D is an orderly manner.  The interrupt
;               is disabled but the PWM output is still active.
;               Integrator is reset
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None.
;  RETURNS:      Nothing.
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 ADC_StopADC:
_ADC_StopADC:
   RAM_PROLOGUE RAM_USE_CLASS_1
   M8C_SetBank1
   and reg[E7h], 3Fh             ; if we are in 29xxx or 24x94   
   or  reg[E7h], 80h             ; then set to incremental Mode
   M8C_SetBank0
   ADC_STOPADC_M
   ADC_RESET_INTEGRATOR_M
   RAM_EPILOGUE RAM_USE_CLASS_1 
   ret
.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: ADC_fIsDataAvailable
;
;  DESCRIPTION: Returns the status of the A/D Data
;-----------------------------------------------------------------------------
;  ARGUMENTS:    None.
;  RETURNS:      fastcall BOOL DataAvailable returned in the A register
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;          
;    Currently only the page pointer registers listed below are modified: 
;          CUR_PP
;
 ADC_fIsDataAvailable:
_ADC_fIsDataAvailable:
   RAM_PROLOGUE RAM_USE_CLASS_4
   ADC_fIsDataAvailable_M   
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret
.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME:  ADC_iClearFlagGetData
;                  ADC_wClearFlagGetData
;
;  DESCRIPTION:    Clears the fStatus and places ADC data in iResult A/D.
;                  Flag is checked after trandfer to insure valid data.
;                  available. Also clears the DATA_READY flag. 
;-----------------------------------------------------------------------------
;  ARGUMENTS:    None.
;  RETURNS:      fastcall int iResult returned in the X and A register
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;          
;    Currently only the page pointer registers listed below are modified: 
;          CUR_PP
;
 ADC_iClearFlagGetData:
_ADC_iClearFlagGetData:
 ADC_wClearFlagGetData:
_ADC_wClearFlagGetData:
   RAM_PROLOGUE RAM_USE_CLASS_4
   ADC_iClearFlagGetData_M   
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret
.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME:  ADC_cClearFlagGetData
;                  ADC_bClearFlagGetData
;
;  DESCRIPTION:    Clears the fStatus and places ADC data in iResult A/D.
;-----------------------------------------------------------------------------
;  ARGUMENTS:    None.
;  RETURNS:      fastcall int iResult returned in the X and A register
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;          
;    Currently only the page pointer registers listed below are modified: 
;          CUR_PP
;
 ADC_cClearFlagGetData:
_ADC_cClearFlagGetData:
 ADC_bClearFlagGetData:
_ADC_bClearFlagGetData:
   RAM_PROLOGUE RAM_USE_CLASS_4
   ADC_bClearFlagGetData_M     
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret
.ENDSECTION
.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME:  ADC_iGetData
;				   ADC_wGetData
;
;  DESCRIPTION:     Returns the data from the A/D.  Does not check if data is
;                   available.
;-----------------------------------------------------------------------------
;  ARGUMENTS:    None.
;  RETURNS:      fastcall int iResult is returned in the X,A registers
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;          
;    Currently only the page pointer registers listed below are modified: 
;          CUR_PP
;
 ADC_iGetData:
_ADC_iGetData:
 ADC_wGetData:
_ADC_wGetData:
   RAM_PROLOGUE RAM_USE_CLASS_4
   ADC_wGetData_M          
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret
.ENDSECTION
.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME:  ADC_bGetData
;                  ADC_cGetData
;
;  DESCRIPTION:     Returns the data from the A/D.  Does not check if data is
;                   available.
;-----------------------------------------------------------------------------
;  ARGUMENTS:    None.
;  RETURNS:      fastcall CHAR cData returned in the A register
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;          
;    Currently only the page pointer registers listed below are modified: 
;          CUR_PP
;
 ADC_bGetData:
_ADC_bGetData:
 ADC_cGetData:
_ADC_cGetData:
   RAM_PROLOGUE RAM_USE_CLASS_4
   ADC_cGetData_M        
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret
.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: ADC_fClearFlag
;
;  DESCRIPTION: Clears the data ready flag.
;-----------------------------------------------------------------------------
;  ARGUMENTS:    None.
;  RETURNS:      Nothing.
;  SIDE EFFECTS: 
;    The DATA_READY flag is cleared.
;    
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;          
;    Currently only the page pointer registers listed below are modified: 
;          CUR_PP
;
 ADC_fClearFlag:
_ADC_fClearFlag:
   RAM_PROLOGUE RAM_USE_CLASS_4
   ADC_fClearFlag_M    
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret
.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: ADC_WritePulseWidth
;
;  DESCRIPTION:
;     Write the 8-bit period value into the compare register (DR2).
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: fastcall BYTE bPeriodValue (passed in A)
;  RETURNS:   Nothing
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 ADC_WritePulseWidth:
_ADC_WritePulseWidth:
   RAM_PROLOGUE RAM_USE_CLASS_1
   ADC_WritePulseWidth_M  
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret
.ENDSECTION

; End of File ADC.asm
