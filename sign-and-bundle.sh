#! /bin/bash

# ------------------------------------------------------------------------
# Signs and bundles the JAR files for a package deployment to the Central
# Repository.
# 
# (C) 2023 Sylvain Hallé
# Laboratoire d'informatique formelle, Université du Québec à Chicoutimi
# 
# Usage: ./sign-and-bundle.sh <passphrase>
# where <passphrase> is the passphrase required to access the GPG key
# ------------------------------------------------------------------------

# The name of the artifact to produce
jarname=beepbeep-3-palettes-0.5

# Sign each file; exit the script as soon as the operation fails for one
# of them
echo $1 | gpg --batch --pinentry-mode loopback --passphrase-fd 0 -ab $jarname.pom
if [ $? -ne 0 ]; then
	exit $?
fi
echo $1 | gpg --batch --pinentry-mode loopback --passphrase-fd 0 -ab $jarname.jar
if [ $? -ne 0 ]; then
	exit $?
fi
echo $1 | gpg --batch --pinentry-mode loopback --passphrase-fd 0 -ab $jarname-sources.jar
if [ $? -ne 0 ]; then
	exit $?
fi
echo $1 | gpg --batch --pinentry-mode loopback --passphrase-fd 0 -ab $jarname-javadoc.jar
if [ $? -ne 0 ]; then
	exit $?
fi

# Bundle into a JAR. If we get here, all 4 files were successfully signed.
jar -cvf bundle.jar \
  $jarname.pom $jarname.pom.asc $jarname.jar \
  $jarname.jar.asc $jarname-sources.jar $jarname-sources.jar.asc \
  $jarname-javadoc.jar $jarname-javadoc.jar.asc