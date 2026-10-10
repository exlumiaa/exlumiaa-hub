# Changelog

## Break and Steal an Egg - 2026-10-10

### Added
- Staged teleports: Q to base, Teleport to Zone, Nearest Egg, Egg Machine and auto-treadmill reposition now move in short hops (~300-350 studs, 1.2s apart) instead of one big jump, so the server no longer pulls you back
- Teleport to Zone lands at the zone edge (boss creatures relocate players who land near zone centers)
- WalkSpeed boost now works in all zones, not just the safe zone
- Creature proximity slowdown: WalkSpeed auto-caps at 100 while within 110 studs of a zone boss creature (they relocate players moving too fast nearby), then resumes full speed
- WalkSpeed toggle note: keep the value close to your natural game speed

### Changed
- Q teleport home / base button uses faster 350-stud hops (~25% quicker from deep zones)
- WalkSpeed apply loop tightened from 0.3s to 0.15s
- Auto Break pauses travel and egg hitting while a teleport is in progress
