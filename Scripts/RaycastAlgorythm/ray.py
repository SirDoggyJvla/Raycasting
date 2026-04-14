import pygame
import math
import vector
import numpy as np

from grid import Grid
from point import Point
from line import Line


class Ray():
    def __init__(self, grid: Grid, start_point: Point, end_point: Point):
        self.grid = grid
        self.start_point = start_point
        self.end_point = end_point
        self.line = Line(grid, start_point, end_point)
        self.direction = self.line.get_angle()

        self.slope = np.tan(np.deg2rad(self.direction))

        self.vector = vector.obj(x=self.end_point.i - self.start_point.i, y=self.end_point.j - self.start_point.j).unit()

    def __repr__(self):
        return f"Ray(start_point={self.start_point}, end_point={self.end_point}, direction={self.direction:.2f}, slope={self.slope:.2f})"

    def draw(self, screen, color):
        line = self.line.copy().set_length(1000)
        start = line.start_point.to_real()
        end = line.end_point.to_real()
        pygame.draw.line(screen, color, start, end, 1)

    def cast(self, grid: Grid) -> list[Point]:
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

        temp = 12
        step_i, step_j = step_i/temp, step_j/temp

        i1, j1 = (i0 + step_i), (j0 + step_j)

        while 0 <= i0 < grid.width and 0 <= j0 < grid.height:
            point = Point(grid, ij=(i0,j0))
            if point not in cells:
                cells.append(point)
            i0, j0 = i1, j1
            i1, j1 = (i0 + step_i), (j0 + step_j)

        # pprint(cells)

        return cells
    

    def cast_amanatides(self, grid: Grid) -> list[Point]:
        cells = []

        i0, j0 = self.start_point.to_gridf()

        # init
        stepX = 1 if self.vector.x > 0 else -1
        stepY = 1 if self.vector.y > 0 else -1

        tDeltaX = abs(1 / self.vector.x) if self.vector.x != 0 else float('inf')
        tDeltaY = abs(1 / self.vector.y) if self.vector.y != 0 else float('inf')

        print(f"{tDeltaX:.4f}", f"{tDeltaY:.4f}")


        # print(f"{tMaxX:.4f}", f"{tMaxY:.4f}")

        i, j = math.floor(i0), math.floor(j0)
        if stepX > 0:
            tMaxX = (i + 1 - i0) * tDeltaX
        else:
            tMaxX = (i0 - i) * tDeltaX if stepX != 0 else float('inf')
        
        if stepY > 0:
            tMaxY = (j + 1 - j0) * tDeltaY
        else:
            tMaxY = (j0 - j) * tDeltaY if stepY != 0 else float('inf')

        while 0 <= i < grid.width and 0 <= j < grid.height:
            point = Point(grid, ij=(i,j))
            if point not in cells:
                cells.append(point)

            if tMaxX < tMaxY:
                i += stepX
                tMaxX += tDeltaX
            else:
                j += stepY
                tMaxY += tDeltaY

        return cells