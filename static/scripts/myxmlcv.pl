#!/usr/bin/perl -w
# xmlcv.pl: perl thing for transforming xml versions of a curriculum vitae 
# into various formats, using the xml resume library from 
# http://xmlresume.sourceforge.net/
#
# Also supports use Gary O'Sullivans openoffice patch:
# http://sourceforge.net/tracker/index.php?func=detail&aid=981727&group_id=29512&atid=396337
#
# v.0.1
# 
#               Copyright (C)2005  Charlie Harvey
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston,
# MA  02111-1307, USA.
# Also available on line: http://www.gnu.org/copyleft/gpl.html
#
use strict;
use XML::LibXSLT;
use XML::LibXML;

# Tweak these settings! 
# ---------------------

my @TARGETS = ();
# If you need pdf versions of your cv/resume, you'll want to install FOP
# from:
# http://xmlgraphics.apache.org/fop/
# $PATH_TO_FOP is the filepath to the fop.sh script.
my $PATH_TO_FOP ='/usr/bin/fop'; 

# $PATH_TO_RESUME is the path to the xmlresume xsl directory on your 
# machine
my $PATH_TO_XML_RESUME = './lib' ;

# $PATH_TO_OO_TEMPLATE is the path to your template OpenOffice sxw file, if you're
# genereating an sxw of your cv.
my $PATH_TO_OO_TEMPLATE = "$PATH_TO_XML_RESUME/charlie.sxw";

# $PATH_TO_OO_OUTPUT is the name you want your sxw output file to be called if you're 
# creating an sxw. You need to set the output file name below to content.xml
my $PATH_TO_OO_OUTPUT = "./charlie_harvey_cv.sxw";
# %FORMATS is a hash of output filenames,
# keyed on xsl filenames (from the $PATH_TO_RESUME/xsl/output directory)
# Nb:
# - To create pdfs make sure your output filename ends in .fo, with no whitespace 
# afterwards, the output will replace this with .pdf
# - To create openoffice files, make sure your output filename is content.xml, the
# resulting file is called cv.sxw, and can be found in the directory you ran xmlcv.pl 
# in. It's based on $PATH_TO_RESUME/cv.sxw, so you'll need a blank oo doc there.
my %FORMATS = ( 'uk-html.xsl'=>'sergios_stamatis_cv.html',           # plain html
		'uk-a4.xsl'=>'sergios_stamatis_cv_uk_a4.fo',         # pdf (a4)
                'us-letter.xsl'=>'sergios_stamatis_cv_us_letter.fo', # pdf (letter)
                'uk-text.xsl'=>'sergios_stamatis_cv.txt',            # good ol' ASCII
		'uk-openoffice.xsl' => 'content.xml');             # OOo sxw
# ====== STOP TWEAKING! ======= #

my $USAGE = "Usage: $0 path_to_cv_or_resume"; 
if (!$ARGV[0]) {die ("$USAGE\n");}
my ($cv) = shift;

my $xslt = XML::LibXSLT->new();
my $parser = XML::LibXML->new();

# remove tags with contexts not in @TARGETS
sub reparse($){
  my $doc = shift; 
  return unless defined $doc;
  my @nodelist = $doc->documentElement()->findnodes('*[@targets]');
  foreach my $node (@nodelist) {
    my @attr = $node->attributes;
    foreach (@attr) {
      my $count = target_find(split /,/, $_->getValue());
      unless ($count > 0) {
        $node->unbindNode();
      }
    }
  }
  return $doc;
}

# find how many of our targets are contained in the targets attribute
sub target_find(@) {
  my @targs = @_;
  my $count = 0;
  foreach my $targ (@targs){
    $count += grep (/$targ/, @TARGETS);
  } 
  return $count;
}

foreach (keys %FORMATS) {
  print "Formatting $FORMATS{$_} using stylesheet $_\n";
  my $xslfile = "$PATH_TO_XML_RESUME/xsl/output/$_";
  my $xmlfile = "$cv";	
  my $source = $parser->parse_file($xmlfile);
  my $doc = reparse($source);
  my $style_doc = $parser->parse_file($xslfile);
  my $stylesheet = $xslt->parse_stylesheet($style_doc);
  my $results = $stylesheet->transform($doc); 

  open (OUT, ">$FORMATS{$_}") || die ("File error processing $cv: $!\n");
  print OUT $stylesheet->output_string($results);
  close OUT;

  if ($FORMATS{$_}=~/\.fo$/) {
    my $pdf_name = $FORMATS{$_};
    $pdf_name =~ s/\.fo$/\.pdf/;
    print "Creating $pdf_name from $FORMATS{$_}\n";
    system ("$PATH_TO_FOP $FORMATS{$_} $pdf_name")==0 || die("FOP error encountered\n");
    print "PDF named  $pdf_name created from  $FORMATS{$_}\n"
  }
  if ($FORMATS{$_}=~/content\.xml/) {
    system ("cp $PATH_TO_OO_TEMPLATE $PATH_TO_OO_OUTPUT")==0 || die ("OpenOffice template file issue\n");
    system ("zip -u $PATH_TO_OO_OUTPUT $FORMATS{$_}")==0 || die ("OpenOffice zip issue\n"); 
    print "OpenOffice file named $PATH_TO_OO_OUTPUT based on $PATH_TO_OO_TEMPLATE created using $FORMATS{$_}\n"
  }
}
print "Done\n";
