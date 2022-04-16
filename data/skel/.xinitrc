#!/bin/sh

dbus-launch --exit-with-x11 -- 9 rc $HOME/.xinitrc.rc &> .xinitrc.log
