import math

class Line():
    def __init__(self, grid, start_point, end_point):
        self.grid = grid
        self.start_point = start_point
        self.end_point = end_point

    def copy(self):
        return Line(self.grid, self.start_point, self.end_point)

    def set_point(self, point_name, point):
        if point_name == "start":
            self.start_point = point
        elif point_name == "end":
            self.end_point = point
        else:
            raise ValueError("point_name must be 'start' or 'end'")
        return self
    
    def set_length(self, length):
        angle = self.get_angle()
        x0, y0 = self.start_point.to_real()
        x1 = x0 + length * math.cos(math.radians(angle))
        y1 = y0 + length * math.sin(math.radians(angle))
        self.end_point = self.end_point.set_xy((x1, y1))
        return self

    def get_delta_real(self):
        x0, y0 = self.start_point.to_real()
        x1, y1 = self.end_point.to_real()
        return (x1 - x0, y1 - y0)
    
    def get_delta_gridf(self):
        i0, j0 = self.start_point.to_gridf()
        i1, j1 = self.end_point.to_gridf()
        return (i1 - i0, j1 - j0)

    def get_delta_grid(self):
        i0, j0 = self.start_point.to_grid()
        i1, j1 = self.end_point.to_grid()
        return (i1 - i0, j1 - j0)
    
    def get_slope(self):
        delta_i, delta_j = self.get_delta_gridf()
        if delta_i == 0:
            return 0 # vertical line
        return delta_j / delta_i
    
    def get_angle(self):
        delta_i, delta_j = self.get_delta_gridf()
        return math.degrees(math.atan2(delta_j, delta_i))