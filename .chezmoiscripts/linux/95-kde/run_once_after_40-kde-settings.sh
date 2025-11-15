#!/usr/bin/env bash

kwriteconfig5 --file ~/.config/systemsettingsrc --group systemsettings_sidebar_mode --key HighlightNonDefaultSettings true

kwriteconfig5 --file ~/.config/kglobalshortcutsrc --group services --group org.kde.spectacle.desktop --key RectangularRegionScreenShot "Meta+Shift+Print	Meta+Shift+S"
