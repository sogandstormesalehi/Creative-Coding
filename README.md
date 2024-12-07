# Creative Coding Projects

## Stellar Spirals

This shader [code](https://github.com/sogandstormesalehi/graphics/blob/main/StellarSpirals.glsl) generates a dynamic, animated visual effect by simulating a set of spiraling boxes that twist and move over time. I define a series of functions to create and manipulate star-like shapes, which are then arranged in a box pattern. The shapes are distorted by rotation matrices and scaled dynamically based on time, producing a twisting, pulsing motion. The main loop in the `mainImage` function traces rays through the scene, accumulating color based on the distance to the closest shape in the scene. The result is an evolving, vibrant pattern that combines geometric transformations with sinusoidal animations, creating a hallucinational display. (p.s. gotta love giving myself a bad headache)

![Screenshot 2024-08-26 210836](https://github.com/user-attachments/assets/a51d4764-5e8d-4e63-89e6-25359241acfb)


https://github.com/user-attachments/assets/46e3b153-6329-4ab2-8f76-5b5359a5c36b

## Eternal Descent


This is a [shader program](https://github.com/sogandstormesalehi/graphics/blob/main/EternalDescent.glsl) that calculates and renders a dynamic scene, featuring a rotating figurine on a background with glowing, neon-like effects. I use a combination of mathematical functions and matrix transformations to generate and animate shapes in 3D space, apply color adjustments with a custom approximation function, and implement blending techniques for layering visuals. The core functions handle the creation of offset paths, color computation, and a rotating figurine, ensuring the scene is dynamically evolving.

https://github.com/user-attachments/assets/5ac768e8-d2fc-4e7e-a496-e2f75a9b48cf


## Trapped In a Nightmare

[Here](https://github.com/sogandstormesalehi/Creative-Coding/blob/main/SuffocationInTheAbyss.glsl) I create a 3D scene where you can't shake the feeling of being slowly enveloped by the environment. The map function forms a spiraling structure that seems to close in on you as time passes, creating a subtle but persistent sense of confinement. As the `mainImage` function traces the rays through this space, the camera's movement is subtly restricted, with the collision detection ensuring that you're always kept close to the spiraling walls. The lighting, rather than illuminating, casts deep shadows that obscure your path, making the space feel tighter and more disorienting. The color variations shift in a way that feels unsettling, as if the environment itself is subtly shifting against you.


https://github.com/user-attachments/assets/f7c39660-80be-4d66-9263-6561d1e89d30



## Sky Wanderer

In this [code](https://github.com/sogandstormesalehi/graphics/blob/main/SkyWanderer.glsl) I create a procedural animation of a small, stylized figure moving within a cloudy sky background. The `noise` and `smoothNoise` functions generate smooth, continuous 2D noise, which is then used in the `clouds` function to simulate dynamic, billowing clouds that shift over time. The main function, `mainImage`, constructs the scene by first rendering the background clouds, which are influenced by time to create a sense of movement. The foreground figure, comprised of a head, body, arms, and legs, is positioned and animated based on the user's mouse input, with default behavior if no input is detected. The figure's limbs subtly animate to give the impression of a simple, lively character floating in the sky, and the final image is a blend of this character and the cloudy background. (p.s. this was so fun to create. I really like the absurd concept of a small endless runner jumping towards the void).


## Mandelbrot

In [this code](https://github.com/sogandstormesalehi/graphics/blob/main/Mandelbrot.py) I generated a dynamic, rotating Mandelbrot fractal animation. It continuously zooms in on the fractal while subtly oscillating the center and rotating the view, producing a colorful gradient effect. The fractal’s detail increases with more iterations, and each frame updates rapidly to create a fluid, evolving visualization.

## Trap Julia

[Here](https://github.com/sogandstormesalehi/Creative-Coding/blob/main/spiral-eclipse-julia.py) I generated animated Julia fractal patterns with different orbit trap shapes, including ellipses and spirals. By iterating over pixels and applying various orbit traps, the code creates intricate and evolving fractal visuals. The animation features adaptive coloring based on angle and orbit distance, with the fractal’s detail and color dynamically changing over time. The `trap_type` parameter allows for exploring different trapping shapes, adding complexity and variety to the resulting patterns.

## Newton Fractal 1

In this [code](https://github.com/sogandstormesalehi/graphics/blob/main/newton.py) I visualized a Newton fractal based on the function $f(z) = z^4 - 1$ and its derivative. I use Newton's method to find roots of the polynomial, iterating to refine the approximation of these roots. In the resulting image, the colors are determined by the number of iterations required to converge. The fractal displays vivid patterns as the algorithm progressively reveals the structure of the polynomial's roots.

## Newton Fractal 2

[Here](https://github.com/sogandstormesalehi/graphics/blob/main/newton-animated.py) I created a dynamic Julia fractal using Newton's method. The fractal is computed based on the cubic polynomial $f(z) = z^3 - 1$, with colors determined by the distance to the nearest root and the number of iterations to converge. The animation features a changing parameter `phi`, which affects the complex constant used in the Newton iteration, creating an evolving and vibrant fractal pattern. The color scheme is designed to differentiate between the three roots of the polynomial, resulting in a continually shifting fractal display.

## Particle Life 1

In this project I set up an interactive particle simulation using SwissGL and WebGL. I initialize a canvas and use shaders to handle particle interactions, such as repulsion and inertia. The particles are rendered with varying colors based on their type and position, and the simulation evolves over time with the visual representation updated continuously. This one is heavily inspired by SwissGL’s [code](https://github.com/google/swissgl/tree/main#:~:text=Soon%20randomly%20scattered,of%20boilerplate%20code.) It’s special to me because it kind of simulates a society of individuals and their interactions in my eyes.

## The Eye

In this [code](https://github.com/sogandstormesalehi/graphics/blob/main/NeuralCA_Eye.js) I define a `NeuralCA` class that generates a creepy eye-like texture using a neural cellular automaton (NCA) approach. I apply some custom rules and radial distortion effects in a shader program to create an evolving, eerie texture. The result is a distorted, pulsating eye appearance, achieved by manipulating color channels and ensuring the texture remains within valid color ranges.
