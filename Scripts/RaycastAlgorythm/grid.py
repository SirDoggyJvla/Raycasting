import pygame

from point import Point

class Grid():
    def __init__(self, screen, width, height, grid_size, color):
        self.screen = screen
        self.width = width
        self.height = height
        self.grid_size = grid_size
        self.color = color

    def ij2xy(self, point):
        i, j = point
        x = i * self.grid_size
        y = j * self.grid_size
        return (x, y)

    def xy2ij(self, point):
        x, y = point
        i = x / self.grid_size
        j = y / self.grid_size
        return (i, j)

    def draw(self):
        for x in range(0, self.width, self.grid_size):
            pygame.draw.line(self.screen, self.color, (x, 0), (x, self.height))
        for y in range(0, self.height, self.grid_size):
            pygame.draw.line(self.screen, self.color, (0, y), (self.width, y))

    def highlight_cells(self, cells, highlight_color):
        for cell in cells:
            self.highlight_cell(cell, highlight_color)

    def highlight_cell(self, point: Point, highlight_color):
        cell_x, cell_y = point.to_grid()
        rect = pygame.Rect(cell_x * self.grid_size, cell_y * self.grid_size, self.grid_size, self.grid_size)
        pygame.Surface.fill(self.screen, highlight_color, rect)


