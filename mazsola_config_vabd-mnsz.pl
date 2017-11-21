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

  { id => 'mnsz',
    db => 'n.betu', # XXX dem�nak csak a n-bet�s ig�k az MNSZ-b�l :)
    dbfreq => '?.fq', # XXX dbfreq = '?.fq' sim�n megy :)
    gloss => '@1115',
    size => '8',
    freqth => 5 },

  { id => 'vabd',
    db => 'db.rosin',
    dbfreq => 'rosin.lemma.fq',
    gloss => 'Danish Dependency Treebank',
    size => '1',
    freqth => 2 },

],


# CFG//$LOAD_AVG_TH                      
LOAD_AVG_TH => 3, # ef�l�tt a load f�l�tt nem fogadunk k�r�st!


# CFG//$CHARSET
CHARSET => 'iso-8859-2',


# CFG//$NOVERBMSG
NOVERBMSG => 1, # 1 ha kell, '' ha nem kell


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

<!-- VAB -->

<a href="#" onClick="clearAll();
set( 'stem', 'h�ny' );
set( 'case1', '-t' );
setR( 'stat', 'stat1' )
">h�ny -t</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'h�ny' );
set( 'case1', '-re' );
setR( 'stat', 'stat1' )
">h�ny -re</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'esik' );
set( 'case1', '-be' );
setR( 'stat', 'stat1' )
">esik -be</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'fakaszt' );
set( 'case1', '-t' );
setR( 'stat', 'stat1' )
">fakaszt -t</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'ker�l' );
set( 'case1', 'al�' );
setR( 'stat', 'stat1' )
">vmi al� ker�l</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'vesz' );
set( 'case1', 'al�' );
setR( 'stat', 'stat1' )
">vmi al� vesz</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'kever' );
set( 'case1', '-t' );
setR( 'stat', 'stat1' )
">kever -t</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'kavar' );
set( 'case1', '-t' );
setR( 'stat', 'stat1' )
">kavar -t</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'fest' );
set( 'case1', '-t' );
setR( 'stat', 'stat1' )
">fest -t</a>,

<br/>

<a href="#" onClick="clearAll();
set( 'stem', 'fest' );
set( 'case1', '-t' );
set( 'case2', '-re' );
setR( 'stat', 'stat2' )
">fest -t -re</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'ad' );
set( 'case1', '-t' );
set( 'lemma1', 'hang' );
set( 'case2', '-nak' );
setR( 'stat', 'stat2' )
">hangot ad -nek</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'vesz' );
set( 'case1', '-t' );
set( 'lemma1', 'r�sz' );
set( 'case2', '-ben' );
setR( 'stat', 'stat2' )
">r�szt vesz -ben</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'ker�l' );
set( 'case1', '-re' );
set( 'case2', 'alany' );
set( 'lemma2', 'sor' );
setR( 'stat', 'stat1' );
">sor ker�l -re</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'ker�l' );
set( 'case1', '-re' );
set( 'case2', 'alany' );
setC( 'lemma2not', true ); set( 'lemma2', 'sor' );
setR( 'stat', 'stat1' )
">ker�l -re (de nem sor!)</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'forog' );
set( 'case1', '-ben' );
set( 'lemma1', 'vesz�ly' );
set( 'case2', 'alany' );
setR( 'stat', 'stat2' )
">vmi vesz�lyben forog</a>

),

