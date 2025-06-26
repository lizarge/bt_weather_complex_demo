/*
    Video: https://www.youtube.com/watch?v=oCMOYS71NIU
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleNotify.cpp
    Ported to Arduino ESP32 by Evandro Copercini
    updated by chegewara

   Create a BLE server that, once we receive a connection, will send periodic notifications.
   The service advertises itself as: 4fafc201-1fb5-459e-8fcc-c5c9c331914b
   And has a characteristic of: beb5483e-36e1-4688-b7f5-ea07361b26a8

   The design of creating the BLE server is:
   1. Create a BLE Server
   2. Create a BLE Service
   3. Create a BLE Characteristic on the Service
   4. Create a BLE Descriptor on the characteristic
   5. Start the service.
   6. Start advertising.

   A connect handler associated with the server starts a background task that performs notification
   every couple of seconds.
*/
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLE2901.h>

BLEServer *pServer = NULL;
BLECharacteristic *pCharacteristicTemperature = NULL;
BLECharacteristic *pCharacteristicPressure = NULL;
BLECharacteristic *pCharacteristicHumidity = NULL;

BLE2901 *descriptor_2901 = NULL;

bool deviceConnected = false;
bool oldDeviceConnected = false;
uint32_t valueT = 30;
uint32_t valueH = 47;
uint32_t valueP = 120;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

// ID взяв тут для прикладу https://github.com/NordicSemiconductor/bluetooth-numbers-database/blob/master/v1/service_uuids.json

#define com_nordicsemi_service_thingy_weather_station        "EF680200-9B35-4933-9B10-52FFA9740042"
#define com_nordicsemi_characteristic_thingy_sensorhub_temperature "506A55C4-B5E7-46FA-8326-8ACAEB1189EB"
#define com_nordicsemi_characteristic_thingy_sensorhub_pressure  "51838AFF-2D9A-B32A-B32A-8187E41664BA"
#define com_nordicsemi_characteristic_thingy_sensorhub_humidity  "753E3050-DF06-4B53-B090-5E1D810C4383"

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
  };

  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
  }
};

void setup() {
  Serial.begin(115200);

  // Create the BLE Device
  BLEDevice::init("ESP32 WEATHER MOCK");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(com_nordicsemi_service_thingy_weather_station);

  // Create a BLE Characteristic
  // для температури, вологості та тиску
  pCharacteristicTemperature = pService->createCharacteristic(
    com_nordicsemi_characteristic_thingy_sensorhub_temperature,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_INDICATE
  );

    pCharacteristicPressure = pService->createCharacteristic(
    com_nordicsemi_characteristic_thingy_sensorhub_pressure,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_INDICATE
  );

  pCharacteristicHumidity = pService->createCharacteristic(
    com_nordicsemi_characteristic_thingy_sensorhub_humidity,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_INDICATE
  );


  // Creates BLE Descriptor 0x2902: Client Characteristic Configuration Descriptor (CCCD)
  // для температури, вологості та тиску

  pCharacteristicTemperature->addDescriptor(new BLE2902());
  // Adds also the Characteristic User Description - 0x2901 descriptor
  descriptor_2901 = new BLE2901();
  descriptor_2901->setDescription("pCharacteristicTemperature");
  descriptor_2901->setAccessPermissions(ESP_GATT_PERM_READ);  // enforce read only - default is Read|Write
  pCharacteristicTemperature->addDescriptor(descriptor_2901);

  pCharacteristicPressure->addDescriptor(new BLE2902());
  // Adds also the Characteristic User Description - 0x2901 descriptor
  descriptor_2901 = new BLE2901();
  descriptor_2901->setDescription("pCharacteristicPressure");
  descriptor_2901->setAccessPermissions(ESP_GATT_PERM_READ);  // enforce read only - default is Read|Write
  pCharacteristicPressure->addDescriptor(descriptor_2901);

  pCharacteristicHumidity->addDescriptor(new BLE2902());
  // Adds also the Characteristic User Description - 0x2901 descriptor
  descriptor_2901 = new BLE2901();
  descriptor_2901->setDescription("pCharacteristicHumidity");
  descriptor_2901->setAccessPermissions(ESP_GATT_PERM_READ);  // enforce read only - default is Read|Write
  pCharacteristicHumidity->addDescriptor(descriptor_2901);

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(com_nordicsemi_service_thingy_weather_station);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  Serial.println("Waiting a client connection to notify...");
}

void loop() {
  // notify changed value
  if (deviceConnected) {

    Serial.println("deviceConnected");


    //Міеяємо всі три характеристики, а Notify Робимо тільку одну, наприклад температуру

    valueT += random(-1,1);

    if (valueT < 0) { //щоб не малювати сніжинки
      valueT = 0;
    }

    pCharacteristicTemperature->setValue((uint8_t *)&valueT, 4);
    pCharacteristicTemperature->notify();

    valueP = random(110,120);
    pCharacteristicPressure->setValue((uint8_t *)&valueP, 4);
   
    valueH = random(45,49);
    pCharacteristicHumidity->setValue((uint8_t *)&valueH, 4);

    delay(random(10, 3000));
  }
  // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);                   // give the bluetooth stack the chance to get things ready
    pServer->startAdvertising();  // restart advertising
    Serial.println("start advertising");
    oldDeviceConnected = deviceConnected;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected) {
    // do stuff here on connecting
    oldDeviceConnected = deviceConnected;
  }
}
