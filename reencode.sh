#!/bin/bash
########################################
# This script reencodes video 
# to x264 or x265 and optionally scales it 
# then runs query defined in query.txt #
# usage:
# for i in *.avi; do reencode.sh $i; done
# scaling:
# -vf scale=540:-2:flags=lanczos
#  -vf scale=720:-2:flags=lanczos
########################################
usage() {             
  echo "Usage: $0 [-h] [-c <codec>] [-s <scale>] [-i <input file>] [-o <output file>] [-p <preset>] [-r <rate>] [-d]
    -h Show help (this).
    -c codec: [264] for H264 or [265] for HEVC - H265 (default is 265).
    -s scale e.g. [720] for 720p [360] for 360p. The other dimension is calculated proportionally (default is keep the current dimensions).
    -r rate (CRF). CRF scale is 0–51, where 0 is lossless and 51 is worst quality possible. A subjectively sane range is 17–28 (default is 23). 
    -i input file (required).
    -p preset (ultrafast, superfast, veryfast, faster, fast, medium  [default preset], slow, slower, veryslow)
    -o output file (if not provided, keep the base file name amd add extension 'mkv'. If thje source file already has 'mkv' extension, add 'reencoded' to the file name).
    -d Delete input file upon successful reencode (default is t o leave it in place).
" 1>&2 
}
exit_abnormal() {     
  usage
  exit 1
}
##############################################
# set defaults
codec="265"
scale=""
input_file=""
output_file=""
delete=0
rename=0
scale_arg=""
codec_arg=""
preset="medium"
rate=23
#
while getopts "c:s:i:o:p:r:dh" options
do
  case "${options}" in                   
    h) 
      usage
      exit 0
      ;;
    d)                      
      delete=1
      ;;
    i)                      
      input_file="${OPTARG}"
      ;;
    o)                      
      output_file="${OPTARG}"
      ;;
    p)                      
      preset="${OPTARG}"
      ;;
    r)                      
      rate="${OPTARG}"
      ;;
    s)                      
      scale="${OPTARG}"
      ;;
    c)                      
      codec="${OPTARG}"
      ;;
    :)                                   
      echo "Error: -${OPTARG} requires an argument." >&2
      exit_abnormal                       
      ;;
    *)                                    
      echo "Error: -${OPTARG} not recognized." >&2
      exit_abno
      mal                       
      ;;
  esac
done
[ -z "$input_file" ] && { echo "No input file specified" ; exit; }
[ ! -r "$input_file" ] && { echo "Input file does not exist or is not readable" ; exit; }
filename="${input_file##*/}"
extension="${filename##*.}"
file="${filename%.*}"
newext="mkv"
if [ "$extension" == "mkv" ]; then
   newext="reencoded.mkv"
	rename=1
fi
[ -z "$output_file" ] && output_file="${file}.${newext}" || rename=0
[[ ! -z "$scale" ]] && scale_arg="-vf scale=-2:${scale}:flags=lanczos"	
# if resizing, add -vf scale=-2:720
case "${codec}" in
     264)                      
      codec_arg="-c:v libx264" 
      ;;
    265)                                   
      codec_arg="-c:v libx265 -vtag hvc1"
      ;;
    *)                                    
      echo "Error: codec ${codec} not recognized." >&2
      exit_abnormal                       
      ;;
esac
cmd=$(echo ffmpeg -y -dn -i '"'$input_file'"' -max_interleave_delta 0  -movflags +faststart "$codec_arg" -crf $rate -preset $preset  $scale_arg  -map 0 -codec:a copy -codec:s copy '"'$output_file'"')
echo $cmd
eval $cmd
retVal=$?
if [ $retVal -ne 0 ]; then
   echo $(date "+%F %H:%M:%S") ERROR during encoding "'"$input_file"'". | tee -a ~/reencode.log
else
   echo $(date "+%F %H:%M:%S") Finished OK encoding "'"$input_file"'". | tee -a ~/reencode.log
   if [[ $delete -gt 0 ]]; then
      rm "$input_file"
      if [ $rename -gt 0 ]; then
        mv "${file}.${newext}" "$filename"
      fi
   fi
fi
#notify-send "$1 DONE"
