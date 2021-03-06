#/bin/sh

. ${TESTDIR}common.sh
set +o errexit
unset SSL_CERT_DIR
unset SSL_CERT_FILE

PORT1=$(($RANDOM + 1024))

mk_cfg <<EOF
backend = "[hitch-tls.org]:80"

frontend = {
  host = "$LISTENADDR"
  port = "$PORT1"
}

pem-file = {
	 cert = "$CERTSDIR/valid.example.com"
	 ocsp-resp-file = "$CERTSDIR/valid.example.com.ocsp"
	 ocsp-verify-staple = on
}
EOF

hitch --test $HITCH_ARGS --config=$CONFFILE
test "$?" != "0" || die "Hitch started when it shouldn't have."

export SSL_CERT_FILE=$CERTSDIR/valid.example.com-ca-chain.pem
hitch --test $HITCH_ARGS --config=$CONFFILE
test "$?" = "0" || die "Hitch did not start."

unset SSL_CERT_FILE

mk_cfg <<EOF
backend = "[hitch-tls.org]:80"

frontend = {
  host = "$LISTENADDR"
  port = "$PORT1"
}

pem-file = {
	 cert = "$CERTSDIR/valid.example.com"
	 ocsp-resp-file = "$CERTSDIR/valid.example.com.ocsp"
	 ocsp-verify-staple = off
}
EOF

hitch --test $HITCH_ARGS --config=$CONFFILE
test "$?" = "0" || die "Hitch did not start."
