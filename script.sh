# Guacamole_server
# script to setup default Guacamole server connectedto internal VNC server with XFCE
# maily taken from https://www.chasewright.com/guacamole-with-mysql-on-ubuntu/
# and here https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-ubuntu-14-04
#
# ok starting from pure server, after we login as root

adduser guauser
sudo adduser guauser sudo

# exit and login under 'guauser'
sudo nano ./.bashrc
export LC_CTYPE=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_TIME=en_US.UTF-8
export LC_COLLATE=en_US.UTF-8  
export LC_MONETARY=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8  
export LC_PAPER=en_US.UTF-8
export LC_NAME=en_US.UTF-8           
export LC_ADDRESS=en_US.UTF-8
export LC_TELEPHONE=en_US.UTF-8
export LC_MEASUREMENT=de_DE.UTF-8
export LC_IDENTIFICATION=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# istall VNC and XFCE
sudo apt-get update
sudo apt-get install xfce4 xfce4-goodies tightvncserver

# launch VNC and setup password
vncserver

# reboot 
sudo shutdown -r now

nano ~/.vnc/xstartup
#add
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &

sudo chmod +x ~/.vnc/xstartup

# now let install deps for Guacamole 
sudo apt-get -y install libcairo2-dev libpng12-dev libossp-uuid-dev libfreerdp-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev mysql-server mysql-client mysql-common mysql-utilities tomcat8 freerdp ghostscript wget curl
wget -O libjpeg-turbo-official_1.5.0_amd64.deb http://downloads.sourceforge.net/project/libjpeg-turbo/1.5.0/libjpeg-turbo-official_1.5.0_amd64.deb
dpkg -i libjpeg-turbo-official_1.5.0_amd64.deb

# point to guacamole for tomcat
echo "GUACAMOLE_HOME=/etc/guacamole" | sudo tee --append /etc/default/tomcat8

# Download Guacamole Files
wget -O guacamole-0.9.9.war http://downloads.sourceforge.net/project/guacamole/current/binary/guacamole-0.9.9.war
wget -O guacamole-server-0.9.9.tar.gz http://sourceforge.net/projects/guacamole/files/current/source/guacamole-server-0.9.9.tar.gz

# extract server
tar -xzf guacamole-server-0.9.9.tar.gz

# MAKE DIRECTORIES
sudo mkdir /etc/guacamole

# Install GUACD
cd guacamole-server-0.9.9
./configure --with-init-dir=/etc/init.d
make
sudo make install
sudo ldconfig
sudo systemctl enable guacd
cd ..

# 

sudo nano /etc/guacamole/guacamole.properties
#add 
guacd-hostname: localhost 
guacd-port: 4822
user-mapping: /etc/guacamole/user-mapping.xml

sudo nano /etc/guacamole/user-mapping.xml
#add 
<user-mapping>
    <authorize username="#####" password="#####">
        <protocol>vnc</protocol>
        <param name="hostname">localhost</param>
        <param name="port">5901</param>
        <param name="######">staffing</param>
    </authorize>
</user-mapping>

# more config
sudo rm -rf /usr/share/tomcat8/.guacamole
sudo ln -s /etc/guacamole /usr/share/tomcat8/.guacamole

# reboot 
sudo shutdown -r now

# open tomcat server to internets :)
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT

# launch everything
vncserver -depth 16 -geometry 960x1080
sudo service tomcat8 restart
sudo service guacd restart


# iptables -n -L -v --line-numbers


nano ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
<property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>

and change it to 

<property name="&lt;Super&gt;Tab" type="empty"/>


wget https://bintray.com/tigervnc/stable/download_file?file_path=ubuntu-16.04LTS%2Famd64%2Ftigervncserver_1.7.0-1ubuntu1_amd64.deb
sudo dpkg -i tigervncserver_1.7.0-3ubuntu1_amd64.deb
sudo apt-get -f install

~/.vnc/config
securitytypes= None # otherwise frequent crash
