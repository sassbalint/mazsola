#!/usr/bin/perl -w
# #!/usr/bin/perl -w -t

use strict;
use POSIX;

use POSIX "locale_h";
setlocale ( LC_ALL, "hu_HU" );
use locale;

use CGI;

# -----

# XXX config!
my %CONFIG = do 'mazsola_config_@0000.pl';

my @CORPORA = @{$CONFIG{'CORPORA'}};
my $LOAD_AVG_TH = $CONFIG{'LOAD_AVG_TH'};
my $CHARSET = $CONFIG{'CHARSET'};
my $NOVERBMSG = $CONFIG{'NOVERBMSG'};
my $EXAMPLES = $CONFIG{'EXAMPLES'};

# -----

use File::Basename;
use Getopt::Std;
my $PROG = basename ( $0 );

my %opt;
getopts ( "pxqnihd", \%opt ) or usage();
usage() if $opt{h} or ( $opt{p} and $opt{x} ); # or ...

my $DEBUG = ( defined $opt{d} ? 1 : 0 );

# kiírási módok
my $PM_BIRM = ( defined $opt{x} ? 1 : '' );
my $PM_EXA  = ( defined $opt{p} ? 1 : '' );
my $PM_HTML = ( ( not defined $opt{x} and not defined $opt{p} ) ? 1 : '' );
  # utóbbi az éles / alap mód - ezen lehet kapcsolókkal változtatni

$SIG{'INT'}  = \&int_handler;
$SIG{'PIPE'} = \&int_handler;
$SIG{'KILL'} = \&int_handler;
$SIG{'TERM'} = \&int_handler;
$SIG{'HUP'}  = \&int_handler;
#$SIG{"PIPE"} = 'SIG_DFL';
## ettõl az egy sortól megszûnik ez: 'cat: write error: Broken pipe' :)
# ha megint megjelennének ezek az error log-ban, akkor
# meg kell próbálni a PIPE-t SIG_DFL-re állítani

# -- eset okosan
# CFG//%esettipp paraméter egyelõre kihagyva!
# ha trim után itt szerepel, akkor csere, kül. marad
my %esettipp = (
  "alany"        => "NOM",
  "tárgy"        => "ACC",
  "részes"       => "DAT",
  "birtokos"     => "DAT",
  "alanyeset"    => "NOM",
  "tárgyeset"    => "ACC",
  "részeseset"   => "DAT",
  "birtokoseset" => "DAT",
  "0"            => "NOM",
  "-?t"          => "ACC",
  "-?n[ae]k( *[,/]? *-?n[ae]k)?"   => "DAT",
  "-?b[ae]( *[,/]? *-?b[ae])?"     => "ILL",
  "-?b[ae]n( *[,/]? *-?b[ae]n)?"   => "INE",
  "-?b[óõ]l( *[,/]? *-?b[óõ]l)?"   => "ELA",
  "-?h[oeö]z( *[,/]? *-?h[oeö]z)*" => "ALL",
  "-?n[áé]l( *[,/]? *-?n[áé]l)?"   => "ADE",
  "-?t[óõ]l( *[,/]? *-?t[óõ]l)?"   => "ABL",
  "-?r[ae]( *[,/]? *-?r[ae])?"     => "SUB",
  "-?[oeö]?n( *[,/]? *-?[oeö]?n)*" => "SUP",
  "-?r[óõ]l( *[,/]? *-?r[óõ]l)?"   => "DEL",
  "-?v[ae]l( *[,/]? *-?v[ae]l)?"   => "INS",
  "-?v[áé]( *[,/]? *-?v[áé])?"     => "FAC",
  "-?ként"       => "FOR",
  "-?kor"        => "TEM",
  "-?ért"        => "CAU",
  "-?ig"         => "TER",
  "-?st[uü]l( *[,/]? *-?st[uü]l)?" => "SOC",
  "-?[uü]l( *[,/]? *-?[uü]l)?"     => "ESS",
  "nom"        => "NOM",
  "acc"        => "ACC",
  "dat"        => "DAT",
  "ill"        => "ILL",
  "ine"        => "INE",
  "ela"        => "ELA",
  "all"        => "ALL",
  "ade"        => "ADE",
  "abl"        => "ABL",
  "sub"        => "SUB",
  "sup"        => "SUP",
  "del"        => "DEL",
  "ins"        => "INS",
  "fac"        => "FAC",
  "for"        => "FOR",
  "tem"        => "TEM",
  "cau"        => "CAU",
  "ter"        => "TER",
  "soc"        => "SOC",
  "ess"        => "ESS",
#  "-A" => "POSS", # ez ugye egyrészt nem eset, másrészt nincs benne
);

# HTML-param - elég rossz helyen van itt.
my $nagyobb_betu = 'font-size: 150%';
my $kisebb_betu = 'font-size: 80%';
my $fontfamily = 'font-family: Verdana, Arial, Helvetica, sans-serif';

# XXX ezekkel majd kezdeni kell vmit... :)
my $DEFAULT_CORPUS_ID = 'k';
my $MNSZ_BETUKREBONTOTT = 'mnsz_betukrebontott';

my $LOCK_DELAY = 300; # ha ennyire régi (300sec) a LOCK, akkor
                      # azt gondoljuk, hogy véletlenül van ott

my $CNTCONSTR = 20000; # találatra korlátozás: max ennyi találat

my $LOGDIR = 'ZZCGILOG_DIRZZ';
my $LOGFILE = "$LOGDIR/mazsola.log";
my $PROCID = $$;
my $TMPDIR = 'ZZCGITMP_DIRZZ';
my $TMPFILE = "$TMPDIR/tmp.$PROCID.mazsola.txt";

my $RELCGIDIR = 'ZZRELCGI_DIRZZ';
my $SCRIPT = "$RELCGIDIR/mazsola_@0000.pl";
my $HTMLDIRFROMCGI = 'ZZHTMLDIRFROMCGIZZ';
my $PICTUREPATH = "$HTMLDIRFROMCGI/mazsola.jpg";
my $MAINPAGEPATH = "$HTMLDIRFROMCGI/index_@0000.html";
my $HTMLSECRETDIRFROMCGI = 'ZZHTMLSECRETDIRFROMCGIZZ';

my $DBFILE_DIR = 'ZZDBFILE_DIRZZ';
my $DBFILE_DEFAULT = 'db.3-10.g5';
my $DBFREQ_DIR = 'ZZDBFREQ_DIRZZ';
my $DBFREQFILE_DEFAULT = '';
# XXX ez nem túl értelmes, ti. ha nem íródik felül, hibát ad.
# XXX az lenne jó, ha nem is kéne $DBFREQFILE_DEFAULT

my $M = '@@';
my $NFLAG = '-v';
my $PUNCT = '[,;:.?!]';

my $NA = 'n/a';

my $SAL    = $opt{q} ? '' : 1; # ez kell XXX XXX XXX
#my $SAL    = $opt{q} ? 1 : ''; # így a régi sima gyakoriságos lenne XXX
my $VISUAL = $opt{n} ? '' : 1;

my $FREQTH_DEFAULT = 5;
                # ennnyiszer (vagy kevesebbszer) elõfordulót már nem írunk ki
                # legalábbis a kattintós részen :)) XXX
                # a példáknál ott van minden, legalábbis egyelõre...

my $html_statstem = '';
my $html_case1not = '';
my $html_lemma1not = '';
my $html_case2not = '';
my $html_lemma2not = '';
my $html_case3not = '';
my $html_lemma3not = '';
my $html_stat1 = '';
my $html_stat2 = '';
my $html_stat3 = '';

my $html_strnot = '';
my $html_fullcover = '';

if ( $opt{i} ) { # simán generáljuk a nyitólapot
  $html_stat1 = boo_checked( 1 );
  html_beg( 'mazsola.jpg' );
  html_end();
  exit 0;
}

# --- program starts HERE
my $begintime = time();

my $query = new CGI;

# logoláshoz ezek ELÕRE kellenek! XXX
my $remote_user = $query->remote_user() ? $query->remote_user() : '';
my $ip = $query->remote_host();
my $LOCKFN = "/tmp/.mazsola_lock_$ip"; # ugye kell hozzá az $ip

log_msg( '0-BEGIN' );

print $query->header(-type=>"text/html; charset=$CHARSET") if $PM_HTML;

# korpuszválasztás
# lehetne esetleg id-alapú hash ...
my $DBFILE_ACT = $DBFILE_DEFAULT;
my $DBFILE_ACT_NOVERB = $DBFILE_DEFAULT;
my $DBFREQFILE = $DBFREQFILE_DEFAULT;
my $FREQTH = $FREQTH_DEFAULT;
my $cop = $query->param( 'corpus' );
my $corpus_param = ( $cop ? $cop : $DEFAULT_CORPUS_ID );
foreach my $corpus ( @CORPORA ) {
  if ( $$corpus{'id'} eq $corpus_param ) {
    $DBFILE_ACT = $$corpus{'db'};
    # igétlen kérdéshez való esetleges külön korpusz
    $DBFILE_ACT_NOVERB = exists $$corpus{'db_noverb'} ? $$corpus{'db_noverb'} : $$corpus{'db'};
    # lemmafreq adatok
    $DBFREQFILE = $$corpus{'dbfreq'}; # XXX ennek kell lennie!
    if ( exists $$corpus{'freqth'} ) { $FREQTH = $$corpus{'freqth'} }
    last;
  }
}

# további paraméterek -> az elemeket clearAll()-ban fel kell sorolni!
my $stem      = sec( $query->param( 'stem' ) );
my $statstem  = ( not defined $query->param( 'stat' )
                  or $query->param( 'stat' ) eq 'statstem'
                ) ? 1 : '';

my $case1not  = $query->param( 'case1not' ) ? 1 : '';
my $case1     = sec( $query->param( 'case1' ) );
my $lemma1not = $query->param( 'lemma1not' ) ? 1 : '';
my $lemma1    = sec( $query->param( 'lemma1' ) );
my $stat1     = ( defined $query->param( 'stat' )
                  and $query->param( 'stat' ) eq 'stat1' ) ? 1 : '';

my $case2not  = $query->param( 'case2not' ) ? 1 : '';
my $case2     = sec( $query->param( 'case2' ) );
my $lemma2not = $query->param( 'lemma2not' ) ? 1 : '';
my $lemma2    = sec( $query->param( 'lemma2' ) );
my $stat2     = ( defined $query->param( 'stat' )
                  and $query->param( 'stat' ) eq 'stat2' ) ? 1 : '';

my $case3not  = $query->param( 'case3not' ) ? 1 : '';
my $case3     = sec( $query->param( 'case3' ) );
my $lemma3not = $query->param( 'lemma3not' ) ? 1 : '';
my $lemma3    = sec( $query->param( 'lemma3' ) );
my $stat3     = ( defined $query->param( 'stat' )
                  and $query->param( 'stat' ) eq 'stat3' ) ? 1 : '';

my $strnot    = $query->param( 'strnot' ) ? 1 : '';
my $str       = sec( $query->param( 'str' ) );

my $fullcover = $query->param( 'fullcover' ) ? 1 : '';

# fullcover esetén a tagadásokat kilövöm (!)
if ( $fullcover ) {
  $case1not = '';
  $lemma1not = '';
  $case2not = '';
  $lemma2not = '';
  $case3not = '';
  $lemma3not = '';
}

# van/nincs ige? ...
my $fixstem = ( $stem and not $stem =~ /^[.]/ ) ? 1 : '';
# ... -> a megfelelõ korpuszt vesszük
my $DBFILE = $fixstem ? $DBFILE_ACT : $DBFILE_ACT_NOVERB;

# betûkrebontás végrehajtása (!) - kell hozzá az igetõ (=$stem)
if ( $DBFILE eq $MNSZ_BETUKREBONTOTT ) {
  # a betûkrebontást külsõ generált program végzi! XXX
  $DBFILE = `echo \"$stem\" | ./auto_feldolgozo.pl`;
  chomp $DBFILE;
}

# tömörített fájlok esetén: 'zcat'
my $CAT = ( $DBFILE =~ m/\.gz$/ ) ? 'zcat' : 'cat';

# -- stat okosan
# alapból az elsõ bõvítményen legyen a stat,
# ha az nincs megadva, akkor azon, ami meg van adva! XXX
#   talán így kéne lennie: ( $case1 ne '' or $lemma1 ne '' ) ? 1 : '';
my $filled1 = ( ( $case1 ne '' ) or ( $lemma1 ne '' ) );
my $filled2 = ( ( $case2 ne '' ) or ( $lemma2 ne '' ) );
my $filled3 = ( ( $case3 ne '' ) or ( $lemma3 ne '' ) );

if ( $stat1 and not $filled1 ) {
  $stat1 = '';
  if ( $filled2 )    { $stat2 = 1; }
  elsif ( $filled3 ) { $stat3 = 1; }
  else               { $statstem = 1; }
  # mert valaminek ki kell töltve lenni
} elsif ( $stat2 and not $filled2 ) {
  $stat2 = '';
  if ( $filled1 )    { $stat1 = 1; }
  elsif ( $filled3 ) { $stat3 = 1; }
  else               { $statstem = 1; }
} elsif ( $stat3 and not $filled3 ) {
  $stat3 = '';
  if ( $filled1 )    { $stat1 = 1; }
  elsif ( $filled2 ) { $stat2 = 1; }
  else               { $statstem = 1; }
}
# if ( $statstem and not $filledstem ) <-- ez nyugodtan lehet!

# ha valamiért totál nincs kitöltve...
# a puszta $str kitöltése nem számít kitöltésnek!
my $not_filled =
  ( not $filled1 and not $filled2 and not $filled3 and not $stem );

$html_statstem = boo_checked( $statstem );
$html_case1not = boo_checked( $case1not );
$html_lemma1not = boo_checked( $lemma1not );
$html_case2not = boo_checked( $case2not );
$html_lemma2not = boo_checked( $lemma2not );
$html_case3not = boo_checked( $case3not );
$html_lemma3not = boo_checked( $lemma3not );
$html_stat1 = boo_checked( $stat1 );
$html_stat2 = boo_checked( $stat2 );
$html_stat3 = boo_checked( $stat3 );

$html_strnot = boo_checked( $strnot );
$html_fullcover = boo_checked( $fullcover );

# ez kell XXX direkt html-megjelenítés után
$stat1 = '' if $case1not;
$stat2 = '' if $case2not;
$stat3 = '' if $case3not;

# elkezdjük a HTML kiírását ...
html_beg() if $PM_HTML;

# ... hozzá a megfelelõ üzenetek (4 féle) - ill. gyors exit, ha kell
# [1] ha valahogy mégsincs normálisan kitöltve -> befejezzük
if ( $not_filled ) {
  if ( $str ) {
    print_html_msg( "@1011" );
    log_msg( 'X-NOT_FILLED_ONLY_STR' );
  } else {
    print_html_msg( "@1010" );
    log_msg( 'X-NOT_FILLED' );
  }
  befejezes();
}
# [2] ha leterhelt a szerver -> befejezzük (load average alapú korlátozás)
my $load_avg = `uptime`;
$load_avg =~ s/.*load average: //; $load_avg =~ s/,.*//; # megvan :)
if ( $load_avg > $LOAD_AVG_TH ) {
  print_html_msg( '@2011' );
  log_msg( 'X-LOAD_TOO_HIGH' );
  befejezes();
}
# [3] ha már fut lekérdezés -> befejezzük; különben lock és mehet
_lock();
# [4] ige nélküli lekérdezés lassúsági üzenete
if ( not $fixstem and not $opt{i} and $NOVERBMSG ) {
  print_html_msg( '@2001' );
}

# trim + kitaláljuk, hogy milyen esetre gondolt :)
$stem   = trim( $stem );
$case1  = trim( $case1 );
foreach my $k ( keys %esettipp ) {
  if ( $case1 =~ m/^$k$/i ) { $case1 = $esettipp{$k}; last; }
}
$lemma1 = trim( $lemma1 );
$case2  = trim( $case2 );
foreach my $k ( keys %esettipp ) {
  if ( $case2 =~ m/^$k$/i ) { $case2 = $esettipp{$k}; last; }
}
$lemma2 = trim( $lemma2 );
$case3  = trim( $case3 );
foreach my $k ( keys %esettipp ) {
  if ( $case3 =~ m/^$k$/i ) { $case3 = $esettipp{$k}; last; }
}
$lemma3 = trim( $lemma3 );
$str    = trim( $str );

# ezeknél több szót is meg lehet adni
$stem   = multi( $stem );
$lemma1 = multi( $lemma1 );
$lemma2 = multi( $lemma2 );
$lemma3 = multi( $lemma3 );
$str    = multi( $str );

# logolás
my $mainlogmsg =
  "corpus==" . "$DBFILE_ACT" . "\t" .
  "stem==" . "$stem" . "\t" .
  "case1==" . ( $case1not ? 'NO%' : '' ) . "$case1" . "\t" .
  "lemma1==" . ( $lemma1not ? 'NO%' : '' ) . "$lemma1" . "\t" .
  "case2==" . ( $case2not ? 'NO%' : '' ) . "$case2" . "\t" .
  "lemma2==" . ( $lemma2not ? 'NO%' : '' ) . "$lemma2" . "\t" .
  "case3==" . ( $case3not ? 'NO%' : '' ) . "$case3" . "\t" .
  "lemma3==" . ( $lemma3not ? 'NO%' : '' ) . "$lemma3" . "\t" .
  "str==" . ( $strnot ? 'NO%' : '' ) . "$str" . "\t" .
  "fullcover==" . ( $fullcover ? 'yes' : 'no' ) . "\t" .
  "stat==" . ( $stat1 ? 'stat1' :
             ( $stat2 ? 'stat2' :
             ( $stat3 ? 'stat3' :
             ( $statstem ? 'statstem' : '???' ) ) ) );
  # XXX lett az adatbázisban '???', úgyhogy ez tutira nem oké!
log_msg( '1-PARSED_Q: ' . $mainlogmsg );

my $savecase1 = $case1; # fú, de gagyi... XXX (csak '-x' kedvéért)

# lekérdezõparancs elõkészítése
$case1 = $case1 ? "\\\\<$case1" : '';
$lemma1 = $lemma1 ? "$lemma1\\\\>" : '';
$case2 = $case2 ? "\\\\<$case2" : '';
$lemma2 = $lemma2 ? "$lemma2\\\\>" : '';
$case3 = $case3 ? "\\\\<$case3" : '';
$lemma3 = $lemma3 ? "$lemma3\\\\>" : '';
#$str simán

# alap lekérdezõparancs összeállítása
my $eg = 'egrep';
my $eg_stem   = $stem ? qq(\\\\<stem$M$stem\\\\>) : ''; # "" nélkül (!)

my $eg_case1  = boo_not_eg($case1not) . qq("$case1$M");
my $eg_lemma1 = $case1not ? qq("$M")
                          : boo_not_eg($lemma1not) . qq("$case1$M$lemma1");

my $eg_case2  = boo_not_eg($case2not) . qq("$case2$M");
my $eg_lemma2 = $case2not ? qq("$M")
                          : boo_not_eg($lemma2not) . qq("$case2$M$lemma2");

my $eg_case3  = boo_not_eg($case3not) . qq("$case3$M");
my $eg_lemma3 = $case3not ? qq("$M")
                          : boo_not_eg($lemma3not) . qq("$case3$M$lemma3");

my $eg_str    = '-i ' . boo_not_eg($strnot) . qq("$str"); # case-insensitive! XXX

# a lényegi egrep-parancsok
my $egreps = qq($eg "$eg_stem" | $eg $eg_case1 | $eg $eg_lemma1 | $eg $eg_case2 | $eg $eg_lemma2 | $eg $eg_case3 | $eg $eg_lemma3 );

# a $fullcover-es kérdést rakogatom itt össze felülbírálva a fentit
if ( $fullcover ) {
  my $eg_ptn1 =
    $case1
      ? ( $lemma1
            ? qq($case1$M$lemma1)
            : qq($case1$M\[^ ]*\\\\>)
        )
      : "";

  my $eg_ptn2 =
    $case2
      ? ( $lemma2
            ? qq($case2$M$lemma2)
            : qq($case2$M\[^ ]*\\\\>)
        )
      : "";

  my $eg_ptn3 =
    $case3
      ? ( $lemma3
            ? qq($case3$M$lemma3)
            : qq($case3$M\[^ ]*\\\\>)
        )
      : "";

  # ugye mindenképp ESET szerinti rendezett sorrendben kellenek a bõv-k!
  my %rendezo = ();
  # ha ész nélkül beletesszük, akkor gond lesz a szpészekkel! :)
  $rendezo{$case1} = $eg_ptn1 if $case1;
  $rendezo{$case2} = $eg_ptn2 if $case2;
  $rendezo{$case3} = $eg_ptn3 if $case3;
  my $rendezett = join ' ', map {$rendezo{$_} } sort keys %rendezo;
  $rendezett = ' ' . $rendezett if $rendezett; # ha nem üres, akkor elé: ' ' 

  # a lényegi egrep-parancsok
  $egreps = qq($eg "$eg_stem$rendezett\$");
}

# a fõfõ futtatandó parancs
my $comm_magyar = "export LC_ALL=hu_HU";
#my $comm = qq($comm_magyar ; cd $DBFILE_DIR ; $CAT $DBFILE | $eg $eg_str | $egreps );
# találatra korlátozás -- kell és kész.
my $comm = qq($comm_magyar ; cd $DBFILE_DIR ; $CAT $DBFILE | $eg $eg_str | $egreps | head -$CNTCONSTR );

$ENV{'PATH'} = '/bin:/usr/bin';
delete $ENV{'BASH_ENV'}; # taint miatt, de mi is ez?

# XXX 1. lekérdezés

# --- ÚJ rész
my $comm_tmp = "$comm > $TMPFILE";
#my $comm_tmp = "$comm | head -10000 > $TMPFILE";
# ez a 'head' azért nagyon durva lenne, randomizálás kell! :) XXX
# vagy mégse? így is jó? így legalább mindig azonos az eredmény?
# az nyilván nem jó, hogy mondjuk csak hivatalos szöveget vesz!!! XXX

log_msg( "2-GREP" ); # a parancsot nem írom ki: `$comm_tmp`

if ( $PM_HTML ) {
print "<!-- " . tohtml( $comm_tmp ) . " -->\n";
}

# kitesszük fájlba és ...
system( "$comm_tmp" );
# ... mostantól már csak cat-tal betöltjük azt (de magyar rendezés legyen!)
$comm = "$comm_magyar ; cat $TMPFILE";
# --- ÚJ rész vége

log_msg( "3-WC" ); # a parancsot nem írom ki: `$comm | wc -l`

my $cnt = `$comm | wc -l`;
chomp $cnt;
$cnt = trim( $cnt );

my $rs = '';
my $comm_stat = '';
my @csop = ();
my $comm_csop = '';

# statisztika
my $sst = 'sort | uniq -c | sort -nr'; # ez az sstat!
if ( $stat1 ) {
  $comm_stat = qq($comm | sed "s/^.*$case1$M//;s/ .*\$//" | $sst);
} elsif ( $stat2 ) {
  $comm_stat = qq($comm | sed "s/^.*$case2$M//;s/ .*\$//" | $sst);
} elsif ( $stat3 ) {
  $comm_stat = qq($comm | sed "s/^.*$case3$M//;s/ .*\$//" | $sst);
} elsif ( $statstem ) {
  $comm_stat = qq($comm | sed "s/^.*stem$M//;s/ .*\$//" | $sst);
}

# XXX 2. lekérdezés - nagyon pazarló 2x kérdezni ugyanazt!
log_msg( "4-SAL_WORDS" ); # a parancsot nem írom ki: `$comm_stat`
$rs = `$comm_stat`;

my @rs = split /\n/, $rs; # $rs-t lehet újrafelhasználni
$rs = '';
my %rs = ();
my %rsf = (); # ez a régi, a frekvencia szerinti, talán nem is kell XXX
my $fr = 0;
foreach my $l ( @rs ) {
  my ( $f, $w ) = $l =~ /(\s*[0-9]+)\s(.*)/; 

  last if ( $f <= $FREQTH ); # ilyet vagy  ritkábbat már nem írunk ki

  if ( $f != $fr ) { $fr = $f; } # új frekvenciaérték
  
  my $lemmafreq = lemmafreq( $w );
  my $mi = fake_MI( $fr, $lemmafreq );

    # hogyan becsüljük a "lényegességet", a salience-t?
    #
    # sima fakeMI: nagyon elõnyben részesíti a ritkákat!
    #my $salience = int ( ( $mi + 30 ) * 1.2 );            # 1. eredeti
    #my $salience = int ( ( ( $mi + 30 ) * 0.5 ) ** 1.3 ); # 2. eredeti
    #
    # kilgarriff2001word: salience-szerû
    # ez nem tûnt jónak:
    #my $salience = int ( ( ( $mi + 30 ) * 0.5 ) ** 1.3 * ( log( $fr ) / log(2) ) );
    # ez már SOKKAL bíztatóbb, maradjunk ennél:
  my $salience = int (
                       ( ( $mi + 30 ) * 0.2 ) *
                       ( log( $fr ) / log(2) ) *
                       ( (-1/3) * $FREQTH + 8/3 ) # ez 5-re ad 1-et :)
                     );
  #my $salience = $mi; # ha salience helyett sima MI-t akarnánk XXX
    # esetleg kellhet additív konstans hozzá, ha $FREQTH túl kicsi XXX
    # abban bízom, hogy ez így korrekt salience,
    # és a +30 és a *0.2 csak a fontméret miatt kell XXX XXX XXX
    # 2007.03.17. Hm.. MI lehet negatív?
    # Lehet, de az azt jelenti, hogy a két szó "nem szeret együtt lenni"
    # Biztos csak a fake-ség okozza ezt. :) XXX

  # - régi: frekvencia szerinti
  if ( not exists $rsf{$fr} ) { $rsf{$fr} = []; }
  push @{ $rsf{$fr} }, [ $w, $salience ]; 
  # - új: salience szerinti
  if ( not exists $rs{$salience} ) { $rs{$salience} = []; }
  push @{ $rs{$salience} }, [ $w, $fr ]; 
    # debuggoláshoz kellhet még: $lemmafreq, $mi, ... XXX
}

# ez itt alább kódismétlés, de talán jobb így,
# mert egyszer talán majd a régi el is marad ...
if ( $SAL ) { # - új: salience szerinti
  foreach my $sal ( sort { $b <=> $a } keys %rs ) {
    my @a = @{ $rs{$sal} };
    foreach my $a ( @a ) {
      my ( $w, $fr ) = @{ $a };
      $fr = trim( $fr );
      if ( $PM_HTML ) {
        if ( $VISUAL ) {
          $rs .= qq( <a style="font-size: $sal" href="#$w">$w</a> <span style="font-size: small">[$fr]</span>);
        } else { # ez nem is olyan érdekes, sose fogjuk használni...
          $rs .= qq( <a href="#$w">$w</a> <span style="font-size: small">[$fr]</span>);
        }
      } else {
        $rs .= "\t$w";
      }
    }
  }
} else { # - régi: frekvencia szerinti - nagyon kódismétlés-gyanús
  foreach my $fr ( sort { $b <=> $a } keys %rsf ) {
    my @a = @{ $rsf{$fr} };
    if ( $PM_HTML ) {
      $rs .= "<br/>\n <pre style=\"display: inline\">$fr</pre>";
    } else {
      $rs .= "\t[fq=$fr]";
    }
    foreach my $a ( @a ) {
      my ( $w, $sal ) = @{ $a };
      if ( $PM_HTML ) {
        if ( $VISUAL ) {
          $rs .= qq( <a style="font-size: $sal" href="#$w">$w</a>);
        } else { # ez nem is olyan érdekes, sose fogjuk használni...
          $rs .= qq( <a href="#$w">$w</a>);
        }
      } else {
        $rs .= "\t$w [$sal]";
      }
    }
  }
}

# csoportosítás - egyelõre csak 1-re!!!
if ( $stat1 ) {
  $comm_csop = qq($comm | sed "s/^\\(.*\\) stem$M.*$case1$M\\([^ ]*\\)\\\\>.*\$/\\1\t\\2/" | sort -t'\t' -k2,2);
} elsif ( $stat2 ) {
  $comm_csop = qq($comm | sed "s/^\\(.*\\) stem$M.*$case2$M\\([^ ]*\\)\\\\>.*\$/\\1\t\\2/" | sort -t'\t' -k2,2);
} elsif ( $stat3 ) {
  $comm_csop = qq($comm | sed "s/^\\(.*\\) stem$M.*$case3$M\\([^ ]*\\)\\\\>.*\$/\\1\t\\2/" | sort -t'\t' -k2,2);
} elsif ( $statstem ) {
  $comm_csop = qq($comm | sed "s/^\\(.*\\) stem$M\\([^ ]*\\)\\\\>.*\$/\\1\t\\2/" | sort -t'\t' -k2,2);
}

# XXX 3. lekérdezés - most már 3x kérdezzük ua-t!
log_msg( "5-GROUPING" ); # a parancsot nem írom ki: `$comm_csop`

#@csop = $cnt < 5000 ? `$comm_csop` : (); # ha túl sok => ne legyenek példák...
@csop = `$comm_csop`;

log_msg( "6-GROUPING READY" );
unlink $TMPFILE;

# vicces :)
#$cnt =~ s/([0-9])/<img src="http:\/\/camel.nytud.hu\/joker\/$1.png" alt="$1"\/>/g;
#$rs  =~ s/([0-9])/<img src="http:\/\/camel.nytud.hu\/joker\/$1.png" alt="$1"\/>/g;
#$res =~ s/([0-9])/<img src="http:\/\/camel.nytud.hu\/joker\/$1.png" alt="$1"\/>/g;

if ( $PM_HTML ) {
print "<!-- " . tohtml( $comm ) . " -->\n";
print "<!-- " . tohtml( $comm_stat ) . " -->\n";
print "<!-- " . tohtml( $comm_csop ) . " -->\n";
}
print "$stem + $savecase1\t" if $PM_BIRM;

# találatok száma
print "[" if $PM_EXA;
print "@1303 " if ( $cnt == $CNTCONSTR );
print $cnt ? $cnt : '@1301';
print " @1300.";
print $cnt ? '' : '@1302';
print "]" if $PM_EXA;
print "\n\n" if $PM_HTML;

# jellemzõ szavak
print "$rs" if not $PM_EXA;
print "\n";

# példák
if ( $PM_HTML or $PM_EXA ) {
print qq(<pre style="margin-left: 1em">\n) if $PM_HTML;
my $aktszoto = '';
foreach my $sor ( @csop ) {
  my ( $mondat, $szoto ) = $sor =~ /(.*)\t(.*)/;
  if ( $szoto ne $aktszoto ) {
    $aktszoto = $szoto;
    if ( $PM_HTML ) {
      print qq(<a name="$szoto">);
      print qq(<strong style="margin-left: -1em">$szoto</strong>\n);
    } elsif ( $PM_BIRM ) {
      print "[$szoto]\n";
    }
  }
  $mondat =~ s/ ($PUNCT+)/$1/g; # kiszedi a mondatvégi írásjel elõl a szóközt
  print "$mondat\n";
}
print "</pre>\n" if $PM_HTML;
}

_unlock();
befejezes( $cnt );

# --- subs
sub int_handler {
  log_msg( "X-SIGNAL_TERMINATION: $_[0]" );
  unlink $TMPFILE if -e $TMPFILE;
  _unlock();
  die "Mazsola: SIGNAL_TERMINATION $_[0]\n"; # ez vajh hová íródik?
}

sub _lock { # kódismétlés: átvéve az MNSZ-bõl
  if ( -e $LOCKFN ) {
    if ( (stat($LOCKFN))[9] < time() - $LOCK_DELAY ) { # ha gyanúsan túl régi a lockfájl
      unlink ( $LOCKFN ) or print STDERR "Mazsola: nem lehet torolni: '$LOCKFN'\n";
      log_msg( 'X-REMOVING OLD STUCK LOCK...' );
      # ez ahhoz vezethet, hogy: nem is õsrégi a LOCK, csak nagyon hosszan fut,
      # és akkor ez az új (gyors) kérdés lényegében törli annak a lockját! Hm..
    } else {  
      print_html_msg( '@2022' );
      log_msg( 'X-LOCK: currently running a query' );
      befejezes();
    }
  }
  
  # elkészítjük a lockfájlt
  open ( LOCKF, ">> $LOCKFN" ) or print STDERR "Mazsola: nem lehet megnyitni: '$LOCKFN'\n";
  close LOCKF;
}

sub _unlock {
  if ( -e $LOCKFN ) {
    unlink ( $LOCKFN ) or print STDERR "Mazsola: nem lehet torolni: '$LOCKFN'\n";
  }
}

sub befejezes {
  my $matches = $_[0] ? $_[0] : '-';

  html_end() if $PM_HTML;
  print $query->end_html if $PM_HTML;

  log_msg( "7-HTML READY: " . ( time() - $begintime ) . 's ' .
           "$matches matches." );
  exit ( 0 );
}

sub log_msg {
  my $msg = shift;
  return if not $PM_HTML;
  my $date = formatdate();
  open ( LOGFILE, ">> $LOGFILE" ) or print STDERR "Mazsola: nem lehet megnyitni a logfájlt '$LOGFILE'-t.\n";
  print LOGFILE "$PROCID\t$date\t$remote_user\t$ip\t$msg\n";
  close LOGFILE;
}

# ez a 2 sub kimásolva az MNSZ scriptbõl
sub formatdate () {
  my ($sc,$mi,$hou,$mday,$mon,$yea,undef,undef,undef) = localtime;
  my $year = $yea+1900;
  my $month = ketjegyure ( $mon+1 );
  my $day = ketjegyure ( $mday );
  my $hour = ketjegyure ( $hou );
  my $min = ketjegyure ( $mi );
  my $sec = ketjegyure ( $sc );
  return "$year-$month-$day $hour:$min:$sec";
}
sub ketjegyure ( $ ) {
  my $s = shift;
  $s = ( ( length $s == 1 ) ? "0" : "" ) . $s;
  return $s;
}

sub lemmafreq {
  my $w = shift;

## -- ez lett volna az új ötletem, az alábbi gagyi(nak tûnõ) helyett
##    hihetetlen, de ez a lassabb (!!!), ezért maradt a régi
#  my $letters = '[a-záéíóöõúüû]';
#
#  my $r = '';
#  my $notok = 1; # mert a grep 0-t ad vissza, ha oké (!)
#  if ( $w =~ m/^($letters)/ ) {
#    # esetleg lehetne ellenõrizni, hogy van-e ilyen fájl - minek? XXX
#    $r = `cat $DBFREQ_DIR/$1.fq | grep -m 1 \"^$w	\"`;
#    $notok = $?;
#  }
   
  my $r = '';
  my $notok = 1; # mert a grep 0-t ad vissza, ha oké (!)

## -- betûkrebontás kezelése  
#  my @letters = split //, "aábcdeéfghiíjklmnoóöõpqrstuúüûvwxyz";
#
#  foreach my $letter ( @letters ) {
#    if ( $w =~ m/^$letter/i ) {
#      # esetleg lehetne ellenõrizni, hogy van-e ilyen fájl... XXX
#      $r = `cat $DBFREQ_DIR/$letter.fq | grep -m 1 \"^$w	\"`;
#      $notok = $?;
#      last;
#    }  
#  }
#  if ( $notok ) { # ha egyik betû se jött be, akkor jellel kezdõdik
#    $r = `cat $DBFREQ_DIR/0.fq | grep -m 1 \"^$w	\"`;
#    $notok = $?;
#  }

  $r = `cat $DBFREQ_DIR/$DBFREQFILE | grep -m 1 \"^$w	\"`;
  $notok = $?;

  chomp $r;
  $r =~ s/^.*?([0-9]+)$/$1/; # utolsó szám kell nekem: egyszerûbben? XXX
  if ( $notok ) {
    $r = $NA;
  }

  return $r;
}

# Attól "fake", hogy a kollokáció "másik tagjával" (->maradek)
# egyszerûen nem számolunk ui. az nehéz, mert lehet bármilyen bonyolult:
# 'tart ACC', vagy akár 'tart fontosDAT ACC' is.
# Azt az egyelemû (!) tagot vesszük figyelembe,
# ami alapján épp a statisztikát is készítjük (->stat_tag)
# ... azaz ...
# MI = log2 N ( f(coll) / f(maradek) * f(stat_tag) )
# ... helyett ...
# MI = log2 ( N / f(maradek) ) * ( f(coll) / f(stat_tag) )
#    = log2 C + log2 ( f(coll) / f(stat_tag) )
# De ez sztem jogos is, ha nem érdekes a konkrét MI érték,
# hanem csak összevetni akarok (azonos maradek mellett!),
# ui. ekkor az elsõ tag konstans (!) -> elhagyhatom!
# ld. még ../fakemi.tex
sub fake_MI {
  my $collfreq = shift;
  my $lemmafreq = shift;
  return -15 if $lemmafreq eq $NA or $lemmafreq == 0; # -15 XXX XXX XXX
  return log( $collfreq / $lemmafreq ) / log( 2 ); # log2 kell
}

sub trim {
  my $s = shift;
  if ( $s ) { 
    $s =~ s/^\s*//;
    $s =~ s/\s*$//;
  }
  $s;
}  

sub tohtml { # html-ben jól jelenjen meg
  my $s = shift;
  $s =~ s/</&lt;/g;
  $s =~ s/>/&gt;/g;
  return $s;
}

sub multi { # több szó -> egrepnek
  my $s = shift;
  return $s if not $s; # ha nemdef, akkor semmit se csinálunk
  my $NBSP = 'XQX';
  if ( $s =~ /[\({\[]/ ) {
    my $b = '';
    my @st = ();
    # zárójelen belüli space-t nem cseréljük le :)
    foreach my $ch ( split //, $s ) {
      if ( $ch eq '{' or $ch eq '[' or $ch eq '(' ) {
        push @st, $ch;
        $b .= $ch;
      } elsif ( $ch eq '}' or $ch eq ']' or $ch eq ')' ) {
        pop @st;
        $b .= $ch;
      } else {
        if ( $ch eq ' ' ) {
          $b .= @st ? $NBSP : ' ';
        } else {
          $b .= $ch;
        }
      }
    }
    $s = $b;
  }
  if ( $s =~ / / ) {
    $s =~ s/ /|/g;
    $s = '(' . $s . ')';
  }
  $s =~ s/$NBSP/ /g;
  return $s;
}

sub sec { # biztonságossá teszi a kapott paramétereket + egrep escape
  my $s = shift;
  if ( defined $s ) {
    $s =~ s/["']//g;
    $s =~ s/  */ /g;
    # egrep escape-elés
    # egyelõre csak a '|' karaktert vettem, de valszeg a többi is kéne:
    # man egrep szerint: ? + { | ( ) meg hát: . *
    # ezt jó lenne egyszer végiggondolni! XXX XXX XXX
    # egyelõre azt a két karaktert vettem ide, ami elõfordul MNSZ-es lemmában
    $s =~ s/[|]/\\|/g;
    #$s =~ s/[.]/\\./g; mégse, mert kell a regkif-hez!
  } else {
    $s = '';
  }
  return $s;
}

sub boo_not_eg {
  return $_[0] ? '-v ' : '';
}

sub boo_checked {
  return $_[0] ? ' checked' : '';
}

sub print_html_msg { # html_beg() és html_end() közé
  my $msg = shift;

  print <<EE
<span style="font-style: italic; $kisebb_betu">
$msg
</span>

<br/>
EE
}

sub html_beg {
  my $pic = $_[0] ? $_[0] : $PICTUREPATH;
  my $picheight = 95;
  my $picwidth = floor( $picheight * 250 / 346 );
  my $left = $picwidth + 5;

  my $nem = qq(<span style="$kisebb_betu">@1299:</span>);
  my $p1 = '<span style="position: absolute; left: 52em">';
#  my $p2 = '<span style="position: absolute; left: 50em">';
#  my $p3 = '<span style="position: absolute; left: 54em">';
  my $pv = '</span>';

  my $korpuszvalaszto = '<select name="corpus">';
  foreach my $corpus ( @CORPORA ) {
    $korpuszvalaszto .= "<option value=\"$$corpus{'id'}\"";
    $korpuszvalaszto .= " selected" if $$corpus{'id'} eq $corpus_param;
    $korpuszvalaszto .= ">$$corpus{'gloss'}</option>"; 
  }
  $korpuszvalaszto .= '</select>';

print <<EE
<html>

<head>
<title>@1000</title>
<meta http-equiv="Content-Type" content="text/html; charset=$CHARSET"/>
<script>

function check () {
  if (
      document.f.stem.value == "" &&
      document.f.case1.value == "" && document.f.lemma1.value == "" &&
      document.f.case2.value == "" && document.f.lemma2.value == "" &&
      document.f.case3.value == "" && document.f.lemma3.value == "" &&
      document.f.str.value == "" ) {
    alert( "@1010" ); return false; }
  return true;
}

function set( name, val ) {
  document.f.elements[name].value = val;
}

// forrás: http://www.somacon.com/p143.php
// set the radio button with the given value as being checked
function setR ( name, val ) {
  var radioObj = document.f.elements[name]; // radiogomb legyen!!!
  var radioLength = radioObj.length;
  if ( radioLength == undefined ) {
    radioObj.checked = (radioObj.value == val.toString());
    return;
  }
  for ( var i = 0; i < radioLength; i++ ) {
    radioObj[i].checked = false;
    if ( radioObj[i].value == val.toString() ) {
      radioObj[i].checked = true;
    }
  }
}

// checkbox bepipálása
function setC ( name ) {
  var checkboxObj = document.f.elements[name]; // checkbox legyen!!!
  checkboxObj.checked = true;
}

// minden mezõ és elem törlése -- egyenként fel kell sorolni õket! XXX
function clearAll () {
  document.f.elements['stem'].value = '';
  document.f.elements['case1not'].checked = false;
  document.f.elements['case1'].value = '';
  document.f.elements['lemma1not'].checked = false;
  document.f.elements['lemma1'].value = '';
  document.f.elements['case2not'].checked = false;
  document.f.elements['case2'].value = '';
  document.f.elements['lemma2not'].checked = false;
  document.f.elements['lemma2'].value = '';
  document.f.elements['case3not'].checked = false;
  document.f.elements['case3'].value = '';
  document.f.elements['lemma3not'].checked = false;
  document.f.elements['lemma3'].value = '';
  document.f.elements['strnot'].checked = false;
  document.f.elements['str'].value = '';
}


</script>
</head>
<body style="$fontfamily">

<div style="position: absolute; top: 0px; left: 0px">
<a href="$MAINPAGEPATH"><img src="$pic" height="$picheight"/></a>
</div>

<div style="position: relative; top: 0px; left: $left;
  font-style: italic">

<h1 style="font-style: normal; $nagyobb_betu">@1000</h1>

<div style="font-style: normal; $kisebb_betu; margin-bottom: 0.5em">
<a href="$HTMLSECRETDIRFROMCGI/@3000">@3001</a>
</div>

<form
  name="f"
  action="$SCRIPT"
  method="post"
  onsubmit="return check()">

<span style="$kisebb_betu">@1200:</span>
&nbsp;$korpuszvalaszto
$p1
@1210:
$pv

<br/>

@1220:   <input type="text" name="stem" size="32" value="$stem"/>
$p1
&nbsp;<input type="radio" name="stat" value="statstem" $html_statstem/>
$pv

<br/>

$nem     <input type="checkbox" name="case1not" $html_case1not/>
@1230:
         <input type="text" name="case1" size="12" value="$case1"/>
$nem     <input type="checkbox" name="lemma1not" $html_lemma1not/>
@1240:   <input type="text" name="lemma1" size="32" value="$lemma1"/>
$p1
&nbsp;<input type="radio" name="stat" value="stat1" $html_stat1/>
$pv

<br/>

$nem     <input type="checkbox" name="case2not" $html_case2not/>
@1230:
         <input type="text" name="case2" size="12" value="$case2"/>
$nem     <input type="checkbox" name="lemma2not" $html_lemma2not/>
@1240:   <input type="text" name="lemma2" size="32" value="$lemma2"/>
$p1
&nbsp;<input type="radio" name="stat" value="stat2" $html_stat2/>
$pv

<br/>

$nem     <input type="checkbox" name="case3not" $html_case3not/>
@1230:
         <input type="text" name="case3" size="12" value="$case3"/>
$nem     <input type="checkbox" name="lemma3not" $html_lemma3not/>
@1240:   <input type="text" name="lemma3" size="32" value="$lemma3"/>
$p1
&nbsp;<input type="radio" name="stat" value="stat3" $html_stat3/>
$pv

<br/>

$nem     <input type="checkbox" name="strnot" $html_strnot/>
@1245:   <input type="text" name="str" size="32" value="$str"/>

<br/>

<span style="$kisebb_betu">@1250:</span>
         <input type="checkbox" name="fullcover" $html_fullcover/>

<br/>

<input type="submit" style="background: #ffe299" value="@1400" onSubmit="check()"/>

</form>
</div>

<div style="position: relative; top: 0px; left: 0px">
EE
}

sub html_end {

print <<EE
</div>

<div style="position: relative; top: 0px; left: 0px;
  font-style: italic; $kisebb_betu">

@1500
<!-- ezt lehetne automatizálni! -->

<br/>

$EXAMPLES

<br/><br/>  

@1600

<br/><br/>  

<div style="font-style: normal">
Please, <a href="mailto:sass.balint[at]nytud.hu">inform us</a>
about your research using our tool and refer to the VAB as:<br/>

Sass, Bálint: <a href="http://dx.doi.org/10.1007/978-3-540-87391-4_25">The Verb Argument Browser</a>. In: <em>Sojka, P. et al. (eds.): Proceedings of TSD 2008,</em> Brno, Czech Republic, 2008, LNCS 5246, 187-192, <code>http://corpus.nytud.hu/vab</code>
</div>

<br/><br/>

<span style="$kisebb_betu">v1.0 &ndash; 2018.01.01.</span><br/>
@1700 <a href="@1702">@1701</a><br>
<a href="http://www.nytud.hu">@1800</a>
@1801, 2006&ndash;2018.
</div>

</body>
</html>
EE
}

# prints usage info
sub usage {
  print STDERR <<USAGE;
Usage: $PROG [-p|-x] [-q] [-n] [-i] [-d] [-h]
Mazsola / Verb Argument Browser.
  -p  printmode: csak a példák txt-ben
  -x  printmode: kísérleti (változó) kimenet Birminghambe (2006. dec.)
  -q  régi frekvencia szerinti lista a salience helyett
  -n  nincs 'vizualizáció' (ami egyelõre fakeMI...)
  -i  HTML nyitólap generálása parancssorból
  -d  turns on debugging
  -h  prints this help message & exit
Report bugs to <joker\@nytud.hu>.
USAGE
  exit 1;
}
