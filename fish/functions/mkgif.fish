function mkgif -a input_file
    set output_file (basename $input_file | sed 's/\.[^.]*$/.gif/')
    ffmpeg -i $input_file -vf scale=320:-1 -r 10 -f image2pipe -vcodec ppm - | convert -delay 10 -loop 0 - $output_file
end
