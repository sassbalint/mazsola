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

  { id => 'ddt',
    db => 'ddt_sample.mazsoladb', # demo: 1000 sentences
    dbfreq => 'ddt_sample.fq', # XXX empty...
    gloss => '@1116 @1180',
    size => '0',
    freqth => 2 },

],


# CFG//$LOAD_AVG_TH                      
LOAD_AVG_TH => 3, # efölött a load fölött nem fogadunk kérést!


# CFG//$CHARSET
CHARSET => 'iso-8859-1',


# CFG//$NOVERBMSG
NOVERBMSG => '', # 1 ha kell, '' ha nem kell


# CFG//$EXAMPLES
EXAMPLES => q(

<!-- VABD -->

<a href="#" onClick="clearAll();
set( 'stem', 'have' );
set( 'case1', 'dobj' );
setR( 'stat', 'stat1' )
">have dobj</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'få' );
set( 'case1', 'dobj' );
setR( 'stat', 'stat1' )
">få dobj</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'være' );
set( 'case1', 'i' );
setR( 'stat', 'stat1' )
">være i</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'være' );
set( 'case1', 'på' );
setR( 'stat', 'stat1' )
">være på</a>,

<a href="#" onClick="clearAll();
set( 'case1', 'til' );
setR( 'stat', 'stat1' )
">til (without verb)</a>,

<a href="#" onClick="clearAll();
set( 'case1', 'ved' );
setR( 'stat', 'stat1' )
">ved (without verb)</a>

),

