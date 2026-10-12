#!/usr/bin/env python3
"""
generate_colors.py
Creates all required .colorset Contents.json files for the NotesApp asset catalog.
Run from the notes_app directory.
"""

import json, os

BASE = "NotesApp/NotesApp/Assets.xcassets"

# colour_name -> { light: (r,g,b), dark: (r,g,b) }   (0-255 ints)
COLORS = {
    "AppBackground": {
        "light": (232, 240, 243),   # soft blue-gray
        "dark":  (18,  18,  28),    # near-black
    },
    "CardBackground": {
        "light": (255, 255, 255),
        "dark":  (30,  30,  45),
    },
    "SurfaceSecondary": {
        "light": (210, 220, 230),
        "dark":  (38,  38,  55),
    },
    "PrimaryText": {
        "light": (20,  20,  40),
        "dark":  (240, 240, 255),
    },
    "SecondaryText": {
        "light": (80,  90, 110),
        "dark":  (160, 165, 185),
    },
    "FABColor": {
        "light": (20,  20,  40),
        "dark":  (240, 240, 255),
    },
    "DetailBackground": {
        "light": (232, 240, 243),
        "dark":  (232, 240, 243),   # always light in this design
    },
}

def make_component(val):
    return str(round(val / 255, 4))

def make_colorset(light, dark):
    def entry(rgb, appearance_name):
        r, g, b = rgb
        base = {
            "color": {
                "color-space": "srgb",
                "components": {
                    "alpha": "1.000",
                    "red":   make_component(r),
                    "green": make_component(g),
                    "blue":  make_component(b),
                }
            },
            "idiom": "universal",
        }
        if appearance_name:
            base["appearances"] = [
                {"appearance": "luminosity", "value": appearance_name}
            ]
        return base

    return {
        "colors": [
            entry(light, None),          # default (light)
            entry(dark, "dark"),         # dark mode
        ],
        "info": {"author": "xcode", "version": 1}
    }

for name, variants in COLORS.items():
    path = os.path.join(BASE, f"{name}.colorset")
    os.makedirs(path, exist_ok=True)
    content = make_colorset(variants["light"], variants["dark"])
    with open(os.path.join(path, "Contents.json"), "w") as f:
        json.dump(content, f, indent=2)
    print(f"  ✅  {name}")

# AppIcon placeholder
appicon_path = os.path.join(BASE, "AppIcon.appiconset")
os.makedirs(appicon_path, exist_ok=True)
appicon_contents = {
  "images": [{"idiom": "universal", "platform": "ios", "size": "1024x1024"}],
  "info": {"author": "xcode", "version": 1}
}
with open(os.path.join(appicon_path, "Contents.json"), "w") as f:
    json.dump(appicon_contents, f, indent=2)
print("  ✅  AppIcon")

print("\nAll color sets generated.")
