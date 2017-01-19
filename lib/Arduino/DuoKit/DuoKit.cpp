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

#ifdef USE_DUOKIT_DEBUG
#define LOGD(...)  LOG(__VA_ARGS__);
#else
#define LOGD(...)
#endif
#define DUOLAYOUT_NULL  (DuoUI){(DuoUIType)NULL, (String)NULL, (DuoPin)NULL, (String)NULL};
#define DUOOBJECT_NULL  (DuoObject){(DuoObjectType)NULL, (String)NULL, (int *)NULL}
#define BLINK_INTERVAL  20

#include "DuoKit.h"
#include <Bridge.h>
#include <BridgeClient.h>

extern String __doubleQuoteEscaped = "\"";

// public:

DuoKit::DuoKit()
{
    
}

void DuoKit::begin()
{
    digitalWrite(LED_BUILTIN, HIGH);
    Bridge.begin();
    server.listenOnLocalhost();
    server.begin();
    digitalWrite(LED_BUILTIN, LOW);
    blink(5);
}

void DuoKit::loop()
{
    BridgeClient client = server.accept();
    if (client) {
        command(client);
        client.stop();
    }
}

void DuoKit::blink(const int blinks)
{
    const int ledStatus = digitalRead(LED_BUILTIN);
    uint8_t tick = !ledStatus;
    int i = 0;
    while (i < blinks * 2) {
        digitalWrite(LED_BUILTIN, tick);
        delay(BLINK_INTERVAL);
        tick = !tick;
        i++;
    };
    digitalWrite(LED_BUILTIN, ledStatus);
}

#ifdef USE_DUOKIT_OBJECT
bool DuoKit::objectForKey(DuoObject *object, const String &key)
{
    if (key && key.length()) {
        for (int i = 0; i < _objectsSize; i++) {
            if (_objects[i].name == key) {
                *object = _objects[i];
                return true;
            }
        }
    }
    return false;
}

bool DuoKit::setObjectForKey(const DuoObject object, const String &key)
{
    if (key && key.length()) {
        int index = -1;
        for (int i = 0; i < _objectsSize; i++) {
            if (_objects[i].name == key) {
                index = i;
                break;
            }
            if (_objects[i].name == (String)NULL) {
                index = i;
            }
        }
        if (index >= 0) {
            _objects[index] = object;
            return true;
        }
    }
    return false;
}

bool DuoKit::updateValueForKey(const DuoObjectType type, void *value, const String &key)
{
    bool result = false;
    if (key && key.length()) {
        int index = -1;
        for (int i = 0; i < _objectsSize; i++) {
            if (_objects[i].name == key) {
                if (_objects[i].type != type) {
                    break;
                }
                result = true;
                switch (type) {
                    case DuoIntType:
                        *_objects[i].intPtr = *((int *)(value));
                        break;
                    case DuoDoubleType:
                        *_objects[i].doublePtr = *((double *)(value));
                        break;
                    case DuoStringType:
                        *_objects[i].stringPtr = *((String *)(value));
                        break;
                    default:
                        result = false;
                        break;
                }
                break;
            }
        }
    }
    return result;
}

#ifdef USE_DUOKIT_COMMMAND_REMOVE
bool DuoKit::removeKey(const String &key)
{
    if (key && key.length()) {
        for (int i = 0; i < _objectsSize; i++) {
            if (_objects[i].name == key) {
                _objects[i] = DUOOBJECT_NULL;
                return true;
            }
        }
    }
    return false;
}
#endif

#endif

// private:

#ifdef USE_DUOKIT_DEBUG
void DuoKit::LOG(const String &message)
{
    Serial.print(F("[D] "));
    Serial.println(message);
}
#endif

int DuoKit::pinModeRead(const uint8_t pin)
{
    if (pin >= NUM_DIGITAL_PINS) {
        return -1;
    }
    uint8_t bit = digitalPinToBitMask(pin);
    uint8_t port = digitalPinToPort(pin);
    volatile uint8_t *reg = portModeRegister(port);
    if (*reg & bit) {
        return (OUTPUT);
    }
    volatile uint8_t *out = portOutputRegister(port);
    return ((*out & bit) ? INPUT_PULLUP : INPUT);
}

#ifdef USE_DUOKIT_LAYOUT
void DuoKit::setLayout(DuoUI *layout, const int size)
{
    _layout = layout;
    _layoutSize = size;
}
#endif

#ifdef USE_DUOKIT_OBJECT
void DuoKit::setObjetcs(DuoObject *objects, const int size)
{
    _objects = objects;
    _objectsSize = size;
}
#endif

String DuoKit::keyPair(const String &key, const String &value, bool isString)
{
    String j = "\"";
    j.concat(key);
    j.concat("\":");
    if (isString) j.concat("\"");
    j.concat(value);
    if (isString) j.concat("\"");
    return j;
}

String DuoKit::JSONFormat(const String &keyPairs)
{
    String j = "{";
    j.concat(keyPair("api", String(DUOKIT_API_VERSION), false));
    j.concat(",");
    j.concat(keyPairs);
    j.concat("}");
    return j;
}

String DuoKit::JSONStatus(const bool status, const String &keyPairs)
{
    String j = keyPair("status", status ? "ok" : "failed");
    if (keyPairs.length() > 5) {
        j.concat(",");
        j.concat(keyPairs);
    }
    return JSONFormat(j);
}

String DuoKit::digitalPinStatus(const uint8_t pin)
{
    bool status = false;
    String j = keyPair("pin", String(pin), false);
    j.concat(",");
    if (pin >= NUM_DIGITAL_PINS) {
        j.concat(keyPair("message", "pin does not exist."));
    } else {
        status = true;
        j.concat(keyPair("value", String(digitalRead(pin)), false));
        j.concat(",");
        j.concat(keyPair("mode", String(pinModeRead(pin)), false));
    }
    return JSONStatus(status, j);
}

String DuoKit::analogPinStatus(const uint8_t pin)
{
    bool status = false;
    String j = keyPair("pin", String(pin), false);
    j.concat(",");
    if (pin >= NUM_ANALOG_INPUTS) {
        j.concat(keyPair("message", "pin does not exist."));
    } else {
        status = true;
        j.concat(keyPair("value", String(analogRead(pin)), false));
        j.concat(",");
        j.concat(keyPair("mode", String(pinModeRead(pin)), false));
    }
    return JSONStatus(status, j);
}

String DuoKit::modeErrorStatus(const uint8_t pin)
{
    String j = keyPair("pin", String(pin), false);
    j.concat(",");
    if (pin >= NUM_DIGITAL_PINS) {
        j.concat(keyPair("message", "pin does not exist."));
    } else {
        j.concat(keyPair("message", "invalid mode."));
    }
    return JSONStatus(false, j);
}

void DuoKit::layoutStatus(BridgeClient client)
{
    client.print("{");
    client.print(keyPair("api", String(DUOKIT_API_VERSION), false));
    client.print(",");
#ifdef USE_DUOKIT_LAYOUT
    if (_layout) {
        client.print("\"layout\":[");
        int count = 0;
        for (int i = 0; i < _layoutSize; i++) {
            if (count) client.print(",");
            client.print("{");
            client.print(keyPair("type", String(_layout[i].type), false));
            if (_layout[i].name != "") {
                String j;
                j.concat(",\"name\":\"");
                j.concat(_layout[i].name);
                j.concat("\"");
                client.print(j);
            }
            if (_layout[i].type != DuoUIWebUI) {
                if (_layout[i].pin) {
                    String j;
                    j.concat(",\"pin\":");
                    j.concat(_layout[i].pin);
                    j.concat(",\"value\":");
                    if (_layout[i].type == DuoUISwitch) {
                        j.concat(digitalRead(_layout[i].pin));
                    } else {
                        j.concat(analogRead(_layout[i].pin));
                    }
                    client.print(j);
                } else if (_layout[i].key != "") {
                    String j;
                    DuoObject object;
                    if (objectForKey(&object, _layout[i].key)) {
                        String v;
                        switch (object.type) {
                            case DuoIntType:
                                v = String(*object.intPtr);
                                break;
                            case DuoDoubleType:
                                v = String(*object.doublePtr);
                                break;
                            case DuoStringType:
                                v = "\"";
                                v.concat(*object.stringPtr);
                                v.concat("\"");
                                break;
                            default:
                                break;
                        }
                        j.concat(",\"key\":\"");
                        j.concat(_layout[i].key);
                        j.concat("\",");
                        j.concat(keyPair("valueType", String(object.type), false));
                        j.concat(",\"value\":");
                        j.concat(v);
                        client.print(j);
                    }
                }
                if (_layout[i].type == DuoUISlider) {
                    String j;
                    j.concat(",\"min\":");
                    j.concat(_layout[i].min);
                    j.concat(",\"max\":");
                    j.concat(_layout[i].max);
                    client.print(j);
                }
                if (_layout[i].useColor) {
                    String j;
                    j.concat(",\"color\":");
                    j.concat(_layout[i].color);
                    client.print(j);
                }
                if (_layout[i].interval) {
                    String j;
                    j.concat(",\"interval\":");
                    j.concat(_layout[i].interval);
                    client.print(j);
                }
            }
            client.print("}");
            count++;
        }
        client.print("],");
        if (layoutProfile != "") {
            client.print(keyPair("profile", layoutProfile, true));
            client.print(",");
        }
        client.print(keyPair("count", String(count), false));
        client.print(",");
    }
#endif
    client.print(keyPair("status", "ok"));
    client.print("}");
}

#ifdef USE_DUOKIT_OBJECT
String DuoKit::readStatus(const String &key)
{
    String j = keyPair("key", key);
    j.concat(",");
    DuoObject object;
    bool status = objectForKey(&object, key);
    if (status) {
        j.concat(keyPair("valueType", String(object.type), false));
        j.concat(",");
        String v;
        switch (object.type) {
            case DuoIntType:
                v = String(*object.intPtr);
                break;
            case DuoDoubleType:
                v = String(*object.doublePtr);
                break;
            case DuoStringType:
                v = "\"";
                v.concat(*object.stringPtr);
                v.concat("\"");
                break;
            default:
                break;
        }
        j.concat(keyPair("value", v, false));
    } else {
        j.concat(keyPair("message", "key does not exist."));
    }
    return JSONStatus(status, j);
}

#ifdef USE_DUOKIT_COMMMAND_LIST
void DuoKit::listStatus(BridgeClient client)
{
    client.print("{");
    client.print(keyPair("api", String(DUOKIT_API_VERSION), false));
    client.print(",");
    client.print("\"keys\":[");
    int count = 0;
    for (int i = 0; i < _objectsSize; i++) {
        String j;
        if (count) j.concat(",");
        j.concat("\"");
        j.concat(_objects[i].name);
        j.concat("\"");
        client.print(j);
        count++;
    }
    client.print("],");
    client.print(keyPair("count", String(count), false));
    client.print(",");
    client.print(keyPair("status", "ok"));
    client.print("}");
}
#endif

String DuoKit::updateStatus(const String &key, const DuoObjectType type, void *value)
{
    String j;
    bool status = updateValueForKey(type, value, key);
    if (status) {
        return readStatus(key);
    } else {
        j = keyPair("key", key);
        j.concat(",");
        j.concat(keyPair("message", "key does not exist."));
    }
    return JSONStatus(status, j);
}

#ifdef USE_DUOKIT_COMMMAND_REMOVE
String DuoKit::removeStatus(const String &key, bool status)
{
    String j = keyPair("key", key);
    if (!status) {
        j.concat(",");
        j.concat(keyPair("message", "key does not exist."));
    }
    return JSONStatus(status, j);
}
#endif

#endif

void DuoKit::command(BridgeClient client)
{
    String command = client.readStringUntil('/');
    if (command == "digital") {
        digitalSet(client);
    } else if (command == "analog") {
        analogSet(client);
    } else if (command == "mode") {
        modeSet(client);
#ifdef USE_DUOKIT_OBJECT
    } else if (command == "read") {
        read(client);
    } else if (command == "update") {
        update(client);
#ifdef USE_DUOKIT_COMMMAND_REMOVE
    } else if (command == "remove") {
        remove(client);;
#endif
#ifdef USE_DUOKIT_COMMMAND_LIST
    } else if (command.startsWith("list")) {
        listStatus(client);
#endif
#endif
    } else if (command.startsWith("ping")) {
        layoutStatus(client);
    } else {
        String j = JSONStatus(false, keyPair("message", "command unknown."));
        client.println(j);
        LOGD(j);
    }
}

void DuoKit::digitalSet(BridgeClient client)
{
    int pin, value;
    pin = client.parseInt();
    if (client.read() == '/') {
        value = client.parseInt();
        digitalWrite(pin, value);
    } else {
        value = digitalRead(pin);
    }
    String j = digitalPinStatus(pin);
    client.print(j);
    LOGD(j);
}

void DuoKit::analogSet(BridgeClient client)
{
    int pin, value;
    pin = client.parseInt();
    if (client.read() == '/') {
        value = client.parseInt();
        analogWrite(pin, value);
    } else {
        value = analogRead(pin);
    }
    String j = analogPinStatus(pin);
    client.print(j);
    LOGD(j);
}

void DuoKit::modeSet(BridgeClient client)
{
    int pin, value;
    pin = client.parseInt();
    if (client.read() == '/') {
        value = client.parseInt();
        switch (value) {
            case DUOKIT_INPUT:
                value = INPUT;
                break;
            case DUOKIT_OUTPUT:
                value = OUTPUT;
                break;
            case DUOKIT_INPUT_PULLUP:
                value = INPUT_PULLUP;
                break;
            default:
                client.print(modeErrorStatus(pin));
                LOGD(modeErrorStatus(pin));
                return;
        }
        pinMode(pin, value);
    }
    String j = digitalPinStatus(pin);
    client.print(j);
    LOGD(j);
}

#ifdef USE_DUOKIT_OBJECT
void DuoKit::read(BridgeClient client)
{
    String key = client.readStringUntil('/');
    key.trim();
    String j = readStatus(key);
    client.print(j);
    LOGD(j);
}

void DuoKit::update(BridgeClient client)
{
    String j;
    String key = client.readStringUntil('/');
    DuoObject object;
    void *value;
    objectForKey(&object, key);
    DuoObjectType type = object.type;
    switch (type) {
        case DuoIntType:
            value = malloc(sizeof(int));
            *((int *)(value)) = client.parseInt();
            break;
        case DuoDoubleType:
            value = malloc(sizeof(double));
            *((double *)(value)) = client.parseFloat();
            break;
        case DuoStringType: {
            unsigned int decodedLen = client.parseInt();
            LOGD(String(decodedLen));
            if (decodedLen &&
                client.read() == '/') {
                String str = client.readString();
                const unsigned int encodedLen = str.length();
                unsigned char encoded[encodedLen];
                str.toCharArray((char *)encoded, encodedLen);
                unsigned char decoded[decodedLen];
                decodeString(decoded, encoded, decodedLen);
                str = String((char *)decoded);
                str.replace("\"", "\\\"");
                value = malloc(sizeof(String));
                *((String *)(value)) = str;
            }
            break;
        }
        default:
            break;
    }
    j = updateStatus(key, type, value);
    if (value) free(value);
    client.print(j);
    LOGD(j);
}

#ifdef USE_DUOKIT_COMMMAND_REMOVE
void DuoKit::remove(BridgeClient client)
{
    String key = client.readString();
    key.trim();
    bool status = removeKey(key);
    String j = removeStatus(key, status);
    client.print(j);
    LOGD(j);
}
#endif

void DuoKit::decodeString(unsigned char *decoded, const unsigned char *encoded, const unsigned int decodedLength)
{
    for (unsigned int i = 2; i < decodedLength; i += 3) {
        decoded[0] = encodedBinary(encoded[0]) << 2 | encodedBinary(encoded[1]) >> 4;
        decoded[1] = encodedBinary(encoded[1]) << 4 | encodedBinary(encoded[2]) >> 2;
        decoded[2] = encodedBinary(encoded[2]) << 6 | encodedBinary(encoded[3]);
        
        encoded += 4;
        decoded += 3;
    }
    
    switch (decodedLength % 3) {
        case 1:
            decoded[0] = encodedBinary(encoded[0]) << 2 | encodedBinary(encoded[1]) >> 4;
            break;
        case 2:
            decoded[0] = encodedBinary(encoded[0]) << 2 | encodedBinary(encoded[1]) >> 4;
            decoded[1] = encodedBinary(encoded[1]) << 4 | encodedBinary(encoded[2]) >> 2;
            break;
    }
    decoded[decodedLength] = '\0';
}

unsigned char DuoKit::encodedBinary(unsigned char c)
{
    if('A' <= c && c <= 'Z') return c - 'A';
    if('a' <= c && c <= 'z') return c - 71;
    if('0' <= c && c <= '9') return c + 4;
    if(c == '+') return 62;
    if(c == '/') return 63;
    return 0xFF;
}
#endif
