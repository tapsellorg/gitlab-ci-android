FROM ubuntu:18.04

MAINTAINER tapsellprg <technical.tapsell@gmail.com>

ARG SDK_TOOLS_VERSION=4333796
ARG GRADLE_VERSION=6.7.1
ARG FLUTTER_VERSION=v1.12.13+hotfix.7-stable

ENV ANDROID_HOME "/android-sdk-linux"

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y curl \
	&& curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
	&& apt-get install -y git wget unzip jq zip openjdk-11-jdk locales nodejs \
	&& apt-get clean \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

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

RUN cd ${ANDROID_HOME}/tools \
  && mkdir jaxb_lib \
  && wget https://repo1.maven.org/maven2/javax/activation/activation/1.1.1/activation-1.1.1.jar -O jaxb_lib/activation.jar \
  && wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.3/jaxb-impl-2.3.3.jar -O jaxb_lib/jaxb-impl.jar \
  && wget https://repo1.maven.org/maven2/com/sun/istack/istack-commons-runtime/3.0.11/istack-commons-runtime-3.0.11.jar -O jaxb_lib/istack-commons-runtime.jar \
  && wget https://repo1.maven.org/maven2/org/glassfish/jaxb/jaxb-xjc/2.3.3/jaxb-xjc-2.3.3.jar -O jaxb_lib/jaxb-xjc.jar \
  && wget https://repo1.maven.org/maven2/org/glassfish/jaxb/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar -O jaxb_lib/jaxb-core.jar \
  && wget https://repo1.maven.org/maven2/org/glassfish/jaxb/jaxb-jxc/2.3.3/jaxb-jxc-2.3.3.jar -O jaxb_lib/jaxb-jxc.jar \
  && wget https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar -O jaxb_lib/jaxb-api.jar \
  && sed -ie 's%^CLASSPATH=.*%\0:$APP_HOME/jaxb_lib/*%' bin/sdkmanager bin/avdmanager


RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses \
	&& ${ANDROID_HOME}/tools/bin/sdkmanager --update

ADD packages.txt .
RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < ./packages.txt && \
    ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}

RUN npm install -g cordova \
	&& npm install --save-dev ci-publish

RUN npm install -g react-native-cli

# install .net Core SDK
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
	&& dpkg -i packages-microsoft-prod.deb \
	&& apt update \
	&& apt install dotnet-sdk-3.1 -y \
	&& rm packages-microsoft-prod.deb

ENV PATH "$PATH:${ANDROID_HOME}/tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin"

