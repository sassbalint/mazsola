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

  { id => 'tlt',
    db => 'tltnlfr_sample.mazsoladb', # demo: 5000 sentences
    dbfreq => 'tltnlfr_sample.fq', # XXX empty...
    gloss => '@1118 @1180',
    size => '1',
    freqth => 3 },

],


# CFG//$LOAD_AVG_TH                      
LOAD_AVG_TH => 3, # efölött a load fölött nem fogadunk kérést!


# CFG//$CHARSET
CHARSET => 'iso-8859-1',


# CFG//$NOVERBMSG
NOVERBMSG => '', # 1 ha kell, '' ha nem kell


# CFG//$EXAMPLES
EXAMPLES => q(

<!-- VABNLFR -->

<a href="#" onClick="clearAll();
set( 'stem', 'nl_maken\\\\+fr_faire' );
set( 'case1', 'nl_ACC' );
setR( 'stat', 'stat1' )
">nl_maken\+fr_faire nl_ACC</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'nl_maken\\\\+fr_faire' );
set( 'case1', 'fr_ACC' );
setR( 'stat', 'stat1' )
">nl_maken\+fr_faire fr_ACC</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'nl_maken\\\\+fr_faire' );
set( 'case1', 'nl_ACC' );
set( 'lemma1', 'deel' );
set( 'case2', 'fr_ACC' );
set( 'lemma2', 'partie' );
setR( 'stat', 'statstem' )
">maken deel + faire partie</a>

),

