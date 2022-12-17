import subprocess
import dataclasses
from typing import Sequence, Optional


@dataclasses.dataclass
class SelectionResult:
    completed: bool
    selection: Optional[str] = None


def get_user_selection(
    *,
    title: Optional[str],
    options: Sequence[str],
) -> SelectionResult:
    kwargs = {
        "stdout": subprocess.PIPE,
        "universal_newlines": True,
    }
    title = title or "Choices:"
    command = ["rofi", "-dmenu", "-p", title]
    result = subprocess.run(command, input="\n".join(options), **kwargs)
    if result.returncode == 0:
        return SelectionResult(
            completed=True,
            selection=result.stdout.rstrip("\n"),
        )
    else:
        return SelectionResult(
            completed=False,
        )
