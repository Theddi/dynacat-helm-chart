# Dynacat Helm Chart

Deploys [dynacat](https://github.com/Panonim/dynacat) with templated config/page
management and an optional local copy of the
[selfh.st icons](https://github.com/selfhst/icons) collection.

For all dynacat configuration options consult the
[dynacat configuration docs](https://dynacat.artur.zone/#configuration/the-config-file).

```sh
helm install dynacat . -n dynacat --create-namespace
```

## Configuration

### `config` → `dynacat.yml`

Everything under `config` is rendered 1:1 into `dynacat.yml`, so any top-level
dynacat section works (`server`, `document`, `branding`, `theme`, ...). Empty
sections are omitted. Example:

```yaml
config:
  server:
    proxied: true
  document:
    head: |
      <script src="/assets/custom.js"></script>
  branding:
    app-name: "My Dashboard"
    hide-footer: true
  theme:
    background-color: 240 21 15
    primary-color: 217 92 83
```

Notes:

- `server.assets-path` (default `/app/assets`) is the directory dynacat serves
  under the **URL path** `/assets/`. The chart mounts icons and custom CSS into
  it automatically.
- If you change `server.port`, the container port and probes follow it.

### `pages`

Each key under `pages` becomes its own `<name>.yml` file next to `dynacat.yml`
and is referenced via dynacat's `$include` directive. Pages are included in
alphabetical key order — prefix keys with numbers to control the tab order:

```yaml
pages:
  10-home:
    name: Home
    columns:
      - size: full
        widgets:
          - type: search
            search-engine: duckduckgo
  20-media:
    name: Media
    columns: [ ... ]
```

Because the config is mounted from a ConfigMap, a checksum annotation restarts
the pod whenever config, pages, or CSS change.

### `css`

A string of custom CSS. When set, it is served as `/assets/user.css` and
`theme.custom-css-file` is wired up automatically (dynacat expects a URL here,
not a file path).

## selfh.st icons

Configured under `selfhstIcons`. A Job (helm `post-install`/`post-upgrade`
hook) fills a PVC using a **sparse git checkout** — only the formats listed in
`iconFileTypes` are downloaded. By default the job only downloads once; set
`selfhstIcons.refreshOnUpgrade: true` to re-fetch the collection on every
`helm upgrade` (new icons are added upstream regularly).

In both modes the environment variable `SH` is injected into dynacat and icons
are referenced the same way:

```yaml
icon: ${SH}immich.png
```

### `dynacatInternal: true` (default)

Icons are copied flat onto the PVC and mounted into dynacat at
`<assets-path>/icons`, so dynacat itself serves them at
`/assets/icons/<name>.<ext>` (`SH=/assets/icons/`).

### `dynacatInternal: false`

A separate [selfh.st icons server](https://github.com/selfhst/icons/wiki)
deployment serves the collection inside the cluster and `SH` points at its
service. Dynacat downloads the icons server-side and re-serves them to the
browser through its image cache (`server.cache-dir`), so the service does not
need to be exposed. This mode additionally supports the server's URL features,
e.g. extension-less requests (`${SH}immich` → WebP) and colorization
(`${SH}immich.svg?color=0f60d9`).

### Sizing

- `svg+png+webp` ≈ 500Mi, all five formats ≈ 1Gi (`pvc.sizeRequest`).
- The init job needs about the same amount of free ephemeral storage on its
  node for the git checkout.
- The PVC is `ReadWriteOnce`: the init job and the pod mounting the icons must
  land on the same node. With node-local storage classes the scheduler handles
  this; on multi-node clusters with network block storage you may need to
  co-schedule them.
