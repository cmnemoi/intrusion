#!/usr/bin/env python3
"""Set a user's credits to a large value in development Redis."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from collections.abc import Callable, Mapping, Sequence
from typing import TextIO

TARGET_CREDITS = 9_999_999
USER_NOT_FOUND = "USER_NOT_FOUND"
DEFAULT_COMPOSE_FILE_PATH = "compose.dev.yaml"
USAGE_LINES = (
    "Usage: mise run dev-give-credits -- <username>",
    "   or: USERNAME=<username> mise run dev-give-credits",
)
FIND_USER_KEY_SCRIPT = (
    "local username=ARGV[1]; local cursor='0'; repeat "
    "local scan=redis.call('SCAN', cursor, 'MATCH', 'intrusion:user:*', 'COUNT', 200); "
    "cursor=scan[1]; local keys=scan[2]; for _,key in ipairs(keys) do "
    "local raw=redis.call('GET', key); if raw then local ok,player=pcall(cjson.decode, raw); "
    "if ok and player and player.username == username then return key; end end end "
    "until cursor == '0'; return 'USER_NOT_FOUND'"
)

RedisCliRunner = Callable[[Sequence[str], str | None], str]
RedisCliFactory = Callable[[str], RedisCliRunner]


def resolve_username(
    arguments: Sequence[str], environment: Mapping[str, str]
) -> str | None:
    """Return username from CLI args first, then USERNAME env."""
    argument_username = arguments[0] if arguments else ""
    if argument_username:
        return argument_username
    environment_username = environment.get("USERNAME", "")
    if environment_username:
        return environment_username
    return None


def resolve_compose_file_path(environment: Mapping[str, str]) -> str:
    """Return compose file path from env with shell-compatible fallbacks."""
    compose_file_path = environment.get("COMPOSE_FILE_PATH", "")
    if compose_file_path:
        return compose_file_path
    compose_file = environment.get("COMPOSE_FILE", "")
    if compose_file:
        return compose_file
    return DEFAULT_COMPOSE_FILE_PATH


def print_usage(output: TextIO) -> None:
    """Write CLI usage help."""
    output.write(f"{USAGE_LINES[0]}\n{USAGE_LINES[1]}\n")


def create_redis_cli(compose_file_path: str) -> RedisCliRunner:
    """Create a redis-cli runner bound to docker compose."""

    def run(arguments: Sequence[str], input_text: str | None = None) -> str:
        command = [
            "docker",
            "compose",
            "-f",
            compose_file_path,
            "exec",
            "-T",
            "redis",
            "redis-cli",
            *arguments,
        ]
        completed_process = subprocess.run(
            command,
            check=True,
            capture_output=True,
            text=True,
            input=input_text,
        )
        return completed_process.stdout.rstrip("\n")

    return run


def find_user_key(username: str, redis_cli: RedisCliRunner) -> str:
    """Find Redis key for a username or return USER_NOT_FOUND."""
    return redis_cli(["--raw", "EVAL", FIND_USER_KEY_SCRIPT, "0", username], None)


def build_updated_player(raw_player: str, target_credits: int) -> str:
    """Return minified player JSON with updated money value."""
    player = json.loads(raw_player)
    player["money"] = int(target_credits)
    return json.dumps(player, separators=(",", ":"))


def set_target_credits(username: str, redis_cli: RedisCliRunner, output: TextIO) -> int:
    """Set target credits for the selected username."""
    user_key = find_user_key(username, redis_cli)
    if user_key == USER_NOT_FOUND:
        output.write(f"User '{username}' not found in Redis\n")
        return 1
    raw_player = redis_cli(["--raw", "GET", user_key], None)
    updated_player = build_updated_player(raw_player, TARGET_CREDITS)
    redis_cli(["-x", "SET", user_key], updated_player)
    output.write(f"User '{username}' ({user_key}) now has {TARGET_CREDITS} credits.\n")
    return 0


def main(
    arguments: Sequence[str] | None = None,
    environment: Mapping[str, str] | None = None,
    output: TextIO | None = None,
    redis_cli_factory: RedisCliFactory = create_redis_cli,
) -> int:
    """Run the CLI command and return process exit code."""
    script_arguments = sys.argv[1:] if arguments is None else list(arguments)
    script_environment = os.environ if environment is None else environment
    destination = sys.stdout if output is None else output
    username = resolve_username(script_arguments, script_environment)
    if username is None:
        print_usage(destination)
        return 1
    compose_file_path = resolve_compose_file_path(script_environment)
    redis_cli = redis_cli_factory(compose_file_path)
    return set_target_credits(username, redis_cli, destination)


if __name__ == "__main__":
    raise SystemExit(main())
