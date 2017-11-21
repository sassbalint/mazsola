
#### # 2012.04.13. -- lett csak találati szám
#### lett ilyen is! (ami tovább bonyolítja)
#### corpus --> mazsola_hun_cnt.pl (ami csak találati számot ad)
#### diff_script.INFO -t (is) nagyon tessék nézni! :)
#### 
#### # 2010.02.24. -- a szerb mazsola kapcsán
####  !
####  ! még tilosabb make-zni :)
####  ! előbb mindent meg kell csinálni, ami itt van! XXX XXX XXX :)
####  ! 
#### kézzel írtam át a deployoltban:
####  ! 
####  ! A deployoltban (camel (és a dánra a corpus is)) van old verzió,
####  ! azzal mindenképp diffvi-zzek, mielőtt felülírnám!!! XXX
####  ! 
#### #
#### # VAB for Serbian-t is kitettem a corpus-ra: http://corpus/vabs
#### # totálisan kézzel másolgattam oda, ez már tök gáz!!! XXX XXX XXX XXX:)
#### 
#### # 2010. feb -- lett jelszómentes nyitólap
#### # így felelnek meg egymásnak a fájlok
#### #  * itt: index*.html    -> szerver: (s/)mazsola*.html
#### #  * itt: nyitolap*.html -> szerver: index*.html
#### # Ezeket is integrálni kellene a mazsola_skel.pl -be
#### # a közös részek miatt (dizájn, verziószám stb.) (!) XXX 
#### 
#### # 2009. máj -- a dán mazsola kapcsán
####  ! 
####  ! TILOS make-zni, csak így: 'make vab_no_db'
####  ! (eredetileg 'make vabd_no_db' volt, de most átírom általánosra!)
####  ! cdiffvi alapján meg kell csinálni a paraméterezést! config-gal?
####  ! 
#### kézzel írtam át a deployoltban:
####  * két korpuszt beletettem a 'POSS' izé vizsgálatára
#### <   { id => 's1', db => 'db.t.noPOSS',
#### <                gloss => 'db.t.noPOSS', size => '1', freqth => 2 },
#### <   { id => 's2', db => 'db.t.POSS',
#### <                gloss => 'db.t.POSS', size => '1', freqth => 2 },
####  * még egy korpusz az "új" Mazsi tesztelésére:
#### <   { id => 's3', db => 'db.5_pers.vert.portionA_clause2.g7',
#### <                gloss => 'új Mazsi teszt 5/porA', size => '1', freqth => 5 }, 
####  * kikommenteztem a 'for' nagybetűsítését, hogy a dán 'for' prep megmaradhasson
#### #  "for"        => "FOR", -- dán 'for' elöljáró miatt kihagyva! XXX :)
####  * könnyebb dán karakterbevitel... :)
#### $s =~ s/aa/ĺ/g;
#### $s =~ s/ae/ć/g;
#### $s =~ s/oe/ř/g;
####  ! 
####  ! A deployolt-akban (camel és corpus) van old verzió,
####  ! azzal mindenképp diffvi-zzek, mielőtt felülírnám!!! XXX
####  ! 


# -- corpus: 'éles teszt'
all:
	@echo
	@echo "tipp: make deploy-no-db :)"
	@echo


# -- változók
#
# !!!FONTOS!!! 'mazsola2' -- ez most az 'éles teszthely'
# = kapásból ide megy "production"-ba a cucc, de csak én tudok róla. :)
# LÉNYEG, hogy a valódi éles Mazsolát ('mazsola') felül ne írjuk!
# XXX XXX XXX azaz nehogy véletlenül MAINNAME=mazsola legyen! (!) XXX :)
MAINNAME=mazsola2
#
# html és cgi
# root -- IN ANY CASE, THESE MUST EXIST ON $(HOST)!
#         otherwise 'make deploy-no-db' will fail
HTMLROOT=/var/www
CGIROOT=/var/www/cgi-bin
#
# dirs for VAB -- do not change maybe
HTMLDIR=$(HTMLROOT)/$(MAINNAME)
HTMLSECRETDIR=$(HTMLDIR)/s
CGIDIR=$(CGIROOT)/$(MAINNAME)
CGITMPDIR=$(CGIDIR)/tmp
CGILOGDIR=$(CGIDIR)/log
#
YOURGROUPONHOST=www
# a group on $(HOST) writable for you
HOSTWEBSERVERUSER=www-data
# webserver user on $(HOST)
#
# XXX ezeket nem lehetne kiküszöblni/kiszámolni? :)
# XXX ugye a HTMLROOT <--> CGIROOT viszonyából kéne vhogy kiszámolni...
RELCGIDIR=/cgi-bin/$(MAINNAME)
HTMLDIRFROMCGI=../../$(MAINNAME)
HTMLSECRETDIRFROMCGI=../../$(MAINNAME)/s
#
# adatok
# adatnak (for reading) használhatjuk persze az eredeti mazsolás adatokat is
# CSAK NEHOGY FELÜLÍRJUK ŐKET VMI MARHASÁGGAL! (!) XXX :)
DATADIR=/home4/joker/$(MAINNAME)_data
LEMMAFREQDIR=$(DATADIR)/lemmafreq
# persze, lehet így a DATADIR alatt, de nem kötelező
#
# deploy szerver -- program és adatok is ide kerülnek
HOST=corpus.nytud.hu
#
# XXX egyelőre feltesszük, hogy létezik:
#     HOSTHTMLDIR HOSTCGIDIR HOSTDATADIR HOSTLEMMAFREQDIR
HOSTHTMLDIR=$(HOST):$(HTMLDIR)
HOSTHTMLSECRETDIR=$(HOST):$(HTMLSECRETDIR)
HOSTCGIDIR=$(HOST):$(CGIDIR)
HOSTCGITMPDIR=$(HOST):$(CGITMPDIR)
HOSTCGILOGDIR=$(HOST):$(CGILOGDIR)
HOSTDATADIR=$(HOST):$(DATADIR)
HOSTLEMMAFREQDIR=$(HOST):$(LEMMAFREQDIR)
#
# lokális (kiinduló) adatok helye
LOCALDATADIR=/home/joker/cvswork/pcp/db
LOCALLEMMAFREQDIR=/home/joker/cvswork/pcp/lemmafreq
#
# url where the deploy is accessible
DEPLOYURL=http://$(HOST)/$(MAINNAME)


# -- deploy (adatbázisok nélkül)
#
# EZ KELL: chmod 777 $(CGIROOT)/mazsola/tmp -- erre mi a mego? XXX
#
deploy-no-db: html langs
	@echo
	@echo " Deploying to $(HOST)"
	@echo
	#scp mazsola_noauth.html corpus:$(HTMLROOT)/auth # --- ezzel mi legyen? XXX
	#
	# kvtárak a távoli gépen -- sudo kell + 'ssh -t' a jelszóhoz
	# fontos hogy a 3 mkdir sudo-n kívül legyen! :)
	@echo
	@echo " Please provide password for sudo on $(HOST):"
	@echo
	ssh -t $(HOST) "sudo -- sh -c 'mkdir $(HTMLDIR) ; chown root.$(YOURGROUPONHOST) $(HTMLDIR) ; chmod g+ws $(HTMLDIR) ; mkdir $(CGIDIR) ; chown root.$(YOURGROUPONHOST) $(CGIDIR) ; chmod g+ws $(CGIDIR)' ; mkdir $(HTMLSECRETDIR) ; mkdir $(CGITMPDIR) ; mkdir $(CGILOGDIR) ; sudo -- sh -c 'chgrp $(HOSTWEBSERVERUSER) $(CGITMPDIR) $(CGILOGDIR) ; chmod g+w $(CGITMPDIR) $(CGILOGDIR)'"
	#
	scp mazsola.jpg ny.png $(HOSTHTMLDIR)
	scp nyitolap_hun.html $(HOSTHTMLDIR)/index.html
	scp nyitolap_hun.html $(HOSTHTMLDIR)/index_hun.html
	scp nyitolap_eng.html $(HOSTHTMLDIR)/index_eng.html
	scp .htaccess mazsola.jpg $(HOSTHTMLSECRETDIR)
	scp index_hun.html $(HOSTHTMLSECRETDIR)/mazsola.html
	scp index_hun.html $(HOSTHTMLSECRETDIR)/mazsola_hun.html
	scp index_eng.html $(HOSTHTMLSECRETDIR)/mazsola_eng.html
	scp .htaccess mazsola.jpg $(HOSTCGIDIR)
	scp $(LOCALDATADIR)/auto_feldolgozo.pl $(HOSTCGIDIR)
	scp mazsola_hun.pl $(HOSTCGIDIR)
	scp mazsola_eng.pl $(HOSTCGIDIR)
	scp mazsola_config_hun.pl $(HOSTCGIDIR)
	scp mazsola_config_eng.pl $(HOSTCGIDIR)
	@echo
	@echo " Deploy successful. Go to $(DEPLOYURL) and enjoy. :)"
	@echo

# -- deploy (csak az adatbázisok)
#
# XXX ez is mehetne a leendő mazsdb_from_scratch-es config fájlból!
deploy-db:
	scp .htaccess $(HOSTDATADIR)
	scp $(LOCALDATADIR)/db.3-10.g5 $(HOSTDATADIR)
	scp $(LOCALDATADIR)/db.00_press_nem_clause2.g5 $(HOSTDATADIR)
	scp $(LOCALDATADIR)/db.07_pers_ind_clause2.g5 $(HOSTDATADIR)
	scp $(LOCALDATADIR)/db.01_lit_dia_clause2.g5 $(HOSTDATADIR)
	scp $(LOCALDATADIR)/*.betu $(HOSTDATADIR)
	scp $(LOCALDATADIR)/db.reszleges.NI $(HOSTDATADIR)
	scp $(LOCALDATADIR)/db.rosin $(HOSTDATADIR)
	scp $(LOCALDATADIR)/db.szerb $(HOSTDATADIR)
	scp $(LOCALLEMMAFREQDIR)/?.fq $(HOSTLEMMAFREQDIR)


# -- csak a command line változat (hely adatból dolgozik)
# XXX kéne vmi ilyesmi ide: sed "s|ZZCGITMP_DIRZZ|$(CGITMPDIR)|" | \
#     de gondolom nem CGI-be kellene ilyenkor a TMP dir... :)
# XXX hasonlóan: CGILOGDIR... :)
# XXX RELCGIDIR gondolom itt nem kell :)
command: langs
	cat mazsola_hun.pl | \
sed "s|ZZDBFREQ_DIRZZ|$(LOCALLEMMAFREQDIR)|" | \
sed "s|ZZDBFILE_DIRZZ|$(LOCALDATADIR)|" > mazsola_command.pl
	chmod 755 mazsola_command.pl


# -- html-generálás
html: langs
	@echo
	@echo " Creating html..."
	@echo
	./mazsola_hun.pl -i > index_hun.html
	./mazsola_eng.pl -i > index_eng.html


# -- kétnyelvűsítés (a *_repl_* fájlok a lényegesek, ld. 'make replace')
langs: replace
	@echo
	@echo " Performing localization..."
	@echo
	./langs.pl
	mv mazsola_repl_hun.pl mazsola_hun.pl
	mv mazsola_repl_eng.pl mazsola_eng.pl
	chmod 755 mazsola_hun.pl mazsola_eng.pl
	rm -f mazsola_repl_skel.pl


# -- (nyelvfüggetlen) változók behelyettesítése
replace: mazsola_skel.pl
	@echo
	@echo " Setting variables..."
	@echo
	cat mazsola_skel.pl | \
sed "s|ZZHTMLDIRFROMCGIZZ|$(HTMLDIRFROMCGI)|" | \
sed "s|ZZHTMLSECRETDIRFROMCGIZZ|$(HTMLSECRETDIRFROMCGI)|" | \
sed "s|ZZCGITMP_DIRZZ|$(CGITMPDIR)|" | \
sed "s|ZZCGILOG_DIRZZ|$(CGILOGDIR)|" | \
sed "s|ZZRELCGI_DIRZZ|$(RELCGIDIR)|" | \
sed "s|ZZDBFILE_DIRZZ|$(DATADIR)|" | \
sed "s|ZZDBFREQ_DIRZZ|$(LEMMAFREQDIR)|" > mazsola_repl_skel.pl

