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

  { id => 'tlt',
    db => 'tltnlfr_sample.mazsoladb', # demo: 5000 sentences
    dbfreq => 'tltnlfr_sample.fq', # XXX empty...
    gloss => '@1118 @1180',
    size => '1',
    freqth => 3 },

],


# CFG//$LOAD_AVG_TH                      
LOAD_AVG_TH => 3, # ef�l�tt a load f�l�tt nem fogadunk k�r�st!


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

