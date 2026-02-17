from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


def logistic_bifurcation(
    r_min: float,
    r_max: float,
    samples: int,
    transient: int,
    keep: int,
    x0: float,
) -> tuple[np.ndarray, np.ndarray]:
    """
    Vectorized logistic-map bifurcation.
    """
    r = np.linspace(r_min, r_max, samples, dtype=np.float64)
    x = np.full(samples, x0, dtype=np.float64)

    for _ in range(transient):
        x = r * x * (1.0 - x)

    tail = np.empty((keep, samples), dtype=np.float64)
    for i in range(keep):
        x = r * x * (1.0 - x)
        tail[i] = x

    return r, tail


def parse_args() -> argparse.Namespace:
    default_output = (
        Path(__file__).resolve().parent / "outputs" / "mapa_logistico_optimized.png"
    )
    parser = argparse.ArgumentParser(description="Generate a logistic-map bifurcation diagram.")
    parser.add_argument("--r-min", type=float, default=2.6)
    parser.add_argument("--r-max", type=float, default=4.0)
    parser.add_argument("--samples", type=int, default=14000)
    parser.add_argument("--transient", type=int, default=650)
    parser.add_argument("--keep", type=int, default=140)
    parser.add_argument("--x0", type=float, default=0.2)
    parser.add_argument("--output", type=Path, default=default_output)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    r, tail = logistic_bifurcation(
        r_min=args.r_min,
        r_max=args.r_max,
        samples=args.samples,
        transient=args.transient,
        keep=args.keep,
        x0=args.x0,
    )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    fig, ax = plt.subplots(figsize=(10, 6), dpi=200)
    for i in range(tail.shape[0]):
        ax.plot(r, tail[i], ",k", alpha=0.20)
    ax.set_xlabel("Taxa de replicacao (r)")
    ax.set_ylabel("Estado populacional")
    ax.set_xlim(args.r_min, args.r_max)
    ax.set_ylim(0.0, 1.0)
    ax.grid(alpha=0.15, linewidth=0.5)
    fig.tight_layout()
    fig.savefig(args.output)
    plt.close(fig)
    print(f"Saved: {args.output}")


if __name__ == "__main__":
    main()
