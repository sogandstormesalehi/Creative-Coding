import taichi as ti

ti.init(arch=ti.gpu)

n = 320
pixels = ti.Vector.field(3, dtype=ti.f32, shape=(n * 2, n))  # Use Vector.field for RGB

@ti.func
def p(z):
    # Compute z^4 - 1
    x, y = z[0], z[1]
    z4_real = x**4 - 6*x**2*y**2 + y**4 - 1
    z4_imag = 4*x**3*y - 4*x*y**3
    return ti.Vector([z4_real, z4_imag])

@ti.func
def p_prime(z):
    # Compute 4*z^3
    x, y = z[0], z[1]
    z3_real = x**3 - 3*x*y**2
    z3_imag = 3*x**2*y - y**3
    return ti.Vector([4*z3_real, 4*z3_imag])

@ti.kernel
def paint(t: float):
    for i, j in pixels:  # Parallelized over all pixels
        z = ti.Vector([i / n - 1, j / n - 0.5]) * 2
        iterations = 0
        while z.norm() < 20 and iterations < 50:
            z = z - p(z) / p_prime(z)  # Newton's method iteration
            iterations += 1
        
        # Color mapping based on number of iterations
        color_value = min(1.0, iterations * 0.02)
        
        # Cyberpunk color palette (purple, pink, blue)
        r = 0.6 * color_value
        g = 0.2 * color_value
        b = 0.8 * color_value
        pixels[i, j] = ti.Vector([r, g, b])

def main():
    gui = ti.GUI("Cyberpunk Newton Fractal", res=(n * 2, n))
    while not gui.get_event(ti.GUI.ESCAPE, ti.GUI.EXIT):
        paint(0.0)  # t is not used in paint, so passing 0.0
        gui.set_image(pixels)
        gui.show()

if __name__ == "__main__":
    main()


"""
@ti.func
def p(z):
    # Define the polynomial p(z) = z^3 - 1
    return ti.Vector([z[0]**3 - 3*z[0]*z[1]**2 - 1, 3*z[0]**2*z[1] - z[1]**3])

@ti.func
def p_prime(z):
    # Define the derivative p'(z) = 3z^2
    return ti.Vector([3*(z[0]**2 - z[1]**2), 6*z[0]*z[1]])
    
    
@ti.func
def p(z):
    # Compute z^8
    z8_real = z[0]**8 - 28*z[0]**6*z[1]**2 + 56*z[0]**4*z[1]**4 - 56*z[0]**2*z[1]**6 + z[1]**8
    z8_imag = 8*z[0]**7*z[1] - 56*z[0]**5*z[1]**3 + 112*z[0]**3*z[1]**5 - 8*z[0]*z[1]**7
    return ti.Vector([z8_real - 1, z8_imag])

@ti.func
def p_prime(z):
    # Compute the derivative 8*z^7
    z7_real = z[0]**7 - 21*z[0]**5*z[1]**2 + 35*z[0]**3*z[1]**4 - 7*z[0]*z[1]**6
    z7_imag = 7*z[0]**6*z[1] - 21*z[0]**4*z[1]**3 + 35*z[0]**2*z[1]**5 - z[1]**7
    return ti.Vector([8*z7_real, 8*z7_imag])


@ti.func
def sin_complex(z):
    # Approximate sin(x + iy) = sin(x) * cosh(y) + i * cos(x) * sinh(y)
    # Since we don't have cosh and sinh, this function may need adjustment for exact results
    return ti.Vector([ti.sin(z[0]), ti.cos(z[0]) * ti.tanh(z[1])])

@ti.func
def cos_complex(z):
    # Approximate cos(x + iy) = cos(x) * cosh(y) - i * sin(x) * sinh(y)
    # Since we don't have cosh and sinh, this function may need adjustment for exact results
    return ti.Vector([ti.cos(z[0]), -ti.sin(z[0]) * ti.tanh(z[1])])

@ti.func
def p(z):
    # Compute z^2
    z2 = ti.Vector([z[0]**2 - z[1]**2, 2*z[0]*z[1]])
    
    # Compute sin(z) for complex z
    sin_z = sin_complex(z)
    
    # Compute p(z) = z^2 * sin(z) - 1
    p_real = z2[0] * sin_z[0] - z2[1] * sin_z[1] - 1
    p_imag = z2[0] * sin_z[1] + z2[1] * sin_z[0]
    return ti.Vector([p_real, p_imag])

@ti.func
def p_prime(z):
    # Compute derivative: p'(z) = 2z * sin(z) + z^2 * cos(z)
    # Compute 2z
    two_z = ti.Vector([2*z[0], 2*z[1]])
    
    # Compute cos(z) for complex z
    cos_z = cos_complex(z)
    
    # Compute z^2
    z2 = ti.Vector([z[0]**2 - z[1]**2, 2*z[0]*z[1]])
    
    # Compute p'(z)
    p_prime_real = two_z[0] * sin_complex(z)[0] - two_z[1] * sin_complex(z)[1] + z2[0] * cos_z[0] - z2[1] * cos_z[1]
    p_prime_imag = two_z[0] * sin_complex(z)[1] + two_z[1] * sin_complex(z)[0] + z2[0] * cos_z[1] + z2[1] * cos_z[0]
    return ti.Vector([p_prime_real, p_prime_imag])
"""