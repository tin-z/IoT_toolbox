1. Select your dep
# Stretch (Debian 9)

deb http://ftp.fr.debian.org/debian/ stretch main
deb-src http://ftp.fr.debian.org/debian/ stretch main
deb http://security.debian.org/debian-security stretch/updates main
deb-src http://security.debian.org/debian-security stretch/updates main
# stretch-updates, previously known as 'volatile'
deb http://ftp.fr.debian.org/debian/ stretch-updates main
deb-src http://ftp.fr.debian.org/debian/ stretch-updates main

# Jessie (Debian 8)

deb http://ftp.fr.debian.org/debian/ jessie main
deb-src http://ftp.fr.debian.org/debian/ jessie main
deb http://security.debian.org/debian-security jessie/updates main
deb-src http://security.debian.org/debian-security jessie/updates main

# Wheezy (Debian 7) //chek here... no more ftp.fr porb is archive.debian too..

deb http://ftp.fr.debian.org/debian/ wheezy main
deb-src http://ftp.fr.debian.org/debian/ wheezy main
deb http://security.debian.org/debian-security wheezy/updates main
deb-src http://security.debian.org/debian-security wheezy/updates main

# Wheezy (Debian 7) archive dep..
deb http://archive.debian.org/debian/ wheezy main non-free contrib
deb-src http://archive.debian.org/debian/ wheezy main non-free contrib
deb http://archive.debian.org/debian-security/ wheezy/updates main non-free contrib
deb-src http://archive.debian.org/debian-security/ wheezy/updates main non-free contrib

# Squeeze (Debian 6)
deb http://archive.debian.org/debian/ squeeze main non-free contrib
deb-src http://archive.debian.org/debian/ squeeze main non-free contrib
deb http://archive.debian.org/debian-security/ squeeze/updates main non-free contrib
deb-src http://archive.debian.org/debian-security/ squeeze/updates main non-free contrib

# Lenny (Debian 5)
deb http://archive.debian.org/debian/ lenny main non-free contrib
deb-src http://archive.debian.org/debian/ lenny main non-free contrib
deb http://archive.debian.org/debian-security/ lenny/updates main non-free contrib
deb-src http://archive.debian.org/debian-security/ lenny/updates main non-free contrib

# Etch (Debian 4)
deb http://archive.debian.org/debian/ etch main non-free contrib
deb-src http://archive.debian.org/debian/ etch main non-free contrib
deb http://archive.debian.org/debian-security/ etch/updates main non-free contrib
deb-src http://archive.debian.org/debian-security/ etch/updates main non-free contrib

# Sarge (Debian 3.1)
deb http://archive.debian.org/debian/ sarge main non-free contrib
deb-src http://archive.debian.org/debian/ sarge main non-free contrib
deb http://archive.debian.org/debian-security/ sarge/updates main non-free contrib
deb-src http://archive.debian.org/debian-security/ sarge/updates main non-free contrib

2. find key expired
apt-key list | grep expired

3. install gpg routine
gpg --keyserver pgpkeys.mit.edu --recv-key [key-name] #or keys.gnupg.net
gpg -a --export [key-name] |  apt-key add -

or

sudo apt-key adv --keyserver keys.gnupg.net --recv-keys  [key-name]




