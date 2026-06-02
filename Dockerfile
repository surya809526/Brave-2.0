FROM ubuntu:22.04

# Non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Zaroori tools, Lightweight Desktop, Xvfb (Virtual Display), x11vnc aur noVNC install karna
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xvfb \
    x11vnc \
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

# Environment variables
ENV HOME=/root
ENV DISPLAY=:1
WORKDIR /root

# Super stable startup script
RUN echo '#!/bin/bash\n\
# Purani temporary files saaf karna\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
\n\
# 1. Background mein Virtual Display start karna (1280x720 resolution)\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
sleep 2\n\
\n\
# 2. XFCE Desktop environment start karna\n\
startxfce4 &\n\
sleep 2\n\
\n\
# 3. VNC Server start karna (Bina password ke taklif mukt connection ke liye)\n\
x11vnc -forever -shared -nopw -display :1 -rfbport 5901 &\n\
sleep 2\n\
\n\
# 4. noVNC proxy chalana jo port 3000 par listen karegi\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 3000\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 3000

CMD ["/entrypoint.sh"]
