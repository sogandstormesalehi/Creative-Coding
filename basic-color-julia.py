import taichi as ti
import taichi.math as tm

ti.init(arch=ti.gpu)

n = 320
pixels = ti.Vector.field(3, dtype=float, shape=(n * 2, n))

@ti.func
def complex_sqr(z):  # complex square of a 2D vector
    return tm.vec2(z[0] * z[0] - z[1] * z[1], 2 * z[0] * z[1])

@ti.func
def orbit_trap(z, trap_radius=0.05):  # Orbit trap using a small circle
    return min(z.norm(), trap_radius)

@ti.kernel
def paint(t: float):
    for i, j in pixels:  # Parallelized over all pixels
        c = tm.vec2(tm.sin(t) * 0.5, tm.cos(t * 0.7) * 0.5)
        z = tm.vec2(i / n - 1, j / n - 0.5) * 2
        iterations = 0
        orbit_distance = 1.0
        while z.norm() < 20 and iterations < 100:
            z = complex_sqr(z) + c
            orbit_distance = min(orbit_distance, orbit_trap(z))
            iterations += 1
        # Color based on iterations and orbit trap distance
        color = tm.vec3(0.5 + 0.5 * tm.sin(3.0 * orbit_distance + t), 
                        0.5 + 0.5 * tm.cos(2.0 * orbit_distance + t),
                        0.5 + 0.5 * tm.sin(5.0 * orbit_distance - t))
        pixels[i, j] = color * (1 - iterations * 0.02)

gui = ti.GUI("Julia Set", res=(n * 2, n))

i = 0
while gui.running:
    paint(i * 0.03)
    gui.set_image(pixels)
    gui.show()
    i += 1
