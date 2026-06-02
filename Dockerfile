# Mate ki jagah XFCE use kar rahe hain jo kam RAM leta hai
FROM linuxserver/webtop:ubuntu-xfce

USER root

# Brave Browser ki repository aur key setup karna
RUN apt-get update && apt-get install -y curl gnupg sudo
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list

# Brave Browser install karna
RUN apt-get update && apt-get install -y brave-browser

USER abc
EXPOSE 3000
