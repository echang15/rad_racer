# Rad Racer Homage

A retro-style pseudo-3D arcade racing game built in **Godot 4.6**.
Inspired by classics like *Rad Racer* and *Outrun*, featuring parallax scrolling backgrounds, high-speed action, and pixel-art visuals.

## 🏁 How to Play

**Objective**: Drive as far as possible without crashing into enemy cars! Avoid puddles to maintain speed.

### Controls
| Action | Key |
| :--- | :--- |
| **Steer Left/Right** | `Arrow Keys` / `A` & `D` |
| **Accelerate** | `Up Arrow` / `W` |
| **Brake** | `Down Arrow` / `S` |
| **Turbo Boost** | `Spacebar` (When Ready) |

## 🌟 Features

*   **Pseudo-3D Road**: Classic raster-style road effect using vertex shaders.
*   **Day/Night Cycle**: Dynamic stage transitions (Night -> Sunset -> Day) as you progress.
*   **Turbo Boost**: Engage nitrous to hit 80 km/h with a warping camera effect!
*   **Hazards & Enemies**:
    *   **Civic Traffic**: Avoid the red enemy cars. Hitting one ends the run.
    *   **Puddles**: Watch out for blue puddles that cause spin-outs.
*   **High Score System**:
    *   Local top 10 leaderboard.
    *   Enter your initials if you make the cut!
*   **Parallax Backgrounds**: Scrolling mountains and skies for depth.
*   **Retro Audio**: Sound effects for turbo, passing, and crashes (requires asset setup).

## 🛠️ How to Run

1.  **Install Godot 4**: Download the latest version of Godot Engine (4.x) from [godotengine.org](https://godotengine.org).
2.  **Import Project**:
    *   Launch Godot.
    *   Click **Import**.
    *   Navigate to this folder and select the `project.godot` file.
3.  **Run**:
    *   Press the **Play** button (or `F5`) in the Godot editor.
    *   The game launches directly into the **Start Screen**.

## 📂 Project Structure

*   `scenes/`: Main game scenes (Game, UI, StartScreen, HighScores).
*   `scripts/`: GDScript logic for RoadManager, Player/Enemy cars, and UI.
*   `assets/`: Sprites and Shaders (`retro_road.gdshader`, `bg_scroll.gdshader`).
*   `shaders/`: Custom shader resources.

Enjoy the ride! 🏎️💨
