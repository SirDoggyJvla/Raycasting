def dda_voxel_traversal(x1, y1, z1, x2, y2, z2):
    dx = x2 - x1
    dy = y2 - y1
    dz = z2 - z1

    steps = int(max(abs(dx), abs(dy), abs(dz)))

    Xinc = dx / steps
    Yinc = dy / steps
    Zinc = dz / steps

    x, y, z = x1, y1, z1
    voxels = set()

    print("Voxel traversal (3D DDA):\n")
    for i in range(steps + 1):
        # Compute voxel coordinates (integer cube position)
        vx, vy, vz = int(x), int(y), int(z)
        if (vx, vy, vz) not in voxels:
            voxels.add((vx, vy, vz))
            print(f"Step {i:2d}: Point=({x:.2f}, {y:.2f}, {z:.2f}) -> Voxel=({vx}, {vy}, {vz})")
        x += Xinc
        y += Yinc
        z += Zinc

    return voxels


# Example usage
if __name__ == "__main__":
    start = (2.3, 1.8, 0.5)
    end = (9.6, 6.4, 4.2)
    voxels = dda_voxel_traversal(*start, *end)
    print("\nVoxels visited:", voxels)


import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
import numpy as np

def draw_voxel(ax, x, y, z, color='skyblue', alpha=0.3):
    r = [0, 1]
    X, Y = np.meshgrid(r, r)
    ones = np.ones_like(X)
    zeros = np.zeros_like(X)
    faces = [
        (X + x, Y + y, zeros + z),
        (X + x, Y + y, ones + z),
        (X + x, zeros + y, Y + z),
        (X + x, ones + y, Y + z),
        (zeros + x, X + y, Y + z),
        (ones + x, X + y, Y + z)
    ]
    for f in faces:
        ax.plot_surface(*f, color=color, edgecolor='k', alpha=alpha)

# Visualization
start = (2.3, 1.8, 0.5)
end = (9.6, 6.4, 4.2)
voxels = dda_voxel_traversal(*start, *end)

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# Draw visited voxels
for vx, vy, vz in voxels:
    draw_voxel(ax, vx, vy, vz, color='orange', alpha=0.4)

# Draw line path
ax.plot([start[0], end[0]], [start[1], end[1]], [start[2], end[2]], 'r-', lw=2)

ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')
ax.set_title('3D DDA Voxel Traversal')
plt.show()

