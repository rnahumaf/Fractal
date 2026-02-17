from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


def grow_copper(
    size: int,
    particles: int,
    max_steps: int,
    seed: int,
    up_prob: float = 0.82,
    stay_prob: float = 0.14,
) -> np.ndarray:
    """
    Optimized copper-like DLA:
    - top row is a conductive seed
    - walkers are launched near the growth frontier
    - horizontal wrap emulates periodic boundary
    """
    rng = np.random.default_rng(seed)

    # Padded matrix avoids bounds checks in neighbor probing.
    cluster = np.zeros((size + 2, size + 2), dtype=np.bool_)
    cluster[1, 1 : size + 1] = True

    frontier = 1
    launch_gap = max(12, size // 18)
    kill_gap = max(35, size // 7)
    down_threshold = up_prob + stay_prob

    for _ in range(particles):
        y = min(size, frontier + launch_gap)
        x = int(rng.integers(1, size + 1))

        for _ in range(max_steps):
            u = float(rng.random())
            if u < up_prob:
                y -= 1
            elif u > down_threshold:
                y += 1

            if y < 1:
                y = 1

            limit = min(size, frontier + kill_gap)
            if y > limit:
                y = min(size, frontier + launch_gap)
                x = int(rng.integers(1, size + 1))
                continue

            v = float(rng.random())
            if v < 0.333333333:
                x -= 1
            elif v > 0.666666666:
                x += 1

            if x < 1:
                x = size
            elif x > size:
                x = 1

            if (
                cluster[y - 1, x - 1]
                or cluster[y - 1, x]
                or cluster[y - 1, x + 1]
                or cluster[y, x - 1]
                or cluster[y, x + 1]
                or cluster[y + 1, x - 1]
                or cluster[y + 1, x]
                or cluster[y + 1, x + 1]
            ):
                cluster[y, x] = True
                if y > frontier:
                    frontier = y
                break

    image = cluster[1 : size + 1, 1 : size + 1].astype(np.float32)
    image[0, :] = 0.0
    return image


def parse_args() -> argparse.Namespace:
    default_output = Path(__file__).resolve().parent / "outputs" / "cobre_optimized.png"
    parser = argparse.ArgumentParser(
        description="Generate an optimized copper-like fractal image."
    )
    parser.add_argument("--size", type=int, default=420)
    parser.add_argument("--particles", type=int, default=32000)
    parser.add_argument("--max-steps", type=int, default=1800)
    parser.add_argument("--seed", type=int, default=123)
    parser.add_argument("--output", type=Path, default=default_output)
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    image = grow_copper(
        size=args.size,
        particles=args.particles,
        max_steps=args.max_steps,
        seed=args.seed,
    )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    plt.imsave(args.output, np.flipud(image), cmap="copper", vmin=0.0, vmax=1.0)
    print(f"Saved: {args.output}")


if __name__ == "__main__":
    main()
