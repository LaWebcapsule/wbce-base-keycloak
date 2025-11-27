# for debug, download net tools
# FROM --platform=linux/amd64 registry.access.redhat.com/ubi9 AS ubi-micro-build
# RUN mkdir -p /mnt/rootfs
# RUN dnf install --installroot /mnt/rootfs net-tools --releasever 9 --setopt install_weak_deps=false --nodocs -y && \
#     dnf --installroot /mnt/rootfs clean all && \
#     rpm --root /mnt/rootfs -e --nodeps setup

#https://www.keycloak.org/server/containers
FROM quay.io/keycloak/keycloak:26.4 AS builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

USER root
RUN chown -R keycloak:keycloak /opt/keycloak/providers
USER keycloak

ADD ./addons/themes/ /opt/keycloak/themes/
ADD ./addons/providers/ /opt/keycloak/providers/
RUN /opt/keycloak/bin/kc.sh build --features=admin-fine-grained-authz

FROM quay.io/keycloak/keycloak:26.4
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# for debug
# USER root
# COPY --from=ubi-micro-build /mnt/rootfs /

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
