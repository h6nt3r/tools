## Autologin
```
cat /etc/X11/default-display-manager
```
```
sudo nano /etc/lightdm/lightdm.conf
```
* Replace `#autologin-user=` to `autologin-user= h6nt3r`
* Press `Ctrl+x` then `y` then `Enter`

## Error mounting
```
sudo apt install nfs-common -y
```
```
sudo apt install cifs-utils -y
```
```
sudo ntfsfix -d /dev/sdb1
```
## Unlock Keyring
```
sudo apt install seahorse -y
```
* Now go to `Application` > `passwords and keys` open it.
* Right click on `Login` select `Change Password`
* First give your `old password` then leave inputs blank and Press `continue`
