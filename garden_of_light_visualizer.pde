import oscP5.*;
OscP5 oscP5;

int numBirds = 25;
int[] empty = {};
int counter = 0;
int frogFlag = 0;
Bird[] birds = new Bird[numBirds];

void setup() {
  size(512, 512, P3D); 
  surface.setLocation((displayWidth / 2) - width / 2, ((int)displayHeight / 2) - height / 2);
  
  //initialize OSC client
  oscP5 = new OscP5(this, 12000);
  
  //initialize bird objects
  for(int i = 0; i <birds.length; i++){
   birds[i] = new Bird(0, empty, 1, 0, 0); 
  }
  
  colorMode(HSB, 360, 100, 100);
}

void draw() {
  background(0);
  
  //draw the birds
  for(int i = 0; i <birds.length; i++){
   if(frogFlag == 1){birds[i].frog();}else{birds[i].pulse();}
  }
}

//OSC event handler
void oscEvent(OscMessage theOscMessage){
  //delay(80);
  
  //parse bird values
  if (theOscMessage.checkAddrPattern("/bird/")==true) {
  int col = 360;
  float amp = theOscMessage.get(0).floatValue();
  float pan = theOscMessage.get(1).floatValue() + 1;
  String time = theOscMessage.get(2).stringValue();
  String[] times = split(time, " ");
  int[] transients = int(times);
  
  //debug
  //println("pan:" + pan);
  //println("amp:" + amp);
  //println("transients:" + time);
  
  //draw birds
  birds[counter] = new Bird(col, transients, pan, amp, 0);
  counter = (counter + 1)%numBirds;
  }
  
  //parse frog value
  if(theOscMessage.checkAddrPattern("/frogs/")==true) {
    frogFlag = 1;
       birds[counter] = new Bird(150, empty, random(0, 2), 0, 0); 
       counter = (counter + 1)%numBirds;
  }else{frogFlag = 0;}
}

//bird class
class Bird {
 color c;
 int[] transients;
 float pan;
 float amp;
 int count;
 
 Bird(color tempC, int[] tempTransients, float tempPan, float tempAmp, int tempCount) {
   c = tempC;
   transients = tempTransients;
   count = tempCount;
   pan = map(tempPan, 0, 2, 70, 450);
   amp = map(tempAmp, 0, 1, 200, 255);
 }
 
 void pulse(){
   stroke(0);
   fill(c, amp);
   if(amp <= 0){amp = 0;}else{amp = amp - 10;}
   if(count <= transients.length-1){
     if(transients[count] <= 0){count ++; amp = 255;}else{transients[count] --;}
   }
   ellipse(pan, 243, 15, 25);
 }
 
 void frog(){
   stroke(0);
   amp = sin(count/10) * 100;
   fill(c, 100, amp);
   ellipse(pan, 243, 30, 25);
   count ++;
 }
}
