#!/bin/sh -xe

# The version of LLVM targeted
llvm_version="RELEASE_371"

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

# Create build dir
mkdir -p $llvm_builddir

# Fetch the correct version of the llvm source
svn co "https://llvm.org/svn/llvm-project/llvm/tags/$llvm_version/final/" $llvmdir

# Build llvm
if [ ! -f $llvm_go ]
then
	(cd $llvm_builddir && cmake $cmake_flags)
	make -C $llvm_builddir -j4
fi

# Create cgo config
$llvm_go print-config > $gollvmdir/llvm_config.go
