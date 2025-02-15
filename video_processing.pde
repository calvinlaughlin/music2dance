//---------------------------------------------------------------------
// name: mosaic_video.pde
// desc: mosAIc video player
//
// usage: to be run with the audio mosAIc in ChucK
//        mosaic-synth.ck -- sends OSC messages (video and startTime)
//        mosaic-synth-key.ck -- the above with keyboard controls
//
// author: Ge Wang
// date: spring 2023
//---------------------------------------------------------------------
import processing.video.*;
import oscP5.*;
import netP5.*;

// open sound control
OscP5 oscP5;
// array of movie objects
Movie[] g_movie = new Movie[128];

// list of video files (should match the order on the chuck/audio side)
// note: Processing has shown to have issues processing more than one video
//       alternative: look into the chunity version
String videoList[] = {
  "rain.mp4",
  "pulp.mp4",
  "dynamite2.mp4",
  "fever.mp4",
  "lalaland.mp4",
  "peanuts.mp4",
  "joker.mp4",
  "sound.mp4",
  "skeleton.mp4"
};

// variables for managing incoming control data
boolean updateRecv = true;
boolean rainbowEffect = false;
int whichVideo = 0;
float startTime = 0;

// initialization function (called by Processing)
void setup()
{
  // set window title
  surface.setTitle("audio mosAIc | video player");
  // make window resizable
  surface.setResizable( true );
  // canvas size
  size(1280, 720);
  
  // load each movie
  for( int i = 0; i < videoList.length; i++ )
  {
      // make a Movie object for each video
      g_movie[i] = new Movie(this, videoList[i] );
      // set it to loop
      g_movie[i].loop();
      // silence the video (since the audio will come from mosaic audio)
      g_movie[i].volume(0);
  }

  // set up open sound control for listening
  setupOSC( 12000 );
}

// set up open sound control for listening
void setupOSC( int port )
{
    // start oscP5, listening for incoming messages at port 12000
    oscP5 = new OscP5( this, port );
}

// read new frames from the movie (called by Movie)
void movieEvent( Movie m )
{
    m.read();
}

int red = 255;
int green = 255;
int blue = 255;

// render one frame (called by Processing)
void draw()
{  
    // if received update
    if( updateRecv )
    {
        // only jump once per update (e.g., once per incoming OSC message)
        g_movie[whichVideo].jump( startTime );
        // set to falst until next incoming message
        updateRecv = false;
    }

    // first number controls opacity
    // second number controls fade
    tint( red, green, blue, 150 ); 
    
    if(rainbowEffect)
    {
        applyRainbowEffect();
    }
    
    // draw
    image(g_movie[whichVideo], 0, 0, width, height);
}

void applyRainbowEffect()
{
    // Change tint over time to create a rainbow effect
    float hueValue = (millis() / 50.0) % 255; // Change this formula as needed
    colorMode(HSB, 255);
    tint(hueValue, 255, 255, 150);
    colorMode(RGB, 255); // Switch back to RGB mode
}


// incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage theOscMessage)
{
  // print the address pattern and the typetag of the received OscMessage
  // print("### received an osc message.");
  // print(" addrpattern: "+theOscMessage.addrPattern());
  // println(" typetag: "+theOscMessage.typetag());

  if( theOscMessage.checkAddrPattern("/mosaic/window")==true )
  {
    // check if the typetag is the right one
    if(theOscMessage.checkTypetag("if"))
    {
      // set flag
      updateRecv = true;
      // parse theOscMessage and extract the values from the osc message arguments.
      whichVideo = theOscMessage.get(0).intValue() % videoList.length;
      startTime = theOscMessage.get(1).floatValue();
      println(" values: "+whichVideo+", "+startTime);
      return;
    }  
  }
  // Check for the rainbow effect message
    if(theOscMessage.checkAddrPattern("/mosaic/rainbow") == true)
    {
        // Toggle the rainbow effect
        rainbowEffect = !rainbowEffect;
    }
  
}
