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

  { id => 'vabs',
    db => 'db.szerb',
    dbfreq => 'szerb.lemma.fq',
    gloss => 'Intera corpus (Serbian)',
    size => '1',
    freqth => 3 },

],


# CFG//$LOAD_AVG_TH                      
LOAD_AVG_TH => 3, # efölött a load fölött nem fogadunk kérést!


# CFG//$CHARSET
CHARSET => 'iso-8859-2',


# CFG//$NOVERBMSG
NOVERBMSG => '', # 1 ha kell, '' ha nem kell


# CFG//$EXAMPLES
EXAMPLES => q(

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

