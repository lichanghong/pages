#!/bin/bash

set -e 

hexo clean
hexo g 
hexo d 
#cp -rf public github.io
