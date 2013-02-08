#!/usr/bin/perl

print "READING file: @ARGV[0]\n";

$filename=@ARGV[0];
$match=@ARGV[1];
$updated_line=@ARGV[2];

open (FD, $filename);
open (FDN, ">/tmp/tempfile");

print "Updated line = $updated_line\n";

while (<FD>)
{
  if (/$match/)
  {
    print FDN "$updated_line\n";
  }
  else
  {
    print FDN "$_";
  }
}

close (FDN);
close (FD);

`mv /tmp/tempfile $filename`
