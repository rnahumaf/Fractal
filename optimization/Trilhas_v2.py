from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


def blur3x3(image: np.ndarray, passes: int) -> np.ndarray:
    out = image
    for _ in range(passes):
        p = np.pad(out, 1, mode="edge")
        out = (
            p[:-2, :-2]
            + p[:-2, 1:-1]
            + p[:-2, 2:]
            + p[1:-1, :-2]
            + p[1:-1, 1:-1]
            + p[1:-1, 2:]
            + p[2:, :-2]
            + p[2:, 1:-1]
            + p[2:, 2:]
        ) / 9.0
    return out


def spawn_ring(
    count: int, center: np.ndarray, radius: float, rng: np.random.Generator
) -> np.ndarray:
    theta = rng.uniform(0.0, 2.0 * np.pi, size=count)
    pos = np.empty((count, 2), dtype=np.float32)
    pos[:, 0] = center[0] + np.sin(theta) * radius
    pos[:, 1] = center[1] + np.cos(theta) * radius
    return pos


def accumulate_bilinear(canvas: np.ndarray, pos: np.ndarray) -> None:
    y = pos[:, 0]
    x = pos[:, 1]

    y0 = np.floor(y).astype(np.int32)
    x0 = np.floor(x).astype(np.int32)
    y1 = y0 + 1
    x1 = x0 + 1

    wy = y - y0
    wx = x - x0

    np.add.at(canvas, (y0, x0), (1.0 - wy) * (1.0 - wx))
    np.add.at(canvas, (y0, x1), (1.0 - wy) * wx)
    np.add.at(canvas, (y1, x0), wy * (1.0 - wx))
    np.add.at(canvas, (y1, x1), wy * wx)


def grow_cloud(
    size: int,
    walkers: int,
    steps: int,
    seed: int,
    drift: float,
    noise: float,
    inertia: float,
    respawn_prob: float,
    blur_passes: int,
) -> np.ndarray:
    """
    Cloud-like random trails:
    - isotropic gaussian perturbation avoids axis artifacts
    - soft radial attraction keeps trajectories near the cloud body
    - bilinear accumulation produces smooth density maps
    """
    rng = np.random.default_rng(seed)

    canvas = np.zeros((size + 3, size + 3), dtype=np.float32)
    center = np.array([(size + 1) * 0.5, (size + 1) * 0.5], dtype=np.float32)

    spawn_radius = size * 0.44
    pos = spawn_ring(walkers, center, spawn_radius, rng)
    vel = np.zeros_like(pos, dtype=np.float32)

    low = 1.0
    high = float(size)
    speed_cap = 2.8

    for _ in range(steps):
        vec = center - pos
        dist = np.sqrt(vec[:, 0] ** 2 + vec[:, 1] ** 2) + 1e-6
        vec[:, 0] /= dist
        vec[:, 1] /= dist

        noise_term = rng.normal(0.0, noise, size=pos.shape).astype(np.float32)
        vel = inertia * vel + drift * vec + noise_term

        speed = np.sqrt(vel[:, 0] ** 2 + vel[:, 1] ** 2) + 1e-9
        scale = np.minimum(1.0, speed_cap / speed).astype(np.float32)
        vel[:, 0] *= scale
        vel[:, 1] *= scale

        pos += vel

        pos[:, 0] = np.clip(pos[:, 0], low, high)
        pos[:, 1] = np.clip(pos[:, 1], low, high)

        boundary = (
            (pos[:, 0] <= low + 0.5)
            | (pos[:, 0] >= high - 0.5)
            | (pos[:, 1] <= low + 0.5)
            | (pos[:, 1] >= high - 0.5)
        )
        if boundary.any():
            vel[boundary] *= -0.35

        if respawn_prob > 0.0:
            respawn_mask = rng.random(walkers) < respawn_prob
            if respawn_mask.any():
                pos[respawn_mask] = spawn_ring(
                    int(respawn_mask.sum()), center, spawn_radius, rng
                )
                vel[respawn_mask] = 0.0

        accumulate_bilinear(canvas, pos)

    image = canvas[1 : size + 1, 1 : size + 1]
    if blur_passes > 0:
        image = blur3x3(image, blur_passes)

    image = np.log1p(image)
    image /= float(image.max()) + 1e-9
    image = image**0.72
    return image


def parse_args() -> argparse.Namespace:
    default_output = (
        Path(__file__).resolve().parent / "outputs" / "trilhas_optimized_v2.png"
    )
    parser = argparse.ArgumentParser(
        description="Generate cloud-like random trails without axis artifacts."
    )
    parser.add_argument("--size", type=int, default=900)
    parser.add_argument("--walkers", type=int, default=300)
    parser.add_argument("--steps", type=int, default=2600)
    parser.add_argument("--seed", type=int, default=123)
    parser.add_argument("--drift", type=float, default=0.055)
    parser.add_argument("--noise", type=float, default=0.42)
    parser.add_argument("--inertia", type=float, default=0.84)
    parser.add_argument("--respawn-prob", type=float, default=0.0075)
    parser.add_argument("--blur-passes", type=int, default=3)
    parser.add_argument("--output", type=Path, default=default_output)
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    image = grow_cloud(
        size=args.size,
        walkers=args.walkers,
        steps=args.steps,
        seed=args.seed,
        drift=args.drift,
        noise=args.noise,
        inertia=args.inertia,
        respawn_prob=args.respawn_prob,
        blur_passes=args.blur_passes,
    )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    plt.imsave(args.output, np.flipud(image), cmap="magma", vmin=0.0, vmax=1.0)
    print(f"Saved: {args.output}")


if __name__ == "__main__":
    main()
