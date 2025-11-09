import pygame
import math


class Ray():
    def __init__(self, grid, start_pos, end_point=None, direction=None):
        self.start_pos = start_pos
        self.grid = grid
        if end_point is not None:
            self.end_point = end_point
            self.direction = math.degrees(math.atan2(end_point[1] - start_pos[1], end_point[0] - start_pos[0]))
        else:
            self.end_point = (self.start_pos[0] + 1, self.start_pos[1])
            self.direction = direction

        self.slope = math.tan(math.radians(self.direction))

    def __repr__(self):
        return f"Ray(start_pos={self.start_pos}, end_point={self.end_point}, direction={self.direction}, slope={self.slope})"

    def draw(self, screen, color, length=1000):
        end_x = self.start_pos[0] + length * math.cos(math.radians(self.direction))
        end_y = self.start_pos[1] + length * math.sin(math.radians(self.direction))
        grid = self.grid
        pygame.draw.line(screen, color, grid.ij2xy(self.start_pos), grid.ij2xy((end_x, end_y)), 1)

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