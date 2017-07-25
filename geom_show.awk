#!/usr/bin/awk -f

# Copyright (c) 2017 Mikhail Zakharov <zmey20000@yahoo.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

#
# Parse GEOM configuration
#
# Typical usage: 
# sysctl -n kern.geom.confxml | /path/to/geom_show.awk -v "class=DISK"
#
# Other options:
# 	-v provider="ada0"	Specify GEOM provider to show
#	-v noheader="yes"	Omit header
#	-v short="yes"		Short form prints only provider name(s)

# 2017.07.25	v 1.0

BEGIN {
	FS = ">|<"

	if (!ofs) 
		ofs = ","
	OFS = ofs

	gprov = provider
	gclass = class

	if (!gprov && !gclass)
		short = "yes"

	if (gclass && !gprov && !short && noheader != "yes")
		print_header(gclass)
}

function expanded_length(s) { gsub("\t", "        ", s); return length(s) }

function print_header(gclass) {
	common_header = "Class" ofs "Provider" ofs "Mediasize" ofs \
		"Sectorsize" ofs "Stripesize" ofs "Stripeoffset"
	disk_header = common_header ofs "Heads" ofs "Sectors" ofs "RPM" ofs \
		"Ident" ofs "Description"
	md_header =  common_header ofs "Heads" ofs "Sectors" ofs "Compression" \
		ofs "Access" ofs "Type"
	part_header = common_header ofs "Start" ofs "End" ofs "Index" ofs "Type"

	if (gclass == "DISK")
		print disk_header
	else if (gclass == "MD")
		print md_header
	else if (gclass == "PART")
		print part_header
	else print common_header
}

/<name>/,/<\/name>/ {
	depth = expanded_length($1)

	if (depth == 4)
		if ($3 == gclass || !gclass) {
		# We have found requested GEOM Class
			in_class = 1
			current_gclass = $3
		} else
			in_class = 0

	if (in_class && depth == 10) {
		if (gprov == $3) {
			# GEOM class for the given provider is detected
			gclass = current_gclass
			if (gclass && !short && noheader != "yes")
				print_header(gclass)
		}
		# This should be the GEOM Name
		gname = $3
	}
}

/<mediasize>/ || /<sectorsize>/ || /<stripesize>/ || /<stripeoffset>/ {
	if (!short && in_class && expanded_length($1) == 10)
	# These are common, default fields for all providers
			gdata = gdata ofs $3
	next
}

/<fwheads>/ || /<fwsectors>/ {
	if (!short && in_class && expanded_length($1) == 12)
		if (gclass == "DISK" || gclass == "MD")
			gdata = gdata ofs $3
	next
}

/<rotationrate>/ || /<ident>/ || /<descr>/ {
	if (!short && in_class && expanded_length($1) == 12 && gclass == "DISK")
		gdata = gdata ofs $3
	next
}

/<compression>/ || /<access>/ {
	if (!short && in_class && expanded_length($1) == 12 && gclass == "MD")
		gdata = gdata ofs $3
	next
}

/<type>/ {
	if (!short && in_class && expanded_length($1) == 12)
		if (gclass == "MD" || gclass == "PART")
			gdata = gdata ofs $3
	next
}

/<start>/ || /<end>/ || /<index>/ {
	if (!short && in_class && expanded_length($1) == 12 && gclass == "PART")
		gdata = gdata ofs $3
	next
}

/<\/provider>/  {
	if (in_class && expanded_length($1) == 8) {
		if (!gprov || gprov == gname)
			if (current_gclass != "LABEL" &&
				current_gclass != "DEV" ||
				current_gclass == gclass)
					if (!short)
						print gclass ofs gname gdata
					else {
						if (!entry_1)
							printf gname
						else
							printf ofs gname
						entry_1 = 1
					}
		gdata = ""
	}
}

END {
	if (short)
		printf "\n"
}

