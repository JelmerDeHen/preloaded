"use strict";
var libc = {
	// #include <unistd.h>
	access:	["int",	["pointer", "int"]],
	alarm:	["int",	["uint"]],
	chdir:	["int",	["pointer"]],
	chown:	["int",  ["pointer", "int", "int"]],
	close:	["int",  ["int"]],
	confstr:	["int",  ["pointer", "int"]],
	//crypt:	["int",  ["pointer", "pointer"]],
	dup:	["int",  ["int"]],
	dup2:	["int",  ["int", "int"]],
	_exit:	["void",  ["int"]],
	//encrypt:	["void",  ["char", "int"]],
	execl:	["int",  ["pointer", "pointer", "pointer"]],// ,...
	execle:	["int",  ["pointer", "pointer", "pointer"]],// ,...
	execvlp:	["int",  ["pointer", "pointer", "pointer"]],// ,...
	execv:	["int",  ["pointer", "pointer"]],
	execve:	["int",  ["pointer", "pointer", "pointer"]],
	execvp:	["int",  ["pointer", "pointer"]],
	faccessat:	["int",  ["int", "pointer", "int", "int"]],
	fchdir:	["int",  ["int"]],
	fchown:	["int",  ["int", "int", "int"]],
	fchownat:	["int",  ["int", "pointer", "int", "int", "int"]],
	fdatasync:	["int",  ["int"]],
	fexecve:	["int",  ["int", "pointer", "pointer"]],
	fork:	["int",  []],
	fpathconf:	["long",  ["int", "int"]],
	fsync:	["int",  ["int"]],
	ftruncate:	["int",  ["int", "int"]],
	getcwd:	["char",  ["pointer", "int"]],
	getegid:	["int",  []],
	geteuid:	["int",  []],
	getgid:	["int",  []],
	getgroups:	["int",  ["int", ["int"]]],
	gethostid:	["long",  []],
	gethostname:	["int",  ["pointer", "int"]],
	//getlogin:	["char",  []],
	getlogin_r:	["int",  ["pointer", "int"]],
	getopt:	["int",  ["int", "pointer", "pointer"]],
	getpgid:	["int",  ["int"]],
	getpgrp:	["int",  []],
	getpid:	["int",  []],
	getppid:	["int",  []],
	getsid:	["int",  ["int"]],
	getuid:	["int",  []],
	isatty:	["int",  ["int"]],
	lchown:	["int",  ["pointer", "int", "int"]],
	link:	["int",  ["pointer", "pointer"]],
	linkat:	["int",  ["int", "pointer", "int", "pointer"]],
	//lockfd:	["int",  []],
	lseek:	["int",  ["int", "int", "int"]],
	nice:	["int",  ["int"]],
	pathconf:	["long",  ["pointer", "int"]],
	pause:	["int",  []],
	pipe:	["int",  [["int", "int"]]],
	pread:	["int",  ["int", "pointer", "int", "int"]],
	pwrite:	["int",  ["pointer", "int", "int"]],
	read:	["int",  ["int", "pointer", "int"]],
	readlink:	["int",  ["pointer", "pointer", "int"]],
	readlinkat:	["int",  ["int", "pointer", "pointer", "int"]],
	rmdir:	["int",  ["pointer"]],
	setegid:	["int",  ["int"]],
	seteuid:	["int",  ["int"]],
	setgid:	["int",  ["int"]],
	setpgid:	["int",  ["int"]],
	setpgrp:	["int",  ["int", "int"]],
	setregid:	["int",  ["int", "int"]],
	setreuid:	["int",  ["int", "int"]],
	setsid:	["int",  []],
	setuid:	["int",  ["int"]],
	sleep:	["int",  ["int"]],
	swab:	["int",  ["pointer", "pointer", "int"]],
	symlink:	["int",  ["pointer", "pointer"]],
	symlinkat:	["int",  ["pointer", "int", "pointer"]],
	sync:	["void",  []],
	sysconf:	["long",  ["int"]],
	tcgetpgrp:	["int",  ["int"]],
	tcsetpgrp:	["int",  ["int", "int"]],
	truncate:	["int",  ["pointer", "int"]],
	ttyname:	["char",  ["int"]],
	ttyname_r:	["int",  ["int", "pointer", "int"]],
	unlink:	["int",  ["pointer"]],
	unlinkat:	["int",  ["int", "pointer", "int"]],
	write:	["int",	["int", "pointer", "int"]],
	// #include <fcntl.h>
	creat:	["int",	["int", "pointer"]],
	fcntl:	["int",	["int", "int"]],//, ...
	open:	["int",	["pointer", "int"]],//, ...
	openat:	["int",	["int", "pointer", "int"]],//, ...
	posix_fadvise:	["int",  ["int", "int", "int", "int"]],
	posix_fallocate:	["int",  ["int", "int", "int"]],
	// #include <sys/mman.h>
	mmap:	["void",	["pointer", "int", "int", "int", "int", "int"]],
	mmap64:	["void",	["pointer", "int", "int", "int", "int", "int"]],
	munmap:	["int",  ["pointer", "int"]],
	mprotect:	["int",  ["pointer", "int", "int"]],
	msync:	["int",	["pointer", "int", "int"]],
	madvise:	["int",  ["pointer", "int", "int"]],
	posix_madvise:	["int",  ["pointer", "int", "int"]],
	mlock:	["int",  ["pointer", "int"]],
	munlock:	["void",  ["pointer", "int"]],
	mlockall:	["int",  ["int"]],
	munlockall:	["int",  []],
	mincore:	["int",  ["pointer", "int", "pointer"]],
	mremap:	["void",  ["pointer", "int", "int", "int"]],// ,...
	remap_file_pages:	["void",  ["pointer", "int", "int", "int", "int"]],
	shm_open:	["int",  ["pointer", "int", "int"]],
	shm_unlink:	["int",  ["pointer"]],
	// #include <sys/memfd.h> !!PARTIAL!!
	memfd_create: ["int",	["pointer", "int"]]
};

var PROT_READ = 0x1;
var PROT_WRITE = 0x2;
var PROT_EXEC = 0x4;

var MAP_SHARED = 0x1;
var MAP_ANONYMOUS = 0x20;
var MAP_GROWSDOWN = 0x0100;
var MAP_DENYWRITE = 0x0800;
var MAP_EXECUTABLE = 0x1000;
var MAP_LOCKED = 0x2000;
var MAP_NORESERVE = 0x4000;
var MAP_POPULATE = 0x8000;

var O_RDONLY = 0x0;
var O_WRONLY = 0x1;
var O_RDWR = 0x2;
var O_CREAT = 0x40;
var O_TRUNC = 0x200;
var O_APPEND = 0x400;

var SEEK_SET = 0;
var SEEK_CUR = 1;
var SEEK_END = 2;

function resolve() {
	var sym = arguments[0];
	//console.log("resolve:"+sym+" "+(nf ? "cache": "resolve"));
	var nf = nativeCache[sym];
	var proxy = function() {
		//console.log("proxy:"+sym+":"+nf);
		var args = [];
		for(var i=0; i<arguments.length; i++) {
			if(typeof arguments[i] == "string") {
				//console.log("String:" + i + ":" + arguments[i] + ":to native utf8");
				args.push(Memory.allocUtf8String(arguments[i]));
			} else {
				//console.log(arguments[i]);
				args.push(arguments[i]);
			}
		}
		return nf.apply(null, args);
	}
	function err = function() {
		console.log("Error resolving " + sym);
		return false;
	}

	if(nf) { return proxy; }
	var np = Module.findExportByName(null, sym);
	if(!np) { return err; }

	// returnType & argTypes are in libc object
	var nf = new NativeFunction(np, libc[sym][0], libc[sym][1]);
	if(!nf) { return err; }

	// Caching
	nativeCache[sym] = nf;
	return proxy;
}

// Idea is that C.fcn will resolve to native implementation
var C = {};
var nativeCache = {};
var fcns = Object.keys(libc);
for(var i=0; i<fcns.length; i++) { Object.defineProperty(C, fcns[i], { get: resolve }); }

// Then use C functions like
function cat() {
	var fd = C.open("/etc/passwd", O_RDONLY);
	if(fd == -1) {
		return false;
	}
	var fsize = C.lseek(fd, 0, SEEK_END);
	C.lseek(fd, 0, SEEK_SET);
	var buf = Memory.alloc(fsize);
	C.read(fd, buf, fsize);
	var ret = Memory.readByteArray(buf, fsize);
	C.close(fd);
	return ret;
}
console.log(cat("/etc/passwd"));
