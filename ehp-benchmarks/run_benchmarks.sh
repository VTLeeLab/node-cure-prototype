#!/bin/bash

# setup the working directories
git clone .. original_node
git clone .. watchdog_node

cd original_node
git checkout "dc6bbb4"
./configure
make -j $(nproc)
cd -

cd watchdog_node
git checkout NODECURE_SILENT
./configure
make -j $(nproc)
cd -

echo "created node projects, now to run benchmarks"

mkdir results
shopt -s nullglob
for file in benchmarks/*.js
do
	
  resultfile=results/"$(basename "${file}" .js)".result
	echo "benchmarking ${file} see the results in ${resultfile}"
	./bench.sh "${file}" &> "${resultfile}"
done
