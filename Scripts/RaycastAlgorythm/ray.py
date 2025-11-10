import pygame
import math

from grid import Grid
from point import Point
from line import Line

class Ray():
    def __init__(self, grid, start_point: Point, end_point: Point):
        self.grid = grid
        self.start_point = start_point
        self.end_point = end_point
        self.line = Line(grid, start_point, end_point)
        self.direction = self.line.get_angle()

        self.slope = math.tan(math.radians(self.direction))

    def __repr__(self):
        return f"Ray(start_point={self.start_point}, end_point={self.end_point}, direction={self.direction:.2f}, slope={self.slope:.2f})"

    def draw(self, screen, color):
        line = self.line.copy().set_length(1000)
        start = line.start_point.to_real()
        end = line.end_point.to_real()
        pygame.draw.line(screen, color, start, end, 1)

    def cast(self, grid):
        cells = []

        i0, j0 = self.start_point.to_gridf()
    
        slope = self.line.get_slope()
        
        # Determine step direction based on ray direction
        direction_x = 1 if self.end_point.x > self.start_point.x else -1
        direction_y = 1 if self.end_point.y > self.start_point.y else -1
        
        if abs(slope) < 1:
            step_i, step_j = direction_x * 1, direction_y * abs(slope)
        else:
            step_i, step_j = direction_x * abs(1 / slope), direction_y * 1

        i1, j1 = (i0 + step_i), (j0 + step_j)

        while 0 <= i0 < grid.width and 0 <= j0 < grid.height:
            cells.append(Point(grid, ij=(i0,j0)))
            i0, j0 = i1, j1
            i1, j1 = (i0 + step_i), (j0 + step_j)

        # pprint(cells)

        return cells