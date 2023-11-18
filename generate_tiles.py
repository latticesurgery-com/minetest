from PIL import Image
import random

def generate_grainy_image(base_color, width, height, transparency, filename):
    image = Image.new('RGBA', (width, height), base_color)
    pixels = image.load()

    for i in range(width):
        for j in range(height):
            r, g, b = base_color
            rand_variation = random.randint(-20, 20)  # Random variation for grainy effect
            alpha = 0
            if random.randint(0, transparency)==0 or (i == width-1 or i == 0 or j == height-1 or j == 0):
                alpha = 255

            pixels[i, j] = (max(min(r + rand_variation, 255), 0), 
                            max(min(g + rand_variation, 255), 0), 
                            max(min(b + rand_variation, 255), 0),
                            alpha)

    image.save(filename)

# Define base colors for the images

distillation_color = (255, 0, 255)
qubit_color = (255, 255, 0)

base_colors = [
    (0+random.randint(0, 70), 255-random.randint(0, 70), 255-random.randint(0, 70)) for jj in range(12)
]

if __name__ == '__main__':
    for i, color in enumerate(base_colors):
        generate_grainy_image(color, 16, 16, 0, f'textures/routing_{i+1}.png')
    generate_grainy_image(distillation_color, 16, 16, 0, f'textures/distillation.png')
    generate_grainy_image(base_colors[0], 16, 16, 10, f'textures/dead.png')
    generate_grainy_image(qubit_color, 16, 16, 0, f'textures/qubit.png')