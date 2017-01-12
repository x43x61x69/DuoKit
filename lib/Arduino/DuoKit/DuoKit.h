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
 */

#ifndef DUOKIT_H
#define DUOKIT_H

#define DUOKIT_VERSION          "1.0.3"
#define DUOKIT_API_VERSION      2
#define DUOKIT_INPUT            0x0
#define DUOKIT_OUTPUT           0x1
#define DUOKIT_INPUT_PULLUP     0x2

#include <Arduino.h>
#include <BridgeServer.h>

typedef uint8_t DuoPin;

typedef enum : uint8_t
{
    DuoUIWebUI          = 0x1,
    DuoUISwitch         = 0x2,
    DuoUIValueSetter    = 0x3,
    DuoUIValueGetter    = 0x4,
    DuoUISlider         = 0x5
} DuoUIType;

typedef struct __attribute__((packed))
{
    String name;
    double *value;
} DuoObject;

typedef struct __attribute__((packed))
{
    DuoUIType   type;
    String      name;
    DuoPin      pin;
    String      key;
    double      min;
    double      max;
    bool        useColor;
    uint32_t    color;
    double      interval;
} DuoUI;

class DuoKit
{
public:
    String layoutProfile;
    BridgeServer server;
    DuoKit(uint32_t serialPort = 0, bool indicator = false);
    void begin(bool shouldWaitForSerial = false);
    void loop();
    void blink(const int blinks);
    void setLayout(DuoUI *layout, const int size);
    void setObjetcs(DuoObject *objects, const int size);
    bool valueForKey(double *value, const String &key);
    bool setValueForKey(double *value, const String &key);
    bool updateValueForKey(double value, const String &key);
    bool removeValueForKey(const String &key);
private:
    bool _indicator;
    uint32_t _serialPort;
    DuoUI *_layout;
    DuoObject *_objects;
    int _objectsSize;
    int _layoutSize;

    void LOG(const String &message);
    int pinModeRead(const uint8_t pin);

    String keyPair(const String &key, const String &value, bool isString = true);
    String JSONFormat(const String &keyPairs);
    String JSONStatus(const bool status, const String &keyPairs = "");
    String digitalPinStatus(const uint8_t pin);
    String analogPinStatus(const uint8_t pin);
    String modeErrorStatus(const uint8_t pin);
    String readStatus(const String &key);
    String writeStatus(const String &key, double value, bool status);
    String updateStatus(const String &key, double value, bool status);
    String removeStatus(const String &key, bool status);

    void command(BridgeClient client);
    void digitalSet(BridgeClient client);
    void analogSet(BridgeClient client);
    void modeSet(BridgeClient client);
    void layoutStatus(BridgeClient client);
    void read(BridgeClient client);
    void list(BridgeClient client);
    void listStatus(BridgeClient client);
    void update(BridgeClient client);
    void remove(BridgeClient client);
};

#endif
