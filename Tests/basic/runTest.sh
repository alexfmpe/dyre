#!/bin/sh

# Tests basic compiling and running.
# Tests state persistence across restarts.
# Tests custom configuration recompilation.
# Tests restarting a custom configuration.
# Tests compilation error reporting.

. ../subr.sh

### SETUP ###
mkdir -p working
cd working

### TEST A ###
cp ../Lib.hs ../Main.hs .
echo "attempting to make"
$HC --make Main.hs -o basic || die "compilation failed"
OUTPUT_A=`./basic --dyre-debug`
assert "$OUTPUT_A" "Basic Test Version 1.0 - 3" "A"

### TEST B ###
cp ../goodConfig.hs basicTest.hs
OUTPUT_B=`./basic --dyre-debug`
assert "$OUTPUT_B" "Basic Test Version 2.0 - 3" "B"

### TEST C ###
sleep 1
cp ../badConfig.hs basicTest.hs
OUTPUT_C=`./basic --dyre-debug`
assert "$OUTPUT_C" "Compile Error" "C"

### TEST D ###
# Now test that removing the custom config results in
# successful run of non-custom binary.
rm basicTest.hs
OUTPUT_D=`./basic --dyre-debug`
assert "$OUTPUT_D" "Basic Test Version 1.0 - 3" "D"

### TEST E ###
# Test use of modules under "$confdir/lib/"
cp ../moduleConfig.hs basicTest.hs
mkdir lib
cp ../MyConfig.hs lib/MyConfig.hs
OUTPUT_E=`./basic --dyre-debug`
assert "$OUTPUT_E" "Modules are great! - 3" "E"

### TEST F ###
# Test that changes to modules under "$confdir/lib/" trigger recompilation
cp ../moduleConfig.hs basicTest.hs
cp ../MyConfig-updated.hs lib/MyConfig.hs
OUTPUT_E=`./basic --dyre-debug`
assert "$OUTPUT_E" "Modules are still great! - 3" "E"


### TEARDOWN ###
echo "Passed"
cd ..
rm -r working
