# reencode

# Description

This script reencodes video to x264 or x265 and optionally scales it 

# Usage

reencode.sh [-h] [-c <codec>] [-s <scale>] [-i <input file>] [-o <output file>] [-p <preset>] [-r <rate>] [-d]
-    -h Show help (this).
-    -c codec: [264] for H264 or [265] for HEVC - H265 (default is 265).
-    -s scale e.g. [720] for 720p [360] for 360p. The other dimension is calculated proportionally (default is keep the current dimensions).
-    -r rate (CRF). CRF scale is 0–51, where 0 is lossless and 51 is worst quality possible. A subjectively sane range is 17–28 (default is 23). 
-    -i input file (required).
-    -p preset (ultrafast, superfast, veryfast, faster, fast, medium  [default preset], slow, slower, veryslow)
-    -o output file (if not provided, keep the base file name amd add extension 'mkv'. If the source file already has 'mkv' extension, add 'reencoded' to the file name).
-    -d Delete input file upon successful reencode (default is t o leave it in place).

# Example

Reencode AVI to MKV with HEVC and the original resolution
```
for i in *.avi; do reencode.sh -i $i; done
```
Reencode 1080p H264 to HEVC scaling down to 720p
```
ls *.mkv | while read i; do echo reencode.sh -i "'"$i"'" -o "'"$(echo $i | sed 's/1080p/720p/' | sed 's/x264/HEVC/')"'" -s 720; done
```



