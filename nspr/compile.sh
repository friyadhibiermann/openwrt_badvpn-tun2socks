#!/bin/sh

set -e
set -x

MAJ_V="4"
MIN_V="8"

SDIR=$(dirname "$0")
build_date=$(date -u --rfc-3339=s)

make_bld_h () {
	echo -n > "$1"
	echo "#define _BUILD_STRING \"`date -d "$build_date" -u +"%F %T"`\"" >> "$1"
	echo "#define _BUILD_TIME `date -d "$build_date" +%s`000000LL" >> "$1"
	echo "#define _PRODUCTION \"lib$2${MAJ_V}.so.${MIN_V}\"" >> "$1"
}

cp -f "$SDIR/pr/include/md/_linux.cfg" ./prcpucfg.h

mkdir -p nspr_inc plc_inc plds_inc
make_bld_h nspr_inc/_pr_bld.h nspr
make_bld_h plc_inc/_pl_bld.h plc
make_bld_h plds_inc/_pl_bld.h plds

CFLAGS="$CFLAGS -fPIC
-I.
-D_LARGEFILE64_SOURCE
-DHAVE_VISIBILITY_HIDDEN_ATTRIBUTE=1
-DHAVE_VISIBILITY_PRAGMA=1
-DXP_UNIX=1
-D_GNU_SOURCE=1
-DHAVE_FCNTL_FILE_LOCKING=1
-DLINUX=1
-DHAVE_LCHOWN=1
-DHAVE_STRERROR=1
-D_REENTRANT=1
-DFORCE_PR_LOG
-D_PR_PTHREADS
"

md_asmfile=""
case $(IFS=-; arr=($CROSS); echo ${arr[0]}) in
	alpha)
		CFLAGS="$CFLAGS -D_ALPHA_ -D__alpha -mieee"
		;;
	i*86)
		CFLAGS="$CFLAGS -Di386"
		md_asmfile="md/unix/os_Linux_x86.s"
		;;
	ia64)
		md_asmfile="md/unix/os_Linux_ia64.s"
		;;
	x86_64)
		md_asmfile="md/unix/os_Linux_x86_64.s"
		;;
	ppc|powerpc)
		md_asmfile="md/unix/os_Linux_ppc.s"
		;;
	m68k)
		CFLAGS="$CFLAGS -m68020-60"
		;;
esac

md_sources=(
	"md/unix/unix.c"
	"md/unix/unix_errors.c"
	"md/unix/uxproces.c"
	"md/unix/uxrng.c"
	"md/unix/uxshm.c"
	"md/unix/uxwrap.c"
	"md/unix/linux.c"
)

nspr_sources=(
	"prvrsion.c"
	"io/prfdcach.c"
	"io/prmwait.c"
	"io/prmapopt.c"
	"io/priometh.c"
	"io/pripv6.c"
	"io/prlayer.c"
	"io/prlog.c"
	"io/prmmap.c"
	"io/prpolevt.c"
	"io/prprf.c"
	"io/prscanf.c"
	"io/prstdio.c"
	"threads/prcmon.c"
	"threads/prrwlock.c"
	"threads/prtpd.c"
	"linking/prlink.c"
	"malloc/prmalloc.c"
	"malloc/prmem.c"
	"md/prosdep.c"
	"memory/prshm.c"
	"memory/prshma.c"
	"memory/prseg.c"
	"misc/pralarm.c"
	"misc/pratom.c"
	"misc/prcountr.c"
	"misc/prdtoa.c"
	"misc/prenv.c"
	"misc/prerr.c"
	"misc/prerror.c"
	"misc/prerrortable.c"
	"misc/prinit.c"
	"misc/prinrval.c"
	"misc/pripc.c"
	"misc/prlog2.c"
	"misc/prlong.c"
	"misc/prnetdb.c"
	"misc/prolock.c"
	"misc/prrng.c"
	"misc/prsystem.c"
	"misc/prthinfo.c"
	"misc/prtpool.c"
	"misc/prtrace.c"
	"misc/prtime.c"
	"pthreads/ptsynch.c"
	"pthreads/ptio.c"
	"pthreads/ptthread.c"
	"pthreads/ptmisc.c"
)

plc_sources=(
	"plvrsion.c"
	"strlen.c"
	"strcpy.c"
	"strdup.c"
	"strcase.c"
	"strcat.c"
	"strcmp.c"
	"strchr.c"
	"strpbrk.c"
	"strstr.c"
	"strtok.c"
	"base64.c"
	"plerror.c"
	"plgetopt.c"
)

plds_sources=(
	"plarena.c"
	"plhash.c"
	"plvrsion.c"
)

# compile MD
md_objs=()
for partfile in ${md_sources[@]}; do
	file="pr/src/$partfile"
	dir=$(dirname "$file")
	mkdir -p "$dir"
	${CROSS}gcc -c $CFLAGS -I "${SDIR}/pr/include" -I "${SDIR}/pr/include/private" "$SDIR/$file" -o "$file.o"
	md_objs=( ${md_objs[@]} "$file.o" )
done
if [ -n "$md_asmfile" ]; then
	file="pr/src/$md_asmfile"
	${CROSS}gcc -c $CFLAGS -I "${SDIR}/pr/include" -I "${SDIR}/pr/include/private" "$SDIR/$file" -o "$file.o"
	md_objs=( ${md_objs[@]} "$file.o" )
fi

# compile NSPR
nspr_objs=()
for partfile in ${nspr_sources[@]}; do
	file="pr/src/$partfile"
	dir=$(dirname "$file")
	mkdir -p "$dir"
	${CROSS}gcc -c $CFLAGS -I "${SDIR}/pr/include" -I "${SDIR}/pr/include/private" -Inspr_inc "$SDIR/$file" -o "$file.o"
	nspr_objs=( ${nspr_objs[@]} "$file.o" )
done

# compile PLC
plc_objs=()
for partfile in ${plc_sources[@]}; do
	file="lib/libc/src/$partfile"
	dir=$(dirname "$file")
	mkdir -p "$dir"
	${CROSS}gcc -c $CFLAGS -I "${SDIR}/pr/include" -I "${SDIR}/lib/libc/include" -Iplc_inc "$SDIR/$file" -o "$file.o"
	plc_objs=( ${plc_objs[@]} "$file.o" )
done

# compile PLDS
plds_objs=()
for partfile in ${plds_sources[@]}; do
	file="lib/ds/$partfile"
	dir=$(dirname "$file")
	mkdir -p "$dir"
	${CROSS}gcc -c $CFLAGS -I "${SDIR}/pr/include" -Iplds_inc "$SDIR/$file" -o "$file.o"
	plds_objs=( ${plds_objs[@]} "$file.o" )
done

# link NSPR
name=nspr
soname=lib${name}${MAJ_V}.so.${MIN_V}
${CROSS}gcc -shared -Wl,-soname -Wl,$soname ${nspr_objs[@]} ${md_objs[@]} -o $soname -lpthread -ldl
ln -sf $soname lib${name}${MAJ_V}.so

# link PLC
name=plc
soname=lib${name}${MAJ_V}.so.${MIN_V}
${CROSS}gcc -shared -Wl,-soname -Wl,$soname ${plc_objs[@]} -o $soname -lpthread -ldl -L. -lnspr${MAJ_V}
ln -sf $soname lib${name}${MAJ_V}.so

# link PLDS
name=plds
soname=lib${name}${MAJ_V}.so.${MIN_V}
${CROSS}gcc -shared -Wl,-soname -Wl,$soname ${plds_objs[@]} -o $soname -lpthread -ldl -L. -lnspr${MAJ_V}
ln -sf $soname lib${name}${MAJ_V}.so
