# Migrator
Migrator for Mac OS with a simple graphical user interface. AppleScript powered. Designed for fast save and restore Mac OS applications and their settings.

The application is useful if you are reinstalling Mac OS or want to transfer configured applications to another computer.

<p align="center">
<img width="420" src="https://github.com/telenkor/migrator/assets/31967374/4dcafa0c-4e0c-41c1-b1dc-88ef4be6d293">
</p>

<p align="center">
<img width="332" src="https://github.com/telenkor/migrator/assets/31967374/929221ea-d04b-43d3-b55e-9c594ceb569b">
</p>

<p align="center">
<img width="605" src="https://github.com/telenkor/migrator/assets/31967374/3c7b9421-5b0b-4a1e-a2bb-1892eec618e4">
</p>

## Features

Migrator itself does not scan your Applications directory. You enter the data into it yourself. Enter only the data that you need for the normal functioning of the application in the new location. There is no need to collect any service databases (sometimes quite large), caches, and more.

The application does not have any built-in database or interface for editing it. This is due to the fact that the necessary entries are made, as a rule, once. And only occasionally are they supplemented or changed. Having built-in functionality for this would unnecessarily complicate this project.

- The settings are stored in a plist file. Plist file <em>must be in the same directory</em> as the application. For editing, you can use any plist file editor.
- Don't worry if your username is in the settings path. When transferred to a machine with another user, the name will change to match the new location.
- If you do not want to delete an entry from the file, but want to hide it, then put an asterisk anywhere in the key line.






## System Requirements
- Mac OS Yosemite (10.10) or later
- Not tested on Apple M-series
