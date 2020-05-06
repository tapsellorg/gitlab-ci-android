FROM ubuntu:18.04

MAINTAINER tapsellprg <technical.tapsell@gmail.com>

ARG SDK_TOOLS_VERSION=4333796
ARG GRADLE_VERSION=5.4.1
ARG FLUTTER_VERSION=v1.12.13+hotfix.7-stable

ENV ANDROID_HOME "/android-sdk-linux"

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y git wget unzip curl jq npm zip openjdk-8-jdk \
	&& apt-get clean

RUN wget --output-document=gradle-${GRADLE_VERSION}-all.zip https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip \
	&& mkdir -p /opt/gradle \
	&& unzip gradle-${GRADLE_VERSION}-all.zip -d /opt/gradle \
	&& rm ./gradle-${GRADLE_VERSION}-all.zip \
	&& mkdir -p ${ANDROID_HOME} \
	&& wget --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip \
	&& unzip ./android-sdk.zip -d ${ANDROID_HOME} \
	&& rm ./android-sdk.zip \
	&& wget --output-document=flutter.tar.xz https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz \
	&& tar xf flutter.tar.xz -C /opt \
	&& rm ./flutter.tar.xz \
	&& mkdir -p ~/.android \
	&& touch ~/.android/repositories.cfg

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses \
	&& ${ANDROID_HOME}/tools/bin/sdkmanager --update

ADD packages.txt .
RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < ./packages.txt && \
    ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}

RUN npm install -g npm \
	&& npm install -g cordova \
	&& npm install --save-dev ci-publish

RUN npm install -g react-native-cli

# install .net Core SDK
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
	&& dpkg -i packages-microsoft-prod.deb \
	&& apt update \
	&& apt install dotnet-sdk-3.1 -y \
	&& rm packages-microsoft-prod.deb

ENV PATH "$PATH:${ANDROID_HOME}/tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin"

