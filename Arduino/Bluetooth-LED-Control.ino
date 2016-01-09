// (first color set value) Green = RED
// (second color set value) Red = GREEN
// (thirs color set value) Blue = BLUE

#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
#include <avr/power.h>
#endif

#define PIN 6
#define FADE_FACTOR 1

// Parameter 1 = number of pixels in strip
// Parameter 2 = Arduino pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(50, PIN, NEO_RGB + NEO_KHZ800);

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
/*
void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available())  {
    uint8_t character = Serial.read();
   
    Serial.println(character);
    if(character < 50){
      //lightUntil(character);
      //lightOnlyOne(character);
      lightUpOneLED(character, 128, 0, 128);
    }
  }
  fadeByFactor();
  delay(10);

  //rainbowCycle(20);
}
*/

//Globals
boolean liveMode = true; //user can control ligths via bluetooth
  boolean rainbowMode = false; //rainbow is turned off by default
  uint8_t turnRainbowOn = 101;
  uint8_t turnLiveModeOn = 100;

void loop(){
 
  
  uint8_t pixel[5] = {6, 10, 220, 30, 35};


  
  //wait until 5 bytes in buffer
  if(Serial.available() >= 5) {
    
    pixel[0] = Serial.read(); 
    pixel[1] = Serial.read();
    pixel[2] = Serial.read();
    pixel[3] = Serial.read();
    pixel[4] = Serial.read(); //if last byte == 101 turn on Rainbowmode

    if (pixel[4] == turnRainbowOn){ 
      rainbowMode = true; 
      liveMode = false; 
      } 
    if (pixel[4] == turnLiveModeOn){
      rainbowMode = false; 
      liveMode = true;
      } //RainbowMode off
    
    //print out what we got
    Serial.print(pixel[4]);
    Serial.print(" ");
    Serial.print(pixel[3]);
    Serial.print(" ");
    Serial.print(pixel[2]);
    Serial.print(" ");
    Serial.print(pixel[1]);
    Serial.print(" ");
    Serial.print(pixel[0]);
    Serial.println("");
    
    if (liveMode){ //user is in active control
      lightUpOneLED(pixel[3], pixel[2], pixel[1], pixel[0]);  
    }
  }

  if(rainbowMode) { rainbowCycle(10); }
  if(liveMode) { fadeByFactor(); }
  
  delay(10);
}

void lightUpOneLED(uint8_t pixel, uint8_t r, uint8_t g, uint8_t b){
  strip.setPixelColor(pixel, r, g, b);
}

void fadeByFactor(){
  uint8_t *pixels = strip.getPixels();
  uint8_t *rgb;
  
  for(uint16_t i = 0; i < strip.numPixels(); i++){
    rgb = &pixels[i*3];
    
    if(rgb[0] < FADE_FACTOR){
      rgb[0] = 0;
    } else {
      rgb[0] -= FADE_FACTOR;
    }

    if(rgb[1] < FADE_FACTOR){
      rgb[1] = 0;
    } else {
      rgb[1] -= FADE_FACTOR;
    }

    if(rgb[2] < FADE_FACTOR){
      rgb[2] = 0;
    } else {
      rgb[2] -= FADE_FACTOR;
    }
    
  }

  strip.show();
}

void printPixels(){
  uint8_t *pixels = strip.getPixels();
  uint8_t *r;
  
  for(uint16_t i = 0; i < strip.numPixels(); i++){
    r = &pixels[i*3];
    Serial.print("\n");
    Serial.print("r:");
    Serial.print(r[0]);
    Serial.print(" g:");
    Serial.print(r[1]);
    Serial.print(" b:");
    Serial.print(r[2]);
    Serial.println("\n");
  } // r1 g0 b2
}

void lightOnlyOne(uint8_t pixel){
  uint8_t g = 255, r = 255, b = 255;
  for(uint16_t i = 0; i < strip.numPixels(); i++){
    if(i == pixel){
      strip.setPixelColor(pixel, (g-(i*5)), (r-(i*5)), (b-(i*5)));
    } else {
      strip.setPixelColor(i, 0, 0, 0);
    }
  }
  strip.show();
  delay(10);
}

void lightUntil(uint8_t pixel){
  if(pixel > 50){
    Serial.println("Pixel out of range");
  } else {
    uint8_t g = 250, r = 250, b = 250;
    for(uint16_t i = 0; i < pixel; i++){
      g -= i*5;
      r -= i*5;
      b -= i*5;
      strip.setPixelColor(i, 255, 0, 0);
    }
    for(uint16_t k = pixel; k < strip.numPixels(); k++){ 
      strip.setPixelColor(k, 0, 0, 0); 
    }
    strip.show();
  }
}

// Fill the dots one after the other with a color
void colorWipe(uint32_t c, uint8_t wait) {
  for (uint16_t i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, c);
    strip.show();
    delay(wait);
  }
}

void setStrandColor(uint8_t r, uint8_t g, uint8_t b, uint16_t wait){
  for(uint16_t i = 0; i < strip.numPixels(); i++){
    strip.setPixelColor(i, r, g, b);
  }
  strip.show();
  delay(wait);
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  WheelPos = 255 - WheelPos;
  if (WheelPos < 85) {
    return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  }
  if (WheelPos < 170) {
    WheelPos -= 85;
    return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
  WheelPos -= 170;
  return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
}

//Theatre-style crawling lights.
void theaterChase(uint32_t c, uint8_t wait) {
  for (int j = 0; j < 10; j++) { //do 10 cycles of chasing
    for (int q = 0; q < 3; q++) {
      for (int i = 0; i < strip.numPixels(); i = i + 3) {
        strip.setPixelColor(i + q, c);  //turn every third pixel on
      }
      strip.show();

      delay(wait);

      for (int i = 0; i < strip.numPixels(); i = i + 3) {
        strip.setPixelColor(i + q, 0);      //turn every third pixel off
      }
    }
  }
}

// Slightly different, this makes the rainbow equally distributed throughout
void rainbowCycle(uint8_t wait) {
  uint16_t i, j;

  for (j = 0; j < 256 * 5; j++) { // 5 cycles of all colors on wheel
    for (i = 0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel(((i * 256 / strip.numPixels()) + j) & 255));
      if(Serial.available() >= 5) {
        Serial.println("found the five");
        uint8_t pixel[5] = {6, 10, 220, 30, 35};
        pixel[0] = Serial.read(); 
        pixel[1] = Serial.read();
        pixel[2] = Serial.read();
        pixel[3] = Serial.read();
        pixel[4] = Serial.read(); //if last byte == 101 turn on Rainbowmode
    
        if (pixel[4] == turnLiveModeOn){
          rainbowMode = false; 
          liveMode = true;
          Serial.println("break");
          break;
          } //RainbowMode off leaving rainbow
      }
    }
    if(rainbowMode == false) { break; }
    strip.show();
    delay(wait);
  }
}

