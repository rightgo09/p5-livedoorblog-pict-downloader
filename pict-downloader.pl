#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use URI;
use Furl;
use Text::Iconv;
use File::Spec;
use Encode qw/ encode_utf8 decode_utf8 /;

my $SAVE_DIR = "$ENV{HOME}/Pictures";

my $url = shift or die <<USAGE;
usage: carton exec perl pict-downloader.pl [URL]
USAGE
$url = URI->new($url);

print "URL: $url\n";

my $furl = Furl->new(
  agent => "Furl/pict-downloader.pl",
  timeout => 180,
);

$furl->env_proxy() if $ENV{HTTP_PROXY};

my $res = $furl->get($url);
die $res->status_line unless $res->is_success;
my $content = decode_utf8($res->content);

(my $title = $content) =~ s!^.*<title>(.*?)</title>.*$!$1!ms;
$title = encode_utf8($title);

print "Title: $title\n";

my $iconv = Text::Iconv->new('UTF-8-MAC' => 'UTF-8');

$title = decode_utf8($iconv->convert($title));
my $dir = File::Spec->catfile($SAVE_DIR, $title);
mkdir $dir or die $!;

print "Save directory: ".encode_utf8($dir)."\n";

my @picture_links;
push(@picture_links, $1) while $content =~ /<a.*?href="(.*?\.(jpe?g|gif|png))".*?>\s*<img.*?class="pict".*?>\s*<\/a>/g;
push(@picture_links, $1) while $content =~ /<img.*?src="(.*?[^-s]{2}\.(jpe?g|gif|png))".*?class="pict".*?>/g;

for my $link (@picture_links) {
  sleep 1;
  (my $file_name = $link) =~ s!^.*/([^/]+)$!$1!;
  $file_name = File::Spec->catfile($dir, $file_name);
  print encode_utf8($file_name)."\n";

  my $res = $furl->get($link);
  if ($res->is_success) {
    open my $fh, '>', $file_name or die $!;
    print $fh $res->content;
    close $fh;
  }
}

print "Finish!\n";

__END__
