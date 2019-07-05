#!/bin/bash
# This script mutates the shell execution environment by creating functions for files on $PATH
# A shell will first look for an alias, then a function and then look for the file on the $PATH.
# By requesting priority through the declaration of a function by the name of the file on the PATH it mitm's the flow

# mkdir -pv /tmp/bin; cp $(which id) /tmp/bin; cd /tmp/bin ; export PATH=/tmp/bin ; alias id='printf "ALIAS\n"' ; id () { printf "FUNCTION\n"; }
# id
# <ALIAS
# unalias id; id
# <FUNCTION
# id
# <uid=0(root) gid=0(root) groups=0(root)

# Testing:
# docker run --rm -ti --mount type=bind,source="${PWD}/hook.sh",target=/hook.sh -- $(docker build -q .)
# . ./hook.sh
_HOOK () {
	bin="$(__WHICH__ ${FUNCNAME[0]})"
	# Check stdin
	# Must happen readline-wise otherwise sudo fails
	STDINDATA=
	if [ ! -t 0 ]; then
		STDINDATA="$(</proc/self/fd/0)"
	fi

	# Check args
	if [ ${#@} -eq 0 ]; then
		cmd="${bin}"
	else
		cmd="${bin} $@"
	fi
	if [ "${DEBUG}" = "1" ]; then
		printf "===[%s]===[input=${#STDINDATA}]\n" "${cmd}" "${#STDINDATA}"
	fi
	if [ -t 0 ]; then
		${cmd}
	else
		if [ "${DEBUG}" = "1" ]; then
			printf "===[STDIN]\n%s\n===\n" "${STDINDATA}"
		fi
		printf "%s" "${STDINDATA}" | ${cmd}
	fi

	code=${?}
	if [ "${DEBUG}" = "1" ]; then
		printf "===[exit status=%s]\n" "$code"
	fi
	return $code
}

# . <( echo 'x() { echo "${FUNCNAME[@]}";}')
# declaration="$(typeset -f x)"
# echo "${declaration/x/bla}"
# . <(echo "${declaration/x/bla}")
# bla

declaration="$(typeset -f _HOOK)"
declaration="${declaration/__WHICH__/$(which which)}"
for f in ${PATH//:/\/* }/*; do
	target="${f##*\/}"
	#if [[ -x "${target}" ]] && 
	if [ "${target}" != "printf" ] && [ "${target}" != "[" ]; then
		printf "%s\n" "${target}"
		. <(printf "%s" "${declaration/_HOOK/function ${target}}")
	fi
done
