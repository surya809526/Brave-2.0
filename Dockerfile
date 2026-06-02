FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV DISPLAY=:1
WORKDIR /root

# Chromium aur baaki sabse halki jaruri cheezein install karna
RUN apt-get update && apt-get install -y \
    chromium-browser \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    && apt-get clean

# Ekdam foolproof startup script
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
\n\
# 1. Virtual Display open karna\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
sleep 2\n\
\n\
# 2. X11VNC server bina password ke direct start karna\n\
x11vnc -forever -shared -nopw -display :1 -rfbport 5901 &\n\
sleep 2\n\
\n\
# 3. NoVNC Proxy port 3000 par start karna\n\
websockify --web /usr/share/novnc 3000 localhost:5901 &\n\
sleep 2\n\
\n\
# 4. Chromium ko bina sandbox aur extreme low-memory mode mein launch karna\n\
chromium-browser --no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --no-first-run --disable-gpu --window-position=0,0 --window-size=1024,768\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 3000
CMD ["/entrypoint.sh"]
