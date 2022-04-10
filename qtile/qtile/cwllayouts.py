from libqtile.layout import TreeTab


class CWLTreeTab(TreeTab):
    def draw_panel(self, *args):
        if not self._panel:
            return
        self._drawer.clear(self.bg_color)
        self._tree.draw(self, 0)
        self._drawer.draw(offsetx=0, width=self.panel_width)
