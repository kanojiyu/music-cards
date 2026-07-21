"""Erzeugt das App-Symbol in allen benötigten Größen.

Motiv: eine Schallplatte. Bewusst schlicht gehalten — ein Symbol muss auf
48 Pixeln noch erkennbar sein, dort verschwindet jedes Detail. Sichtbar
bleiben deshalb nur drei Dinge: die dunkle Scheibe, das farbige Mitteletikett
und das Loch.

Aufruf aus dem Projektverzeichnis:

    python3 tool/make_icon.py
"""

import os

from PIL import Image, ImageDraw

# Grundfarbe der App, wie im Farbschema von main.dart.
BLUE = (63, 107, 214)
VINYL = (20, 22, 30)
LABEL = (232, 236, 245)

# Groß zeichnen und herunterskalieren — das glättet die Kanten besser als
# jede Antialias-Einstellung beim Zeichnen selbst.
CANVAS = 2048


def _circle(draw: ImageDraw.ImageDraw, center: float, radius: float, **kwargs):
    draw.ellipse(
        [center - radius, center - radius, center + radius, center + radius],
        **kwargs,
    )


def draw_record(size: int, with_background: bool) -> Image.Image:
    """Zeichnet die Platte, wahlweise auf farbigem Untergrund."""
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    center = size / 2

    if with_background:
        draw.rounded_rectangle(
            [(0, 0), (size, size)], radius=int(size * 0.22), fill=BLUE
        )
        # Auf dem Untergrund darf die Platte nicht bis zum Rand reichen.
        outer = size * 0.36
    else:
        # Für Androids adaptives Symbol: nur das Motiv, der Untergrund kommt
        # vom System, und der Rand wird je nach Gerät beschnitten.
        outer = size * 0.44

    # Die Scheibe.
    _circle(draw, center, outer, fill=VINYL)

    # Rillen: viele und sehr fein. Deutlich sichtbare Ringe ließen die
    # Scheibe wie eine Zielscheibe aussehen; auf einer echten Platte
    # verschmelzen sie zu einer matten Fläche mit leichtem Schimmer. Bei
    # kleinen Symbolgrößen verschwinden sie ganz, was gewollt ist.
    groove_width = max(1, int(size * 0.0016))
    steps = 34
    for index in range(steps):
        factor = 0.42 + (0.96 - 0.42) * index / (steps - 1)
        # Außen etwas kräftiger als innen — das gibt der Scheibe Tiefe.
        alpha = int(10 + 12 * factor)
        _circle(
            draw,
            center,
            outer * factor,
            outline=(255, 255, 255, alpha),
            width=groove_width,
        )

    # Das Mitteletikett. Auf einer echten Platte etwa ein Drittel des
    # Durchmessers.
    label_radius = outer * 0.33
    _circle(draw, center, label_radius, fill=LABEL)

    # Eine feine Rille um das Etikett trennt es sauber von der Scheibe.
    _circle(
        draw,
        center,
        label_radius * 1.06,
        outline=(255, 255, 255, 34),
        width=max(1, int(size * 0.002)),
    )

    # Das Loch in der Mitte.
    _circle(draw, center, outer * 0.075, fill=BLUE if with_background else VINYL)

    return image


def save_android(icon: Image.Image, foreground: Image.Image) -> None:
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, px in sizes.items():
        path = os.path.join("android/app/src/main/res", folder)
        os.makedirs(path, exist_ok=True)
        icon.resize((px, px), Image.LANCZOS).save(
            os.path.join(path, "ic_launcher.png")
        )
        foreground.resize((px, px), Image.LANCZOS).save(
            os.path.join(path, "ic_launcher_foreground.png")
        )


def save_macos(icon: Image.Image) -> None:
    path = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(path, exist_ok=True)
    for px in (16, 32, 64, 128, 256, 512, 1024):
        icon.resize((px, px), Image.LANCZOS).save(
            os.path.join(path, f"app_icon_{px}.png")
        )


def save_ios(icon: Image.Image) -> None:
    path = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    if not os.path.isdir(path):
        return

    # iOS duldet keine Transparenz im App-Symbol.
    opaque = Image.new("RGB", icon.size, BLUE)
    opaque.paste(icon, (0, 0), icon)
    for name in os.listdir(path):
        if not name.endswith(".png"):
            continue
        existing = Image.open(os.path.join(path, name))
        opaque.resize(existing.size, Image.LANCZOS).save(
            os.path.join(path, name)
        )


def main() -> None:
    icon = draw_record(CANVAS, with_background=True)
    foreground = draw_record(CANVAS, with_background=False)

    icon.save("tool/icon_preview.png")
    save_android(icon, foreground)
    save_macos(icon)
    save_ios(icon)
    print("Symbole erzeugt.")


if __name__ == "__main__":
    main()
