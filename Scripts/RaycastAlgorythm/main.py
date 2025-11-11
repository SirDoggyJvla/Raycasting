import pygame
import sys

from ray import Ray
from grid import Grid
from point import Point
from line import Line

# Initialize Pygame
pygame.init()

# Screen dimensions
WIDTH, HEIGHT = 800, 600
GRID_SIZE = 40

# Colors
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
GRAY = (200, 200, 200)
PINK = (255, 0, 255)



# Create screen
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Grid")

font = pygame.font.SysFont(None, 24)

grid = Grid(screen, WIDTH, HEIGHT, GRID_SIZE, GRAY)

# default values
mouse_x, mouse_y = 0, 0
RAY_START_POS = Point(grid, xy=(WIDTH // 2, HEIGHT // 2))

MOUSE_POINT = Point(grid, ij=(0, 0))
RAY_LINE = Line(grid, RAY_START_POS, MOUSE_POINT)

# Game loop
running = True
while running:
    for event in pygame.event.get():
        match event.type:
            case pygame.QUIT:
                print("Quit event detected")
                running = False
            case pygame.KEYDOWN:
                match event.key:
                    case pygame.K_q:
                        running = False
            case pygame.MOUSEMOTION:
                # update mouse point
                mouse_x, mouse_y = event.pos
                MOUSE_POINT.set_xy((mouse_x, mouse_y))


    # Fill background
    screen.fill(WHITE)

    # ray from 0,0 to mouse position
    angle = RAY_LINE.set_point("end", MOUSE_POINT).get_angle()
    ray = Ray(grid, RAY_START_POS, MOUSE_POINT)

    cells = ray.cast(grid)
    grid.highlight_cells(cells, PINK)

    # draw mouse cell
    grid.highlight_cell(MOUSE_POINT, GRAY)

    # draw text with the number of cells on the same square for each cells
    count = {}
    for cell in cells:
        coord = cell.to_grid()
        count[coord] = count.get(coord, 0) + 1
    for coord, c in count.items():
        img = font.render(f"{c}", True, BLACK)
        screen.blit(img, grid.ij2xy(coord))

    # Draw grid
    grid.draw()

    # draw ray
    ray.draw(screen, BLACK)

    # draw text with cell coordinates
    point = MOUSE_POINT.to_grid()
    img = font.render(f"Cell: ({point[0]}, {point[1]})", True, BLACK)
    screen.blit(img, (10, 10))

    # draw ray informations
    img = font.render(f"{ray}", True, BLACK)
    screen.blit(img, (10, 30))

    # Update display
    pygame.display.flip()

pygame.quit()
sys.exit()