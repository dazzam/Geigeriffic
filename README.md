Geigeriffic
===========

Geigeriffic is the Processing Sketch that I wrote to interface with the MightyOhm Geiger Counter kit in order to graph the Counts Per Second (CPS), Counts Per Minute (CPM), and the equivalent dose (expressed in µSv/hr).  This data is transmitted wirelessly from the serial port of the geiger counter using 2 XBee transceivers.  One of the transceivers is connected directly to the geiger counter's serial port using a serial adapter, and draws power from the geiger counter's own 2 AAA batteries.  The second transceiver is connected directly to the computer with a usb adapter.  I was able to configure the XBees to "speak" with each other using CoolTerm (Also had to install a driver here: http://www.ftdichip.com/Drivers/VCP.htm since using a Mac).  In the code, the one thing that must be configured is the serial port in the top of the code, which must correspond the the port the XBee is connected to (In Windows it is gonna be COM#, and in Mac just change the letters to match the ones that CoolTerm is connecting to in prefrences.  

I am also in the process of writing firmware for the geiger counter's ATTINY microcontroller that will allow me to plug a GPS unit into it, and have it broadcast that along with the radiation levels.  This is still a work in progress, and I will post as I make improvements and achieve milestones.

-TechieTrekkie