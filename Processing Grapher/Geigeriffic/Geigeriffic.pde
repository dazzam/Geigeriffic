import processing.serial.*;
Serial port;
String data="";

PImage img;
PFont font;

float[] cpsArray=new float[1150];
float[] cpmArray=new float[1150];
float[] uSvArray=new float[1150];

String filePath = "/Users/Dillon/Desktop/Dropbox/Blue Stamp Engineering/Geiger Counter/Geigeriffic Logs/" + year()+"|"+month()+"|"+day()+" "+hour()+":"+minute() + ".csv"; 

String mode="";
int cps;
int cpm;
String uSvString;
int uSvInt;

boolean firstContact=true;
boolean writeData=true;

void setup()
{
  img = loadImage("display.jpg");
  size(screen.width, screen.height);
  println(Serial.list());
  port=new Serial(this, "/dev/tty.usbserial-A1011FUU", 9600);//What is Port?

  delay(500);

  //Wait until recieve first message
  port.bufferUntil('\n');
  smooth();
  frameRate(8);

  //Write to File
  String[] csvTitle= {
    "Date, Time, CPS, CPM, µSv/hr, Mode"
  };
  appendToFile(filePath, csvTitle);
}//End Setup

void draw()
{
  background(255, 255, 255);
  image(img, 0, 0);
  fill(50, 50, 50);

  //Graph Table
  textSize(30);
  fill(109, 207, 71);  
  text("Current CPS: "+cps, 1300, 620);
  fill(109, 41, 71);  
  text("Current CPM: "+cpm, 1300, 660);
  fill(37, 87, 223);  
  text("Current µSv/hr: "+uSvString, 1300, 700);
  fill(238, 58, 0);  
  text("Current Mode: "+mode, 1300, 740);  

  //Grid Lines
  for (int i = 0 ;i<=width/20;i++)
  {
    strokeWeight(1);
    stroke(200);
    line((-frameCount%20)+i*20-450, 375, (-frameCount%20)+i*20-450, height);
    line(0, i*20 +375, width-450, i*20+375);
  }
  
  //uSv/hr Graph
  noFill();
  stroke(37, 87, 223);
  strokeWeight(2);
  beginShape();
  for (int i = 0; i<uSvArray.length;i++)
  {
    vertex(i, 825-uSvArray[i]);
  }
  endShape();
  for (int i = 1; i<uSvArray.length;i++)
  {
    uSvArray[i-1] = uSvArray[i];
  }
  uSvArray[uSvArray.length-1]=(int) ((float(uSvInt)/90.0)*350.0);

  //CPS Graph
  noFill();
  stroke(109, 207, 71);
  strokeWeight(2);
  beginShape();
  for (int i = 0; i<cpsArray.length;i++)
  {
    vertex(i, 825-cpsArray[i]);
  }
  endShape();
  for (int i = 1; i<cpsArray.length;i++)
  {
    cpsArray[i-1] = cpsArray[i];
  }
  cpsArray[cpsArray.length-1]=(int) ((float(cps)/90.0)*350.0);
}//END DRAW

void serialEvent(Serial port)
{
  if (!firstContact)//Ignore first contact, information incorrect
  {
    data = port.readStringUntil('\n');
    data = data.substring(0, data.length() - 1);
    println(data);
    //Grab the Actual values from this data string
    String[] values = splitTokens(data, ", ");
    println(values);
    cps=int(values[1]);
    println(cps);
    cpm=int(values[3]);
    uSvString=values[5];
    uSvInt=int(values[5]);
    mode=values[6];
    if (writeData)
    {
      String[] csvData= {
        month()+"/"+day()+"/"+year()+","+hour()+":"+minute()+":"+second()+","+cps+","+cpm+","+uSvString+","+mode
      };
      appendToFile(filePath, csvData);
    }
  }
  else
  {
    firstContact=false;
  }
}

//http://forum.processing.org/topic/log-data-on-a-csv-file-is-it-possible
void appendToFile(String filePath, String[] data)
{
  PrintWriter pw = null;
  try
  {
    pw = new PrintWriter(new BufferedWriter(new FileWriter(filePath, true))); // true means: "append"
    for (int i = 0; i < data.length; i++)
    {
      pw.println(data[i]);
    }
  }
  catch (IOException e)
  {
    // Report problem or handle it
    e.printStackTrace();
  }
  finally
  {
    if (pw != null)
    {
      pw.close();
    }
  }
}

