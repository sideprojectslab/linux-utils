#!/bin/bash

cp create-shortcut.nemo_action /home/$USER/.local/share/nemo/actions/
mkdir -p /home/$USER/.local/share/nemo-shortcut/
cp create-shortcut.sh /home/$USER/.local/share/nemo-shortcut/
chmod +x /home/$USER/.local/share/nemo-shortcut/create-shortcut.sh
