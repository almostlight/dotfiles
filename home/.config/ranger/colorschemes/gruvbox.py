from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import default_colors, reverse, bold, normal, default


# pylint: disable=too-many-branches,too-many-statements
class Gruvbox(ColorScheme):
    progress_bar_color = 142  # Green for progress bars

    def use(self, context):
        fg, bg, attr = default_colors

        if context.reset:
            return default_colors

        elif context.in_browser:
            if context.selected:
                attr = reverse
            else:
                attr = normal
            if context.empty or context.error:
                fg = 124  # Red
                bg = 235  # Dark gray
            if context.border:
                fg = 245  # Gray
            if context.image:
                fg = 109  # Blue
            if context.video:
                fg = 108  # Aqua
            if context.audio:
                fg = 107  # Green
            if context.document:
                fg = 223  # Beige
            if context.container:
                attr |= bold
                fg = 208  # Orange
            if context.directory:
                attr |= bold
                fg = 214  # Yellow
            elif context.executable and not \
                    any((context.media, context.container,
                         context.fifo, context.socket)):
                attr |= bold
                fg = 142  # Green
            if context.socket:
                fg = 208  # Orange
                attr |= bold
            if context.fifo or context.device:
                fg = 109  # Blue
                if context.device:
                    attr |= bold
            if context.link:
                fg = 108 if context.good else 208  # Aqua if good, Orange if bad
                bg = 235  # Dark gray
            if context.bad:
                bg = 235  # Dark gray
            if context.tag_marker and not context.selected:
                attr |= bold
                if fg in (208, 124):
                    fg = 245  # Gray
                else:
                    fg = 208  # Orange
            if not context.selected and (context.cut or context.copied):
                fg = 142  # Green
                bg = 235  # Dark gray
            if context.main_column:
                if context.selected:
                    attr |= bold
                if context.marked:
                    attr |= bold
                    fg = 214  # Yellow
            if context.badinfo:
                if attr & reverse:
                    bg = 124  # Red
                else:
                    fg = 124  # Red

        elif context.in_titlebar:
            attr |= bold
            if context.hostname:
                fg = 208 if context.bad else 214  # Orange if bad, Yellow otherwise
            elif context.directory:
                fg = 214  # Yellow
            elif context.tab:
                if context.good:
                    bg = 214  # Yellow
            elif context.link:
                fg = 108  # Aqua

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = 142  # Green
                elif context.bad:
                    fg = 124  # Red
            if context.marked:
                attr |= bold | reverse
                fg = 214  # Yellow
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = 124  # Red
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = 108  # Aqua
                attr &= ~bold
            if context.vcscommit:
                fg = 109  # Blue
                attr &= ~bold

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = 108  # Aqua

            if context.selected:
                attr |= reverse

            if context.loaded:
                if context.selected:
                    fg = self.progress_bar_color
                else:
                    bg = self.progress_bar_color

        if context.vcsfile and not context.selected:
            attr &= ~bold
            if context.vcsconflict:
                fg = 124  # Red
            elif context.vcschanged:
                fg = 208  # Orange
            elif context.vcsunknown:
                fg = 208  # Orange
            elif context.vcsstaged:
                fg = 142  # Green
            elif context.vcssync:
                fg = 142  # Green
            elif context.vcsignored:
                fg = default

        elif context.vcsremote and not context.selected:
            attr &= ~bold
            if context.vcssync:
                fg = 142  # Green
            elif context.vcsbehind:
                fg = 208  # Orange
            elif context.vcsahead:
                fg = 108  # Aqua
            elif context.vcsdiverged:
                fg = 124  # Red
            elif context.vcsunknown:
                fg = 208  # Orange

        return fg, bg, attr