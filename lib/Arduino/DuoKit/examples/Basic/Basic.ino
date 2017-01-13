/*
 The MIT License (MIT)

 Copyright © 2017 Zhi-Wei Cai. All rights reserved.

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

 Setup your device before you begin, see:

 https://github.com/x43x61x69/DuoKit

 ------------------------------------------------------------------------------

*/

//
// As Arduino does not show error messages when memory overflows, make sure you
// test your layout/object settings with ping/read command before you deploy
// your sketch.
//
#define LAYOUT_LENGTH   6
#define OBJECTS_LENGTH  3

#include <DuoKit.h>

//
// Use "duokit(SERIAL_PORT_NUM)" to initialize a DuoKit object. Simply use
// "duokit" if you don't need the serial output.
//
DuoKit duokit;

DuoUI layout[LAYOUT_LENGTH];
DuoObject objects[OBJECTS_LENGTH];

double count = 0;
int fixed = 1337;
String str = "I\'m a String!";

void setup()
{
    duokit.begin();

    //
    // Setup layout profile name.
    //
    duokit.layoutProfile = "Basic Controller";

    //
    // Setup variable pointers:
    // Format: {VAR_KEY_NAME, VAR_POINTER}
    // - VAR_KEY_NAME: A String object that will be referencing to the variable.
    // - VAR_POINTER: A memory pointer that points to the variable. (.intPtr, .doublePtr, .stringPtr)
    //
    objects[0].type         = DuoDoubleType;
    objects[0].name         = "count";
    objects[0].doublePtr    = &count;

    objects[1].type         = DuoIntType;
    objects[1].name         = "fixed";
    objects[1].intPtr       = &fixed;

    objects[2].type         = DuoStringType;
    objects[2].name         = "str";
    objects[2].stringPtr    = &str;

    //
    // Setup the DuoKit object with "duokit.setObjetcs(OBJECTS_ARRAY, OBJECTS_LENGTH)".
    // Get current UI layout via: "/arduino/ping"
    //
    duokit.setObjetcs(objects, OBJECTS_LENGTH);

    //
    // Set pre-defined layout:
    // Format: {DUO_UI_TYPE, DISPLAY_TEXT, PIN_NUM, VAR_KEY_NAME, SLIDER_MIN, SLIDER_MAX, USE_COLOR, COLOR, RELOAD_INTERVAL}
    // DUO_UI_TYPE Can be one of the followings:
    // - DuoUIWebUI: Setup UI for WebUI. PIN_NUM, VAR_KEY_NAME, SLIDER_MIN, SLIDER_MAX, USE_COLOR, COLOR and RELOAD_INTERVAL will be ignored.
    // - DuoUISwitch: Setup a switch for a pin. VAR_KEY_NAME, SLIDER_MIN and SLIDER_MAX will be ignored.
    // - DuoUIValueSetter: Setup a setter for a variable. PIN_NUM, SLIDER_MIN, SLIDER_MAX, USE_COLOR and COLOR will be ignored.
    // - DuoUIValueGetter: Setup a getter for a variable. PIN_NUM, SLIDER_MIN, SLIDER_MAX, USE_COLOR and COLOR will be ignored.
    // - DuoUISlider: Setup a slider for an analog pin or a variable. If PIN_NUM was provided, VAR_KEY_NAME will be ignored.
    //
    layout[0].type      = DuoUIWebUI;
    layout[0].name      = "Access WebUI";

    layout[1].type      = DuoUISwitch;
    layout[1].name      = "Built-in LED";
    layout[1].pin       = 13;
    layout[1].interval  = 10;

    layout[2].type      = DuoUIValueSetter;
    layout[2].name      = "This is count";
    layout[2].key       = "count";
    layout[2].interval  = 10;

    layout[3].type      = DuoUIValueSetter;
    layout[3].name      = "This is fixed";
    layout[3].key       = "fixed";
    layout[3].interval  = 10;

    layout[4].type      = DuoUISlider;
    layout[4].name      = "Slider for fixed";
    layout[4].key       = "fixed";
    layout[4].min       = 0;
    layout[4].max       = 9999;
    layout[4].interval  = 10;

    layout[5].type      = DuoUIValueSetter;
    layout[5].name      = "This is an ASCII string";
    layout[5].key       = "str";
    layout[5].interval  = 10;

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
