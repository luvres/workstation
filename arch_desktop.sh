
#!/bin/bash

if [ $# -ne 1 ]; then
  echo ""
  echo "   sh arch_desktop.sh [ xorg , plasma, xfce , xfce4 , packages , virtualbox , development, networkmanager, bluetooth ]"
  echo ""
  exit 1
fi

## Swap File
_swapfile(){
  # dd if=/dev/zero of=/swapfile bs=1M count=512
  dd if=/dev/zero of=/swapfile bs=1M count=4096
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap defaults 0 0' >>/etc/fstab

 # ILoveCnady
  sed -i 's/VerbosePkgLists/VerbosePkgLists\nILoveCandy/' /etc/pacman.conf
  sed -i '/Color/s/#//' /etc/pacman.conf
  #pacman-key --refresh-keys && pacman-key --init && pacman -Syu --noconfirm
  pacman -Syyu --noconfirm

 # Correction Makepkg
  sed -i '/If using/s/--/#--/' /etc/makepkg.conf

 # Reflector
  pacman -S --noconfirm reflector
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
  reflector --verbose -l 30 -p http --sort rate --save /etc/pacman.d/mirrorlist
}

## Bashrc
_bashrc(){
  curl -L https://github.com/luvres/workstation/blob/master/bashrc.tar.gz?raw=true | tar -xzf - -C /home/`ls /home/`/
  echo '' >>/home/`ls /home/`/.bashrc
  #echo screenfetch >>/home/`ls /home/`/.bashrc
}

## Xorg
#---------------
_xorg(){
 # Xorg
  pacman -S --noconfirm \
  xorg xorg-xinit

 # Sound
  pacman -S --noconfirm \
  alsa-utils alsa-plugins pulseaudio pulseaudio-alsa

 # Input Drivers
  pacman -S --noconfirm \
  xf86-input-keyboard xf86-input-mouse

 # Video drivers
  pacman -S --noconfirm \
  xf86-video-vesa xf86-video-intel
  #virtualbox-guest-utils

 # Fonts
  pacman -S --noconfirm \
  artwiz-fonts font-bh-ttf font-bitstream-speedo gsfonts sdl_ttf \
  ttf-bitstream-vera ttf-cheapskate ttf-dejavu ttf-liberation xorg-fonts-type1 \
  ttf-droid ttf-gentium ttf-liberation ttf-ubuntu-font-family ttf-anonymous-pro

 # Print
  pacman -S --noconfirm \
  cups cups-pdf ghostscript

  systemctl enable org.cups.cupsd
}

## Makepkg
#----------
_makepkg(){
  sed -i '/MAKEFLAGS/s/#//' /etc/makepkg.conf
  sed -i '/MAKEFLAGS/s/2/4/' /etc/makepkg.conf
  sed -i '/COMPRESSXZ/s/c/c -T 6/' /etc/makepkg.conf
  # nano /etc/makepkg.conf #line 63
}

_makepkg6(){
  sed -i '/MAKEFLAGS/s/#//' /etc/makepkg.conf
  sed -i '/MAKEFLAGS/s/2/6/' /etc/makepkg.conf
  sed -i '/COMPRESSXZ/s/c/c -T 6/' /etc/makepkg.conf
  # nano /etc/makepkg.conf #line 63
}

_makepkg8(){
  sed -i '/MAKEFLAGS/s/#//' /etc/makepkg.conf
  sed -i '/MAKEFLAGS/s/2/8/' /etc/makepkg.conf
  sed -i '/COMPRESSXZ/s/c/c -T 6/' /etc/makepkg.conf
  # nano /etc/makepkg.conf #line 63
}


## KDE Plasma
#-------------
_plasma(){
 # Core
  pacman -S --noconfirm \
  plasma-desktop
  echo "exec startkde &" >/home/`ls /home/`/.xinitrc
  chown -R `ls /home/`. /home/`ls /home/`/.xinitrc

 # Base
  pacman -S --noconfirm \
  plasma-nm plasma-pa powerdevil \
  breeze-gtk breeze-kde4 kde-gtk-config kdeplasma-addons kinfocenter

 # Packages base
  pacman -S --noconfirm \
  dolphin ffmpegthumbs kdegraphics-thumbnailers xdg-user-dirs \
  ark kipi-plugins \
  konsole kwrite kate kcolorchooser ktorrent gwenview

 # Packages
  pacman -S --noconfirm \
  freeglut jdk8-openjdk wine \
  gftp xclip terminator youtube-dl mysql-workbench sublime-text-dev screenfetch \
  firefox chromium libreoffice-fresh vlc gimp blender

 # Bluetooth
  pacman -S --noconfirm bluez bluez-utils bluedevil
  systemctl enable bluetooth.service

 # NetworkManager
  pacman -S --noconfirm networkmanager
  systemctl enable NetworkManager
  systemctl disable dhcpcd
  # openconnect networkmanager-openconnect

 # Simple Desktop Display Manager
  #pacman -S --noconfirm sddm
  #systemctl enable sddm.service
  sed -i '/Current=/s/$/&breeze/' /etc/sddm.conf

  #################
  # pacman -S --noconfirm \
  # kwalletmanager digikam spectacle kruler okular amarok speedcdrunch redshift kompare kfind sddm-kcm
  # adobe-source-sans-pro-fonts aspell-en enchant gst-libav gst-plugins-good hunspell-en \
  # icedtea-web  languagetool libmythes mythes-en pkgstats
  #################
}

## Deepin
#---------
_deepin(){
 # Core
  pacman -S --noconfirm \
  deepin
  echo "exec startkde &" >/home/`ls /home/`/.xinitrc
  chown -R `ls /home/`. /home/`ls /home/`/.xinitrc

 # Base
  pacman -S --noconfirm \
  deepin-extra

 # LightDM
  sed -i '/#greeter-sess/s/example-gtk-gnome/lightdm-deepin-greeter/' /etc/lightdm/lightdm.conf
  sed -i '/#greeter-sess/s/#//' /etc/lightdm/lightdm.conf
}

## Xfce4
#--------
_xfce4(){
 # Core
  pacman -S --noconfirm \
  xfce4-panel xfce4-session xfce4-settings xfdesktop xfwm4
  # cp /etc/X11/xinit/xinitrc /home/`ls /home/`/.xinitrc
  # sed -i 's/exec xterm/#exec xterm/' /home/`ls /home/`/.xinitrc
  # sed -i "/twm/s/twm &/exec startxfce4\n&/" /home/`ls /home/`/.xinitrc
  echo "exec startxfce4 &" >/home/`ls /home/`/.xinitrc
  chown -R `ls /home/`. /home/`ls /home/`/.xinitrc

 # Packages base
  pacman -S --noconfirm \
  xfce4-power-manager xfce4-pulseaudio-plugin xfce4-whiskermenu-plugin \
  lxappearance gnome-system-monitor gksu \
  terminator ristretto leafpad chromium zathura zathura-pdf-poppler file-roller
  sed -i 's/NotShowIn/#NotShowIn/' /usr/share/applications/lxappearance.desktop
}

## Thunar
#---------
_thunar(){
  pacman -S --noconfirm \
  thunar thunar-volman gvfs xdg-user-dirs
}

## NetworkManager
#-----------------
_networkmanager(){
  pacman -S --noconfirm \
  networkmanager networkmanager-dispatcher-ntpd network-manager-applet \
  wireless_tools dialog openconnect networkmanager-openconnect
  systemctl enable NetworkManager
}

## Bluetooth
#------------
_bluetooth(){
  pacman -S --noconfirm \
  blueman bluez-utils
  systemctl enable bluetooth.service
}

## Packages
#-----------
_packages(){
  pacman -S --noconfirm \
  gftp youtube-dl screenfetch transmission-gtk \
  firefox flashplugin vlc qt4 \
  libreoffice-fresh gimp blender
}

## Development
#--------------
_development(){
  pacman -S --noconfirm \
  qt5-base qtcreator eclipse-jee netbeans \
  mysql-workbench arduino atom
}

## SDDM
#-------
_sddm(){
  pacman -S --noconfirm sddm
  systemctl enable sddm.service
}

## LightDM
#----------
_lightdm(){
  pacman -S --noconfirm lightdm
  systemctl enable lightdm.service
}

## Slim
#-------
_slim(){
  pacman -S --noconfirm slim slim-themes archlinux-themes-slim
  systemctl enable slim.service
  sed -i '/#default_user/s/#//' /etc/slim.conf
  sed -i "s/simone/`ls /home/`/" /etc/slim.conf
  sed -i '/current_theme/s/default/archlinux-simplyblack/' /etc/slim.conf
  ##
  # sed -i '/auto_login/s/#//' /etc/slim.conf
  # sed -i '/auto_login/s/no/yes/' /etc/slim.conf
  ## sed -i 's/auto_login/#auto_login/' /etc/slim.conf
  ## sed -i '/auto_login/s/yes/no/' /etc/slim.conf
}

## Background
#-------------
_background(){
  curl -L https://github.com/luvres/workstation/blob/master/background.tar.gz?raw=true | tar -xzf - -C /usr/share/backgrounds/
}

## Plank
#--------
_plank(){
  pacman -S --noconfirm plank
  git clone https://github.com/mateuspv/plank-themes.git
  cp -a plank-themes/themes/Translucent-Panel /usr/share/plank/themes/
  rm plank-themes/ -fR
  cp /usr/share/plank/themes/Translucent-Panel/dock.theme /usr/share/plank/themes/Default/

  #echo "plank &" >>/home/`ls /home/`/.xinitrc
  chown -R `ls /home/`. /home/`ls /home/`/.xinitrc
}

## Virtualbox
#-------------
_virtualbox(){
  pacman -S --noconfirm \
  virtualbox virtualbox-host-dkms linux-headers  
  gpasswd -a `ls /home/` vboxusers
  echo 'vboxnetadp' >>/etc/modules-load.d/virtualbox.conf
  echo 'vboxnetflt' >>/etc/modules-load.d/virtualbox.conf
  # http://download.virtualbox.org/virtualbox/
  # depmod -a
  # modprobe -a vboxnetadp vboxnetflt
}

## Mac OS X Themes
#------------------
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
}


if [[ $1 == "xorg" ]]; then
  _swapfile
  _bashrc
  _xorg
fi

if [[ $1 == "makepkg" ]]; then
  _makepkg
fi
if [[ $1 == "makepkg6" ]]; then
  _makepkg6
fi
if [[ $1 == "makepkg8" ]]; then
  _makepkg8
fi

if [[ $1 == "plasma" ]]; then
  _sddm
  _plasma
fi

if [[ $1 == "deepin" ]]; then
  _lightdm
  _deepin
  _networkmanager
fi

if [[ $1 == "xfce" ]]; then
  _sddm
  _xfce4
  _thunar
  _networkmanager
  _bluetooth
  _background
fi


if [[ $1 == "packages" ]]; then
  _packages
fi

if [[ $1 == "virtualbox" ]]; then
  _virtualbox
fi

if [[ $1 == "development" ]]; then
  _development
fi

if [[ $1 == "networkmanager" ]]; then
  _networkmanager
fi

if [[ $1 == "bluetooth" ]]; then
  _bluetooth
fi


if [[ $1 == "xfce4" ]]; then
 # Xorg
  _swapfile
  _bashrc
  _xorg
  _makepkg
 # XFCE
  _sddm
  _xfce4
  _thunar
  _networkmanager
  _bluetooth
  _background
 # Extras
  _plank
  _macosx
  _packages
  _virtualbox
  _development
fi

