FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy as buildstage

# build args
ARG EMBY_RELEASE
ENV DEBIAN_FRONTEND="noninteractive" 

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    cpio \
    jq \
    rpm2cpio && \
  echo "**** install emby ****" && \
  mkdir -p \
    /app/emby && \
  if [ -z ${EMBY_RELEASE+x} ]; then \
    EMBY_RELEASE=$(curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases \
    | jq -r 'first(.[] | select(.prerelease==true )) | .tag_name'); \
  fi && \
  curl -o \
    /tmp/emby.rpm -L \
    "https://github.com/MediaBrowser/Emby.Releases/releases/download/${EMBY_RELEASE}/emby-server-rpm_${EMBY_RELEASE}_x86_64.rpm" && \
  cd /tmp && \
  rpm2cpio emby.rpm \
    | cpio -i --make-directories && \
  mv -t \
    /app/emby/ \
    /tmp/opt/emby-server/system/* \
    /tmp/opt/emby-server/lib/* \
    /tmp/opt/emby-server/bin/ff* \
    /tmp/opt/emby-server/etc \
    /tmp/opt/emby-server/extra/lib/*

# runtime stage
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

ARG DEBIAN_FRONTEND="noninteractive"

# add needed nvidia environment variables for https://github.com/NVIDIA/nvidia-docker
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# install packages
RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    mesa-va-drivers \
    netcat && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY --from=buildstage /app/emby /app/emby
COPY root/ /

# patch
COPY patch /patch
RUN echo "**** patching ****" && /bin/sh /patch/patch.sh

# ports and volumes
EXPOSE 8096 8920
VOLUME /config
