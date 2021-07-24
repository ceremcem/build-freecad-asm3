#!/bin/bash

for b in backups/*; do
	rev=$(cd $b/home/*/FreeCAD; git rev-parse HEAD)
	echo "$b : $rev"
done
