# Philips Hue light control plasmoid for KDE (Stand alone version)

This plasmoid enables you to control [Philips Hue](http://www.meethue.com) light bulbs.
The idea of the stand alone version is that it requires no compiled backend and thus can be 
deployed as is, e.g. via Get Hot New Stuff.

It allows you to 

* Control your lights
  * Turn lights on / off
  * Set the brightness
  * Set the colour or white temperature
* Control your groups  
  * Turn whole groups on / off
  * Set the brightness
  * Set the colour or white temperature
  * Control single lights belonging to the group
* Actions
  * Use some global actions, such as turning all lights on or off
* Set an alternative connection, including http basic auth
  * Control your lights from outside your home network 
  * You need to set up a proxy (e.g. apache httpd) reachable from the outside

As of right now, the groups and lights have to be managed (Created, removed, renamed ...) 
from the official Hue app. This might be added in a later release.

## License 

This software is distributed under the LGPL 2.1 License. See COPYING for details. 

## Requirements
* Plasma 5 & Qt 5.4+
* Qt5 Graphical Effects
* Extra CMake Modules (only for building)

## Compile and install


```
git clone https://github.com/Fuchs/hoppla-sa.git
cd hoppla-sa
```

### Global installation

```
mkdir build
cd build
cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DLIB_INSTALL_DIR=lib \
    -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make
sudo make install
```

### Local installation (per user)


`plasmapkg2 -i package`

to install the plasmoid

and 

`plasmapkg2 -r ch.fuchsnet.plasma.hoppla-sa`

to remove it again.

## Control lights from outside your network 

You have to set up a public reachable proxy, I recommend apache httpd or nginx / lighttpd 
over a secured (TLS) connection with basic auth. 
A possible apache httpd configuration would be 

```
<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerName hue.mydynamicdnsdomain.org
                ProxyRequests On
                <Proxy *>
                   Order deny,allow
                   Allow from localhost
                </Proxy>

                SSLEngine on

                SSLCertificateFile /etc/ssl/certs/apache.pem
                SSLCertificateKeyFile /etc/ssl/private/keys/apache.key

                <Location "/">
                        AuthType Basic
                        AuthName "Restricted Content"
                        AuthUserFile /etc/httpd/some/place/.htpasswd-hue
                        Require valid-user
                </Location>
                # Set IP to your internal hue bridge IP
                ProxyPass / http://192.168.1.1/
                ProxyPassReverse / http://192.168.1.1/
        </VirtualHost>
</IfModule>
```

where mydyanmicdnsdomain.org is a domain pointing at your public address from your home network.
Please read your httpd documentation on how to set it up, especially on how to add basic authentication.
Note that due to the higher delay between requests and replies to the bridge, this can lead to the plasmoid
being sometimes not up to date about the current state until the next background update occurs. 
Updates can always be forced with the refresh button.
