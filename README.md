# Wifi Qr connect (Mac OS)

Since every device has this option I was annoyed why my Mac doesn't have this feature, sometime its really hard to find the right wifi in heavy zone like Universities.

## Installation

### Git clone

* Clone this repo.
```
git clone https://github.com/anoying-kid/Wifi-Qr-Connect.git
```

* Install required libraries
```
pip install -r requirements.txt
```

## Usage

* Run the file connect_to_wifi.py using 
```
python3 connect_to_wifi.py
``` 

* New pop screen will come of your webcam, show the qr code into webcam.

* If the screen stops that means the code is working and wait for 5-10 seconds.

> **Note:** Running this for the time may ask you for the camera permission after that rerun the program.

[![Youtube video](https://img.youtube.com/vi/GmNAa8-BM3Y/0.jpg)](https://www.youtube.com/watch?v=GmNAa8-BM3Y)

## Only for MacOS

You can furthur make a shortcut for that

> **Open Shortcut App \> New Shortcut \> Scripting \> Run Shell Script \> python3 connect_to_wifi.py \> First run for giving required permission then save.**

[LICENSE](./LICENSE)