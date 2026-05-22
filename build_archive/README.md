# Firmware Build Archive

This directory is the local archive root for experiment firmware builds.

Create a new archive entry with:

```bash
python tools/manage_firmware_builds.py archive --bitstream-path bit/Z7_LITE/main.bit --experiment exp01 --board Z7_LITE
```

Each archived build gets its own folder:

```text
build_archive/
  build_YYYY_MM_DD_expNN/
    main.bit
    parameters.json
```

`parameters.json` records the source firmware hash, extracted `src/main.vhd`
build parameters, optional user parameters, optional generic overrides, and Git
state at archive time.

Check for generated bitstreams that are not archived yet:

```bash
python tools/manage_firmware_builds.py check
```
