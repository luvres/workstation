#!/bin/bash

## Partitions
fdisk /dev/sdb
n
p
1
<Enter>
+100M
n
p
2
<Enter>
<Enter>
t
1
c
w

dd bs=1024M if=/dev/zero of=/dev/sdb status=progress

_install(){
# Format
  rm boot root -fR; mkdir boot root
  mkfs.vfat /dev/sdb1 && mount /dev/sdb1 boot
  mkfs.f2fs /dev/sdb2 && mount -t f2fs /dev/sdb2 root
##Install
 # RPI 2
  # wget -c http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
  bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root; sync
 # RPI 3
  #wget -c http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-3-latest.tar.gz
  bsdtar -xpf ArchLinuxARM-rpi-3-latest.tar.gz -C root; sync

  mv root/boot/* boot
}; _install


_f2fs(){
# https://www.zybuluo.com/yangxuan/note/344907
  echo '/dev/mmcblk0p2 / f2fs defaults,noatime,discard 0 0' >>root/etc/fstab
  echo 'tmpfs   /tmp     tmpfs   nodev,nosuid,size=2G  0 0' >>root/etc/fstab
  cp root/bin/true root/sbin/fsck.f2fs
  sed -i 's/$/& rootfstype=f2fs/' boot/cmdline.txt # Mouse lag
  sed -i 's/$/& usbhid.mousepoll=0/' boot/cmdline.txt # Rootfs type
  echo 'dtparam=audio=on' >>boot/config.txt
  echo 'hdmi_drive=2' >>boot/config.txt
  echo 'dtparam=sd_overclock=100' >>boot/config.txt #Class 10 SD card
  umount boot root
}; _f2fs


############
### Init ###
############
ssh -l alarm pi
passwd: alarm
su # passwd: root

## Pass
_pass(){
  echo "root:aamu02" | chpasswd
  echo "alarm:aamu02" | chpasswd
}; _pass

## Swap File
_swap(){
  dd if=/dev/zero of=/swapfile bs=1M count=512
  chmod 0600 /swapfile 
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap defaults 0 0' >>/etc/fstab
}; _swap

## ILoveCandy
_ilovecandy(){
  sed -i 's/VerbosePkgLists/VerbosePkgLists\nILoveCandy/' /etc/pacman.conf
  sed -i '/Color/s/#//' /etc/pacman.conf
}; _ilovecandy

## Update
_update(){
  rm /etc/ssl/certs/ca-certificates.crt 2>/dev/null
  pacman-key --init
  pacman -Syu --noconfirm
# Base
  pacman -S --noconfirm \
  sudo rsync git docker wget screen tmux htop cpio screenfetch
# Base devel
  pacman -Sy --noconfirm --needed base-devel
}; _update


## Desktop
_desktop(){
# Xorg
  pacman -S --noconfirm \
  xorg-server xf86-video-fbdev xorg-xrefresh
# Sound
  pacman -S --noconfirm \
  alsa-utils alsa-plugins pulseaudio pulseaudio-alsa
# xfce4 Core
  pacman -S --noconfirm \
  xfce4-panel xfce4-session xfce4-settings xfdesktop xfwm4
# sddm
  pacman -S --noconfirm sddm
  #sddm --example-config >/etc/sddm.conf
# Packages base
  pacman -S --noconfirm \
  xfce4-power-manager xfce4-pulseaudio-plugin \
  lxappearance gnome-system-monitor gksu \
  xfce4-terminal ristretto leafpad chromium
}; _desktop

## Thunar
_thunar(){
  pacman -S --noconfirm \
  thunar thunar-volman gvfs xdg-user-dirs
}; _thunar

## NetworkManager
_networkmanager(){
  pacman -S --noconfirm \
  networkmanager networkmanager-dispatcher-ntpd network-manager-applet \
  wireless_tools dialog
  systemctl enable NetworkManager
}; _networkmanager

## Bluetooth
_bluetooth(){
  sudo pacman -S blueman bluez-utils
  yaourt -S pi-bluetooth
  sudo systemctl start bluetooth.service
  sudo systemctl enable bluetooth.service
  sudo systemctl enable brcm43438.service
}; _bluetooth

## Plank
_plank(){
  pacman -S --noconfirm plank && \
  git clone https://github.com/mateuspv/plank-themes.git
  cp -a plank-themes/themes/Translucent-Panel /usr/share/plank/themes/
  rm plank-themes/ -fR
  cp /usr/share/plank/themes/Translucent-Panel/dock.theme /usr/share/plank/themes/Default/
  #echo "plank &" >>/home/`ls /home/`/.xinitrc
  chown -R `ls /home/`. /home/`ls /home/`/.xinitrc
}; _plank

## Background
_background(){
  curl -L https://github.com/luvres/workstation/blob/master/background.tar.gz?raw=true | tar -xzf - -C /usr/share/backgrounds/
}; _background

## Mac OS X Themes
_macosx(){
  # Themes
  mkdir /home/`ls /home/`/.themes
  curl http://logico.com.ar/downloads/xosemite-gtk.tar.gz | tar -xzf - -C /home/`ls /home/`/.themes
  curl http://logico.com.ar/downloads/xosemite-xfce.tar.gz | tar -xzf - -C /home/`ls /home/`/.themes
  chown -R `ls /home/`. /home/`ls /home/`/.themes

  # Fonts
  mkdir /home/`ls /home/`/.fonts
  curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Bold.ttf?raw=true -o /home/`ls /home/`/.fonts/System\ San\ Francisco\ Display\ Bold.ttf
  curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Regular.ttf?raw=true -o /home/`ls /home/`/.fonts/System\ San\ Francisco\ Display\ Regular.ttf
  curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Thin.ttf?raw=true -o /home/`ls /home/`/.fonts/System\ San\ Francisco\ Display\ Thin.ttf
  curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Ultralight.ttf?raw=true -o /home/`ls /home/`/.fonts/System\ San\ Francisco\ Display\ Ultralight.ttf
  curl -L https://github.com/hbin/top-programming-fonts/blob/master/Menlo-Regular.ttf?raw=true -o /home/`ls /home/`/.fonts/Menlo-Regular.ttf
  chown -R `ls /home/`. /home/`ls /home/`/.fonts
}; _macosx

## Configurations
# archlinuxfr
  echo '[archlinuxfr]' >> /etc/pacman.conf
  echo 'SigLevel = Never' >> /etc/pacman.conf
  echo 'Server = http://repo.archlinux.fr/arm' >> /etc/pacman.conf
# Sudo
  echo 'alarm  ALL=NOPASSWD: ALL' >>/etc/sudoers.d/myOverrides
# Locale
  sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
  locale-gen
  echo 'export LANG=en_US.UTF-8' >>/etc/profile
  echo 'export LC_ALL=en_US.UTF-8' >>/etc/profile
# Docker
  #pacman -Rns docker
  #rm -rf /var/lib/docker
  systemctl enable docker
  usermod -aG docker `ls /home/`
# sddm
  systemctl enable sddm.service
  #autologin
  sed -i '6s/$/&xfce.desktop/' /etc/sddm.conf
  sed -i "9s/$/&`ls /home`/" /etc/sddm.conf
  #sed -i '30s/$/&archlinux-simplyblack/' /etc/sddm.conf
# Java 8
  archlinux-java set java-8-openjdk/jre
}; _configs

## Packages
_packages(){
  pacman -S --noconfirm \
  gftp youtube-dl \
  firefox vlc qt4 \
  libreoffice-fresh gimp blender
}; _packages

## Development
_development(){
  pacman -S --noconfirm \
  qt5-base qtcreator netbeans mysql-workbench
}; _development

## Arduino IDE
_arduino(){
  VERSION_ARDUINO=1.8.1
  wget -c https://downloads.arduino.cc/arduino-${VERSION_ARDUINO}-linuxarm.tar.xz
  tar Jxf arduino-${VERSION_ARDUINO}-linuxarm.tar.xz
  rm arduino-${VERSION_ARDUINO}-linuxarm.tar.xz
  arduino-${VERSION_ARDUINO}/install.sh
}; _arduino


reboot

#####################
### <ctrl>d alarm ###
#####################
## Files
_files(){
# Mountpoint
  sudo sh -c "echo '/dev/sda1 /mnt auto noatime 0 0' >>/etc/fstab"
# Lighttpd
  docker run --name ftp -h ftp \
  -p 80:80 \
  -v /mnt/ftp:/var/www \
  -d izone/arm:lighttpd
  #rsync -avz --delete --progress /aux/ pi@raspberrypi:/mnt/ftp
  #sshpass -p "aamu02" rsync -avz --delete --progress /aux/ alarm@alarmpi:/mnt/ftp
}; _files

## Bashrc
_bashrc(){
  curl -L https://github.com/luvres/workstation/blob/master/bashrc.tar.gz?raw=true | tar -xzf - -C $HOME
  echo '' >>$HOME/.bashrc
  echo screenfetch >>$HOME/.bashrc
}; _bashrc

## Yaourt
_yaourt(){
  #sudo pacman -Sy --noconfirm --needed base-devel
  cd ~ && curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
  tar zxvf package-query.tar.gz && cd package-query
  makepkg -si
  sudo pacman -S --noconfirm yaourt
  cd ~ && rm package-query* -fR
}; _yaourt

#################
### Customers ###
#################
## Themes
yaourt -S --noconfirm \
faenza-icon-theme numix-circle-icon-theme-git

## Terminal Mac OS X
# Text color: #000000
# Background color: #FFFFFF 
# Cursor color: #929292
# Tab active color: #BFBFBF
# [x] Text selection color: #BFBFBF
# [x] Bold text color: #000000



## Compile FreeCAD
sudo mount -o remount,size=1G,noatime /tmp
# Swap File
sudo swapon /mnt/swapfile
# FreeCAD Netgen Git
yaourt -S freecad-netgen-git
# Source FreeCAD
mkdir 1uvr3z && cd 1uvr3z
git clone https://github.com/FreeCAD/FreeCAD.git
mkdir freecad-build && cd freecad-build
# Build
cmake -DCMAKE_BUILD_TYPE=Debug -DBUILD_FEM_NETGEN=ON ../FreeCAD
time make


######################
######################
######################

## xf86-video-fbturbo
_fbturbo(){
    sudo pacman -S make gcc git-core automake autoconf pkg-config libtool
    cd ~
    git clone https://github.com/robclark/libdri2.git
    git clone https://github.com/ssvb/xf86-video-fbturbo
    cd ~/libdri2
    ./autogen.sh --prefix=/usr
    sudo make install
    cd ~/xf86-video-fbturbo
    autoreconf -vi
    ./configure --prefix=/usr
    make
    sudo make install
    sudo cp xorg.conf /usr/share/X11/xorg.conf.d/99-fbturbo.conf
}; _fbturbo


### Web Server
_webserver(){
  pacman -S --noconfirm apache
  sed -i '/DocumentRoot/s/\/srv\/http/\/srv\/http\/ftp/g' /etc/httpd/conf/httpd.conf
  ln -s /mnt/ftp/ /srv/http/ftp
  systemctl enable httpd
  systemctl start httpd
  #rsync -avz --delete --progress /aux/ alarm@pi:/mnt/ftp
  #sshpass -p "aamu02" rsync -avz --delete --progress /aux/ alarm@pi:/mnt/ftp
# Mountpoint
  echo '/dev/sda1 /mnt auto noatime 0 0' >>/etc/fstab
}; _webserver

## VNC
pacman -S tigervnc
vncserver
x0vncserver -display :0 -passwordfile ~/.vnc/passwd

###########################

# Bashrc
nano $HOME/.bashrc
alias ls='ls --color=auto'
alias ll='ls -lA'
alias l='ll -h'
alias pacman='pacman --color=auto'
alias h='history'
alias grep='grep --color'
source $HOME/.bashrc

### packer
sudo pacman -S packer
sudo sed -i '/${EDITOR:-vi}/s/vi/nano/g' /usr/bin/packer

# Keyboard map
echo 'setxkbmap -model abnt2 -layout br -variant abnt2' >>$HOME/.bashrc

#######################
### Powerline
sudo pip install powerline-status
packer -S powerline-fonts-git tmux

cat >> $HOME/.bashrc <<EOF

# Powerline
if [ -f `which powerline-daemon` ]; then
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/lib/python3.5/site-packages/powerline/bindings/bash/powerline.sh
fi
EOF

mkdir ~/.config/powerline
cp /usr/lib/python3.5/site-packages/powerline/config_files/config.json ~/.config/powerline

sudo nano ~/.config/powerline/config.json
   "shell": {
           ...
           #"theme": "default",
           "theme": "default_leftonly",

powerline-daemon --replace


# Tmux
cat >>$HOME/.tmux.conf <<EOF
# 256 Color
source /usr/lib/python3.5/site-packages/powerline/bindings/tmux/powerline.conf
set-option -g default-terminal "screen-256color"
EOF

# Vim
packer -S gvim
cat >>$HOME/.vimrc <<EOF
set  rtp+=/usr/lib/python3.5/site-packages/powerline/bindings/vim
set laststatus=2
set t_Co=256
EOF

### backup/migration
sudo pacman -Syu rsync
sudo rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / /path/to/backup/folder

### Samba
sudo pacman -S samba
sudo cp /etc/samba/smb.conf.default /etc/samba/smb.conf
sudo pdbedit -a -u username
sudo systemctl start smbd nmbd
sudo systemctl enable smbd nmbd
sudo pacman -S gvfs-smb

### MATE ###
sudo pacman -S xorg-server xorg-server-utils xorg-xinit xorg-utils 
sudo pacman -S mate mate-extra
echo 'exec mate-session' >$HOME/.xinitrc

### NFS
pacman -S nfs-utils rpcbind
mkdir $HOME/www
echo '$HOME/www 191.96.255.100/27(rw,sync,no_subtree_check)' >>/etc/exports
systemctl start rpcbind
systemctl start nfs-server.service
## Reinstall
#pacman -R nfs-utils
#rm -r /var/lib/nfs
#pacman -S nfs-utils
##
pacman -S nfs-utils rpcbind
mkdir $HOME/www
echo '$HOME/www 191.96.255.100/27(rw,sync,no_subtree_check)' >>/etc/exports
echo '$HOME/www *(rw,sync,no_subtree_check)' >>/etc/exports
##
systemd start rpcbind
systemd start nfs-server
##
exportfs -ra
##
sudo systemctl enable rpc-idmapd
sudo systemctl start rpc-idmapd
sudo systemctl enable rpc-mountd
sudo systemctl start rpc-mountd


