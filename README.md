# geom_show
Simple scripts to parse FreeBSD GEOM configuration and show information about disks, partitions, volumes and etc.

- **geom_show.awk** is an awk-script which makes the job of parsing sysctl kern.geom.confxml variable
- **geom_show.sh** is a wrapper to make things simplier.

### Examples
```
zmey@fbsd:~ % ./geom_show.sh -l -c DISK -s ";"
Class;Provider;Mediasize;Sectorsize;Stripesize;Stripeoffset;Heads;Sectors;RPM;Ident;Description
DISK;ada1;52428800;512;0;0;16;63;unknown;VBef22e825-34dd5784;VBOX HARDDISK
DISK;ada0;25769803776;512;0;0;16;63;unknown;VB05968cbc-2007b6c8;VBOX HARDDISK
DISK;cd0;0;2048;0;0;0;0;unknown;;VBOX CD-ROM
DISK;da1;740294656;512;0;0;64;32;unknown;;VBOX HARDDISK
DISK;da0;62914560;512;0;0;64;32;unknown;;VBOX HARDDISK

zmey@fbsd:~ % sysctl -n kern.geom.confxml | ./geom_show.awk -v class=DISK -v ofs=";"
Class;Provider;Mediasize;Sectorsize;Stripesize;Stripeoffset;Heads;Sectors;RPM;Ident;Description
DISK;ada1;52428800;512;0;0;16;63;unknown;VBef22e825-34dd5784;VBOX HARDDISK
DISK;ada0;25769803776;512;0;0;16;63;unknown;VB05968cbc-2007b6c8;VBOX HARDDISK
DISK;cd0;0;2048;0;0;0;0;unknown;;VBOX CD-ROM
DISK;da1;740294656;512;0;0;64;32;unknown;;VBOX HARDDISK
DISK;da0;62914560;512;0;0;64;32;unknown;;VBOX HARDDISK
```
