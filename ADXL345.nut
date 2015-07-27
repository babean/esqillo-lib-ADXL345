/*
Software License Agreement (BSD License)

Copyright (c) 2012, Adafruit Industries
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holders nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

class ADXL345
{
    i2c = null;
    reg = blob(1);
    data = blob(6);
}

/*=========================================================================
    I2C ADDRESS/BITS
    -----------------------------------------------------------------------*/
    const ADXL345_ADDRESS                 =0x53;    // Assumes ALT address pin low
/*=========================================================================*/

/*=========================================================================
    REGISTERS
    -----------------------------------------------------------------------*/
    const ADXL345_REG_DEVID               =0x00;    // Device ID
    const ADXL345_REG_THRESH_TAP          =0x1D;    // Tap threshold
    const ADXL345_REG_OFSX                =0x1E;    // X-axis offset
    const ADXL345_REG_OFSY                =0x1F;    // Y-axis offset
    const ADXL345_REG_OFSZ                =0x20;    // Z-axis offset
    const ADXL345_REG_DUR                 =0x21;    // Tap duration
    const ADXL345_REG_LATENT              =0x22;    // Tap latency
    const ADXL345_REG_WINDOW              =0x23;    // Tap window
    const ADXL345_REG_THRESH_ACT          =0x24;    // Activity threshold
    const ADXL345_REG_THRESH_INACT        =0x25;    // Inactivity threshold
    const ADXL345_REG_TIME_INACT          =0x26;    // Inactivity time
    const ADXL345_REG_ACT_INACT_CTL       =0x27;    // Axis enable control for activity and inactivity detection
    const ADXL345_REG_THRESH_FF           =0x28;    // Free-fall threshold
    const ADXL345_REG_TIME_FF             =0x29;    // Free-fall time
    const ADXL345_REG_TAP_AXES            =0x2A;    // Axis control for single/double tap
    const ADXL345_REG_ACT_TAP_STATUS      =0x2B;    // Source for single/double tap
    const ADXL345_REG_BW_RATE             =0x2C;    // Data rate and power mode control
    const ADXL345_REG_POWER_CTL           =0x2D;    // Power-saving features control
    const ADXL345_REG_INT_ENABLE          =0x2E;    // Interrupt enable control
    const ADXL345_REG_INT_MAP             =0x2F;    // Interrupt mapping control
    const ADXL345_REG_INT_SOURCE          =0x30;    // Source of interrupts
    const ADXL345_REG_DATA_FORMAT         =0x31;    // Data format control
    const ADXL345_REG_DATAX0              =0x32;    // X-axis data 0
    const ADXL345_REG_DATAX1              =0x33;    // X-axis data 1
    const ADXL345_REG_DATAY0              =0x34;    // Y-axis data 0
    const ADXL345_REG_DATAY1              =0x35;    // Y-axis data 1
    const ADXL345_REG_DATAZ0              =0x36;    // Z-axis data 0
    const ADXL345_REG_DATAZ1              =0x37;    // Z-axis data 1
    const ADXL345_REG_FIFO_CTL            =0x38;    // FIFO control
    const ADXL345_REG_FIFO_STATUS         =0x39;    // FIFO status
/*=========================================================================*/

/*=========================================================================
    REGISTERS
    -----------------------------------------------------------------------*/
    const ADXL345_MG2G_MULTIPLIER =0.004;  // 4mg per lsb
/*=========================================================================*/

function ADXL345::constructor(_i2c)
{
    i2c = _i2c;
    
    i2c.address(ADXL345_ADDRESS);

    // Make sure the ADXL345 is there
    if (i2c.read8(ADXL345_REG_DEVID) != 0xE5)
        throw("ADXL345 device not found");
    
    // Set Sensitivity ADXL345_RANGE_2_G
    i2c.write8(ADXL345_REG_DATA_FORMAT, 0x00);
    
    // Enable measurements
    i2c.write8(ADXL345_REG_POWER_CTL, 0x08);
}

function ADXL345::accel_read()
{
    local accel = {};
    reg[0] = ADXL345_REG_DATAX0;
    
    local SENSORS_GRAVITY_EARTH           = 9.80665;
    local SENSORS_GRAVITY_STANDARD        = SENSORS_GRAVITY_EARTH;
    local ADXL345_MG2G_MULTIPLIER         = 0.0039;  // 4mg per lsb
    
    i2c.address(ADXL345_ADDRESS);
    i2c.xfer(reg, data);
    data.seek(0);
    accel.x <- (data.readn('s') * ADXL345_MG2G_MULTIPLIER*SENSORS_GRAVITY_STANDARD);
    accel.y <- (data.readn('s') * ADXL345_MG2G_MULTIPLIER*SENSORS_GRAVITY_STANDARD);
    accel.z <- -(data.readn('s') * ADXL345_MG2G_MULTIPLIER*SENSORS_GRAVITY_STANDARD);

    return accel;
}