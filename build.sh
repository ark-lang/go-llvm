#!/bin/sh

# The version of LLVM targeted
llvm_major="3"
llvm_minor="7"
llvm_patch="1"
llvm_version="$llvm_major.$llvm_minor.$llvm_patch"
llvm_svn_tag="RELEASE_$llvm_major$llvm_minor$llvm_patch"

# Setup various paths
basedir=$(dirname "$(readlink -f "$0")")
gollvmdir=$basedir/llvm
workdir=$basedir/workdir
llvmdir=$workdir/src
llvm_builddir=$workdir/build

# Setup cmake flags and easy access to llvm-config and llvm-go
cmake_flags="$llvmdir $@"
llvm_config="$llvm_builddir/bin/llvm-config"
llvm_go="$llvm_builddir/bin/llvm-go"

# Check if we have a compatible LLVM version installed
if [ -n `which llvm-config` ]
then
	system_llvm_version="`llvm-config --version`"
	if [ "$system_llvm_version" = "$llvm_version" ]
	then
		echo "[ ] Using system LLVM"
		rm $basellvm/llvm_config.go &> /dev/null
		export CGO_CPPFLAGS="`llvm-config --cppflags`"
 		export CGO_LDFLAGS="`llvm-config --ldflags --libs --system-libs all`"
 		export CGO_CXXFLAGS="-std=c++11"
 		go install -tags byollvm github.com/ark-lang/go-llvm/llvm
 		exit
	else
		echo "[!] System LLVM version ($system_llvm_version) != required LLVM version ($llvm_version)"
		
	fi
fi

echo "[ ] Building LLVM from source"

# Create build dir
mkdir -p $llvm_builddir

# Fetch the correct version of the llvm source
echo "[ ] Fetching LLVM source tree"
svn co --quiet "https://llvm.org/svn/llvm-project/llvm/tags/$llvm_svn_tag/final/" $llvmdir

# Build llvm
if [ ! -f $llvm_go ]
then
	echo "[ ] Building LLVM"
	(cd $llvm_builddir && cmake $cmake_flags)
	make -C $llvm_builddir -j4
fi

# Create cgo config
echo "[ ] Creating CGO config"
$llvm_go print-config > $gollvmdir/llvm_config.go

# Install binding
echo "[ ] Installing LLVM bindings"
go install github.com/ark-lang/go-llvm/llvm

echo "[ ] Done"