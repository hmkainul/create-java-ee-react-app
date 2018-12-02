#!/bin/sh
# Shell script for bootstrapping Java EE and React project.
# JDK and Node binaries are macOS versions.
# 
# Heikki Kainulainen, 2018-12-02
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
    get jdk8u192-b12/Contents/Home/bin https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u192-b12/OpenJDK8U-jdk_x64_mac_hotspot_8u192b12.tar.gz
}

get_maven() {
    get apache-maven-3.6.0/bin http://www.nic.funet.fi/pub/mirrors/apache.org/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
}

adam_bien_jee_archetype() {
    mvn archetype:generate -DarchetypeGroupId=com.airhacks -DarchetypeArtifactId=javaee8-essentials-archetype -DarchetypeVersion=0.0.2 -DgroupId=com.example -DartifactId=backend -Dversion=0.0.1 -Darchetype.interactive=false --batch-mode
}

build_backend() {
    cd backend
    mvn clean install
    cd ..
}

get_payara() {
    get payara5/bin https://s3-eu-west-1.amazonaws.com/payara.fish/Payara+Downloads/5.183/payara-5.183.tar.gz
}

install_war() {
    asadmin start-domain
    asadmin deploy --force=true backend/target/backend.war
}

open_chrome() {
    open -na "Google Chrome"  --args --new-window --incognito "http://localhost:3000/" "http://localhost:8080/backend/resources/ping"
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
    get node-v11.3.0-darwin-x64/bin https://nodejs.org/dist/v11.3.0/node-v11.3.0-darwin-x64.tar.gz
}

create_react_app() {
    npx create-react-app frontend
    cd frontend
    export BROWSER=none
    npm start
}

frontend() {
    get_node
    create_react_app
}

backend
frontend
open_chrome