# dnstap.m4

# dt_DNSTAP(default_dnstap_socket_path, [action-if-true], [action-if-false])
# --------------------------------------------------------------------------
# Check for required dnstap libraries and add dnstap configure args.
AC_DEFUN([dt_DNSTAP],
[
  AC_ARG_ENABLE([dnstap],
    AS_HELP_STRING([--disable-dnstap],
                   [Disable dnstap support (requires fstrm, protobuf-c)]),
    [opt_dnstap=$enableval], [opt_dnstap=yes])

  AC_ARG_WITH([dnstap-socket-path],
    AS_HELP_STRING([--with-dnstap-socket-path=pathname],
                   [set default dnstap socket path]),
    [opt_dnstap_socket_path=$withval], [opt_dnstap_socket_path="$1"])

  if test "x$opt_dnstap" != "xno"; then
    AC_PATH_PROG([PROTOC], [protoc])
    # 'protoc-c' is deprecated. We use 'protoc' instead. If it can not be
    # found, try 'protoc-c'.
    if test -z "$PROTOC"; then
	AC_PATH_PROG([PROTOC_C], [protoc-c])
    else
	PROTOC_C="$PROTOC"
    fi
    if test -z "$PROTOC_C"; then
      AC_MSG_ERROR([[The protoc or protoc-c program was not found. It is needed for dnstap, use --disable-dnstap, or install protobuf-c to provide protoc or protoc-c]])
    fi
    AC_ARG_WITH([protobuf-c], AS_HELP_STRING([--with-protobuf-c=path],
    	[Path where protobuf-c is installed, for dnstap]), [
	  # workaround for protobuf-c includes at old dir before protobuf-c-1.0.0
	  if test -f $withval/include/google/protobuf-c/protobuf-c.h; then
	    CFLAGS="$CFLAGS -I$withval/include/google"
	  else
	    CFLAGS="$CFLAGS -I$withval/include"
	  fi
	  LDFLAGS="$LDFLAGS -L$withval/lib"
	], [
	  # workaround for protobuf-c includes at old dir before protobuf-c-1.0.0
	  if test -f /usr/include/google/protobuf-c/protobuf-c.h; then
	    CFLAGS="$CFLAGS -I/usr/include/google"
	  else
	    if test -f /usr/local/include/google/protobuf-c/protobuf-c.h; then
	      CFLAGS="$CFLAGS -I/usr/local/include/google"
	      LDFLAGS="$LDFLAGS -L/usr/local/lib"
	    fi
	  fi
    ])
    AC_ARG_WITH([libfstrm], AS_HELP_STRING([--with-libfstrm=path],
    	[Path where libfstrm is installed, for dnstap]), [
	CFLAGS="$CFLAGS -I$withval/include"
	LDFLAGS="$LDFLAGS -L$withval/lib"
    ])
    AC_SEARCH_LIBS([fstrm_iothr_init], [fstrm], [],
      AC_MSG_ERROR([[The fstrm library was not found. It is needed for dnstap, use --disable-dnstap, or install fstrm-devel]]))
    AC_SEARCH_LIBS([protobuf_c_message_pack], [protobuf-c], [],
      AC_MSG_ERROR([[The protobuf-c library was not found. It is needed for dnstap, use --disable-dnstap, or install protobuf-c]]))
    $2
  else
    $3
  fi
])
