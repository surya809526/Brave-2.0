FROM linuxserver/webtop:ubuntu-xfce

USER root

# s6-overlay ke permission issues ko bypass karne ke liye environment variables
ENV S6_STAGE2_HOOK=/init-hook
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Brave Browser ki repository aur key setup karna
RUN apt-get update && apt-get install -y curl gnupg sudo && \
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list

# Brave Browser install karna
RUN apt-get update && apt-get install -y brave-browser

# Render par uid/gid mismatch fixed karne ke liye script
RUN echo '#!/bin/with-contenv bash' > /init-hook && \
    echo 'chmod -R 777 /run' >> /init-hook && \
    chmod +x /init-hook

# Wapas default non-root user par switch karna safely
USER abc
EXPOSE 3000
