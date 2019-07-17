# cwl-dotfiles

These dotfiles uses `stow` for maintaining the configuration updated with the repository. `make link-{name}` can be used to create and update the symbolic links to the configuration folders.

Nowadays, these dotfiles are ever evolving. Thus, small details change or are added constantly.


## TODO

- [] A quick screenshot keyboard shortcut
	- Functional requirements:
		- desktop, window and area screenshot
		- must save into a folder and/or send to clipboard easily
	- may use more than one tool, if needed ([options](https://itsfoss.com/take-screenshot-linux/))
	- a simple script if needed to abstract the tool
	- I3 keybindings

- [] A back-end for I3 automation (needs use cases)
	- [Python I3ipc](https://github.com/acrisci/i3ipc-python)


## dotfiles organization

- **I3:** 
	The configuration file is currently divided several files inside the `config.d/`directory. Each file represent some some section of the complete configuration, like startup applications and key bindings. This division in several files mostly exists because I used a custom script to build different configurations according to the computer. Nowadays, the separated sections still exists but the differing configurations are created inside the files using GPP `#IFDEF` directives with the host name. Thus, the new configuration makes the separation (mostly) unnecessary. Still, its is currently maintained. If you are looking my configuration to resolve the problem of different configurations for different hosts, you may use only the `#IFDEF` section and no file separation. 
	To create the (compiled) config file, use `make create_config` inside the `i3/config` directory.


# Next?

- Dark theming for Rofi, bar & etc based on:
	- https://www.youtube.com/watch?v=L3yYEu-NKVI
	- https://github.com/Algorithm79/Dotfiles_i3
- BetterLockscreen install?
	- https://github.com/pavanjadhaw/betterlockscreen
