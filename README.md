# Dynacat Helm Chart

For configuration consult [Dynacat configuration](https://dynacat.artur.zone/#configuration/the-config-file)

## (selfhosted) local icons
Optional installation of [selfhosted icons](https://github.com/selfhst/icons?tab=readme-ov-file), configurable under `selfhstIcons`.
By default it introduces the environment variable SH and therefore icon references start with `${SH}`

### local
If you choose `selfhstIcons.local: true`, the icons are installed directly in dynacat and referenced by path, and therefore need to reference the icon filename
-> `${SH}cool-icon.png`

### selfhosted
On `selfhstIcons.local: false` a instance of the container is created instead, which installs the icons and will serve a local port for dynacat.
The address is then used für `SH` and can therefore be used like other weblinks -> `${SH}:cool-icon`