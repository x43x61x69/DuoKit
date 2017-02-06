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
// Comment this out if you have a common cathode RGB LED.
//
#define RGBCommonAnode

#define LAYOUT_LENGTH   5
#define OBJECTS_LENGTH  3

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
DuoObject objects[OBJECTS_LENGTH];

double r = 0;
double g = 0;
double b = 0;

uint8_t _r = 0;
uint8_t _g = 0;
uint8_t _b = 0;

void setup()
{
    //
    // Initialize with a random color.
    //
    randomSeed(analogRead(0));
    r = _r = random(LED_MAX);
    g = _g = random(LED_MAX);
    b = _b = random(LED_MAX);

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
    analogWrite(RED_PIN,    _r);
    analogWrite(GREEN_PIN,  _g);
    analogWrite(BLUE_PIN,   _b);

    //
    // Setup layout profile name.
    //
    duokit.layoutProfile = "RGB LED Contorller";

    //
    // Setup object pointers.
    //
    uint8_t i = 0;
    objects[i].type         = DuoDoubleType;
    objects[i].name         = "r";
    objects[i].doublePtr    = &r;

    objects[++i].type       = DuoDoubleType;
    objects[i].name         = "g";
    objects[i].doublePtr    = &g;

    objects[++i].type       = DuoDoubleType;
    objects[i].name         = "b";
    objects[i].doublePtr    = &b;


    duokit.setObjetcs(objects, OBJECTS_LENGTH);

    //
    // Setup layouts.
    //
    i = 0;
    layout[i].type      = DuoUIWebUI;
    layout[i].name      = "Access WebUI";

    layout[++i].type    = DuoUISwitch;
    layout[i].name      = "Built-in LED";
    layout[i].pin       = 13;
    layout[i].interval  = 10;

    layout[++i].type    = DuoUISlider;
    layout[i].name      = "Red";
    layout[i].key       = "r";
    layout[i].min       = 0;
    layout[i].max       = LED_MAX;
    layout[i].useColor  = true;
    layout[i].color     = 0xFF3B30;
    layout[i].interval  = 10;

    layout[++i].type    = DuoUISlider;
    layout[i].name      = "Green";
    layout[i].key       = "g";
    layout[i].min       = 0;
    layout[i].max       = LED_MAX;
    layout[i].useColor  = true;
    layout[i].color     = 0x0BD318;
    layout[i].interval  = 10;

    layout[++i].type    = DuoUISlider;
    layout[i].name      = "Blue";
    layout[i].key       = "b";
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

    //
    // Transition r, g, b values to user selection.
    // Use "CommonCathodeRGB()" if you have a common cathode LED.
    //
    ledTransition(RED_PIN,   &_r,  RBGLED(r));
    ledTransition(GREEN_PIN, &_g,  RBGLED(g));
    ledTransition(BLUE_PIN,  &_b,  RBGLED(b));
}

void ledTransition(const uint8_t pin, uint8_t *current, const uint8_t value)
{
    if (*current > value) {
        *current -= 1;
    } else if (*current < value) {
        *current += 1;
    } else {
      return;
    }
    analogWrite(pin, *current);
}
