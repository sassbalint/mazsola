#!/usr/bin/perl -w

use strict;

# CFG//@CORPORA
#
# id, adatb�zisf�jl, lemmafreqf�jl, le�r�s, m�ret (milli� sz�), freqth
# XXX m�g db_noverb is van/lesz egyszer! :)
#
# az id-k sz�veskedjenek k�l�nb�z�k lenni! :)
#  * .gz f�jlokat is lehet ide �rni sz�ks�g eset�n!
#  * t�bb f�jlt is meg lehet egy korpuszk�nt adni, de akkor azok a f�jlok
#    egys�gesen vagy t�m�r�tettek vagy t�m�r�tetlenek legyenek!
CORPORA => [

  { id => 'ddt',
    db => 'ddt_sample.mazsoladb', # demo: 1000 sentences
    dbfreq => 'ddt_sample.fq', # XXX empty...
    gloss => '@1116 @1180',
    size => '0',
    freqth => 2 },

],


# CFG//$LOAD_AVG_TH                      
LOAD_AVG_TH => 3, # ef�l�tt a load f�l�tt nem fogadunk k�r�st!


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
set( 'stem', 'f�' );
set( 'case1', 'dobj' );
setR( 'stat', 'stat1' )
">f� dobj</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'v�re' );
set( 'case1', 'i' );
setR( 'stat', 'stat1' )
">v�re i</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'v�re' );
set( 'case1', 'p�' );
setR( 'stat', 'stat1' )
">v�re p�</a>,

<a href="#" onClick="clearAll();
set( 'case1', 'til' );
setR( 'stat', 'stat1' )
">til (without verb)</a>,

<a href="#" onClick="clearAll();
set( 'case1', 'ved' );
setR( 'stat', 'stat1' )
">ved (without verb)</a>

),

