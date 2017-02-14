// (first color set value) Green = RED
// (second color set value) Red = GREEN
// (thirs color set value) Blue = BLUE

#include "./libraries/Adafruit_NeoPixel/Adafruit_NeoPixel.h"
#include "./libraries/SimpleTimer/SimpleTimer.h"
#ifdef __AVR__
#include <avr/power.h>
#endif

#define PIN 6
#define FADE_FACTOR 2

// Parameter 1 = number of pixels in strip
// Parameter 2 = Arduino pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(50, PIN, NEO_RGB + NEO_KHZ800);

// the timer object
SimpleTimer timer;

//Globals
boolean liveMode = true; //user can control ligths via bluetooth
boolean rainbowMode = false; //rainbow is turned off by default
uint8_t turnRainbowOn = 101;
uint8_t turnLiveModeOn = 100;
uint8_t fadeSpeed = 2;
int fadeSpeedTimer = 2;
int timerID = 0;

void setup() {
   // This is for Trinket 5V 16MHz, you can remove these three lines if you are not using a Trinket
  #if defined (__AVR_ATtiny85__)
    if (F_CPU == 16000000) clock_prescale_set(clock_div_1);
  #endif
  // End of trinket special code

  Serial.begin(115200);  //initial the Serial

  
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
}

void loop(){
  uint8_t pixel[6] = {6, 10, 220, 30, 35, 20};
  setStrandColor(254,254,254);  
}

void setStrandColor(uint8_t r, uint8_t g, uint8_t b){
  for(uint16_t i = 0; i < strip.numPixels(); i++){
    strip.setPixelColor(i, r, g, b);
  }
  strip.show();
}

