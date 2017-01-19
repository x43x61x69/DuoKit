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
// We got one LED to control.
//
#define LAYOUT_LENGTH 1

#include <DuoKit.h>
DuoKit duokit;
DuoUI layout[LAYOUT_LENGTH];

void setup()
{
    //
    // Turn off LED.
    //
    digitalWrite(LED_BUILTIN, LOW);

    //
    // Initialize LED mode.
    //
    pinMode(LED_BUILTIN, OUTPUT);

    //
    // Initialize DuoKit.
    //
    duokit.begin();

    //
    // Setup layout profile name.
    //
    duokit.layoutProfile = "LED Contorller";

    //
    // Setup layouts.
    //
    layout[0].type      = DuoUISwitch;
    layout[0].name      = "LED";
    layout[0].pin       = LED_BUILTIN;
    layout[0].interval  = 10;
    duokit.setLayout(layout, LAYOUT_LENGTH);
}

void loop()
{
    duokit.loop();
}
