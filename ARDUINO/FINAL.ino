/*
 * Dhimas Roby Satrio Nugroho
 * 15.11.9238
 * Universitas Amikom Yogyakarta
 */
//library GPS
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

TinyGPSPlus gps;

bool statusKontak;
bool statusMesin;

double latitude, longitude;
char cekPerintah = 0;

//Deklarasi Relay
static const int relay1 = 4, relay2 = 3, alarm = 8;

//Deklarasi GPS
static const int RXPin = 13, TXPin = 12;
SoftwareSerial ss(RXPin, TXPin);
static const uint32_t GPSBaud = 9600;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  ss.begin(GPSBaud);
  pinMode(relay1,OUTPUT);
  pinMode(relay2,OUTPUT);
  pinMode(alarm,OUTPUT);
  digitalWrite(relay1, 1);
  digitalWrite(relay2, 1);
}

void kalibrasiRelay() {
  delay(1000);
  digitalWrite(relay1, 0);
  delay(1000);
  digitalWrite(relay2, 0);
  delay(1000);
  digitalWrite(relay1, 1);
  delay(1000);
  digitalWrite(relay2, 1);
  delay(1000);
  Serial.println("Kalibrasi Selesai");
  }


void printLat () {
               Serial.println(gps.location.lat(), 6);
   }

void printLong () {
                Serial.println(gps.location.lng(), 6);
    }


void findMyVehicle() {
  tone(alarm,5000);
  delay(200);
  noTone(alarm);
  delay(200);
  tone(alarm,5000);
  delay(200);
  noTone(alarm);
  delay(200);
  tone(alarm,5000);
  delay(200);
  noTone(alarm);
  delay(200);
  Serial.println("Alarm Sudah Berbunyi");
}

void cekCmd (char perintahMasuk) {
  // check if a number was received
    if ((perintahMasuk >= '0')) {
      if ((perintahMasuk == '1')) {
       if ((statusKontak == true)){
        delay(100);
        Serial.println("Stop Kontak sudah Menyala");
        tone(alarm,3000);
        delay(100);
        noTone(alarm);
        delay(100);
        tone(alarm,3000); 
        delay(100);      
        noTone(alarm); 
        }
       else {
        digitalWrite(relay1, 0);
        statusKontak = true;
        delay(70);
        Serial.println("Menyalakan Stop Kontak");
        tone(alarm,1000);
        delay(50);
        noTone(alarm); 
        delay(50);
        tone(alarm,3000);
        delay(50);
        noTone(alarm); 
        delay(50);
        tone(alarm,5000);
        delay(50);
        noTone(alarm);           
        }     
      }
      else if ((perintahMasuk == '2')) {
        if ((statusKontak == true)){
          digitalWrite(relay1, 1);
          statusKontak = false;
          statusMesin = false;
          delay(70);
          Serial.println("Mematikan Stop Kontak");
           tone(alarm,5000);
           delay(50); 
           noTone(alarm); 
           delay(50);
           tone(alarm,3000);
           delay(50);
           noTone(alarm); 
           delay(50);
           tone(alarm,1000);
           delay(50);
           noTone(alarm);
          }
        else {
           delay(50);
          Serial.println("Stop Kontak tidak Menyala");
          tone(alarm,3000);
          delay(50);
          noTone(alarm);
          delay(50);
          tone(alarm,3000); 
          delay(50);      
          noTone(alarm); 
          }
        }
      else if ((perintahMasuk == '3')) {
        if ((statusKontak == true)){
          if ((statusMesin == false)){            
            digitalWrite(relay2, 0);
            delay(70);
            Serial.println("Menyalakan Mesin");
            tone(alarm,1000);
            delay(50);
            noTone(alarm); 
            delay(50);
            tone(alarm,3000);
            delay(50);
            noTone(alarm); 
            delay(50);
            tone(alarm,5000);
            delay(50);
            noTone(alarm);
            delay(2000);
            digitalWrite(relay2, 1);
            statusMesin = true;
          }
          else {
            delay(100);
            Serial.println("Mesin sudah Menyala");
            tone(alarm,3000);
            delay(50);
            noTone(alarm);
            delay(50);
            tone(alarm,3000); 
            delay(50);      
            noTone(alarm); 
            }
          }
          else {
            delay(100);
            Serial.println("Stop Kontak belum Menyala");
            tone(alarm,3000);
            delay(50);
            noTone(alarm);
            delay(50);
            tone(alarm,3000); 
            delay(50);      
            noTone(alarm); 
            }
        }
      else if ((perintahMasuk == '4')) {
        if ((statusKontak == true) && (statusMesin == true)){          
            digitalWrite(relay1, 1);
            statusMesin = false;
            delay(70);
            Serial.println("Mematikan Mesin");
            tone(alarm,5000);
           delay(50); 
           noTone(alarm); 
           delay(50);
           tone(alarm,3000);
           delay(50);
           noTone(alarm); 
           delay(50);
           tone(alarm,1000);
           delay(50);
           noTone(alarm);
           delay(1500);
            digitalWrite(relay1, 0);
            }
          else {
            delay(100);
            Serial.println("Mesin tidak Menyala");
            tone(alarm,3000);
            delay(50);
            noTone(alarm);
            delay(50);
            tone(alarm,3000); 
            delay(50);     
            noTone(alarm); 
            }
         }
       else if ((perintahMasuk == '5')) {
        printLat();
        
        }
       else if ((perintahMasuk == '6')) {
        findMyVehicle();
        
        }
       else if ((perintahMasuk == '7')) {
        printLong();
        
        }
       else if ((perintahMasuk == '9')) {
        kalibrasiRelay();
        
        }
       else {
        delay(100);
        Serial.println("Perintah tidak Valid");
      }
    }
}

void loop() {
  while (ss.available() > 0)
          if (gps.encode(ss.read())) {
            if (gps.location.isValid())     {
              latitude = gps.location.lat(), 6;
              longitude = gps.location.lng(), 6;
            }
          }
  
  if (Serial.available() > 0) {    // is a character available?
    cekPerintah = Serial.read();       // get the character
    cekCmd(cekPerintah);
    
    }
  }
