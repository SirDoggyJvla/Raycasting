import pygame
import math

from grid import Grid
from point import Point
from line import Line

class Ray():
    def __init__(self, grid, start_pos: Point, end_point: Point):
        self.grid = grid
        self.start_pos = start_pos
        self.end_point = end_point
        self.line = Line(grid, start_pos, end_point)
        self.direction = self.line.get_angle()

        self.slope = math.tan(math.radians(self.direction))

    def __repr__(self):
        return f"Ray(start_pos={self.start_pos}, end_point={self.end_point}, direction={self.direction}, slope={self.slope})"

    def draw(self, screen, color):
        line = self.line.copy().set_length(1000)
        start = line.start_point.to_real()
        end = line.end_point.to_real()
        pygame.draw.line(screen, color, start, end, 1)

    def cast(self, grid):
        cells = []

        i0, j0 = self.start_pos

        slope = self.slope
        
        if abs(slope) < 1:
            step_i, step_j = 1, slope
        else:
            step_i, step_j = 1 / slope, 1


        while 0 <= i0 < grid.width and 0 <= j0 < grid.height:
            cells.append((i0,j0))
            i1, j1 = (i0 + step_i), (j0 + step_j)
            i0, j0 = i1, j1

        # pprint(cells)

        return cells