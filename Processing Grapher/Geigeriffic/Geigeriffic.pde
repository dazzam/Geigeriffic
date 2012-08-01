import processing.serial.*;
Serial port;
String data="";

PImage img;
PFont font;

float[] cpsArray=new float[1150];
float[] cpmArray=new float[1150];
float[] uSvArray=new float[1150];

String filePath = "/Users/Dillon/Desktop/Dropbox/Blue_Stamp_Engineering/Geiger Counter/Geigeriffic Logs/" + year()+"|"+month()+"|"+day()+" "+hour()+":"+minute() + ".csv"; 

String mode="";
int cps;
int cpm;
String uSvString;
int uSvInt;
String Satellites;
String lat;
float goodLat;
String latLetter;
String lon;
float goodLon;
String lonLetter;
String altitude;
String altLetter;
String fix="Void";

boolean firstContact=true;
boolean writeData=false;

void setup()
{
  img = loadImage("display.jpg");
  size(screen.width, screen.height);
  println(Serial.list());
  port=new Serial(this, "/dev/tty.usbserial-A1011FUU", 9600);//What is Port?
  port.write("$PMTK314,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
  delay(500);

  //Wait until recieve first message
  port.bufferUntil('\n');
  smooth();
  frameRate(8);

  //Write to File
  String[] csvTitle= {
    "Date, Time, CPS, CPM, µSv/hr, Mode, Lat, Lon, Satelites, Altitude"
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
  fill(277, 198, 58);  
  text("Current Mode: "+mode, 1300, 740);  

  if (fix=="Void")
  {
    fill(211, 29, 25);
  }
  else if (fix=="Active")
  {
    fill(70, 144, 46);
  }  
  text("GPS Fix: "+fix, 1300, 780);

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
    if (data.charAt(0)=='$')
    {
      if (data.charAt(3)=='G' && data.charAt(4)=='G' && data.charAt(5)=='A') 
      {
        String[] gpsvalues = splitTokens(data, ",");
        println(gpsvalues);
        if (float(gpsvalues[2])==0)
        {
          Satellites="Void";
          lat="Void";
          latLetter="Void";
          lon="Void";
          lonLetter="Void";
          altitude="Void";
          altLetter="Void";
          fix="Void";
        }
        else if (float(gpsvalues[6])==1)
        {
          Satellites=gpsvalues[7];
          lat=gpsvalues[2];
          if(gpsvalues[2].charAt(4)=='.')//If Degrees is 2 digits
          {
             goodLat=float(gpsvalues[2].substring(0, 2))+(float(gpsvalues[2].substring(2, gpsvalues[2].length()))/60);
          }
          else if (lat.charAt(5)=='.')//If Degrees is 3 digits
          {
            goodLat=float(gpsvalues[2].substring(0, 3))+(float(gpsvalues[2].substring(3, gpsvalues[2].length()))/60);
          }
         
          latLetter=gpsvalues[3];
          lon=gpsvalues[4];
          if(gpsvalues[4].charAt(4)=='.')//If Degrees is 2 digits
          {
             goodLon=float(gpsvalues[4].substring(0, 2))+(float(gpsvalues[4].substring(2, gpsvalues[4].length()))/60);
          }
          else if (lon.charAt(5)=='.')//If Degrees is 3 digits
          {
            goodLon=float(gpsvalues[4].substring(0, 3))+(float(gpsvalues[4].substring(3, gpsvalues[4].length()))/60);
          }
          lonLetter=gpsvalues[5];
          altitude=gpsvalues[9];
          altLetter=gpsvalues[10];
          fix="Active";
        }
      }
      else
      {
        port.write("$PMTK314,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
      }
      
    }
    else if (data.charAt(0)=='C')
    {
      //Grab the Actual values from this data string
      String[] values = splitTokens(data, ", ");
      println(values);
      cps=int(values[1]);
      println(cps);
      cpm=int(values[3]);
      uSvString=values[5];
      uSvInt=int(values[5]);
      mode = values[6].substring(0, values[6].length() - 1);
      if (writeData)
      {
        String[] csvData= {
month()+"/"+day()+"/"+year()+","+hour()+":"+minute()+":"+second()+","+cps+","+cpm+","+uSvString+","+mode+","+goodLat+" "+latLetter+","+goodLon+" "+lonLetter+","+Satellites+","+altitude+" "+altLetter
        };
        println("Blah");
        println(csvData);
        appendToFile(filePath, csvData);
      }
    }
  }
  else
  {
    firstContact=false;
    writeData=true;
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

