# for debug, download net tools
# FROM --platform=linux/amd64 registry.access.redhat.com/ubi9 AS ubi-micro-build
# RUN mkdir -p /mnt/rootfs
# RUN dnf install --installroot /mnt/rootfs net-tools --releasever 9 --setopt install_weak_deps=false --nodocs -y && \
#     dnf --installroot /mnt/rootfs clean all && \
#     rpm --root /mnt/rootfs -e --nodeps setup

#https://www.keycloak.org/server/containers
FROM --platform=linux/amd64 quay.io/keycloak/keycloak:26.0 AS builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

#dependencies for the ec2 cache stack
ARG AWS_SDK_VERSION=2.28.9
ADD \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/s3/${AWS_SDK_VERSION}/s3-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/auth/${AWS_SDK_VERSION}/auth-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/utils/${AWS_SDK_VERSION}/utils-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/aws-core/${AWS_SDK_VERSION}/aws-core-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/sdk-core/${AWS_SDK_VERSION}/sdk-core-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/retries-spi/${AWS_SDK_VERSION}/retries-spi-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/retries/${AWS_SDK_VERSION}/retries-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/identity-spi/${AWS_SDK_VERSION}/identity-spi-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/http-client-spi/${AWS_SDK_VERSION}/http-client-spi-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/regions/${AWS_SDK_VERSION}/regions-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/profiles/${AWS_SDK_VERSION}/profiles-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/endpoints-spi/${AWS_SDK_VERSION}/endpoints-spi-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/http-auth-spi/${AWS_SDK_VERSION}/http-auth-spi-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/http-auth-aws/${AWS_SDK_VERSION}/http-auth-aws-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/http-auth/${AWS_SDK_VERSION}/http-auth-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/url-connection-client/${AWS_SDK_VERSION}/url-connection-client-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/metrics-spi/${AWS_SDK_VERSION}/metrics-spi-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/aws-xml-protocol/${AWS_SDK_VERSION}/aws-xml-protocol-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/protocol-core/${AWS_SDK_VERSION}/protocol-core-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/aws-query-protocol/${AWS_SDK_VERSION}/aws-query-protocol-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/checksums/${AWS_SDK_VERSION}/checksums-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/checksums-spi/${AWS_SDK_VERSION}/checksums-spi-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/json-utils/${AWS_SDK_VERSION}/json-utils-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/software/amazon/awssdk/third-party-jackson-core/${AWS_SDK_VERSION}/third-party-jackson-core-${AWS_SDK_VERSION}.jar" \
    "https://repo1.maven.org/maven2/org/jgroups/aws/jgroups-aws/3.0.0.Final/jgroups-aws-3.0.0.Final.jar" \
    /opt/keycloak/providers/

USER root
RUN chown -R keycloak:keycloak /opt/keycloak/providers
USER keycloak

ADD ./addons/themes/ /opt/keycloak/themes/

RUN /opt/keycloak/bin/kc.sh build --features=admin-fine-grained-authz

FROM --platform=linux/amd64 quay.io/keycloak/keycloak:26.0
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# for debug
# USER root
# COPY --from=ubi-micro-build /mnt/rootfs /

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
