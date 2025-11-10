

class Point():
    def __init__(self, grid, ij=None, xy=None):
        assert ij is not None or xy is not None, "Either ij or xy must be provided"
        
        self.grid = grid
        
        if ij is not None:
            self.i, self.j = ij
            self.x, self.y = grid.ij2xy(ij)    
        else:
            self.x, self.y = xy
            self.i, self.j = grid.xy2ij(xy)
    
    def __repr__(self):
        return f"Point({self.i:.2f}, {self.j:.2f})"

    def copy(self):
        return Point(self.grid, ij=(self.i, self.j))

    def set_ij(self, ij):
        self.i, self.j = ij
        self.x, self.y = self.grid.ij2xy(ij)
        return self

    def set_xy(self, xy):
        self.x, self.y = xy
        self.i, self.j = self.grid.xy2ij(xy)
        return self


    def to_real(self):
        """
        Screen coordinates
        """
        return (self.x, self.y)
    
    def to_gridf(self):
        """
        Grid float
        """
        return (self.i, self.j)

    def to_grid(self):
        """
        Grid exact
        """
        GRID_SIZE = self.grid.grid_size
        return (self.x // GRID_SIZE, self.y // GRID_SIZE)
