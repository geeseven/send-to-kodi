# send-to-kodi

This is my approach to playing videos on a [Kodi][0] powered TV from a computer.  It takes a url as an argument or from the copy buffer and attempts to play it in Kodi via its API.  After enabling the ([webserver][1]) in Kodi, you will need to change the 'HOST' and 'AUTH' variables in `send-to-kodi.sh`.  Wayland users might need to set `XDG_SESSION_TYPE=wayland` environment variable.

## Usage

### Terminal

```console
$ /path/to/send-to-kodi.sh https://www.youtube.com/watch?v=OfIQW6s1-ew
```
or via URL in copy buffer

```console
$ /path/to/send-to-kodi.sh
```

### i3/Sway

Via URL in copy buffer and keybinding with this configuration.

```sh
bindsym $mod+x exec "/path/to/send-to-kodi.sh"
```

### qutebrowser

Using 'X' hint with this configuration.

```python
config.bind('X', 'hint links spawn /path/to/send-to-kodi.sh {hint-url}')
```

### tuir or ttrv

Using tuir's [viewing media links][2] feature with this configuration in the mailcap file.

```sh
video/*; /path/to/send-to-kodi.sh '%s' ; test=test -n "$DISPLAY"
```

[0]: https://kodi.tv
[1]: https://kodi.wiki/view/Webserver#Enabling_the_webserver
[2]: https://gitlab.com/ajak/tuir#viewing-media-links
