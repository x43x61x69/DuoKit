/*
 The MIT License (MIT)

 Copyright © 2017 MediaTek Inc. All rights reserved.

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

DuoKit duokit;

DuoUI layout[LAYOUT_LENGTH];
DuoObject objects[OBJECTS_LENGTH];

double count = 0;
int fixed = 1337;
String boot = "0 secs ago.";

void setup()
{
    duokit.begin();

    //
    // Setup layout profile name.
    //
    duokit.layoutProfile = "Basic Controller";

    //
    // Setup variable pointers:
    // Format: {VAR_TYPE, VAR_KEY_NAME, VAR_POINTER}
    // - VAR_TYPE:      A DuoObjectType that consists with the variable. (DuoIntType, DuoDoubleType, DuoStringType)
    // - VAR_KEY_NAME:  A String object that will be referencing to the variable.
    // - VAR_POINTER:   A memory pointer that points to the variable. (.intPtr, .doublePtr, .stringPtr)
    //

    uint8_t i = 0;
    objects[i].type         = DuoDoubleType;
    objects[i].name         = "count";
    objects[i].doublePtr    = &count;

    objects[++i].type       = DuoIntType;
    objects[i].name         = "fixed";
    objects[i].intPtr       = &fixed;

    objects[++i].type       = DuoStringType;
    objects[i].name         = "boot";
    objects[i].stringPtr    = &boot;

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

    i = 0;
    layout[i].type      = DuoUIWebUI;
    layout[i].name      = "Access WebUI";

    layout[++i].type    = DuoUISwitch;
    layout[i].name      = "Built-in LED";
    layout[i].pin       = LED_BUILTIN;
    layout[i].interval  = 10;

    //
    // Although String is supported, it's not recommanded as this might cause problems.
    //
    layout[++i].type    = DuoUIValueGetter;
    layout[i].name      = "Program started";
    layout[i].key       = "boot";
    layout[i].interval  = 5;

    layout[++i].type    = DuoUIValueSetter;
    layout[i].name      = "This is count";
    layout[i].key       = "count";
    layout[i].interval  = 10;

    layout[++i].type    = DuoUIValueSetter;
    layout[i].name      = "This is fixed";
    layout[i].key       = "fixed";
    layout[i].interval  = 10;

    layout[++i].type    = DuoUISlider;
    layout[i].name      = "Slider for fixed";
    layout[i].key       = "fixed";
    layout[i].min       = 0;
    layout[i].max       = 9999;
    layout[i].interval  = 10;

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

    //
    // Update the variable "str".
    //
    boot = String(millis()/1000, DEC) + " secs ago.";
}
