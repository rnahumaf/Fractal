from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


def spawn_square(size: int, rng: np.random.Generator) -> np.ndarray:
    side = int(rng.integers(0, 4))
    if side == 0:
        return np.array([1.0, float(rng.integers(1, size + 1))], dtype=np.float32)
    if side == 1:
        return np.array([float(size), float(rng.integers(1, size + 1))], dtype=np.float32)
    if side == 2:
        return np.array([float(rng.integers(1, size + 1)), 1.0], dtype=np.float32)
    return np.array([float(rng.integers(1, size + 1)), float(size)], dtype=np.float32)


def spawn_circle(
    center: np.ndarray, radius: float, size: int, rng: np.random.Generator
) -> np.ndarray:
    theta = float(rng.uniform(0.0, 2.0 * np.pi))
    y = center[0] + np.sin(theta) * radius
    x = center[1] + np.cos(theta) * radius
    y = min(float(size), max(1.0, y))
    x = min(float(size), max(1.0, x))
    return np.array([y, x], dtype=np.float32)


def grow_flake(
    size: int,
    particles: int,
    max_steps: int,
    seed: int,
    mode: str,
    geometry: str,
    target: str,
    drift: float,
    jitter: float,
    burst_prob: float,
) -> np.ndarray:
    """
    Unified and fast growth engine:
    - DLA-like sticking by neighborhood contact
    - center attraction (fixed or moving center-of-mass)
    - optional intensity mode for "cosmos" style output
    """
    rng = np.random.default_rng(seed)

    occupied = np.zeros((size + 2, size + 2), dtype=np.bool_)
    values = np.zeros((size + 2, size + 2), dtype=np.float32)

    center = np.array([(size + 1) * 0.5, (size + 1) * 0.5], dtype=np.float32)
    cy = int(center[0] + 0.5)
    cx = int(center[1] + 0.5)
    occupied[cy, cx] = True
    values[cy, cx] = 1.0

    mass_sum = np.array([float(cy), float(cx)], dtype=np.float64)
    mass_count = 1.0

    max_radius = 2.0
    base_radius = size * 0.48
    spawn_gap = max(6.0, size * 0.03)
    kill_gap = max(30.0, size * 0.08)

    for _ in range(particles):
        if geometry == "circle":
            spawn_radius = min(base_radius, max_radius + spawn_gap)
            pos = spawn_circle(center, spawn_radius, size, rng)
        else:
            pos = spawn_square(size, rng)

        for _ in range(max_steps):
            target_point = (
                mass_sum / mass_count if target == "center-mass" else center.astype(np.float64)
            )

            vec_y = float(target_point[0] - pos[0])
            vec_x = float(target_point[1] - pos[1])
            dist = float(np.hypot(vec_y, vec_x))
            if dist > 0.0:
                pos[0] += float(drift * vec_y / dist)
                pos[1] += float(drift * vec_x / dist)

            if jitter > 0.0:
                pos += rng.normal(0.0, jitter, size=2).astype(np.float32)

            pos[0] = min(float(size), max(1.0, float(pos[0])))
            pos[1] = min(float(size), max(1.0, float(pos[1])))

            if geometry == "circle":
                rad = float(np.hypot(pos[0] - center[0], pos[1] - center[1]))
                if rad > min(base_radius, max_radius + kill_gap):
                    spawn_radius = min(base_radius, max_radius + spawn_gap)
                    pos = spawn_circle(center, spawn_radius, size, rng)
                    continue

            y = int(pos[0] + 0.5)
            x = int(pos[1] + 0.5)

            if (
                occupied[y - 1, x - 1]
                or occupied[y - 1, x]
                or occupied[y - 1, x + 1]
                or occupied[y, x - 1]
                or occupied[y, x + 1]
                or occupied[y + 1, x - 1]
                or occupied[y + 1, x]
                or occupied[y + 1, x + 1]
            ):
                occupied[y, x] = True

                if mode == "cosmos":
                    local_max = float(values[y - 1 : y + 2, x - 1 : x + 2].max())
                    if rng.random() < burst_prob:
                        val = local_max + float(rng.uniform(4.0, 30.0))
                    else:
                        val = max(1.0, local_max * 0.98 + float(rng.uniform(0.0, 0.8)))
                    values[y, x] = val
                else:
                    values[y, x] = 1.0

                mass_sum[0] += y
                mass_sum[1] += x
                mass_count += 1.0

                d = float(np.hypot(y - center[0], x - center[1]))
                if d > max_radius:
                    max_radius = d
                break

    if mode == "flake":
        image = occupied[1 : size + 1, 1 : size + 1].astype(np.float32)
    else:
        image = values[1 : size + 1, 1 : size + 1]
        image = np.log1p(image)
        image = image / (float(image.max()) + 1e-9)

    return image


def parse_args() -> argparse.Namespace:
    default_output = Path(__file__).resolve().parent / "outputs" / "floco_optimized.png"
    parser = argparse.ArgumentParser(description="Generate optimized snowflake/cosmos art.")
    parser.add_argument("--size", type=int, default=520)
    parser.add_argument("--particles", type=int, default=26000)
    parser.add_argument("--max-steps", type=int, default=1000)
    parser.add_argument("--seed", type=int, default=123)
    parser.add_argument("--mode", choices=["flake", "cosmos"], default="flake")
    parser.add_argument("--geometry", choices=["circle", "square"], default="circle")
    parser.add_argument("--target", choices=["fixed", "center-mass"], default="center-mass")
    parser.add_argument("--drift", type=float, default=0.80)
    parser.add_argument("--jitter", type=float, default=0.85)
    parser.add_argument("--burst-prob", type=float, default=0.012)
    parser.add_argument("--output", type=Path, default=default_output)
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    image = grow_flake(
        size=args.size,
        particles=args.particles,
        max_steps=args.max_steps,
        seed=args.seed,
        mode=args.mode,
        geometry=args.geometry,
        target=args.target,
        drift=args.drift,
        jitter=args.jitter,
        burst_prob=args.burst_prob,
    )

    cmap = "bone_r" if args.mode == "flake" else "inferno"
    args.output.parent.mkdir(parents=True, exist_ok=True)
    plt.imsave(args.output, np.flipud(image), cmap=cmap, vmin=0.0, vmax=1.0)
    print(f"Saved: {args.output}")


if __name__ == "__main__":
    main()
