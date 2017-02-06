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

 Setup your device before you begin, see:

 https://github.com/x43x61x69/DuoKit

 ------------------------------------------------------------------------------

*/

//
// You should install the necessary libraries for your choice of DHT sensor and configure the settings accordingly.
//
#include "DHT.h"

#define DHT_PIN  5          // Pin of your DHT sensor.
//
// Type of your DHT sensor. 
// Uncomment only the one that you use!
//
//#define DHT_TYPE DHT11    // DHT11
//#define DHT_TYPE DHT22    // DHT22  AM2302, AM2321
//#define DHT_TYPE DHT21    // DHT21  AM2301

DHT dht(DHT_PIN, DHT_TYPE); // Initialize DHT object.

//
// We got 2 variables, one for the humidity and one for the temperature.
//
#define LAYOUT_LENGTH   2
#define OBJECTS_LENGTH  2

#include <DuoKit.h>

DuoKit duokit;

DuoUI layout[LAYOUT_LENGTH];
DuoObject objects[OBJECTS_LENGTH];

double humidity    = 0;
double temperature = 0;

void setup()
{
    //
    // Initialize the DHT sensor.
    //
    dht.begin();

    //
    // Initialize DuoKit.
    //
    duokit.begin();

    //
    // Setup layout profile name.
    //
    duokit.layoutProfile = "Humidity & Temperature";

    uint8_t i = 0;
    objects[i].type         = DuoDoubleType;
    objects[i].name         = "humidity";
    objects[i].doublePtr    = &humidity;

    objects[++i].type       = DuoDoubleType;
    objects[i].name         = "temperature";
    objects[i].doublePtr    = &temperature;

    duokit.setObjetcs(objects, OBJECTS_LENGTH);
    
    //
    // Setup layouts.
    //
    i = 0;
    layout[i].type      = DuoUIValueGetter;
    layout[i].name      = "Humidity (%)";
    layout[i].key       = "humidity";
    layout[i].interval  = 5;
    
    layout[++i].type    = DuoUIValueGetter;
    layout[i].name      = "Temperature (°C)";
    layout[i].key       = "temperature";
    layout[i].interval  = 5;
    
    duokit.setLayout(layout, LAYOUT_LENGTH);
}

void loop()
{
    duokit.loop();

    // Read values from the DHT sensor.
    float h = dht.readHumidity();
    float t = dht.readTemperature();

    // If values were not NaN, update the variables for displaying.
    if (!isnan(t) && !isnan(h))  {
      humidity    = h;
      temperature = t;
    }
}
