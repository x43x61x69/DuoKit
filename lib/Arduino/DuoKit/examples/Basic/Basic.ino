/*
 The MIT License (MIT)

 Copyright © 2017 Zhi-Wei Cai (MediaTek Inc.). All rights reserved.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 ------------------------------------------------------------------------------

 For LinkIt 7688 Duo:

 Enable Yun Bridge on your LinkIt 7688 Duo before use this example:
 uci set yunbridge.config.disabled='0' && uci commit && reboot

 ------------------------------------------------------------------------------

 For Arduino Yun:

 Set REST API Access to "Open" on your Arduino Yun before use this example.

 ------------------------------------------------------------------------------

*/

//
// As Arduino does not show error messages when memory overflows, make sure you
// test your layout/object settings with ping/read command before you deploy
// your sketch.
//
#define LAYOUT_LENGTH   5
#define OBJECTS_LENGTH  2

#include <DuoKit.h>

//
// Use "duokit(SERIAL_PORT_NUM)" to initialize a DuoKit object. Simply use
// "duokit()" if you don't need the serial output.
//
DuoKit duokit(9600);

DuoUI layout[LAYOUT_LENGTH];
DuoObject objects[OBJECTS_LENGTH];

double count = 0;
double fixed = 1337;

void setup()
{
    duokit.begin();

    //
    // Setup variable pointers:
    // Format: {VAR_KEY_NAME, VAR_POINTER}
    // - VAR_KEY_NAME: A String object that will be referencing to the variable.
    // - VAR_POINTER: A memory pointer that points to the variable (as double).
    //
    objects[0] = {"count", &count};
    objects[1] = {"fixed", &fixed};

    //
    // Setup the DuoKit object with "duokit.setObjetcs(OBJECTS_ARRAY, OBJECTS_LENGTH)".
    // Get current UI layout via: "/arduino/ping"
    //
    duokit.setObjetcs(objects, OBJECTS_LENGTH);

    //
    // Set pre-defined layout:
    // Format: {DUO_UI_TYPE, DISPLAY_TEXT, PIN_NUM, VAR_KEY_NAME, SLIDER_MIN, SLIDER_MAX, RELOAD_INTERVAL}
    // DUO_UI_TYPE Can be one of the followings:
    // - DuoUIWebUI: Setup UI for WebUI. PIN_NUM, VAR_KEY_NAME, SLIDER_MIN, SLIDER_MAX and RELOAD_INTERVAL will be ignored.
    // - DuoUISwitch: Setup a switch for a pin. VAR_KEY_NAME, SLIDER_MIN and SLIDER_MAX will be ignored.
    // - DuoUIValueSetter: Setup a setter for a variable. PIN_NUM, SLIDER_MIN and SLIDER_MAX will be ignored.
    // - DuoUIValueGetter: Setup a getter for a variable. PIN_NUM, SLIDER_MIN and SLIDER_MAX will be ignored.
    // - DuoUISlider: Setup a slider for a variable. PIN_NUM will be ignored.
    //
    layout[0] = {DuoUIWebUI,        "Access WebUI",     0,   "",        0,  0,      0};
    layout[1] = {DuoUISwitch,       "Built-in LED",     13,  "",        0,  0,      10};
    layout[2] = {DuoUIValueSetter,  "This is count",    0,   "count",   0,  0,      10};
    layout[3] = {DuoUIValueGetter,  "This is fixed",    0,   "fixed",   0,  0,      10};
    layout[4] = {DuoUISlider,       "Slider for fixed", 0,   "fixed",   0,  9999,   10};

    //
    // Setup the DuoKit layout with "duokit.setLayout(LAYOUT_ARRAY, LAYOUT_LENGTH)".
    // Read current value via: "/arduino/read/count".
    // Update current value via: "/arduino/update/count/NEW_VALUE" (up to 2 decimal places).
    //
    duokit.setLayout(layout, LAYOUT_LENGTH);
}

void loop()
{
    //
    // Setup a loop for DuoKit to listen for REST API commands.
    //
    duokit.loop();

    //
    // Update the variable "count" to see the changes via "read" command.
    //
    count += 0.01;
}
