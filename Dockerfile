FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV DISPLAY=:1
WORKDIR /root

# Zaroori packages aur stable TigerVNC + websockify install karna
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    curl \
    gnupg \
    sudo \
    && apt-get clean

# Brave Browser install karna
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list && \
    apt-get update && apt-get install -y brave-browser

# TigerVNC configuration (Bina local localhost restrictions ke chalne ke liye)
RUN mkdir -p /root/.vnc && \
    echo "vncpasswd" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo "#!/bin/sh\nstartxfce4 &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Full-proof Startup script
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
\n\
# Standalone VNC server start karna jo native ports ko allow kare\n\
vncserver :1 -localhost no -geometry 1280x720 -depth 24 &\n\
sleep 3\n\
\n\
# Websockify ko directly internal display port se link karna\n\
websockify --web /usr/share/novnc 3000 localhost:5901\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 3000
CMD ["/entrypoint.sh"]
