"""Run path-dependent launchers under a different home, without launching apps."""
import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import unittest

ROOT = Path(os.environ.get("DOTFILES_TEST_ROOT", Path(__file__).resolve().parents[1]))

LUA_CAPTURE = r'''
local mt
mt = {
    __index = function(t, key)
        local value = setmetatable({}, mt)
        rawset(t, key, value)
        return value
    end,
    __call = function() end,
}
hl = setmetatable({}, mt)
hl.dsp.exec_cmd = function(command) return { command = command } end
hl.bind = function(key, dispatcher)
    if key == "SUPER + T" then print(dispatcher.command) end
end
hl.on = function() end
-- Exercise the actual config while replacing compositor APIs with no-ops.
dofile(arg[1])
'''


class PortabilityTests(unittest.TestCase):
    def test_hyprland_launcher_uses_current_home_and_quotes_it(self):
        for name in ("another-user", "different user's $home"):
            with self.subTest(home=name), tempfile.TemporaryDirectory() as tmp:
                home = Path(tmp) / name
                script = home / ".config/hypr/scripts/Toggles.sh"
                script.parent.mkdir(parents=True)
                script.write_text("#!/bin/sh\nprintf 'portable launcher'\n")
                script.chmod(0o755)
                env = dict(os.environ, HOME=str(home))
                command = subprocess.check_output(
                    ["lua", "-", str(ROOT / "hypr/hyprland.lua")],
                    input=LUA_CAPTURE, text=True, env=env,
                ).strip()
                self.assertEqual(shlex.split(command), [str(script)])
                self.assertEqual(subprocess.check_output(
                    ["sh", "-c", command], env=env, text=True,
                ), "portable launcher")

    def test_zed_tasks_find_helper_under_current_home(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp) / "different user's $home"
            helper = home / ".config/zed/bin/television-open"
            helper.parent.mkdir(parents=True)
            helper.write_text("#!/bin/sh\nprintf '%s' \"$1\"\n")
            helper.chmod(0o755)
            tasks = json.loads((ROOT / "zed/tasks.json").read_text())
            for task, expected in zip(tasks, ("files", "text"), strict=True):
                result = subprocess.check_output(
                    ["bash", "--noprofile", "--norc", "-c",
                     task["command"] + " " + shlex.join(task["args"])],
                    env=dict(os.environ, HOME=str(home)), text=True,
                )
                self.assertEqual(result, expected)

    def recording_args(self, home, **overrides):
        binary = home / "bin/gpu-screen-recorder"
        binary.parent.mkdir(parents=True, exist_ok=True)
        binary.write_text("#!/bin/sh\nprintf '%s\\n' \"$@\"\n")
        binary.chmod(0o755)
        env = dict(os.environ, HOME=str(home), PATH=str(binary.parent) + os.pathsep + os.defpath)
        for name in ("GSR_OUTPUT_DIR", "GSR_MONITOR", "GSR_CODEC"):
            env.pop(name, None)
        env.update(overrides)
        return subprocess.check_output(
            ["bash", str(ROOT / "extras/local-bin/gsr-start.sh")], env=env, text=True,
        ).splitlines()

    def test_recording_defaults_to_home(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp) / "another user"
            args = self.recording_args(home)
            destination = home / "Videos/Clips"
            self.assertEqual(args[args.index("-o") + 1], str(destination))
            self.assertTrue(destination.is_dir())

    def test_recording_accepts_machine_local_overrides(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp) / "another user"
            destination = Path(tmp) / "custom disk/clips"
            args = self.recording_args(home, GSR_OUTPUT_DIR=str(destination),
                                       GSR_MONITOR="HDMI-A-2", GSR_CODEC="hevc")
            self.assertEqual(args[args.index("-o") + 1], str(destination))
            self.assertEqual(args[args.index("-w") + 1], "HDMI-A-2")
            self.assertEqual(args[args.index("-k") + 1], "hevc")
            self.assertTrue(destination.is_dir())


if __name__ == "__main__":
    unittest.main()
