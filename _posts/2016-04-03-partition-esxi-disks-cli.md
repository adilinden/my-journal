---
layout: post
title: Partition And Format ESXi Disks using CLI
date: 2016-04-03 16:21:00
comments: 
tags:
  - vmware
  - esxi
category:
  - Sysadmin
---

Today I needed to remove two disks from an ESXi 5.5 host and replace them with another set of used disks.  This describes the process I used to condition these disks with vmfs5 partitions using SSH access and command line commands. 

Enable SSH

    <F2> Customize System/View Logs
    Troubleshooting Options
    Enable SSH

Connect to host via SSH.  Optionally disable warnings about SSH being enabled on the host.

    vim-cmd hostsvc/advopt/update UserVars.SuppressShellWarning long 1

See if any disks are used as scratch partition.

    vim-cmd hostsvc/advopt/view ScratchConfig.ConfiguredScratchLocation

Result:

    ~ # vim-cmd hostsvc/advopt/view ScratchConfig.ConfiguredScratchLocation
    (vim.option.OptionValue) [
       (vim.option.OptionValue) {
          dynamicType = <unset>, 
          key = "ScratchConfig.ConfiguredScratchLocation", 
          value = "/vmfs/volumes/57017270-43f7d020-b2d0-b8ac6f929c2c/.locker", 
       }
    ]

If result indicates the scratch partition is using an existing disk, then create a temporary scratch location on ramdisk and point config to it.

    mkdir /tmp/.scratch
    vim-cmd hostsvc/advopt/update ScratchConfig.ConfiguredScratchLocation string /tmp/.scratch

Reboot host for new scratch location to take effect then connext to host via SSH.  List all available disks.

    ls -l /vmfs/devices/disks/

Result:

    ~ # ls -l /vmfs/devices/disks/
    total 3247613391
    -rw-------    1 root     root     4010803200 Apr  3 20:05 mpx.vmhba32:C0:T0:L0
    -rw-------    1 root     root       4161536 Apr  3 20:05 mpx.vmhba32:C0:T0:L0:1
    -rw-------    1 root     root     262127616 Apr  3 20:05 mpx.vmhba32:C0:T0:L0:5
    -rw-------    1 root     root     262127616 Apr  3 20:05 mpx.vmhba32:C0:T0:L0:6
    -rw-------    1 root     root     115326976 Apr  3 20:05 mpx.vmhba32:C0:T0:L0:7
    -rw-------    1 root     root     299876352 Apr  3 20:05 mpx.vmhba32:C0:T0:L0:8
    -rw-------    1 root     root     160000000000 Apr  3 20:05 t10.ATA_____SAMSUNG_HE161HJ_______________________________S209J90Z803673
    -rw-------    1 root     root     159998934528 Apr  3 20:05 t10.ATA_____SAMSUNG_HE161HJ_______________________________S209J90Z803673:1
    -rw-------    1 root     root     1500301910016 Apr  3 20:05 t10.ATA_____ST31500341AS________________________________________9VS3D7RQ
    -rw-------    1 root     root     1500300844544 Apr  3 20:05 t10.ATA_____ST31500341AS________________________________________9VS3D7RQ:1
    lrwxrwxrwx    1 root     root            20 Apr  3 20:05 vml.0000000000766d68626133323a303a30 -> mpx.vmhba32:C0:T0:L0
    lrwxrwxrwx    1 root     root            22 Apr  3 20:05 vml.0000000000766d68626133323a303a30:1 -> mpx.vmhba32:C0:T0:L0:1
    lrwxrwxrwx    1 root     root            22 Apr  3 20:05 vml.0000000000766d68626133323a303a30:5 -> mpx.vmhba32:C0:T0:L0:5
    lrwxrwxrwx    1 root     root            22 Apr  3 20:05 vml.0000000000766d68626133323a303a30:6 -> mpx.vmhba32:C0:T0:L0:6
    lrwxrwxrwx    1 root     root            22 Apr  3 20:05 vml.0000000000766d68626133323a303a30:7 -> mpx.vmhba32:C0:T0:L0:7
    lrwxrwxrwx    1 root     root            22 Apr  3 20:05 vml.0000000000766d68626133323a303a30:8 -> mpx.vmhba32:C0:T0:L0:8
    lrwxrwxrwx    1 root     root            72 Apr  3 20:05 vml.01000000002020202020202020202020203956533344375251535433313530 -> t10.ATA_____ST31500341AS________________________________________9VS3D7RQ
    lrwxrwxrwx    1 root     root            74 Apr  3 20:05 vml.01000000002020202020202020202020203956533344375251535433313530:1 -> t10.ATA_____ST31500341AS________________________________________9VS3D7RQ:1
    lrwxrwxrwx    1 root     root            72 Apr  3 20:05 vml.0100000000202020202020533230394a39305a38303336373353414d53554e -> t10.ATA_____SAMSUNG_HE161HJ_______________________________S209J90Z803673
    lrwxrwxrwx    1 root     root            74 Apr  3 20:05 vml.0100000000202020202020533230394a39305a38303336373353414d53554e:1 -> t10.ATA_____SAMSUNG_HE161HJ_______________________________S209J90Z803673:1

In this case our physical disks are:

    t10.ATA_____SAMSUNG_HE161HJ_______________________________S209J90Z803673
    t10.ATA_____ST31500341AS________________________________________9VS3D7RQ

Erase or disks by creating a new disk label.

    partedUtil mklabel /vmfs/devices/disks/t10.ATA_____SAMSUNG_HE161HJ_______________________________S209J90Z803673 gpt
    partedUtil mklabel /vmfs/devices/disks/t10.ATA_____ST31500341AS________________________________________9VS3D7RQ gpt

Determine the usable beginning and end sectors of our two disks.

    partedUtil getUsableSectors /vmfs/devices/disks/t10.ATA_____SAMSUNG_HE161HJ_______________________________S209J90Z803673
    partedUtil getUsableSectors /vmfs/devices/disks/t10.ATA_____ST31500341AS________________________________________9VS3D7RQ

Result:

    ~ # partedUtil getUsableSectors /vmfs/devices/disks/t10.ATA_____SAMSUNG_HE161HJ_______________________________S209J90Z803673
    34 312499966
    ~ # partedUtil getUsableSectors /vmfs/devices/disks/t10.ATA_____ST31500341AS________________________________________9VS3D7RQ
    34 2930277134

Create new partitions on each disk using all available space.  Note the syntax for partedUtil in this case `Set Partitions : setptbl <diskName> <label> ["partNum startSector endSector type/guid attr"]*`.  It is recommended to use a `startSector` value of 128 for vmfs3 and 2048 for vmfs5.

    partedUtil setptbl "/vmfs/devices/disks/t10.ATA_____SAMSUNG_HE161HJ_______________________________S209J90Z803673" gpt "1 2048 312499966 AA31E02A400F11DB9590000C2911D1B8 0"
    partedUtil setptbl "/vmfs/devices/disks/t10.ATA_____ST31500341AS________________________________________9VS3D7RQ" gpt "1 2048 2930277134 AA31E02A400F11DB9590000C2911D1B8 0"

Format each partition using vmfs5 file system.

    vmkfstools -C vmfs5 -b 1m -S Datastore1 /vmfs/devices/disks/t10.ATA_____SAMSUNG_HE161HJ_______________________________S209J90Z803673:1
    vmkfstools -C vmfs5 -b 1m -S Datastore2 /vmfs/devices/disks/t10.ATA_____ST31500341AS________________________________________9VS3D7RQ:1


Create a scratch partition on disk and set it.

    mkdir /vmfs/volumes/Datastore1/.scratch
    vim-cmd hostsvc/advopt/update ScratchConfig.ConfiguredScratchLocation string /vmfs/volumes/Datastore1/.scratch

Reboot the ESXi host for scratch partition setting to take effect.
