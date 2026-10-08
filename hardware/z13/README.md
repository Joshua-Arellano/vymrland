# ROG Flow Z13 (2025, Strix Halo) hardware quirks

Applied from the **user layer** only. `omarchy-apply-hardware` is root-only and
reads Omarchy's own `/usr/share/omarchy/install/hardware`, which the user layer
cannot extend, so Vymrland does **not** call it.

Planned (Phase 5):

- **CS35L41 audio** — amplifier/firmware fix applied via a `post-boot` hook.
- **MT7925 WiFi firmware** — firmware/`modprobe.d` changes are root-only and
  documented here as explicit `sudo` steps, not run by `install.sh`.
- **asusctl defaults** — performance/battery/keyboard defaults under
  `~/.config` and surfaced in the `ROG Z13` menu submenu.

Any step requiring root will be listed below with the exact commands so the
user can run them deliberately.

## Root steps (manual, not automated)

_To be filled in during Phase 5._
