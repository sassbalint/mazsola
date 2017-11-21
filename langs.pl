#!/usr/bin/perl -w

# többnyelvûsítõ programocska
# v0.2 -- 2003.09.20. -- Sass Bálint

use strict;

my $SKEL = 'skel';
my $TRTABLE = 'translation_table.pl';
my $CODECHAR = '@';
my $CODESIZE = 4;
my $LANGCODE = '0' x $CODESIZE;

my $command = "ls *$SKEL*";
my @files = split /\n/, `$command`;

open C, "< $TRTABLE";
my @ct = <C>;
close C;

my ( $line ) = grep /^$CODECHAR$LANGCODE/, @ct;
$line =~ s/^$CODECHAR$LANGCODE\s*//;
my @langs = split /\s+/, $line;

my $patt;
$patt .= "^($CODECHAR";
$patt .= '\d' x $CODESIZE;
$patt .= ')';
#for ( my $i = 0; $i < scalar @langs; ++$i ) { $patt .= '\t([^\t]*)'; }
$patt .= '\t([^\t]*)' x @langs;
$patt .= '$';

my %filetexts = ();

foreach my $cl ( @ct ) {
	next if $cl !~ /^$CODECHAR/;
	my ( $code, @vals ) = $cl =~ m#$patt#;
	foreach ( @vals ) { s#/#\\/#g; }
	chomp $vals[$#vals];
	for ( my $i = 0; $i < scalar @langs; ++$i ) {
		$filetexts{$langs[$i]} .= "s/$code/$vals[$i]/g\n";
	}
}

foreach my $lang ( @langs ) {
	open F, "> $lang.sed";
	print F $filetexts{$lang};
	close F;
	foreach my $file ( @files ) {
		my $newfile = $file;
		$newfile =~ s/$SKEL/$lang/;
		my $command = "cat $file | sed -f $lang.sed > $newfile";
		system $command;
	}
	unlink "$lang.sed";
}

#clean:
#	for i in `ls *skel*` ; do for l in `cat conversion_table.pl | head -2 | tail -1 | sed "s/^@[0-9]*	//;"` ; do rm `echo $$i | sed "s/skel/$$l/"` ; done ; done
#foreach files {
#	foreach langs {
#		rm file =~ s/skel/lang/;
#	}	
#}
