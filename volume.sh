#!/bin/sh

amixer sget Master | grep -o -m 1 '[[:digit:]]*%'
