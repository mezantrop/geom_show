# Warning! This project has been migrated to GitLab with the same name.

<a href="https://www.buymeacoffee.com/mezantrop" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

# geom_show
Simple scripts to parse FreeBSD GEOM configuration (sysctl -n kern.geom.conftxt or sysctl -n kern.geom.confxml) and show information about disks, partitions, volumes and etc.

- **geom_show.awk** is the awk-script which makes the job of parsing sysctl kern.geom.confxml variable
- **geom_show.sh** is the wrapper to make things simpler.

See https://mezzantrop.wordpress.com/portfolio/geom_show/ for addition information.

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

- **sas2da.sh** translates SAS addresses to /dev/daXXs with drive sizes + drive serials and vendor info. It depends on geom_show.sh. Output is sorted by "Serial numbers" to group the same drives together in case they have several SAS connections.

### Examples
```
# ./sas2da.sh
Address Dev Size Serial Vendor Model
5000cca261280e69 da4 8001563222016 VJGR0XDX HGST HUH728080AL5204
5000cca261280e6a da5 8001563222016 VJGR0XDX HGST HUH728080AL5204
5000cca26128680d da13 8001563222016 VJGR6WGX HGST HUH728080AL5204
5000cca26128680e da12 8001563222016 VJGR6WGX HGST HUH728080AL5204
5000cca261289589 da15 8001563222016 VJGR9XBX HGST HUH728080AL5204
5000cca26128958a da14 8001563222016 VJGR9XBX HGST HUH728080AL5204
5000cca26128a42d da27 8001563222016 VJGRAWLX HGST HUH728080AL5204
5000cca26128a42e da28 8001563222016 VJGRAWLX HGST HUH728080AL5204
5000cca26128d551 da19 8001563222016 VJGRG51X HGST HUH728080AL5204
5000cca26128d552 da18 8001563222016 VJGRG51X HGST HUH728080AL5204
5000cca26128fc29 da46 8001563222016 VJGRJS7X HGST HUH728080AL5204
5000cca26128fc2a da47 8001563222016 VJGRJS7X HGST HUH728080AL5204
5000cca26129887d da2 8001563222016 VJGRV2YX HGST HUH728080AL5204
5000cca26129887e da3 8001563222016 VJGRV2YX HGST HUH728080AL5204
5000cca261298ab5 da41 8001563222016 VJGRV7JX HGST HUH728080AL5204
5000cca261298ab6 da40 8001563222016 VJGRV7JX HGST HUH728080AL5204
5000cca26129a071 da23 8001563222016 VJGRWPDX HGST HUH728080AL5204
5000cca26129a072 da22 8001563222016 VJGRWPDX HGST HUH728080AL5204
5000cca26129a21d da32 8001563222016 VJGRWTVX HGST HUH728080AL5204
5000cca26129a21e da33 8001563222016 VJGRWTVX HGST HUH728080AL5204
```
