
# -- corpus: 'éles teszt'
all:
	@echo
	@echo " You maybe want to do:"
	@echo "make deploy-no-db"
	@echo " to deploy the VAB itself or"
	@echo "make deploy-db"
	@echo " to deploy the data for the VAB."
	@echo
	@echo "The system will be deployed here:"
	@echo "$(DEPLOYURL)"
	@echo
	@echo "Consider setting the following variables in Makefile:"
	@echo " HOST (currently: $(HOST))"
	@echo " MAINNAME (currently: $(MAINNAME))"
	@echo


# -- változók
#
# !!!FONTOS!!! 'mazsola2' -- ez most az 'éles teszthely'
#              -- persze lehet 'mazsola3' is, csak 'mazsola' ne! XXX :)
# = kapásból ide megy "production"-ba a cucc, ideiglenes hely. :)
# LÉNYEG, hogy a valódi éles Mazsolát ('mazsola') felül ne írjuk!
# XXX XXX XXX azaz nehogy véletlenül MAINNAME=mazsola legyen! (!) XXX :)
MAINNAME=mazsola3
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
# CSAK NEHOGY FELÜLÍRJUK ŐKET VMIVEL! (!) XXX :)
DATADIR=/home4/joker/$(MAINNAME)_data
LEMMAFREQDIR=$(DATADIR)/lemmafreq
# persze, lehet így a DATADIR alatt, de nem kötelező
#
# deploy szerver -- program és adatok is ide kerülnek
HOST=localhost
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
LOCALDATADIR=./data
LOCALLEMMAFREQDIR=./data/lemmafreq
#
# url where the deploy is accessible
DEPLOYURL=http://$(HOST)/$(MAINNAME)


# -- deploy (without data)
deploy-no-db: html langs
	@echo
	@echo " Deploying to $(HOST) [MAINNAME=$(MAINNAME)]"
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

# -- deploy (only data)
deploy-db:
	@echo
	@echo " Deploying DATA to $(HOST) [MAINNAME=$(MAINNAME)]"
	@echo
	ssh $(HOST) 'mkdir -p $(DATADIR)'
	ssh $(HOST) 'mkdir -p $(LEMMAFREQDIR)'
	scp .htaccess $(HOSTDATADIR)
	scp $(LOCALDATADIR)/*.mazsoladb $(HOSTDATADIR)
	scp $(LOCALLEMMAFREQDIR)/*.fq $(HOSTLEMMAFREQDIR)
	@echo
	@echo " Deploy of DATA successful. See $(HOSTDATADIR)"
	@echo

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
	@echo " Creating html... (ignore warnings in this part, please)"
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

# -- clean after 'make deploy-no-db'
clean:
	rm -f index_eng.html index_hun.html
	rm -f mazsola_config_eng.pl mazsola_config_hun.pl
	rm -f mazsola_eng.pl mazsola_hun.pl

