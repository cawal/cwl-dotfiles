from libqtile import widget

class TestCounterWidget(widget_base._TextBox):
    def __init__(self, **config: dict):
        super().__init__("", **config)
        self.value = 0
        self.text = str(self.value)
        self.add_callbacks(
            {
                "Button1": self.add,
                "Button2": self.zero,
                "Button3": self.subtract,
            }
        )

    def add(self):
        self.value = self.value + 1
        self.update()

    def subtract(self):
        self.value = self.value - 1
        self.update()

    def zero(self):
        self.value = 0
        self.update()

    def update(self):
        self.text = str(self.value)
        self.drawer.draw(offsetx=self.offsetx, offsety=self.offsety, width=self.width)
        self.bar.draw()
