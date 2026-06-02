FROM ubuntu:22.04

# Non-interactive mode set karna taaki installation ke waqt prompt na ruke
ENV DEBIAN_FRONTEND=noninteractive

# Zaroori packages, Lightweight XFCE Desktop, VNC, aur noVNC install karna
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    novnc \
    websockify \
    curl \
    gnupg \
    sudo \
    && apt-get clean

# Brave Browser ki official repository add aur install karna
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list && \
    apt-get update && apt-get install -y brave-browser

# Environment setup
ENV HOME=/root
ENV DISPLAY=:1
WORKDIR /root

# VNC aur noVNC ko ek sath start karne ke liye startup script
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
mkdir -p /root/.vnc\n\
echo "vncpasswd" | vncpasswd -f > /root/.vnc/passwd\n\
chmod 600 /root/.vnc/passwd\n\
echo "startxfce4 &" > /root/.vnc/xstartup\n\
chmod +x /root/.vnc/xstartup\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 3000\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 3000

CMD ["/entrypoint.sh"]
