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

#define LAYOUT_LENGTH   5
#define OBJECTS_LENGTH  3

#define LED_MAX     0xFF
#define CommonAnodeRGB(value)   LED_MAX - int(value)
#define CommonCathodeRGB(value) int(value)

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
    objects[0] = {"r", &r};
    objects[1] = {"g", &g};
    objects[2] = {"b", &b};
    duokit.setObjetcs(objects, OBJECTS_LENGTH);

    //
    // Setup layouts.
    //
    layout[0] = {DuoUIWebUI,        "Access WebUI",     0,   "",        0,  0,          false,  0,          0};
    layout[1] = {DuoUISwitch,       "Built-in LED",     13,  "",        0,  0,          true,   0xFF5B37,   10};
    layout[2] = {DuoUISlider,       "Red",              0,   "r",       0,  LED_MAX,    true,   0xFF3B30,   10};
    layout[3] = {DuoUISlider,       "Green",            0,   "g",       0,  LED_MAX,    true,   0x0BD318,   10};
    layout[4] = {DuoUISlider,       "Blue",             0,   "b",       0,  LED_MAX,    true,   0x1D62F0,   10};
    duokit.setLayout(layout, LAYOUT_LENGTH);
}

void loop()
{
    duokit.loop();

    //
    // Transition r, g, b values to user selection.
    // Use "CommonCathodeRGB()" if you have a common cathode LED.
    //
    ledTransition(RED_PIN,   &_r,  CommonAnodeRGB(r));
    ledTransition(GREEN_PIN, &_g,  CommonAnodeRGB(g));
    ledTransition(BLUE_PIN,  &_b,  CommonAnodeRGB(b));
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
