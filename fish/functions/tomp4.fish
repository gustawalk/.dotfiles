function tomp4 -a input_file
    set output_file (basename $input_file | sed 's/\.[^.]*$/.mp4/')

    ffmpeg -i $input_file \
        -c:v libx264 \
        -preset medium \
        -crf 24 \
        -pix_fmt yuv420p \
        -movflags +faststart \
        -c:a aac \
        -b:a 192k \
        $output_file
end
