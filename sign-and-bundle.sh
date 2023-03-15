#! /bin/bash
jarname=beepbeep-3-0.10.8-alpha

# Sign each file
gpg -ab $jarname.pom
gpg -ab $jarname.jar
gpg -ab $jarname-sources.jar
gpg -ab $jarname-javadoc.jar

# Bundle
jar -cvf bundle.jar $jarname.pom $jarname.pom.asc $jarname.jar $jarname.jar.asc $jarname-sources.jar $jarname-sources.jar.asc $jarname-javadoc.jar $jarname-javadoc.jar.asc