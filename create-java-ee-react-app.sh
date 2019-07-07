#!/bin/sh
# Shell script for bootstrapping Java EE and React project.
# JDK and Node binaries are macOS versions.
# 
# Heikki Kainulainen, 2018-12-02, 2019-07-07
# https://github.com/hmkainul/create-java-ee-react-app.git

get() {
    BIN=$1
    URL=$2
    FILE=${URL##*/}
    curl -OL $URL
    tar -xf $FILE
    export PATH=$PWD/$BIN:$PATH
}

get_jdk() {
    get jdk8u212-b04/Contents/Home/bin https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u212-b04/OpenJDK8U-jdk_x64_mac_hotspot_8u212b04.tar.gz
}

get_maven() {
    get apache-maven-3.6.1/bin http://www.nic.funet.fi/pub/mirrors/apache.org/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz
}

adam_bien_jee_archetype() {
    mvn archetype:generate \
      -DarchetypeGroupId=com.airhacks \
      -DarchetypeArtifactId=javaee8-essentials-archetype \
      -DarchetypeVersion=0.0.2 \
      -DgroupId=com.example \
      -DartifactId=backend \
      -Dversion=0.0.1 \
      -Darchetype.interactive=false \
      --batch-mode
}

build_backend() {
    cd backend
    mvn clean install
    cd ..
}

get_payara() {
    get payara5/bin https://s3-eu-west-1.amazonaws.com/payara.fish/Payara+Downloads/5.192/payara-5.192.tar.gz
}

install_war() {
    asadmin start-domain
    asadmin deploy --force=true backend/target/backend.war
}

backend() {
    get_jdk
    get_maven
    adam_bien_jee_archetype
    build_backend
    get_payara
    install_war
}

get_node() {
    get node-v12.6.0-darwin-x64/bin https://nodejs.org/dist/v12.6.0/node-v12.6.0-darwin-x64.tar.gz
}

create_react_app() {
    npx create-react-app frontend
    cd frontend
}

modify_package_json() {
    sed 's#  "name": "frontend",#  "name": "frontend",\
  "proxy": "http://localhost:8080/",#' package.json > temp.json
    mv temp.json package.json
}

modify_import() {
    sed 's#import React from#import React, { useState, useEffect } from#' App.js > temp.js
    mv temp.js App.js
}

add_state() {
    sed 's#return (#const [greeting, setGreeting] = useState();\
\
  useEffect(() => {\
    fetch('"'"'/backend/resources/ping'"'"')\
      .then(response => response.text())\
      .then(text => setGreeting(text));\
  }, []);\
\
  return (#' App.js > temp.js
    mv temp.js App.js
}

modify_render() {
    sed 's#</header>#  <p>{greeting}</p>\
      </header>#' App.js > temp.js
    mv temp.js App.js
}

modify_app_js() {
    cd src
    modify_import
    add_state
    modify_render
    cd ..
}

start_frontend() {
    export BROWSER=none
    npm start
}

frontend() {
    get_node
    create_react_app
    modify_package_json
    modify_app_js
    start_frontend
}

open_chrome() {
    open -na "Google Chrome"  --args --new-window --incognito "http://localhost:3000/" "http://localhost:8080/backend/resources/ping"
}

backend
open_chrome
frontend
