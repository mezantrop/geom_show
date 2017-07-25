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

zmey@fbsd:~ % sysctl -n kern.geom.confxml | ./geom_show.awk -v class=PART -v ofs=" "
Class Provider Mediasize Sectorsize Stripesize Stripeoffset Start End Index Type
PART ada0p3 1073700352 512 0 3221245952 48234536 50331606 3 freebsd-swap
PART ada0p2 24695537664 512 0 544768 1064 48234535 2 freebsd-ufs
PART ada0p1 524288 512 0 20480 40 1063 1 freebsd-boot
```
