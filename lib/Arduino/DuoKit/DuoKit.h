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
 */

#ifndef DUOKIT_H
#define DUOKIT_H

//
// To avoid wasting sketch space, you have to define the features you need.
//
//#define USE_DUOKIT_DEBUG
#define USE_DUOKIT_LAYOUT
#define USE_DUOKIT_OBJECT
//#define USE_DUOKIT_COMMMAND_LIST
//#define USE_DUOKIT_COMMMAND_REMOVE

#define DUOKIT_VERSION          "1.0.4"
#define DUOKIT_API_VERSION      3
#define DUOKIT_INPUT            0x0
#define DUOKIT_OUTPUT           0x1
#define DUOKIT_INPUT_PULLUP     0x2

#include <Arduino.h>
#include <BridgeServer.h>

typedef uint8_t DuoPin;

#ifdef USE_DUOKIT_LAYOUT
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
#endif

#ifdef USE_DUOKIT_OBJECT
typedef enum : uint8_t {
    DuoNoneType,
    DuoIntType,
    DuoDoubleType,
    DuoStringType
} DuoObjectType;

typedef struct __attribute__((packed))
{
    DuoObjectType type;
    String name;
    union {
        int     *intPtr;
        double  *doublePtr;
        String  *stringPtr;
    };
} DuoObject;
#endif

class DuoKit
{
public:
    String layoutProfile;
    BridgeServer server;
    DuoKit();
    void begin();
    void loop();
    void blink(const int blinks);
#ifdef USE_DUOKIT_LAYOUT
    void setLayout(DuoUI *layout, const int size);
#endif
#ifdef USE_DUOKIT_OBJECT
    void setObjetcs(DuoObject *objects, const int size);
    bool objectForKey(DuoObject *object, const String &key);
    bool setObjectForKey(const DuoObject object, const String &key);
    bool updateValueForKey(const DuoObjectType type, void *value, const String &key);
#ifdef USE_DUOKIT_COMMMAND_REMOVE
    bool removeKey(const String &key);
#endif
#endif
private:
#ifdef USE_DUOKIT_LAYOUT
    DuoUI *_layout;
    int _layoutSize;
#endif
#ifdef USE_DUOKIT_OBJECT
    DuoObject *_objects;
    int _objectsSize;
#endif
    
#ifdef USE_DUOKIT_DEBUG
    void LOG(const String &message);
#endif
    int pinModeRead(const uint8_t pin);

    String keyPair(const String &key, const String &value, bool isString = true);
    String JSONFormat(const String &keyPairs);
    String JSONStatus(const bool status, const String &keyPairs = "");
    String digitalPinStatus(const uint8_t pin);
    String analogPinStatus(const uint8_t pin);
    String modeErrorStatus(const uint8_t pin);
#ifdef USE_DUOKIT_OBJECT
    String readStatus(const String &key);
    String writeStatus(const String &key, void *value, bool status);
    String updateStatus(const String &key, const DuoObjectType type, void *value);
#ifdef USE_DUOKIT_COMMMAND_REMOVE
    String removeStatus(const String &key, bool status);
#endif
#endif

    void command(BridgeClient client);
    void digitalSet(BridgeClient client);
    void analogSet(BridgeClient client);
    void modeSet(BridgeClient client);
    void layoutStatus(BridgeClient client);
#ifdef USE_DUOKIT_OBJECT
    void read(BridgeClient client);
#ifdef USE_DUOKIT_COMMMAND_LIST
    void listStatus(BridgeClient client);
#endif
    void update(BridgeClient client);
#ifdef USE_DUOKIT_COMMMAND_REMOVE
    void remove(BridgeClient client);
#endif
    
    void decodeString(unsigned char *decoded, const unsigned char *encoded, const unsigned int decodedLength);
    unsigned char encodedBinary(unsigned char c);
#endif
};

#endif
