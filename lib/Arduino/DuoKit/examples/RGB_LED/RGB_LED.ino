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

#define LED_OFF     0xFF
#define GREEN_PIN   9
#define BLUE_PIN    10
#define RED_PIN     11

#include <DuoKit.h>

DuoKit duokit;

DuoUI layout[LAYOUT_LENGTH];
DuoObject objects[OBJECTS_LENGTH];

double r = 0;
double g = 0;
double b = 0;

void setup()
{
    pinMode(RED_PIN,    OUTPUT);
    pinMode(BLUE_PIN,   OUTPUT);
    pinMode(GREEN_PIN,  OUTPUT);

    //
    // Turn RGB LED Module off.
    //
    analogWrite(RED_PIN,    LED_OFF);
    analogWrite(GREEN_PIN,  LED_OFF);
    analogWrite(BLUE_PIN,   LED_OFF);

    //
    // Initialize with a random color.
    //
    randomSeed(analogRead(0));
    r = random(LED_OFF);
    g = random(LED_OFF);
    b = random(LED_OFF);

    //
    // Initialize DuoKit.
    //
    duokit.begin();

    objects[0] = {"r", &r};
    objects[1] = {"g", &g};
    objects[2] = {"b", &b};
    duokit.setObjetcs(objects, OBJECTS_LENGTH);

    layout[0] = {DuoUIWebUI,        "Access WebUI",     0,   "",        0,  0,      0};
    layout[1] = {DuoUISwitch,       "Built-in LED",     13,  "",        0,  0,      10};
    layout[2] = {DuoUISlider,       "LED - Red",        0,   "r",       0,  255,    10};
    layout[3] = {DuoUISlider,       "LED - Green",      0,   "g",       0,  255,    10};
    layout[4] = {DuoUISlider,       "LED - Blue",       0,   "b",       0,  255,    10};
    duokit.setLayout(layout, LAYOUT_LENGTH);
}

void loop()
{
    duokit.loop();

    ledWrite(RED_PIN,    int(r));
    ledWrite(GREEN_PIN,  int(g));
    ledWrite(BLUE_PIN,   int(b));

    delay(3);
}

void ledWrite(const uint8_t pin, const uint8_t value)
{
    uint8_t current = analogRead(pin);
    if (current > value) {
        analogWrite(pin, --current);
    } else if (current < value) {
        analogWrite(pin, ++current);
    }
}
