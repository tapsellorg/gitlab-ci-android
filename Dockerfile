FROM ubuntu:18.04

MAINTAINER behdad.222 <behdad.222@gmail.com>

ARG SDK_TOOLS_VERSION=4333796
ARG GRADLE_VERSION=5.4.1
ARG FLUTTER_VERSION=v1.9.1+hotfix.6

ENV ANDROID_HOME "/android-sdk-linux"
ENV PATH "$PATH:${ANDROID_HOME}/tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin:/opt/flutter/bin"

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y openjdk-8-jdk \
	&& apt-get install -y git wget unzip curl jq npm zip \
	&& apt-get clean

RUN wget --output-document=gradle-${GRADLE_VERSION}-all.zip https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip \
	&& mkdir -p /opt/gradle \
	&& unzip gradle-${GRADLE_VERSION}-all.zip -d /opt/gradle \
	&& rm ./gradle-${GRADLE_VERSION}-all.zip \
	&& mkdir -p ${ANDROID_HOME} \
	&& wget --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip \
	&& unzip ./android-sdk.zip -d ${ANDROID_HOME} \
	&& rm ./android-sdk.zip \
	&& wget --output-document=flutter.tar.xz https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
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
        && npm install -g react-native-cli \
        && npm install --save-dev ci-publish