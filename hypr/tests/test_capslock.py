"""Regression checks for authoritative state and synchronized bar updates."""
import importlib.util
import json
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock, patch

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location(
    "capslock", Path(__file__).resolve().parents[1] / "UserScripts/Capslock.py"
)
capslock = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capslock)


class CapsLockTests(unittest.TestCase):
    def test_main_keyboard_overrides_stale_physical_led(self):
        devices = {"event7": Mock(leds=lambda: [capslock.ecodes.LED_CAPSL])}
        result = SimpleNamespace(stdout=json.dumps({"keyboards": [
            {"main": False, "capsLock": True},
            {"main": True, "capsLock": False},
        ]}))
        with patch.object(capslock.subprocess, "run", return_value=result):
            self.assertIs(capslock.capslock_state(devices), False)

    def test_two_bars_read_identical_state_despite_device_order(self):
        off = Mock(leds=lambda: [])
        on = Mock(leds=lambda: [capslock.ecodes.LED_CAPSL])
        with patch.object(capslock.subprocess, "run", side_effect=OSError):
            self.assertEqual(
                capslock.capslock_state({"event8": on, "event3": off}),
                capslock.capslock_state({"event3": off, "event8": on}),
            )

    def test_absent_devices_hide_the_indicator(self):
        self.assertIsNone(capslock.capslock_state({}))
        self.assertEqual(capslock.status_message(None)["text"], "")

    def test_event_watch_publishes_settled_state_without_timeout(self):
        led = SimpleNamespace(type=capslock.ecodes.EV_LED, code=capslock.ecodes.LED_CAPSL)
        device = Mock(path="event7", fd=10)
        device.capabilities.return_value = {capslock.ecodes.EV_LED: [capslock.ecodes.LED_CAPSL]}
        device.read.side_effect = [[led], [led], [led]]
        selector = Mock()
        selector.__enter__ = Mock(return_value=selector)
        selector.__exit__ = Mock(return_value=False)
        selector.select.side_effect = [
            [(SimpleNamespace(data=device), 1)],
            [(SimpleNamespace(data=device), 1)],
            [(SimpleNamespace(data=device), 1)],
            KeyboardInterrupt,
        ]
        libc = Mock()
        libc.inotify_init1.return_value = 20
        libc.inotify_add_watch.return_value = 1
        input_dir = Mock()
        input_dir.glob.return_value = ["event7"]
        with patch.object(capslock.ctypes, "CDLL", return_value=libc), \
             patch.object(capslock.os, "fsencode", return_value=b"/dev/input"), \
             patch.object(capslock.os, "close"), \
             patch.object(capslock, "InputDevice", return_value=device), \
             patch.object(capslock, "filter_events"), \
             patch.object(capslock.selectors, "DefaultSelector", return_value=selector), \
             patch.object(capslock, "capslock_state", side_effect=[False, True, True, False]), \
             patch("builtins.print") as output:
            with self.assertRaises(KeyboardInterrupt):
                capslock.watch(input_dir)
        messages = [json.loads(call.args[0])["class"] for call in output.call_args_list]
        self.assertEqual(messages, ["off", "on", "off"])
        for call in selector.select.call_args_list:
            self.assertEqual(call.args, ())  # A blocking wait, never timed polling.
        device.close.assert_called_once()


if __name__ == "__main__":
    unittest.main()
