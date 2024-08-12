import taichi as ti
import taichi.math as tm

ti.init(arch=ti.gpu)

n = 640
pixels = ti.Vector.field(3, dtype=float, shape=(n * 2, n))

@ti.kernel
def paint(t: float):
    # Define zoom scale and center offset
    zoom = 1.0 + 2.0 * t * t * tm.sqrt(t)  # Increased zoom rate for faster zooming
    center_x = -0.743643887037158304752191506114774  # Center x coordinate to zoom on an interesting region
    center_y = 0.131835904205311970493133056385139  # Center y coordinate to zoom on an interesting region

    for i, j in pixels:
        # Map pixel coordinates to the fractal coordinates
        x = (i - n) / (0.5 * n * zoom) + center_x
        y = (j - n / 2) / (0.5 * n * zoom) + center_y
        c = tm.vec2(x, y)
        z = tm.vec2(0.0, 0.0)
        iterations = 0
        max_iterations = 100  # Reduced max iterations for faster rendering

        while z.norm() < 4.0 and iterations < max_iterations:
            z = tm.vec2(z[0] * z[0] - z[1] * z[1], 2 * z[0] * z[1]) + c
            iterations += 1

        # Calculate color based on iteration count
        k = iterations / max_iterations
        # Define the color gradient
        color = tm.vec3(
            0.5 + 0.5 * tm.sin(3.14 * k + 4.0),  # Pink to Purple gradient
            0.5 + 0.5 * tm.sin(3.14 * k + 2.0),  # Blue to Pink gradient
            0.5 + 0.5 * tm.sin(3.14 * k + 0.0)   # Purple to Blue gradient
        )
        pixels[i, j] = color * (iterations / max_iterations)

gui = ti.GUI("Mandelbrot Set", res=(n * 2, n))

i = 0
while gui.running:
    paint(i * 0.1)  # Faster frame update
    gui.set_image(pixels)
    gui.show()
    i += 1
