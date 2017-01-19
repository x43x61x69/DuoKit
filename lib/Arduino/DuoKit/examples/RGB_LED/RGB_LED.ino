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
// Comment this out if you have a common cathode RGB LED.
//
#define RGBCommonAnode

#define LAYOUT_LENGTH   5

#define LED_MAX     0xFF
#define CommonAnodeRGB(value)   LED_MAX - int(value)
#define CommonCathodeRGB(value) int(value)

#ifdef RGBCommonAnode
#define RBGLED(value) CommonAnodeRGB(value)
#else
#define RBGLED(value) CommonCathodeRGB(value)
#endif

#define LED_OFF     LED_MAX
#define RED_PIN     9
#define BLUE_PIN    10
#define GREEN_PIN   11

#include <DuoKit.h>

DuoKit duokit;

DuoUI layout[LAYOUT_LENGTH];

void setup()
{
    //
    // Turn off RGB LED color.
    //
    analogWrite(RED_PIN,    LED_OFF);
    analogWrite(GREEN_PIN,  LED_OFF);
    analogWrite(BLUE_PIN,   LED_OFF);

    //
    // Initialize LED module.
    //
    pinMode(RED_PIN,    OUTPUT);
    pinMode(BLUE_PIN,   OUTPUT);
    pinMode(GREEN_PIN,  OUTPUT);

    //
    // Initialize DuoKit.
    //
    duokit.begin();

    //
    // Change RGB LED color.
    //
    randomSeed(analogRead(0));
    analogWrite(RED_PIN,    random(LED_MAX));
    analogWrite(GREEN_PIN,  random(LED_MAX));
    analogWrite(BLUE_PIN,   random(LED_MAX));

    //
    // Setup layout profile name.
    //
    duokit.layoutProfile = "RGB LED Contorller";

    //
    // Setup layouts.
    //
    uint8_t i = 0;
    layout[i].type      = DuoUIWebUI;
    layout[i].name      = "Access WebUI";

    layout[++i].type    = DuoUISlider;
    layout[i].name      = "Red";
    layout[i].pin       = RED_PIN;
    layout[i].min       = 0;
    layout[i].max       = LED_MAX;
    layout[i].useColor  = true;
    layout[i].color     = 0xFF3B30;
    layout[i].interval  = 10;

    layout[++i].type    = DuoUISlider;
    layout[i].name      = "Green";
    layout[i].pin       = GREEN_PIN;
    layout[i].min       = 0;
    layout[i].max       = LED_MAX;
    layout[i].useColor  = true;
    layout[i].color     = 0x0BD318;
    layout[i].interval  = 10;

    layout[++i].type    = DuoUISlider;
    layout[i].name      = "Blue";
    layout[i].pin       = BLUE_PIN;
    layout[i].min       = 0;
    layout[i].max       = LED_MAX;
    layout[i].useColor  = true;
    layout[i].color     = 0x1D62F0;
    layout[i].interval  = 10;

    duokit.setLayout(layout, LAYOUT_LENGTH);
}

void loop()
{
    duokit.loop();
}
