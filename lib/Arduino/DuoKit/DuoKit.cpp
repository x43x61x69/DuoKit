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

#define LOGD(...)       LOG(__VA_ARGS__);
#define DUOLAYOUT_NULL  (DuoUI){(DuoUIType)NULL, (String)NULL, (DuoPin)NULL, (String)NULL};
#define DUOOBJECT_NULL  (DuoObject){(String)NULL, (double *)NULL}
#define BLINK_INTERVAL  20

#include "DuoKit.h"
#include <stdio.h>
#include <Bridge.h>
#include <BridgeClient.h>

// public:

DuoKit::DuoKit(uint32_t serialPort, bool indicator)
{
    _serialPort = serialPort;
    _indicator = indicator;
}

void DuoKit::begin(bool shouldWaitForSerial)
{
    blink(2);
    digitalWrite(LED_BUILTIN, HIGH);
    Bridge.begin();
    server.listenOnLocalhost();
    server.begin();
    digitalWrite(LED_BUILTIN, LOW);
    if (_serialPort) {
        Serial.begin(_serialPort);
        if (shouldWaitForSerial) {
            while (!Serial) {
                blink(1);
            }
        }
        String log = "v";
        log.concat(DUOKIT_VERSION);
        log.concat(" (");
        log.concat(__DATE__);
        log.concat(" ");
        log.concat(__TIME__);
        log.concat(")");
        LOGD(log);
    }
    blink(5);
}

void DuoKit::loop()
{
    BridgeClient client = server.accept();
    if (client) {
        blink(_indicator);
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

bool DuoKit::valueForKey(double *value, const String &key)
{
    if (!key || !key.length()) {
        return false;
    }
    for (int i = 0; i < _objectsSize; i++) {
        if (_objects[i].name == key) {
            *value = *_objects[i].value;
            return true;
        }
    }
    return false;
}

bool DuoKit::setValueForKey(double *value, const String &key)
{
    if (!key || !key.length()) {
        return false;
    }
    int index = -1;
    bool result = false;
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
        result = true;
        _objects[index] = (DuoObject){key, value};
    }
    return result;
}

bool DuoKit::updateValueForKey(double value, const String &key)
{
    if (!key || !key.length()) {
        return false;
    }
    int index = -1;
    bool result = false;
    for (int i = 0; i < _objectsSize; i++) {
        if (_objects[i].name == key) {
            result = true;
            *_objects[i].value = value;
            break;
        }
    }
    return result;
}

bool DuoKit::removeValueForKey(const String &key)
{
    if (!key || !key.length()) {
        return false;
    }
    for (int i = 0; i < _objectsSize; i++) {
        if (_objects[i].name == key) {
            _objects[i] = DUOOBJECT_NULL;
            return true;
        }
    }
    return false;
}

// private:

void DuoKit::LOG(const String &message)
{
    Serial.print(F("[DuoKit] "));
    Serial.println(message);
}

int DuoKit::pinModeRead(const uint8_t pin)
{
    if (pin >= NUM_DIGITAL_PINS) return (-1);
    uint8_t bit = digitalPinToBitMask(pin);
    uint8_t port = digitalPinToPort(pin);
    volatile uint8_t *reg = portModeRegister(port);
    if (*reg & bit) return (OUTPUT);
    volatile uint8_t *out = portOutputRegister(port);
    return ((*out & bit) ? INPUT_PULLUP : INPUT);
}

void DuoKit::setLayout(DuoUI *layout, const int size)
{
    _layout = layout;
    _layoutSize = size;
}

void DuoKit::setObjetcs(DuoObject *objects, const int size)
{
    _objects = objects;
    _objectsSize = size;
}

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

String DuoKit::layoutStatus()
{
    bool status = false;
    String j;
    if (_layout) {
        j.concat("\"layout\":[");
        int count = 0;
        for (int i = 0; i < _layoutSize; i++) {
            if (count) j.concat(",");
            j.concat("{");
            j.concat(keyPair("type", String(_layout[i].type), false));
            if (_layout[i].name != "") {
                j.concat(",\"name\":\"");
                j.concat(_layout[i].name);
                j.concat("\"");
            }
            if (_layout[i].pin) {
                j.concat(",\"pin\":");
                j.concat(_layout[i].pin);
            }
            if (_layout[i].key != "") {
                j.concat(",\"key\":\"");
                j.concat(_layout[i].key);
                j.concat("\"");
            }
            if (_layout[i].interval) {
                j.concat(",\"interval\":");
                j.concat(_layout[i].interval);
            }
            j.concat("}");
            count++;
        }
        j.concat("],");
        j.concat(keyPair("count", String(count), false));
        LOGD(JSONStatus(true, j));
    }
    return JSONStatus(true, j);
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

String DuoKit::readStatus(const String &key)
{
    double value;
    bool status = valueForKey(&value, key);
    String j = keyPair("key", key);
    j.concat(",");
    if (status) {
        j.concat(keyPair("value", String(value), false));
    } else {
        j.concat(keyPair("message", "key does not exist."));
    }
    return JSONStatus(status, j);
}

String DuoKit::listStatus()
{
    String j = "\"keys\":[";
    int count = 0;
    for (int i = 0; i < _objectsSize; i++) {
        if (count) j.concat(",");
        j.concat("\"");
        j.concat(_objects[i].name);
        j.concat("\"");
        count++;
    }
    j.concat("],");
    j.concat(keyPair("count", String(count), false));
    return JSONStatus(true, j);
}

String DuoKit::updateStatus(const String &key, double value, bool status)
{
    String j = keyPair("key", key);
    j.concat(",");
    if (status) {
        j.concat(keyPair("value", String(value), false));
    } else {
        j.concat(keyPair("message", "key does not exist."));
    }
    return JSONStatus(status, j);
}

String DuoKit::removeStatus(const String &key, bool status)
{
    String j = keyPair("key", key);
    if (!status) {
        j.concat(",");
        j.concat(keyPair("message", "key does not exist."));
    }
    return JSONStatus(status, j);
}

void DuoKit::command(BridgeClient client)
{
    String command = client.readStringUntil('/');
    if (command == "digital") {
        digitalSet(client);
    } else if (command == "analog") {
        analogSet(client);
    } else if (command == "mode") {
        modeSet(client);
    } else if (command == "read") {
        read(client);
    } else if (command == "update") {
        update(client);
    } else if (command == "remove") {
        remove(client);
    } else if (command.startsWith("list")) {
        list(client);
    } else if (command.startsWith("ping")) {
        client.println(layoutStatus());
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
    client.println(digitalPinStatus(pin));
    LOGD(digitalPinStatus(pin));
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
    client.println(analogPinStatus(pin));
    LOGD(analogPinStatus(pin));
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
    client.print(digitalPinStatus(pin));
    LOGD(digitalPinStatus(pin));
}

void DuoKit::read(BridgeClient client)
{
    String key = client.readStringUntil('/');
    key.trim();
    client.print(readStatus(key));
    LOGD(readStatus(key));
}

void DuoKit::list(BridgeClient client)
{
    client.print(listStatus());
    LOGD(listStatus());
}

void DuoKit::update(BridgeClient client)
{
    String key = client.readStringUntil('/');
    double value = client.parseFloat();
    bool status = updateValueForKey(value, key);
    client.print(updateStatus(key, value, status));
    LOGD(updateStatus(key, value, status));
}

void DuoKit::remove(BridgeClient client)
{
    String key = client.readString();
    key.trim();
    bool status = removeValueForKey(key);
    client.print(removeStatus(key, status));
    LOGD(removeStatus(key, status));
}
