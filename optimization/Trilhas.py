from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


def spawn_border(size: int, rng: np.random.Generator) -> tuple[int, int]:
    side = int(rng.integers(0, 4))
    if side == 0:
        return 1, int(rng.integers(1, size + 1))
    if side == 1:
        return size, int(rng.integers(1, size + 1))
    if side == 2:
        return int(rng.integers(1, size + 1)), 1
    return int(rng.integers(1, size + 1)), size


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


def grow_trails(
    size: int,
    runs: int,
    max_steps: int,
    seed: int,
    pull: float,
    blur_passes: int,
) -> np.ndarray:
    """
    Fast trail painter:
    - many walkers start from borders
    - soft attraction to center
    - trail intensity increases with path length
    """
    rng = np.random.default_rng(seed)

    trails = np.zeros((size + 2, size + 2), dtype=np.float32)
    anchors = np.zeros((size + 2, size + 2), dtype=np.bool_)

    center = (size // 2) + 1
    anchors[center, center] = True

    for _ in range(runs):
        y, x = spawn_border(size, rng)
        weight = 0.0

        for step in range(max_steps):
            weight += 1.0

            if rng.random() < pull:
                dy = int(np.sign(center - y))
                dx = int(np.sign(center - x))
                if rng.random() < 0.35:
                    dy += int(rng.integers(-1, 2))
                if rng.random() < 0.35:
                    dx += int(rng.integers(-1, 2))
            else:
                dy = int(rng.integers(-1, 2))
                dx = int(rng.integers(-1, 2))

            if dy == 0 and dx == 0:
                continue

            y += dy
            x += dx

            if y < 1:
                y = 1
            elif y > size:
                y = size
            if x < 1:
                x = 1
            elif x > size:
                x = size

            trails[y, x] += 1.0 + weight / max_steps

            if (
                anchors[y - 1, x - 1]
                or anchors[y - 1, x]
                or anchors[y - 1, x + 1]
                or anchors[y, x - 1]
                or anchors[y, x + 1]
                or anchors[y + 1, x - 1]
                or anchors[y + 1, x]
                or anchors[y + 1, x + 1]
            ):
                anchors[y, x] = True
                break

            # Safety exit for very long runs that stayed far from center.
            if step > max_steps * 0.8:
                if abs(y - center) + abs(x - center) > size * 0.7:
                    break

    image = trails[1 : size + 1, 1 : size + 1]
    if blur_passes > 0:
        image = blur3x3(image, blur_passes)
    image = np.log1p(image)
    image = image / (float(image.max()) + 1e-9)
    image = image**0.85
    return image


def parse_args() -> argparse.Namespace:
    default_output = Path(__file__).resolve().parent / "outputs" / "trilhas_optimized.png"
    parser = argparse.ArgumentParser(description="Generate optimized trail painting.")
    parser.add_argument("--size", type=int, default=700)
    parser.add_argument("--runs", type=int, default=60)
    parser.add_argument("--max-steps", type=int, default=9000)
    parser.add_argument("--seed", type=int, default=123)
    parser.add_argument("--pull", type=float, default=0.58)
    parser.add_argument("--blur-passes", type=int, default=2)
    parser.add_argument("--output", type=Path, default=default_output)
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    image = grow_trails(
        size=args.size,
        runs=args.runs,
        max_steps=args.max_steps,
        seed=args.seed,
        pull=args.pull,
        blur_passes=args.blur_passes,
    )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    plt.imsave(args.output, np.flipud(image), cmap="magma", vmin=0.0, vmax=1.0)
    print(f"Saved: {args.output}")


if __name__ == "__main__":
    main()
