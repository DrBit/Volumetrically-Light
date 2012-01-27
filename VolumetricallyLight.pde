
/** DmxSimple is available from: http://code.google.com/p/tinkerit/
** Help and support: http://groups.google.com/group/dmxsimple       */
/* To use DmxSimple, you will need the following line. Arduino will
** auto-insert it if you select Sketch > Import Library > DmxSimple. */
#include <DmxSimple.h>


#define dimmer_DMX_add 1            // DMX starting address of the dimmer (4 channels)
#define smoke_DMX_add 5             // DMX starting address of the Smoke Machine (2 channels: pump and fan)
#define dmx_delay 30                // DMX delay refresh rate

int rele =  4;                     // Relay connected to digital pin 4
int pin_trigger = 5;                // Trigger connected to digital pin 5
int dim1_val = 0;                   // DMX value of Dimmer 1
int dim2_val = 0;                   // DMX value of Dimmer 2
int dim3_val = 0;                   // DMX value of Dimmer 3
int dim4_val = 0;                   // DMX value of Dimmer 4
//FAN being first DMX address and pump the following next
int smoke_fan_val = 0;              // DMX value of Smoke , FAN channel
int smoke_pump_val = 0;             // DMX value of Smoke , Pump channel

//DMX values
/////////////////////////////////////////
// Default state (Not activated)
/////////////////////////////////////////
#define Ddim1 255
#define Ddim2 255
#define Ddim3 255
#define Ddim4 255
#define Dsmoke_fan 29
#define Dsmoke_pump 0

/////////////////////////////////////////
// Performance sate  (Activated)
/////////////////////////////////////////
#define Pdim1 50
#define Pdim2 50
#define Pdim3 50
#define Pdim4 50
#define Psmoke_fan 200
#define Psmoke_pump 100

// Timing
long lastPerformanceTime = 0;        // the last time the performance was toggled
long idleDelay = 3600000;            // The delay of each performance play
#define performance_duration 140000  // Duration betwen the lights go off and the lights go on again    
long activation_timelimit = 1000;    // Time out for the performance to start when the trigger is not activated

//Debounce button trigger
int buttonState;             // the current reading from the input pin
int lastButtonState = LOW;   // the previous reading from the input pin
long lastDebounceTime = 0;   // the last time the output pin was toggled
long debounceDelay = 50;     // the debounce time; increase if the output flickers


void setup() {
  /* The most common pin for DMX output is pin 3, which DmxSimple
  ** uses by default. If you need to change that, do it here. */
  DmxSimple.usePin(3);

  /* DMX devices typically need to receive a complete set of channels
  ** even if you only need to adjust the first channel. You can
  ** easily change the number of channels sent here. If you don't
  ** do this, DmxSimple will set the maximum channel number to the
  ** highest channel you DmxSimple.write() to. */
  DmxSimple.maxChannel(6);
  pinMode(rele, OUTPUT);           // set rele pin as output
  pinMode(pin_trigger, OUTPUT);    // set rele pin as output
  Serial.begin(9600);              // Serial start
  lastPerformanceTime = millis() + idleDelay;  // Mark for counting idle_delay_time and make it start right away
  Serial.println("Press a Key to enter test mode...");
  if (Serial.available()) {
    Serial.println("Entering test mode...");
    test_mode ();
  }
  default_lights ();
  Serial.println("**** Arduino in standby waiting for a next time execution");
}

void loop() {
  
  if (idle_time_expired()) {
    // Delay time expired, start the performance
    wait_trigger ();
    // START PERFORMANCE
    Serial.println("Performance activated!!");
    start_smoke ();
    Serial.println("wait 10 seconds");
    delay (10000);
    performance_lights ();
    stop_smoke ();
    delay (5000);
    start_video ();
    Serial.println("wait Video to end");
    delay (performance_duration);
    // int performance_duration = 140000;
    default_lights ();
    restart();
  }
}

void performance_lights () {
  Serial.println("Processing dmx values for Lights Performance...");
  // Declare temporal markers
  boolean dim1_done = false;
  boolean dim2_done = false;
  boolean dim3_done = false;
  boolean dim4_done = false;
  boolean not_finished = true;
  // Process dmx
  while (not_finished) {
    if (dim1_val != Pdim1)
    {
      if (dim1_val > Pdim1){
        dim1_val --;
      } else if (dim1_val < Pdim1) {
        dim1_val ++;
      }
    }else{
      // Fan has reached the right amount
      dim1_done = true;
    }
    // Process DIM2 dmx
    if (dim2_val != Pdim2)
    {
      if (dim2_val > Pdim2){
        dim2_val --;
      } else if (dim2_val < Pdim2) {
        dim2_val ++;
      }
    }else{
      // Pump has reached the right amount
      dim2_done = true;
    }
    // Process DIM3 dmx
    if (dim3_val != Pdim3)
    {
      if (dim3_val > Pdim3){
        dim3_val --;
      } else if (dim3_val < Pdim3) {
        dim3_val ++;
      }
    }else{
      // Pump has reached the right amount
      dim3_done = true;
    }
    // Process DIM4 dmx
    if (dim4_val != Pdim4)
    {
      if (dim4_val > Pdim4){
        dim4_val --;
      } else if (dim4_val < Pdim4) {
        dim4_val ++;
      }
    }else{
      // Pump has reached the right amount
      dim4_done = true;
    }
    
    /* Update DMX channels for pump and fan */
    DmxSimple.write(dimmer_DMX_add, dim1_val);
    DmxSimple.write(dimmer_DMX_add+1, dim2_val);
    DmxSimple.write(dimmer_DMX_add+2, dim3_val);
    DmxSimple.write(dimmer_DMX_add+3, dim4_val);
    /* Small delay to slow down the ramping */
    delay(dmx_delay);
    //Check if we already finished
    if (dim1_done && dim2_done && dim3_done && dim4_done) {
      not_finished = false;
    }
  }
  Serial.println("Processing PERFORMANCE LIGHTS dmx values done!");
}

void default_lights (){
  Serial.println("Processing dmx values for Lights DEFAULT...");
  // Declare temporal markers
  boolean dim1_done = false;
  boolean dim2_done = false;
  boolean dim3_done = false;
  boolean dim4_done = false;
  boolean not_finished = true;
  // Process dmx
  while (not_finished) {
    if (dim1_val != Ddim1)
    {
      if (dim1_val > Ddim1){
        dim1_val --;
      } else if (dim1_val < Ddim1) {
        dim1_val ++;
      }
    }else{
      // Fan has reached the right amount
      dim1_done = true;
    }
    // Process DIM2 dmx
    if (dim2_val != Ddim2)
    {
      if (dim2_val > Ddim2){
        dim2_val --;
      } else if (dim2_val < Ddim2) {
        dim2_val ++;
      }
    }else{
      // Pump has reached the right amount
      dim2_done = true;
    }
    // Process DIM3 dmx
    if (dim3_val != Ddim3)
    {
      if (dim3_val > Ddim3){
        dim3_val --;
      } else if (dim3_val < Ddim3) {
        dim3_val ++;
      }
    }else{
      // Pump has reached the right amount
      dim3_done = true;
    }
    // Process DIM4 dmx
    if (dim4_val != Ddim4)
    {
      if (dim4_val > Ddim4){
        dim4_val --;
      } else if (dim4_val < Ddim4) {
        dim4_val ++;
      }
    }else{
      // Pump has reached the right amount
      dim4_done = true;
    }
    
    /* Update DMX channels for pump and fan */
    DmxSimple.write(dimmer_DMX_add, dim1_val);
    DmxSimple.write(dimmer_DMX_add+1, dim2_val);
    DmxSimple.write(dimmer_DMX_add+2, dim3_val);
    DmxSimple.write(dimmer_DMX_add+3, dim4_val);
    /* Small delay to slow down the ramping */
    delay(dmx_delay);
    //Check if we already finished
    if (dim1_done && dim2_done && dim3_done && dim4_done) {
      not_finished = false;
    }
  }
  Serial.println("Processing DEFAULT LIGHTS dmx values done!");
}

void test_mode () {
}

void wait_trigger () {
  Serial.println("Wait for trigger");
  long time_trigger = millis();
  boolean trigger = false;
  
  while (!trigger) {
    //if we got a trigger
    if (button_trigger ()) {
      Serial.println("We got trigger!!!!!!");
      trigger = true;
      //activate
    }else{
      // Check if we reached the timeout to be activated
      if (time_trigger + activation_timelimit < millis()) {   //10 seconds of time limit
        //activate due timout
        trigger = true;
        Serial.println("Trigger time out, we start anyway");
      }
      //otherwise wait
    }
  }
}

boolean button_trigger () {
  //debounce
  int reading = digitalRead(pin_trigger);
  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  } 
  if ((millis() - lastDebounceTime) > debounceDelay) {
    buttonState = reading;
  }
  lastButtonState = reading;
  if (buttonState == HIGH) {
    Serial.println("Button HIGH");
    buttonState = LOW;
    return true;
  }else{
    return false;
  }
}

void start_video () {
  //Press play in the DVD video and start counting
  Serial.println("Video starting");
  digitalWrite (rele,HIGH);
  delay (500);
  digitalWrite (rele, LOW);
}

void restart() {
  //restart
  lastPerformanceTime = millis();  // Mark for counting idle_delay_time
  Serial.println("********************** RESTART *********************");
  Serial.println("Arduino in standby waiting for a next time execution");
}

// Arduino in standby
boolean idle_time_expired () {
  if ((millis() - lastPerformanceTime) > idleDelay) {
    // whatever the reading is at, it's been there for longer
    // than the performance idle time, so take it as the actual current state:
    return true;
  }else{
    return false;
  }
}

void start_smoke (){
  Serial.println("Processing Smoke dmx values...");
  // Declare temporal markers
  boolean fan_done = false;
  boolean pump_done = false;
  boolean not_finished = true;
  // Process fan dmx
  while (not_finished) {
    if (smoke_fan_val != Psmoke_fan)
    {
      if (smoke_fan_val > Psmoke_fan){
        smoke_fan_val --;
      } else if (smoke_fan_val < Psmoke_fan) {
        smoke_fan_val ++;
      }
    }else{
      // Fan has reached the right amount
      fan_done = true;
    }
    // Process pump dmx
    if (smoke_pump_val != Psmoke_pump)
    {
      if (smoke_pump_val > Psmoke_pump){
        smoke_pump_val --;
      } else if (smoke_pump_val < Psmoke_pump) {
        smoke_pump_val ++;
      }
    }else{
      // Pump has reached the right amount
      pump_done = true;
    }
    /* Update DMX channels for pump and fan */
    DmxSimple.write(smoke_DMX_add, smoke_fan_val);
    DmxSimple.write(smoke_DMX_add+1, smoke_pump_val);
    /* Small delay to slow down the ramping */
    delay(dmx_delay);
    //Check if we already finished
    if (fan_done && pump_done) {
      not_finished = false;
    }
  }
  Serial.println("Processing Smoke dmx values done!");
}

void stop_smoke (){
  Serial.println("Setting Smoke dmx values to default...");
  // Decalre temporal markers
  boolean fan_done = false;
  boolean pump_done = false;
  boolean not_finished = true;
  // Process fan dmx
  while (not_finished) {
    if (smoke_fan_val != Dsmoke_fan)
    {
      if (smoke_fan_val > Dsmoke_fan){
        smoke_fan_val --;
      } else if (smoke_fan_val < Dsmoke_fan) {
        smoke_fan_val ++;
      }
    }else{
      // Fan has reached the right amount
      fan_done = true;
    }
    // Process pump dmx
    if (smoke_pump_val != Dsmoke_pump)
    {
      if (smoke_pump_val > Dsmoke_pump){
        smoke_pump_val --;
      } else if (smoke_pump_val < Dsmoke_pump) {
        smoke_pump_val ++;
      }
    }else{
      // Pump has reached the right amount
      pump_done = true;
    }
    /* Update DMX channels for pump and fan */
    DmxSimple.write(smoke_DMX_add, smoke_fan_val);
    DmxSimple.write(smoke_DMX_add+1, smoke_pump_val);
    /* Small delay to slow down the ramping */
    delay(dmx_delay);
    //Check if we already finished
    if (fan_done && pump_done) {
      not_finished = false;
    }
  }
  Serial.println("Smoke dmx values to default!");
}
  
