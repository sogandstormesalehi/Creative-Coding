import taichi as ti

ti.init(arch=ti.gpu)

n = 800
pixels = ti.Vector.field(3, dtype=ti.f32, shape=(n, n))  # 3D vector field for RGB

@ti.func
def complex_sqr(z):
    return ti.Vector([z[0] ** 2 - z[1] ** 2, 2 * z[0] * z[1]])

@ti.func
def complex_cube(z):
    z2 = complex_sqr(z)
    return ti.Vector([z[0] * z2[0] - z[1] * z2[1], z[0] * z2[1] + z[1] * z2[0]])

@ti.func
def derivative_p(z):
    z2 = complex_sqr(z)
    return ti.Vector([3 * z2[0], 3 * z2[1]])

@ti.func
def newton_method(z, c):
    p_z = complex_cube(z) - ti.Vector([1.0, 0.0])
    dp_z = derivative_p(z)
    dp_norm_sq = dp_z.norm_sqr() + 1e-6
    z = z - ti.Vector([(p_z[0] * dp_z[0] + p_z[1] * dp_z[1]),
                       (p_z[1] * dp_z[0] - p_z[0] * dp_z[1])]) / dp_norm_sq * c
    return z

@ti.func
def find_root(z):
    roots = [ti.Vector([1.0, 0.0]), 
             ti.Vector([-0.5, ti.sqrt(3) / 2]), 
             ti.Vector([-0.5, -ti.sqrt(3) / 2])]
    closest_root = -1
    min_dist = 1e6

    for k in ti.static(range(3)):
        dist = (z - roots[k]).norm()
        if dist < min_dist:
            min_dist = dist
            closest_root = k

    return closest_root

@ti.func
def smooth_color(z, iterations):
    return iterations - ti.log(ti.log(z.norm() + 1e-6)) / ti.log(2)

@ti.kernel
def paint(phi: float):
    for I in ti.grouped(pixels):
        z = ti.Vector([I[0] / n * 4 - 2, I[1] / n * 4 - 2])
        c = ti.Vector([0.5 * ti.cos(phi), 0.5 * ti.sin(phi)])
        iterations = 0
        while z.norm() < 50 and iterations < 50:
            z = newton_method(z, c)
            iterations += 1

        root = find_root(z)
        color_value = smooth_color(z, iterations)

        if root == 0:
            pixels[I] = ti.Vector([0.5, 0.1, 0.1]) + color_value * ti.Vector([0.878, 0.157, 0.933]) * 0.02
        elif root == 1:
            pixels[I] = ti.Vector([0.1, 0.5, 0.1]) + color_value * ti.Vector([0.361, 0.157, 0.933]) * 0.02
        elif root == 2:
            pixels[I] = ti.Vector([0.1, 0.1, 0.5]) + color_value * ti.Vector([0.157, 0.933, 0.906]) * 0.02
        else:
            pixels[I] = ti.Vector([1.0, 0.8, 0.898])

def main():
    gui = ti.GUI("Julia Nova Fractal", res=(n, n))
    phi = 0.0
    while not gui.get_event(ti.GUI.ESCAPE, ti.GUI.EXIT):
        paint(phi)
        phi += 0.01
        gui.set_image(pixels)
        gui.show()

if __name__ == "__main__":
    main()
