#!/bin/bash
getVer() {
  if [ -z "$1" ]; then echo "Missing apk"; return; fi
  aapt d badging "$1" | grep pack
}

getVer $1