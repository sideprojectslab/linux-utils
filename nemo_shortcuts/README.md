# Nemo Create-Shortcut Action

This tool adds a "create shortcut" context menu to the Nemo file manager that imitates the functionality of Windows Explorer's "create shortcut" context menu entry.

## Rationale

In Linux often "shortcut" and "symbolic link" are often used interchangeably, however these are two very different concepts that behave differently and serve different purposes. The Linux equivalent of a Microsoft Windows shortcut is an executable .desktop file, which itself points to an executable command (possibly with parameters) and an icon.

Following are the main differences between shortcuts and symbolic links in Linux:

* A shortcut can be assigned any icon as well as emblems. The icon must reside within the filesystem, often under ~/.local/share/icons. A symlink always "mirrors" the icon of the original file.
* A shortcut can be used to register an application with the operating system, so that it becomes available in the application menu and search bar. This is done by adding the shortcut to ~/local/share/applications
* A shortcut always **runs a command**, while a symlink is just a mirror of another file/folder. For example, a shortcut to a folder would run the filesystem command (Nemo in this case) and pass it the path to the folder we want to travel to as a parameter. A symlink instead is just a mirror of the original folder

This for instance has implications when running commands from within the destination folder:

* When entering a folder through a shortcut, you enter the actual destination folder at its original location in the filesystem. Running a command or script from within the folder will resolve all relative paths from the original folder location.
* In contrast, when entering a folder through a symbolic link you enter the "mirror" version of the folder. Running a command or script from within the folder's symbolic link will resolve all relative paths from the symbolic link as opposed to the original folder path, which may or may not be the desired behavior.

Even just from the perspective of filesystem navigation, say you have a folder somewhere at `/path/to/my_folder/` and you made a symlink to it on the desktop for easy access. If you enter the folder symlink you will see that the current path is `~/Desktop/my_folder/` as opposed to `/path/to/my_folder/`. Pressing the "go to parent folder" arrow in the file manager will therefore take you back to `~/Desktop/`. A result of this is that you have no immediate information about where that folder actually resides in the filesystem unless you start using terminal commands to resolve the link. Again this may or may not be the desired behavior.

In contrast, if you were to make a shortcut to that same folder on the desktop, entering it would take you to `/path/to/my_folder/`, and pressing the "go to parent folder" button in the file manager would take you to `/path/to/`

The same considerations apply to files and programs though the practical difference might be less apparent than for folders. Take AppImages for instance, these are just self-contained executables and, unlike applications installed through the package manager or FlatPak, do not have an entry in the OS's application menu.

In order to "register" the appimage with the OS's application menu one must (i)extract the AppImage icon, (ii) create a shortcut to the AppImage pointing to the extracted icon, (iii) make it executable and (iv) copy it to `~/.local/share/applications`. This is simply not possible with symlinks only.

## Installation

make the `install.sh` executable with `chmod +x install.sh` and run it as sudo (`sudo ./install.sh`). You might need to log out and in again to see the new entry in the Nemo context menu (right click)

## Supported Shortcut Targets

* Folders
* Files
* Other shortcuts (.desktop)
* AppImages (also extracts icon)
