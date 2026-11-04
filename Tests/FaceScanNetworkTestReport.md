# Face-scan network warnings: test cases and execution report

Executed on **2 November 2026** using Xcode 27.0 (27A266a) and an **iPad Pro 13-inch (M5), iOS 26.2 simulator**.

**Result: 61 automated checks passed — 29 monitor/state cases and 32 simulator integration/UI cases.**

## Scope

The tests compile the production `FaceScanNetworkMonitor`, `FaceScanNetworkToast`, and, in the simulator suite, `MeasurementDelegate` and `LandscapeScanPresentationController`. Only the Network framework path source and external SDK/API/socket boundaries are replaced by test doubles. Production warning logic is not rewritten. The one-second polling timer, five-second request threshold, toast dismissal, main-queue delivery, and UIKit layout run normally.

No real scan data is collected or submitted. The screenshots show a simulated camera view. Physical network switching, live backend behavior, and Anura's actual camera/overlay lifecycle are not covered by these automated results.

## Monitor and state cases

| Cases | Setup/action | Expected result | Result |
|---|---|---|---|
| M01–M02 | Idle preview; request completes before 5 seconds | No warning | Pass |
| M03 | Leave a request unfinished at 4.999 and 5.000 seconds | Silent before the threshold; slow warning at the threshold | Pass |
| M04 | Repeated checks while request stays slow | No duplicate before 15 seconds; reminder at 15 seconds | Pass |
| M05 | Lose connectivity while slow warning is active | Offline warning replaces slow immediately | Pass |
| M06 | Remain offline and complete pending requests | Offline warning persists; reminders remain throttled | Pass |
| M07–M08 | Restore connectivity, with and without a stalled request | Clear once if healthy; retain slow warning if request remains stalled | Pass |
| M09 | Complete a fast request while another request is stalled | Stalled request still produces a warning | Pass |
| M10–M12 | Inject not-connected, connection-lost, and data-not-allowed errors | Offline warning; transient error expires after 5 seconds | Pass |
| M13–M14 | Inject a timeout, including while path is offline | Slow warning immediately; known offline path takes priority | Pass |
| M15–M18 | Inject HTTP-domain errors, cancellation, bad URL, and authentication errors | No false connectivity warning | Pass |
| M19 | Begin a fresh scan | No inherited warning/cooldown; immediate warning if offline | Pass |
| M20–M21 | Emit satisfied, unsatisfied, duplicate, and requires-connection path updates | Correct warning/recovery events without duplicates | Pass |
| M22 | Restart monitor, then deliver old path/request callbacks | Old monitor cancelled; stale callbacks ignored | Pass |
| M23–M24 | Complete unknown/cancelled requests or requests after stop | No warning appears | Pass |
| M25 | Complete an upload on a background queue | UI event arrives on the main thread | Pass |
| M26–M28 | Leave a request pending using the real timer, then complete it | Silent before 5 seconds; warning on a later tick; clear on success | Pass |
| M29 | Release the monitor | Monitor deallocates and underlying path source is cancelled | Pass |

## Simulator integration and UI cases

| Cases | Setup/action | Expected result | Result |
|---|---|---|---|
| U01–U02 | Open healthy scan, then emit offline path | No initial toast; correct offline text appears immediately | Pass |
| U03–U05 | Inspect portrait popup | Toast fits; text is visible; touches pass through; close button remains clear | Pass |
| U06–U07 | Repeat offline update, then restore path | One toast only; recovery removes it | Pass |
| U08–U10 | Delay measurement creation, then return success | No early warning; slow toast after threshold; success clears it | Pass |
| U11–U12 | Delay actual delegate chunk-upload callback, then succeed | Slow toast appears and clears | Pass |
| U13–U14 | Disconnect/reconnect live-results subscriber | Delayed reconnection warns; successful connection clears | Pass |
| U15 | Send an error from an old results subscriber | Event is ignored | Pass |
| U16–U17 | Inject socket timeout, then lose connectivity | Slow warning appears immediately, then one offline toast replaces it | Pass |
| U18–U19 | Wait through the original and replacement dismissal deadlines | Old timer cannot dismiss replacement; replacement dismisses after 5 seconds | Pass |
| U20–U21 | Reset measurement and close scan | Pending warnings clear; path monitoring stops; toast is removed | Pass |
| U22–U24 | Rotate to landscape, replace scan, and deliver old/new path events | Landscape reached; old event ignored; new offline scan warns | Pass |
| U25–U27 | Inspect landscape popup | Toast fits; text is visible; touches pass through; close button remains clear | Pass |
| U28 | Fail measurement creation with a timeout | Slow toast appears immediately | Pass |
| U29 | Fail upload with connection-lost error | Offline toast appears immediately | Pass |
| U30 | Add an SDK-like overlay and send a pipeline update | Toast is brought above the overlay | Pass |
| U31 | Finish scan while warning is visible | Toast removed and monitoring stopped before results presentation | Pass |
| U32 | Attempt to show a toast in an offscreen controller | No view/toast is created | Pass |

Portrait and landscape screenshots were also visually inspected. Automated layout checks cover bounds, ambiguous layout, full text height, touch handling, and close-button overlap.

## Run again

Run from the repository root:

```bash
bash Tests/run-face-scan-network-tests.sh
bash Tests/run-face-scan-network-simulator-tests.sh <booted-iPad-simulator-UDID> /tmp/hh-face-scan-network-results
```

Each case prints `PASS`; a failed assertion terminates the runner. The simulator runner exports `result.txt` and screenshots to the supplied output directory. Simulator timings allow for the monitor's one-second polling interval: an operation first becomes eligible at five seconds and is reported on the next tick.

## Physical-device checks still to perform

| Scenario | Steps | Expected result | Status |
|---|---|---|---|
| Actual offline transition | Start a real face scan; disable Wi-Fi/mobile data; restore it | Offline warning appears; recovery clears it | Not run |
| Wi-Fi without upstream internet | Keep Wi-Fi connected but disconnect the router's internet during a scan | Pending scan requests warn as slow; transport errors may identify offline state | Not run |
| Throttled or lossy network | Apply controlled latency/packet loss and start a real scan | Warning when an operation exceeds 5 seconds; no claim to measure signal strength/Mbps | Not run |
| Real SDK lifecycle | Repeat scan close/retry, rotation, and background/foreground while warnings are visible | No stale toast on a new scan or results screen; actual SDK overlays remain usable | Not run |

A slow server can trigger the same slow warning as a slow network; the implementation measures request responsiveness.

## Saved execution evidence

- [Monitor test log](/Users/applitesolutions/.codex/visualizations/2026/11/02/01a19c9d-c6d2-74f1-8b64-38e791f9421d/face-scan-network-tests/hh-face-scan-network-tests.log)
- [Simulator test log](/Users/applitesolutions/.codex/visualizations/2026/11/02/01a19c9d-c6d2-74f1-8b64-38e791f9421d/face-scan-network-tests/hh-face-scan-network-simulator-tests.log)
- [Portrait screenshot](/Users/applitesolutions/.codex/visualizations/2026/11/02/01a19c9d-c6d2-74f1-8b64-38e791f9421d/face-scan-network-tests/network-toast-portrait.png)
- [Landscape screenshot](/Users/applitesolutions/.codex/visualizations/2026/11/02/01a19c9d-c6d2-74f1-8b64-38e791f9421d/face-scan-network-tests/network-toast-landscape.png)
