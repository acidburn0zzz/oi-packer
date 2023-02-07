#!/usr/bin/bash

mkisofs -graft-points -dlrDJN -relaxed-filenames -o cidata.iso -V cidata user-data meta-data network-config
