import taichi as ti
import taichi.math as tm
import math

ti.init(arch=ti.gpu)

n = 320  # Higher resolution for more detail
pixels = ti.Vector.field(3, dtype=float, shape=(n * 2, n))

@ti.func
def complex_sqr(z):
    return tm.vec2(z[0] * z[0] - z[1] * z[1], 2 * z[0] * z[1])

@ti.func
def orbit_trap(z, trap_type: int):
    distance = 1.0  # Default value
    if trap_type == 0:  # Ellipse
        a = 0.8 + 0.2 * tm.cos(z[0] + z[1])
        b = 0.5 + 0.3 * tm.sin(z[0] - z[1])
        distance = (z[0] / a)**2 + (z[1] / b)**2
    elif trap_type == 1:  # Spiral
        angle = tm.atan2(z[1], z[0])
        radius = z.norm()
        distance = abs(radius - angle / (2 * tm.pi))
    else:  # Default to circle trap
        distance = z.norm()
    return min(distance, 1.0)

@ti.kernel
def paint(t: float, trap_type: int):
    for i, j in pixels:
        # Introduce fractal noise to c for more complex shapes
        c = tm.vec2(tm.sin(t) * 0.5, tm.cos(t * 0.7) * 0.5)
        c += tm.vec2(0.2 * tm.sin(i * 0.02 + t), 0.2 * tm.cos(j * 0.02 + t))
        
        z = tm.vec2(i / n - 1, j / n - 0.5) * 2
        iterations = 0
        orbit_distance = 1.0
        
        while z.norm() < 50 and iterations < 200:  # Higher iterations for finer detail
            z = complex_sqr(z) + c
            orbit_distance = min(orbit_distance, orbit_trap(z, trap_type))
            iterations += 1
        
        # Adaptive coloring based on angle and orbit distance
        angle = tm.atan2(z[1], z[0])
        hue = 0.5 + 0.5 * tm.sin(3.0 * orbit_distance + angle + t)
        saturation = 0.7 + 0.3 * tm.cos(2.0 * orbit_distance + t)
        value = 1.0 - iterations * 0.005
        
        color = tm.vec3(hue, saturation, value) * (1 - iterations * 0.02)
        pixels[i, j] = color

gui = ti.GUI("Julia-Inspired Patterns", res=(n * 2, n))

i = 0
trap_type = 0  # Set to 0 for ellipse, 1 for spiral, or other numbers for the default circle
while gui.running:
    paint(i * 0.03, trap_type)
    gui.set_image(pixels)
    gui.show()
    i += 1
