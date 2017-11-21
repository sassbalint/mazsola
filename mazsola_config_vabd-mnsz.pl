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

  { id => 'mnsz',
    db => 'n.betu', # XXX demónak csak a n-betûs igék az MNSZ-bõl :)
    dbfreq => '?.fq', # XXX dbfreq = '?.fq' simán megy :)
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
LOAD_AVG_TH => 3, # efölött a load fölött nem fogadunk kérést!


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

<!-- VAB -->

<a href="#" onClick="clearAll();
set( 'stem', 'hány' );
set( 'case1', '-t' );
setR( 'stat', 'stat1' )
">hány -t</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'hány' );
set( 'case1', '-re' );
setR( 'stat', 'stat1' )
">hány -re</a>,

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
set( 'stem', 'kerül' );
set( 'case1', 'alá' );
setR( 'stat', 'stat1' )
">vmi alá kerül</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'vesz' );
set( 'case1', 'alá' );
setR( 'stat', 'stat1' )
">vmi alá vesz</a>,

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
set( 'lemma1', 'rész' );
set( 'case2', '-ben' );
setR( 'stat', 'stat2' )
">részt vesz -ben</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'kerül' );
set( 'case1', '-re' );
set( 'case2', 'alany' );
set( 'lemma2', 'sor' );
setR( 'stat', 'stat1' );
">sor kerül -re</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'kerül' );
set( 'case1', '-re' );
set( 'case2', 'alany' );
setC( 'lemma2not', true ); set( 'lemma2', 'sor' );
setR( 'stat', 'stat1' )
">kerül -re (de nem sor!)</a>,

<a href="#" onClick="clearAll();
set( 'stem', 'forog' );
set( 'case1', '-ben' );
set( 'lemma1', 'veszély' );
set( 'case2', 'alany' );
setR( 'stat', 'stat2' )
">vmi veszélyben forog</a>

),

