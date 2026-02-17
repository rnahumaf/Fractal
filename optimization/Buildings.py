from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


def add_sky(canvas: np.ndarray) -> None:
    h, w, _ = canvas.shape
    y = np.linspace(0.0, 1.0, h, dtype=np.float32)[:, None]
    canvas[:, :, 0] = 0.01 + 0.02 * (1.0 - y)
    canvas[:, :, 1] = 0.01 + 0.03 * (1.0 - y)
    canvas[:, :, 2] = 0.05 + 0.15 * (1.0 - y)


def add_stars(canvas: np.ndarray, rng: np.random.Generator) -> None:
    h, w, _ = canvas.shape
    n_stars = max(80, (h * w) // 3200)
    ys = rng.integers(0, int(h * 0.58), size=n_stars)
    xs = rng.integers(0, w, size=n_stars)
    brightness = rng.uniform(0.55, 1.0, size=n_stars).astype(np.float32)
    stars = np.repeat(brightness[:, None], 3, axis=1)
    canvas[ys, xs] = np.maximum(canvas[ys, xs], stars)


def add_moon(canvas: np.ndarray, rng: np.random.Generator) -> None:
    h, w, _ = canvas.shape
    cx = int(rng.integers(int(w * 0.14), int(w * 0.86)))
    cy = int(rng.integers(int(h * 0.10), int(h * 0.35)))
    r = int(max(18, h * 0.045))

    yy, xx = np.ogrid[:h, :w]
    dist2 = (yy - cy) ** 2 + (xx - cx) ** 2
    moon = dist2 <= r * r
    halo = dist2 <= int((r * 1.8) ** 2)

    canvas[halo] = np.maximum(canvas[halo], np.array([0.20, 0.20, 0.25], dtype=np.float32))
    canvas[moon] = np.array([0.95, 0.95, 0.95], dtype=np.float32)


def add_building_layer(
    canvas: np.ndarray,
    rng: np.random.Generator,
    ground_ratio: float,
    color: tuple[float, float, float],
    width_range: tuple[int, int],
    height_mean_ratio: float,
    height_std_ratio: float,
    window_prob: float,
    window_alpha_range: tuple[float, float],
) -> None:
    h, w, _ = canvas.shape
    ground = int(h * ground_ratio)
    base_color = np.array(color, dtype=np.float32)
    warm_light = np.array([1.0, 0.96, 0.75], dtype=np.float32)

    x = 0
    while x < w:
        bw = int(rng.integers(width_range[0], width_range[1] + 1))
        x2 = min(w, x + bw)

        bheight = int(
            max(
                12,
                rng.normal(height_mean_ratio * h, height_std_ratio * h),
            )
        )
        top = max(0, ground - bheight)

        canvas[top:ground, x:x2] = base_color

        # Simple procedural windows.
        win_step_x = max(3, bw // 6)
        win_step_y = max(4, int(h * 0.012))
        for wx in range(x + 2, x2 - 2, win_step_x):
            for wy in range(top + 3, ground - 3, win_step_y):
                if rng.random() < window_prob:
                    alpha = float(rng.uniform(window_alpha_range[0], window_alpha_range[1]))
                    glow = float(rng.uniform(0.45, 1.0))
                    light = warm_light * glow
                    patch = canvas[wy : wy + 2, wx : wx + 2]
                    canvas[wy : wy + 2, wx : wx + 2] = patch * (1.0 - alpha) + light * alpha

        x = x2 + int(rng.integers(0, 4))


def generate_city(width: int, height: int, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    canvas = np.zeros((height, width, 3), dtype=np.float32)

    add_sky(canvas)
    add_stars(canvas, rng)
    add_moon(canvas, rng)

    # Far -> near layers.
    add_building_layer(
        canvas=canvas,
        rng=rng,
        ground_ratio=0.72,
        color=(0.22, 0.22, 0.24),
        width_range=(12, 28),
        height_mean_ratio=0.16,
        height_std_ratio=0.045,
        window_prob=0.10,
        window_alpha_range=(0.20, 0.45),
    )
    add_building_layer(
        canvas=canvas,
        rng=rng,
        ground_ratio=0.82,
        color=(0.14, 0.14, 0.16),
        width_range=(16, 34),
        height_mean_ratio=0.22,
        height_std_ratio=0.06,
        window_prob=0.14,
        window_alpha_range=(0.25, 0.60),
    )
    add_building_layer(
        canvas=canvas,
        rng=rng,
        ground_ratio=0.94,
        color=(0.08, 0.08, 0.10),
        width_range=(20, 44),
        height_mean_ratio=0.30,
        height_std_ratio=0.08,
        window_prob=0.20,
        window_alpha_range=(0.30, 0.95),
    )

    return np.clip(canvas, 0.0, 1.0)


def parse_args() -> argparse.Namespace:
    default_output = (
        Path(__file__).resolve().parent / "outputs" / "buildings_optimized.png"
    )
    parser = argparse.ArgumentParser(description="Generate optimized procedural skyline.")
    parser.add_argument("--width", type=int, default=1200)
    parser.add_argument("--height", type=int, default=1000)
    parser.add_argument("--seed", type=int, default=123)
    parser.add_argument("--output", type=Path, default=default_output)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    image = generate_city(width=args.width, height=args.height, seed=args.seed)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    plt.imsave(args.output, image)
    print(f"Saved: {args.output}")


if __name__ == "__main__":
    main()
