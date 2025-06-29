#!/bin/bash

make_shortcut_name() {
	local filename="$1"                    # e.g., my_file.archive.tar.gz
	local base="${filename%%.*}"           # part before first dot
	local rest="${filename#${base}}"       # everything after the first dot (including the dot)
	echo "${base} - shortcut${rest}"
}


TARGET="$(realpath "$1")"
BASENAME="$(basename "$TARGET")"
PARENT_DIR="$(dirname "$TARGET")"
SHORTCUT_NAME="$(make_shortcut_name "$BASENAME")"
SHORTCUT_NAME_NOEXT="${SHORTCUT_NAME%.*}"
SHORTCUT_PATH="$PARENT_DIR/$SHORTCUT_NAME.desktop"
SHORTCUT_PATH_NOEXT="$PARENT_DIR/$SHORTCUT_NAME_NOEXT.desktop"


################################################################################

create_folder_shortcut() {
	cat > "$SHORTCUT_PATH" <<EOF
[Desktop Entry]
Name=$SHORTCUT_NAME
Icon=folder
Exec=nemo $TARGET
Terminal=false
Type=Application
StartupNotify=false
EOF
}

################################################################################

create_appimage_shortcut() {
	ICON_PATH="$HOME/.local/share/icons/$BASENAME.png"
	xapp-appimage-thumbnailer -i "$TARGET" -o "$ICON_PATH" -s 64

	SHORTCUT_PATH=$SHORTCUT_PATH_NOEXT
	SHORTCUT_NAME=$SHORTCUT_NAME_NOEXT

	# Create .desktop file
	cat > "$SHORTCUT_PATH" <<EOF
[Desktop Entry]
Name=$SHORTCUT_NAME
Exec=$TARGET %F
Icon=$ICON_PATH
Terminal=false
Type=Application
StartupNotify=false
EOF

	chmod +x "$SHORTCUT_PATH_NOEXT"
	gtk-update-icon-cache ~/.local/share/icons/ &>/dev/null || true

}

################################################################################

create_file_shortcut() {
	# Get MIME type of the file
	MIME_TYPE=$(xdg-mime query filetype "$TARGET")

	# Try to find associated icon for MIME type
	MIME_ICON=$(grep -i "$MIME_TYPE" /usr/share/mime/globs2 | cut -d: -f2 | head -n1)

	# Fallback: use icon from associated .desktop launcher
	DEFAULT_APP=$(xdg-mime query default "$MIME_TYPE")
	DESKTOP_FILE=$(find /usr/share/applications ~/.local/share/applications -name "$DEFAULT_APP" | head -n 1)

	if [ -f "$DESKTOP_FILE" ]; then
		ICON_NAME=$(grep -m1 '^Icon=' "$DESKTOP_FILE" | cut -d= -f2)
	else
		ICON_NAME="application-x-executable"
	fi

	if [ -f "$DESKTOP_FILE" ]; then
		EXEC_CMD=$(grep -m1 '^Exec=' "$DESKTOP_FILE" | cut -d= -f2 | sed 's/ *%[fFuU]//g')
		ICON_NAME=$(grep -m1 '^Icon=' "$DESKTOP_FILE" | cut -d= -f2)
	else
		EXEC_CMD="xdg-open"
		ICON_NAME="application-x-executable"
	fi

	if [ -n "$MIME_ICON" ]; then
		# Use icon name if found (usually something like text-x-generic)
		ICON_NAME="${MIME_TYPE//\//-}"  # Convert "text/plain" -> "text-plain"
	fi

	cat > "$SHORTCUT_PATH" <<EOF
[Desktop Entry]
Type=Application
Name=$SHORTCUT_NAME
Exec=$EXEC_CMD "$TARGET"
Icon=$ICON_NAME
Terminal=false
EOF
}

################################################################################

copy_shortcut() {
	SHORTCUT_PATH="${SHORTCUT_PATH%.*}"
	cp "$TARGET" "$SHORTCUT_PATH"
	sed -i "s/^Name=.*/Name=$SHORTCUT_NAME_NOEXT/" "$SHORTCUT_PATH"
}

################################################################################

if [ -d "$TARGET" ]; then
	create_folder_shortcut

elif [[ "$TARGET" == *.AppImage ]]; then
	create_appimage_shortcut

elif [[ "$TARGET" == *.desktop ]]; then
	copy_shortcut

else
	create_file_shortcut
fi

gio set -t stringv "$SHORTCUT_PATH" metadata::emblems emblem-new
touch "$SHORTCUT_PATH"


chmod +x "$SHORTCUT_PATH"
