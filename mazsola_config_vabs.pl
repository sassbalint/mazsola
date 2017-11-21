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

  { id => 'vabs',
    db => 'db.szerb',
    dbfreq => 'szerb.lemma.fq',
    gloss => 'Intera corpus (Serbian)',
    size => '1',
    freqth => 3 },

],


# CFG//$LOAD_AVG_TH                      
LOAD_AVG_TH => 3, # ef�l�tt a load f�l�tt nem fogadunk k�r�st!


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

