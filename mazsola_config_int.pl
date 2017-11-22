#!/usr/bin/perl -w

use strict;

# CFG//@CORPORA
#
# id, adatbázisfájl, lemmafreqfájl, leírás, méret (millió szó), freqth
# XXX még db_noverb is van/lesz egyszer! :)
#
# az id-k szíveskedjenek különbözõk lenni! :)
#  * .gz fájlokat is lehet ide írni szükség esetén!
#  * több fájlt is meg lehet egy korpuszként adni, de akkor azok a fájlok
#    egységesen vagy tömörítettek vagy tömörítetlenek legyenek!
CORPORA => [

  { id => 'int',
    db => 'intera_sample.mazsoladb', # demo: 1000 sentences
    dbfreq => 'intera_sample.fq', # XXX empty...
    gloss => '@1117 @1180',
    size => '0',
    freqth => 2 },

],


# CFG//$LOAD_AVG_TH                      
LOAD_AVG_TH => 3, # efölött a load fölött nem fogadunk kérést!


# CFG//$CHARSET
CHARSET => 'iso-8859-2',


# CFG//$NOVERBMSG
NOVERBMSG => '', # 1 ha kell, '' ha nem kell


# CFG//$EXAMPLES
EXAMPLES => q(

<!-- VABS -->

<a href="#" onClick="clearAll();
set( 'stem', 'imati' );
set( 'case1', 'ANYCASE' );
setR( 'stat', 'stat1' )
">imati ANYCASE</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'imati' );
set( 'case1', 'ANYCASE' );
set( 'lemma1', 'pravo' );
set( 'case2', 'na' );
setR( 'stat', 'stat2' )
">imati pravo na</a>

),

