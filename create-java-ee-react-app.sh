#!/bin/sh
# Shell script for bootstrapping Java EE and React project.
# JDK and Node binaries are macOS versions.
# 
# Heikki Kainulainen, 2018-12-02
# https://github.com/hmkainul/create-java-ee-react-app.git

get_jdk() {
    curl -OL https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u192-b12/OpenJDK8U-jdk_x64_mac_hotspot_8u192b12.tar.gz
    tar -xf OpenJDK8U-jdk_x64_mac_hotspot_8u192b12.tar.gz
    export PATH=$PWD/jdk8u192-b12/Contents/Home/bin:$PATH
}

get_maven() {
    curl -OL http://www.nic.funet.fi/pub/mirrors/apache.org/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
    tar -xf apache-maven-3.6.0-bin.tar.gz
    export PATH=$PWD/apache-maven-3.6.0/bin:$PATH
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
    curl -OL https://s3-eu-west-1.amazonaws.com/payara.fish/Payara+Downloads/5.183/payara-5.183.tar.gz
    tar -xf payara-5.183.tar.gz
    export PATH=$PWD/payara5/bin:$PATH
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
    curl -OL https://nodejs.org/dist/v11.3.0/node-v11.3.0-darwin-x64.tar.gz
    tar -xf node-v11.3.0-darwin-x64.tar.gz
    export PATH=$PWD/node-v11.3.0-darwin-x64/bin:$PATH
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
