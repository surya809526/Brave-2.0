FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV DISPLAY=:1

EXPOSE 7860

# Sirf zaroori X11 server, lightweight window manager (openbox), aur noVNC install karna
RUN apt-get update && apt-get install -y \
    openbox \
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

# Startup script banana jo sirf Openbox aur Brave Browser ko full-screen chalaye
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
mkdir -p /root/.vnc\n\
echo "renderpass" | vncpasswd -f > /root/.vnc/passwd\n\
chmod 600 /root/.vnc/passwd\n\
\n\
# Xstartup configuration (Bina desktop ke direct Brave run karna)\n\
echo "#!/bin/sh\n\
openbox-session &\n\
brave-browser --no-sandbox --window-position=0,0 --window-size=1280,720 --start-maximized &" > /root/.vnc/xstartup\n\
chmod +x /root/.vnc/xstartup\n\
\n\
# VNC Server start karna mobile-friendly resolution mein\n\
vncserver :1 -localhost no -geometry 1280x720 -depth 16 &\n\
sleep 2\n\
\n\
# noVNC web interface chalana port 7860 par\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 7860\n\
' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

WORKDIR /root
CMD ["/root/entrypoint.sh"]
