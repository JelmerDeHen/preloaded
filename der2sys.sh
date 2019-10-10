#!/bin/sh
# Helper to append X502 der formatted CA cert exported from intercepting proxy to system
# Apps targeting Android API 23 (V6.0) trust user-added CA store by-default
# Anything higher needs special networkSecurityConfig
# By adding cert to system CA bundle its possible to intercept this particular set-up again
#
#
# All this function does is generate the command needed to append a CA to the system
# For android often a variation of the following may be needed:
# * Authenticate over adb to gain shell access
# * Become root by invoking 'adb root' locally or 'su' remotely
# * Turn SELinux from 'Enforcing' to 'Permissive' (setenforce/getenforce)
# * Remount /system to write to it: mount -o rw,remount /system
# * Or through Magisk module (the example extends hosts module)
der2sys () {
	[ ! -f "${1}" ] && printf "Usage: %s <der>\n" "${0}" && return 1
	X509="$(openssl x509 -inform der -in ${1})"
	HASH="$(printf "%s" "${X509}" | openssl x509 -inform PEM -subject_hash_old | head -n1)"
	DEST="/data/adb/modules/hosts/system/etc/security/cacerts/${HASH}.0"
	cat <<-EOF
		cat >"${DEST}" <<CA
		${X509}
		CA
	EOF
}

der2sys "$1"
