import dataclasses
from pathlib import Path
from typing import ForwardRef, List, Hashable, Optional

from ..utils.logger import create_logger
from .node import NodeType

log = create_logger(__name__)


@dataclasses.dataclass
class CodeBlock:
    """A class that represents a functional block of code.

    Attributes:
        code: The code block.
        path: The path to the file containing the code block.
        complete: Whether or not the code block is complete. If it isn't complete, it
                  should have children components. This means that this code block has
                  missing sections inside of it that are in its children.
        start_line: The line number of the first line of the code block.
        end_line: The line number of the last line of the code block.
        language: The language of the code block.
        type: The type of the code block ('function', 'module', etc.). Defined in the
              language-specific modules.
        tokens: The number of tokens in the code block.
        depth: The depth of the code block in the AST.
        id: The id of the code block in the AST at depth `N`.
        children: A tuple of child code blocks.
    """

    code: Optional[str]
    path: Optional[Path]
    complete: bool
    start_line: int
    end_line: int
    language: str
    type: NodeType
    tokens: int
    depth: int
    id: Hashable
    parent_id: Optional[Hashable]
    children: List[ForwardRef("CodeBlock")]


@dataclasses.dataclass
class TranslatedCodeBlock(CodeBlock):
    """A class that represents the translated functional block of code.

    Attributes:
        original: The original code block.
        cost: The total cost to translate the original code block.
    """
    original: CodeBlock
    cost: float = 0.0

    @classmethod
    def from_original(cls, original: CodeBlock, language: str) -> ForwardRef("TranslatedCodeBlock"):
        block = cls(
            **dataclasses.asdict(original),
            original=original
        )
        return dataclasses.replace(
            block,
            code=None,
            path=None,
            complete=False,
            language=language,
            tokens=0,
            children=[],
        )