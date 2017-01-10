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

#define LAYOUT_LENGTH   5
#define OBJECTS_LENGTH  3

#include <DuoKit.h>

DuoKit duokit();

DuoUI layout[LAYOUT_LENGTH];
DuoObject objects[OBJECTS_LENGTH];

double r = 0;
double g = 0;
double b = 0;

void setup()
{
    duokit.begin();

    objects[0] = {"r", &r};
    objects[0] = {"g", &g};
    objects[0] = {"b", &b};
    duokit.setObjetcs(objects, OBJECTS_LENGTH);

    layout[0] = {DuoUIWebUI,        "Access WebUI",     0,   "",        0,  0,      0};
    layout[1] = {DuoUISwitch,       "Built-in LED",     13,  "",        0,  0,      10};
    layout[2] = {DuoUISlider,       "Red",              0,   "r",       0,  255,    10};
    layout[3] = {DuoUISlider,       "Green",            0,   "g",       0,  255,    10};
    layout[4] = {DuoUISlider,       "Blue",             0,   "b",       0,  255,    10};
    duokit.setLayout(layout, LAYOUT_LENGTH);
}

void loop()
{
    duokit.loop();
}
