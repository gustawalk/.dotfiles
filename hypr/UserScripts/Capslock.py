#!/usr/bin/env python3
"""Watch LED changes, then show Hyprland's authoritative Caps Lock state."""

import ctypes
import fcntl
import json
import os
import selectors
import struct
import subprocess
from pathlib import Path

from evdev import InputDevice, ecodes


def compositor_state(keyboards):
    """Use the compositor's main keyboard, including virtual/input-method seats."""
    return next(
        (keyboard["capsLock"] for keyboard in keyboards
         if keyboard.get("main") and isinstance(keyboard.get("capsLock"), bool)),
        None,
    )


def capslock_state(devices):
    if not devices:
        return None
    try:
        result = subprocess.run(
            ["hyprctl", "-j", "devices"], capture_output=True, text=True,
            timeout=2, check=True,
        )
        state = compositor_state(json.loads(result.stdout).get("keyboards", []))
        if state is not None:
            return state
    except (OSError, subprocess.SubprocessError, ValueError, AttributeError):
        pass
    # Stable device order makes the fallback identical on every output.
    for path in sorted(devices):
        try:
            return ecodes.LED_CAPSL in devices[path].leds()
        except OSError:
            continue
    return None


def status_message(state):
    if state is None:
        return {"text": "", "tooltip": "Caps Lock unavailable", "class": "unavailable"}
    return {
        "text": "大" if state else "小",
        "tooltip": "Caps Lock ON" if state else "Caps Lock OFF",
        "class": "on" if state else "off",
    }


def filter_events(device, capabilities):
    """Filter key presses out in the kernel; this descriptor only needs Caps LED."""
    for event_type in capabilities:
        if event_type == ecodes.EV_SYN:
            continue
        # The kernel requires a native-word-sized bitmap, even for one LED.
        mask = ctypes.create_string_buffer(struct.pack(
            "@L", 1 << ecodes.LED_CAPSL if event_type == ecodes.EV_LED else 0
        ))
        # EVIOCSMASK changes only this client's event mask, never device state.
        request = (1 << 30) | (16 << 16) | (ord("E") << 8) | 0x93
        fcntl.ioctl(device.fd, request, struct.pack("=IIQ", event_type, struct.calcsize("@L"), ctypes.addressof(mask)))


def watch(input_dir=Path("/dev/input")):
    libc = ctypes.CDLL(None, use_errno=True)
    libc.inotify_init1.argtypes = [ctypes.c_int]
    libc.inotify_add_watch.argtypes = [ctypes.c_int, ctypes.c_char_p, ctypes.c_uint32]
    notify = libc.inotify_init1(os.O_NONBLOCK | os.O_CLOEXEC)
    if notify < 0:
        raise OSError(ctypes.get_errno(), "Cannot watch input devices")
    # CREATE, DELETE, ATTRIB, MOVED_FROM, MOVED_TO; ATTRIB catches udev permissions.
    if libc.inotify_add_watch(notify, os.fsencode(input_dir), 0x3C4) < 0:
        os.close(notify)
        raise OSError(ctypes.get_errno(), "Cannot watch /dev/input")

    devices = {}
    previous = object()
    with selectors.DefaultSelector() as selector:
        selector.register(notify, selectors.EVENT_READ, None)

        def refresh():
            for path, device in list(devices.items()):
                try:
                    removed = os.fstat(device.fd).st_ino != Path(path).stat().st_ino
                except OSError:
                    removed = True
                if removed:
                    selector.unregister(device.fd)
                    device.close()
                    del devices[path]
            for path in sorted(input_dir.glob("event*")):
                if str(path) in devices:
                    continue
                device = None
                try:
                    device = InputDevice(str(path))
                    capabilities = device.capabilities()
                    if ecodes.LED_CAPSL not in capabilities.get(ecodes.EV_LED, []):
                        device.close()
                        continue
                    filter_events(device, capabilities)
                    selector.register(device.fd, selectors.EVENT_READ, device)
                    devices[str(path)] = device
                except OSError:
                    if device is not None:
                        device.close()

        try:
            refresh()
            dirty = True
            while True:
                if dirty:
                    state = capslock_state(devices)
                    if state != previous:
                        print(json.dumps(status_message(state), ensure_ascii=False), flush=True)
                        previous = state
                dirty = False
                # No timeout: sleep until a real LED or device lifecycle event.
                for key, _ in selector.select():
                    device = key.data
                    if device is None:
                        os.read(notify, 65536)
                        refresh()
                        dirty = True
                        continue
                    if devices.get(device.path) is not device:
                        continue
                    try:
                        for event in device.read():
                            if (event.type == ecodes.EV_LED and event.code == ecodes.LED_CAPSL
                                    or event.type == ecodes.EV_SYN and event.code == ecodes.SYN_DROPPED):
                                dirty = True
                    except BlockingIOError:
                        pass
                    except OSError:
                        if devices.pop(device.path, None) is not None:
                            selector.unregister(key.fd)
                            device.close()
                            refresh()
                        dirty = True
        finally:
            for device in devices.values():
                device.close()
            os.close(notify)


if __name__ == "__main__":
    try:
        watch()
    except (BrokenPipeError, KeyboardInterrupt):
        pass
