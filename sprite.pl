#!/usr/bin/perl

use strict;
use Image::Magick;

my $sprite_dir = 'sprite';
my $sprite_css = 'sprite.css';
my $sprite_png = 'sprite.png';

my $line = 0;
my $column = 0;

my $count_png = `ls -1 $sprite_dir/*.png 2>/dev/null | wc -l`;
$count_png =~ s/\d$/0/;
my $lines_count = $count_png/10+1;
my $height = $lines_count*16;

my $res_sprite = Image::Magick->new();
$res_sprite->Set(size=>"160x$height");
#$res_sprite->ReadImage('canvas:white');
$res_sprite->Read('NULL:');

open (my $css_fh, '>', "$sprite_css") || die "Can't open > $sprite_css: $!";

print $css_fh <<"EOF";
[class^="icon-"] {
    display:inline-block;    
    width:16px;    
    height:16px;  
    vertical-align:text-top;  
    background-image:url(/sprite.png);  
    background-position:16px 16px;  
    background-repeat:no-repeat;
    margin-right: 8px;
} 
EOF

opendir(my $dh, $sprite_dir) || die "Can't open $sprite_dir: $!";
while (my $png_file = readdir $dh) {
    next unless $png_file =~ /^\w.*\.png$/;
    my ($icon_name) = ( $png_file =~ /^(.*)\.png$/ );
    my $icon = Image::Magick->new;	
    $icon->Read("png:$sprite_dir/$png_file");
    my ($icon_height, $icon_width) = $icon->Get('base-rows', 'base-columns');
    next unless $icon_height==16 and $icon_width==16;
    
    $res_sprite->Composite(
        image   => $icon,
        compose => 'over',
        x       => $column*16,
        y       => $line*16,
        gravity => 'NorthWest',
    );
    printf $css_fh ".icon-$icon_name { background-position: %dpx %dpx; }\n",-$column*16,-$line*16;
    
    $column++;
    if ( $column>9 ) {
        $column=0;
        $line++;
    }
    
}
closedir $dh;

close $css_fh;

$res_sprite->Write("png:$sprite_png");
