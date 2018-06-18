
FROM openshift/base-centos7

RUN yum -y update && yum install -y --enablerepo=updates \
    yum-utils \
    bzip2 \
    unzip \
    xz-utils && \
    rm -rf /var/cache/yum && yum clean all -y

RUN yum install -y java-1.8.0-openjdk 

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

# do some fancy footwork to create a JAVA_HOME that's cross-architecture-safe
RUN ln -svT "/usr/lib/jvm/java-8-openjdk-$(uname -m)" /docker-java-home
ENV JAVA_HOME /docker-java-home

ENV JAVA_VERSION 8u171
ENV JAVA_DEBIAN_VERSION 8u171-b11-1~deb9u1

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20170531+nmu1


###
#RUN set -ex; \
## verify that "docker-java-home" returns what we expect
#	[ "$(readlink -f "$JAVA_HOME")" = "$(docker-java-home)" ]; \
#	\
## update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
#	update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
## ... and verify that it actually worked for one of the alternatives we care about
#	update-alternatives --query java | grep -q 'Status: manual'
#
## see CA_CERTIFICATES_JAVA_VERSION notes above
#RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# If you're reading this and have any feedback on how this image could be
# improved, please open an issue or a pull request so we can discuss it!
#
#   https://github.com/docker-library/openjdk/issues
