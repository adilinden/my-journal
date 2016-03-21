---
layout: post
title: Using Cisco IP Phones with Asterisk
date: 2005-10-10 00:35:20
comments: Yes
tags:
  - asterisk
  - cisco

redirect_from:
  - /article/using-cisco-ip-phones-with-asterisk/
category:
  - Sysadmin
assets: resources/2005-10-10-using-cisco-ip-phones-with-asterisk
---

My home telephone system is a Asterisk Open Source PBX. The actual handsets are Cisco IP phones. In this document I am describing the steps taken to setup the TFTP files needed to provision and manage Cisco phones.

Some additional Asterisk specific information worth reading:

* [Setup SiP on 7940 – 7960](http://www.voip-info.org/wiki-Setup+SiP+on+7940+-+7960)
* [Ring Tones](http://www.loligo.com/asterisk/Cisco/79xx/current/)

**_Cisco 7940_**

**Release 6.3**
Obtain the firmware zip file from Cisco CCO. Also grab the latest SIPDefault.cnf and SIPmacaddress.cnf. The example here is based on firmware version 6.3. Extract the zip archive into a directory:

    mkdir 7940-6.3
    cd 7940-6.3
    unzip ../P0S3-06-3-00.zip
    cd ..

Copy the firmware files and the SIPDefault.cnf configuration file to the `/tftpboot` directory.

    cp 7940-6.3/P0S* /tftpboot

    cp SIPDefault.cnf /tftpboot
Create `/tftpboot/OS79XX.TXT`with this content:

    P0S3-06-3-00

Edit `/tftpboot/SIPDefault.cnf` to show the proper image version. For example:

    image_version: P0S3-06-3-00

Further edit the `/tftpboot/SIPDefault.cnf` file by specifying all parameters that will be common to all 7940 phones on the system. Some example parameters to configure:

    proxy1_address: "192.168.77.4"
    proxy_register: 1
    sntp_server: "192.168.77.4"
    sntp_mode: unicast
    time_zone: CST

Next create a phone specific file. Copy the SIPmacaddress.cnf file to the `/tftpboot` directory replacing the ‘macaddress’ with the actual MAC address of the 7940 being configured. Note that the mac address for the 7940 needs to be upper case. The example assumes the 000f.3486.6628 MAC address.

    cp SIPmacaddress.cnf /tftpboot/SIP000F34866628.cnf

Edit the `/tftpboot/SIP000F34866628.cnf` and change phone specific parameters such as the extension numbers and logins. I actually reorganized the file and changed the comments, just to make it simpler for myself.

    # SIP Configuration File
    # 7940 w/2 lines

    # Line 1 Parameters
    line1_name: 211
    line1_authname: "211"
    line1_displayname: "User ID"
    line1_password: "test"

    # Line 2 Parameters
    line2_name: 212
    line2_authname: "212"
    line2_displayname: ""
    line2_password: "test"

    # Phone Label (Text desired to be displayed in upper right corner)
    # Has no effect on SIP messaging
    phone_label: ""

    # Remote Access Parameters for console or telnet login
    phone_prompt:   "SIP Phone"
    phone_password: "secretpassword"
    user_info: none

**Release 7.4**
Follow the steps for the 6.3 release first.

Obtain the firmware zip file from Cisco CCO. Extract the zip archive into the `/tftpboot` directory. This will place the release 7.4 firmware files and an updated OS79XX.TXT file in `/tftpboot`.

    cd /tftpboot
    unzip /path/to/P0S3-07-4-00.zip

The `/tftpboot/OS79XX.TXT` file should now contain this single line:

    P003-07-4-00

Edit `/tftpboot/SIPDefault.cnf` to show the proper image version.

    image_version: P0S3-07-4-00

Create `/tftpboot/XMLDefault.cnf.xml` with the following content:

    <Default>
      <callManagerGroup>
        <members>
          <member priority="0">
            <callManager>
              <ports>
                <ethernetPhonePort>2000</ethernetPhonePort>
              </ports>
              <processNodeName>192.168.77.4</processNodeName>
            </callManager>
          </member>
        </members>
      </callManagerGroup>
      <loadInformation6 model="IP Phone 7910"></loadInformation6>
      <loadInformation124 model"Addon 7914"></loadInformation124>
      <loadInformation9 model="IP Phone 7935"></loadInformation9>
      <loadInformation8 model="IP Phone 7940">P003-07-4-00</loadInformation8>
      <loadInformation7 model="IP Phone 7960">P003-07-4-00</loadInformation7>
      <loadInformation20000 model="IP Phone 7905"></loadInformation20000>
      <loadInformation30008 model="IP Phone 7902"></loadInformation30008>
      <loadInformation30007 model="IP Phone 7912"></loadInformation30007>
    </Default>

Symlink `/tftpboot/xmlDefault.CNF.XML` to `/tftpboot/XMLDefault.cnf.xml` to support Cisco’s spelling mistakes in various firmware releases.

Theory of operation for loading the 7.4 relase is as follows. With 7.4 Cisco introduced a “Universal Bootloader Application” which parses config files for firmware load information. With the 7.4 firmware the OS79XX.TXT file becomes obsolete.

A phone running pre-7.0 firmware will fetch OS79XX.TXT. The file causes the phone to upgrade firmware to the “Universal Bootloader Application”. Once the “Universal Bootloader Application” has been loaded the phone reboots and looks for configuration files. If the phone was previously running SIP it will look for “image_version:” information in SIPDefault.cnf to determine the image it should load. If the phone was previously running SCCP or has the factory firmware load it looks for load information in XMLDefault.cnf.xml.

**Hint**
To reboot the 7940/7960 without pulling the powercord press ‘*’, ’6′ and the ‘settings key’ (checkbox button) all at the same time.

**Custom Logo**
The logo has to meet some specific characteristics. See the Cisco site for details.

> The background space allocated for the image is 90 x 56 pixels. Images that are larger than this will automatically be scaled down to 90 x 56 pixels. The recommended file size for the image is from 5 to 15 Kb. For example, use logo_url: “http://10.10.10.10/companylogo.bmp”.
> 
> Note This parameter supports Windows 256 color bitmap format only. CMXML PhoneImage objects are not supported for this parameter. Using anything other than a Windows bitmap (.bmp) file can cause unpredictable results.”

Place the logo in `/var/www/asterisk`. Reference the logo in `/tftpboot/SIPDefault.cnf` or `/tftpboot/SIP000F34866628.cnf` by editing or adding the logo_url parameter:

    logo_url: "http://192.168.77.4/adisterisk/asterisk-tux.bmp"

**Additional Features**
The Cisco 7940 supports custom ring tone. Have a look at RINGLIST.DAT and these websites:

* [Ring Tones](http://www.loligo.com/asterisk/Cisco/79xx/current/)
* [Asterisk phone cisco 79xx](http://www.voip-info.org/wiki-Asterisk+phone+cisco+79xx)

Note that the RINGLIST.DAT file supports a path for the ringtone filename. This makes it possible to place the actually tone files into a subdirectory of `/tftpboot` such as `/tftpboot/ringtones`. The second site also explains how to address forwarding * and # keys to asterisk via dialplan.xml.

**_Cisco ATA186_**

Obtain the ATA186 SIP firmware from Cisco CCO. The version I am using for the purpose of this document is 3.2.0. Extract the zip archive into a temporary location.

    mkdir ata186-3.2.0
    cd ata186-3.2.0
    unzip ../ata_03_02_00_sip_041111_1.zip
    cd ..

The Cico ATA186 requires a binary configuration file. The tool to create a binary file from a text file has been provided by Cisco. Create a temporay location for the text onfiguration files. I like this to be a subdirectory of `/tftpboot`.

    mkdir /tftpboot/ata186_txt

Copy the firmaware image to `/tftpboot` and the configuration files to `/tftpboot/ata186_txt`. Change permissions on cfgfmt.linux to make it executable.

    cp ata186-3.1.1/ATA030200SIP041111A.zup /tftpboot
    cp ata186-3.1.1/cfgfmt.linux /tftpboot/ata186_txt
    cp ata186-3.1.1/ptag.dat /tftpboot/ata186_txt
    cp ata186-3.1.1/sip_example.txt /tftpboot/ata186_txt/atacommon.txt
    chmod 755 /tftpboot/ata186_txt/cfgfmt.linux

Create a phone specific file, such as `/tftpboot/ata186_txt/atamacaddress.txt` where ‘macaddress’ is replaced with the mac address of the ata device. Note that the mac address for the ATA186 needs to be lower case. For example create `/tftpboot/ata186_txt/ata0006d7a576d0.txt`:

    #txt
    include:atacommon.txt

    # Configuration information
    TftpURL:192.168.77.4
    NTPIP:192.168.77.4
    upgradecode:3,0x301,0x0400,0x0200,192.168.77.4,69,0x041111A,ATA030200SIP041111A.zup
    
    # Our asterisk server 
    Proxy:192.168.77.4
    SIPRegOn:1

    # line appearances
    UID0:201
    PWD0:test
    UID1:202
    PWD1:test

    # Make G.711u the default codec
    RxCodec:2
    TxCodec:2

    # Turn off G.711 silence suppression (VAD)
    AudioMode:0x00140014

Finally create the binary configuration file for the specific ATA186 by running the cfgfmt.linux tool:

    cd /tftpboot/ata186_txt
    ./cfgfmt.linux -sip ata0006d7a576d0.txt ../ata0006d7a576d0

**_Cisco 7905G_**

I understand that the Cisco 7905G is based on the ATA186 hardware. This explains why the firmware upgrade and configuration process for the 7905G phone is very much like the ATA186.

Obtain the SIP firmware for the Cisco 7905G from CCO. The firmware version I am using here is 1.2. Extract the .zip archive into a temporary location.

    mkdir 7905-1.2
    cd 7905-1.2
    unzip ../CP7905010200SIP040406A.zip
    cd ..

The Cisco 7905G requires a binary configuration file. We therefore create a working directory under our tftp server root directory.

    mkdir /tftpboot/7905g_txt

Copy the firmaware image to /tftpboot and the configuration files to `/tftpboot/7905g_txt`. Change permissions on cfgfmt.linux to make it executable.

    cp 7905-1.2/CP7905010200SIP040406A.zup /tftpboot/
    cp 7905-1.2/CP7905010200SIP040406A.sbin /tftpboot/
    cp 7905-1.2/cfgfmt.linux /tftpboot/7905g_txt/
    cp 7905-1.2/sip_ptag.dat /tftpboot/7905g_txt/
    cp 7905-1.2/sipexample.txt /tftpboot/7905g_txt/ldcommon.txt
    chmod 755 /tftpboot/7905g_txt/cfgfmt.linux

Create a phone specific file, such as `/tftpboot/7905g_txt/ldmacaddress.txt` where ‘macaddress’ is replaced with the mac address of the ata device. Note that the mac address for the 7905G needs to be lower case. For example create /tftpboot/7905g_txt/ld0006d7a576d0.txt:

    #txt
    include:ldcommon.txt

    # Logo
    #upgradelogo:0,0,none

    # line appearances
    UID:123
    PWD:0

    # The name to display on the phone (31 characters max)
    DisplayName:0

    # Configuration information
    UseTftp:1
    TftpURL:192.168.77.4
    upgradecode:3,0x501,0x0400,0x0100,192.168.77.4,0x040406A,CP7905010200SIP040406A.sbin

    # Time
    TimeZone:19
    NTPIP:192.168.77.4

    # Our asterisk server
    Proxy:192.168.77.4
    SIPRegOn:1

    # Dialstring sent when voicemail key is pressed
    VoiceMailNumber:0

    # Make G.711u the default codec
    RxCodec:2
    TxCodec:2

    # Turn off G.711 silence suppression (VAD)
    AudioMode:0x00000010

    # Some other defaults
    ForwardToVMDelay:4294967295

    # End

Finally create the binary configuration file for the specific 7905G by running the cfgfmt.linux tool:

    cd /tftpboot/7905g_txt
    ./cfgfmt.linux -sip -tsip_ptag.dat ld0006d7a576d0.txt ../ld0006d7a576d0

**Display Logo**
The Cisco 7905G supports loading a custom logo on the LCD. Doing so is a somewhat involved process. The Cisco tool to convert a bitmap into a file suitable for a 7905G only works on the Windows operating system

Create a black-and-white file 88 pixels wide and 27 pixels high. Save this file as a .bmp file. Note that the image will display negative on the 7905G display.

Use the bmp2logo.exe tool to create a binary image file. The imageID is an integer from 0 through 4294967295 and must be different than the identifier of the image loaded onto the 7905G now.

    bmp2logo imageID image.bmp image.logo

Place the image file on the tftpserver and specify the image file in the configuration for the 7905G using this parameter.
    
    upgradelogo:imageID,TFTPServerIP,image.logo
    
    
