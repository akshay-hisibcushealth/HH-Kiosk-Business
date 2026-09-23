# HIBISCUS-2893: external camera preview orientation

Both supplied recordings show the preview retaining the same incorrect rotation
after changing Preview orientation. The portrait recording shows a sideways face;
the landscape recording shows an upside-down face.

AnuraCore 1.9.7 applies the external-camera orientation and scaling to its Metal
preview. The app's layout callbacks replaced that transform with the built-in
camera correction (including identity in portrait). The correction now leaves
external previews untouched in both popup layouts. Camera discovery also covers
automatic external-camera selection when “Use external camera only” is off.
The saved orientation preference and SDK configuration are unchanged.

## Automated checks

Run on a booted arm64 iPad simulator:

```sh
bash Tests/run-camera-preview-orientation-tests.sh <simulator-UDID>
```

Checks preserve SDK rotation, scaling and mirroring through 4,800 repeated layout
updates across four interface orientations and both popup layouts. They also
check built-in rotation, unchanged preview bounds/center, upright controls,
unknown orientation, and the absence of a preview during startup.

The checks use a Metal view with representative SDK transforms, not live camera
frames. The iOS app must also build with the bundled AnuraCore framework.

## Physical iPad verification

The affected external camera is required for these checks:

1. Connect the camera, open Physical Attributes, then Camera Settings. In portrait,
   select each of the four Preview orientation values and reopen the scan. Each
   setting must change the preview rotation; select the one matching the mount.
2. Repeat in both landscape directions. Check that the face stays centered, the
   controls stay upright, and the selected rotation is not reset after layout.
3. Repeat with Mirror external camera video on/off and with Use external camera
   only on/off while the external camera remains connected.
4. Rotate the iPad with the scan open, then retry the scan. Confirm the reopened
   preview honors the saved setting. Navigate home and relaunch to check persistence.
5. Disconnect the external camera, disable external-only mode, and reopen the scan.
   Confirm the built-in camera still displays correctly in portrait and landscape.
