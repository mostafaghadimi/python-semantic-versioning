import logging
import re
from typing import Tuple

from pydantic.dataclasses import dataclass
from semantic_release.commit_parser._base import CommitParser, ParserOptions
from semantic_release.commit_parser.token import (
    ParsedCommit,
    ParsedMessageResult,
    ParseError,
    ParseResult,
)
from semantic_release.enums import LevelBump

logger = logging.getLogger(__name__)

# Types with long names in changelog
LONG_TYPE_NAMES = {
    "feat": "features",
    "fix": "bug fixes",
    "refactor": "refactoring",
    "docs": "documentation",
    "test": "tests",
    "chore": "chores",
}


@dataclass
class DataBurstEmojiParserOptions(ParserOptions):
    """Options for the Emoji Commit Parser."""

    minor_tags: Tuple[str, ...] = ("feat",)
    patch_tags: Tuple[str, ...] = ("fix",)
    other_allowed_tags: Tuple[str, ...] = ("refactor", "docs", "test", "chore")
    allowed_tags: Tuple[str, ...] = minor_tags + patch_tags + other_allowed_tags
    default_bump_level: LevelBump = LevelBump.NO_RELEASE

    @property
    def tag_to_level(self) -> dict[str, LevelBump]:
        """Map commit types to their bump levels."""
        tag_to_level_map = {}

        for tag in self.minor_tags:
            tag_to_level_map[tag] = LevelBump.MINOR

        for tag in self.patch_tags:
            tag_to_level_map[tag] = LevelBump.PATCH

        for tag in self.other_allowed_tags:
            tag_to_level_map[tag] = LevelBump.NO_RELEASE

        return tag_to_level_map


class DataBurstEmojiCommitParser(
    CommitParser[ParseResult, DataBurstEmojiParserOptions]
):
    """Commit parser for custom emoji commit format."""

    parser_options = DataBurstEmojiParserOptions

    def __init__(self, options: DataBurstEmojiParserOptions | None = None) -> None:
        super().__init__(options)

        # Define regex for the emoji, type, scope, subject, and optional breaking change `!`
        try:
            commit_type_pattern = (
                rf"(?P<emoji>:\S+: )?(?P<type>{'|'.join(self.options.allowed_tags)})"
            )
        except re.error:
            raise ValueError("Invalid commit type pattern.")

        # Updated regex construction to avoid duplicate group names
        self.re_parser = re.compile(
            rf"^{commit_type_pattern}"  # Start of the line, emoji and type
            r"(?:\((?P<scope>[^\)]+)\))?"  # Optional scope in parentheses
            r"(?P<break>!)?:\s+(?P<subject>[^\n]+)"  # Optional breaking change `!`, subject line
            r"(?:\n\n(?P<body>.+))?",  # Optional body with newlines
            flags=re.DOTALL,
        )

        # Match issue references (e.g., `#123`)
        self.issue_selector = re.compile(
            r"(?:clos(?:e|es|ed|ing)|fix(?:es|ed|ing)?|resolv(?:e|es|ed|ing)|implement(?:s|ed|ing)?):?[\s]*(?P<issue>#[0-9]+)",
            flags=re.IGNORECASE,
        )

        # Match pull request references (e.g., `!123`)
        self.mr_selector = re.compile(
            r"[\t ]+\((?:pull request )?(?P<mr_number>[#!]\d+)\)[\t ]*$"
        )

    def parse_message(self, message: str) -> ParsedMessageResult | None:
        """Parse the commit message and return parsed components."""
        if not (parsed := self.re_parser.match(message)):
            return None

        parsed_break = parsed.group("break")
        parsed_emoji = parsed.group("emoji")
        parsed_type = parsed.group("type")
        parsed_scope = parsed.group("scope")
        parsed_subject = parsed.group("subject")
        parsed_body = parsed.group("body")

        logger.debug(f"parsed emoji: {parsed_emoji}")

        # Detect linked issues in the body or subject
        linked_issues = set()
        for match in self.issue_selector.finditer(parsed_body or ""):
            linked_issues.add(match.group("issue"))

        # Detect linked PRs in the subject
        linked_pr: str = ""
        if pr_match := self.mr_selector.search(parsed_subject):
            linked_pr = pr_match.group("mr_number")

        return ParsedMessageResult(
            bump=LevelBump.MAJOR
            if parsed_break
            else self.options.tag_to_level.get(
                parsed_type, self.options.default_bump_level
            ),
            type=parsed_type,
            category=LONG_TYPE_NAMES.get(parsed_type, parsed_type),
            scope=parsed_scope,
            descriptions=(parsed_subject,),
            breaking_descriptions=(),
            linked_issues=tuple(linked_issues),
            linked_merge_request=linked_pr,
        )

    def parse(self, commit) -> ParseResult:
        """Parse a full commit object."""
        if not (pmsg_result := self.parse_message(str(commit.message))):
            return ParseError(
                commit, f"Unable to parse commit message: {commit.message!r}"
            )

        logger.debug(
            "commit %s introduces a %s level_bump",
            commit.hexsha[:8],
            pmsg_result.bump,
        )

        return ParsedCommit.from_parsed_message_result(commit, pmsg_result)

