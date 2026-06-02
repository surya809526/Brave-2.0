FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV DISPLAY=:1
WORKDIR /root

# Sirf zaroori tools, Xvfb, x11vnc, aur noVNC (Desktop environment poora hata diya RAM bachane ke liye)
RUN apt-get update && apt-get install -y \
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

# Bare-minimum startup script (Sirf display aur direct Brave chalane ke liye)
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
\n\
# 1. Virtual Display start karna\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
sleep 2\n\
\n\
# 2. Bina kisi desktop ke, SEEDHA Brave Browser launch karna sandboxed environments ke liye\n\
brave-browser --no-sandbox --disable-dev-shm-usage --window-position=0,0 --window-size=1024,768 &\n\
sleep 2\n\
\n\
# 3. VNC Server chalana bina password ke\n\
x11vnc -forever -shared -nopw -display :1 -rfbport 5901 &\n\
sleep 2\n\
\n\
# 4. noVNC Proxy chalana\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 3000\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 3000
CMD ["/entrypoint.sh"]
