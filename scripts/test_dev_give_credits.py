from __future__ import annotations

import io
import json
from collections.abc import Callable, Sequence

from scripts.dev_give_credits import TARGET_CREDITS, main


RedisCall = tuple[list[str], str | None]
RedisCliRunner = Callable[[Sequence[str], str | None], str]
RedisCliFactory = Callable[[str], RedisCliRunner]


def test_should_print_usage_and_exit_when_username_is_missing() -> None:
    redis_cli_factory, _, _ = given_redis_cli_factory([])
    output = io.StringIO()

    exit_code = main(
        arguments=[],
        environment={},
        output=output,
        redis_cli_factory=redis_cli_factory,
    )

    assert exit_code == 1
    assert output.getvalue() == (
        "Usage: mise run dev-give-credits -- <username>\n"
        "   or: USERNAME=<username> mise run dev-give-credits\n"
    )


def test_should_use_username_from_cli_argument_before_environment() -> None:
    redis_cli_factory, _, redis_calls = given_redis_cli_factory(["USER_NOT_FOUND"])
    output = io.StringIO()

    exit_code = main(
        arguments=["cli-user"],
        environment={"USERNAME": "env-user"},
        output=output,
        redis_cli_factory=redis_cli_factory,
    )

    assert exit_code == 1
    assert redis_calls[0][-1] is None
    assert redis_calls[0][0][-1] == "cli-user"


def test_should_use_username_from_environment_when_argument_missing() -> None:
    redis_cli_factory, _, redis_calls = given_redis_cli_factory(["USER_NOT_FOUND"])
    output = io.StringIO()

    exit_code = main(
        arguments=[],
        environment={"USERNAME": "env-user"},
        output=output,
        redis_cli_factory=redis_cli_factory,
    )

    assert exit_code == 1
    assert redis_calls[0][0][-1] == "env-user"


def test_should_set_user_money_to_target_credits() -> None:
    raw_player = '{"username":"alice","money":12,"level":7}'
    redis_cli_factory, compose_paths, redis_calls = given_redis_cli_factory(
        ["intrusion:user:42", raw_player, "OK"]
    )
    output = io.StringIO()

    exit_code = main(
        arguments=["alice"],
        environment={"COMPOSE_FILE_PATH": "custom-compose.yaml"},
        output=output,
        redis_cli_factory=redis_cli_factory,
    )

    assert exit_code == 0
    assert compose_paths == ["custom-compose.yaml"]
    assert redis_calls[1][0] == ["--raw", "GET", "intrusion:user:42"]
    assert redis_calls[2][0] == ["-x", "SET", "intrusion:user:42"]
    assert redis_calls[2][1] is not None
    stored_player = json.loads(redis_calls[2][1])
    assert stored_player["money"] == TARGET_CREDITS
    assert (
        output.getvalue()
        == "User 'alice' (intrusion:user:42) now has 9999999 credits.\n"
    )


def given_redis_cli_factory(
    responses: list[str],
) -> tuple[RedisCliFactory, list[str], list[RedisCall]]:
    response_queue = list(responses)
    compose_paths: list[str] = []
    redis_calls: list[RedisCall] = []

    def when_running_redis(
        arguments: Sequence[str], input_text: str | None = None
    ) -> str:
        redis_calls.append((list(arguments), input_text))
        if response_queue:
            return response_queue.pop(0)
        return ""

    def when_creating_redis_cli(compose_file_path: str) -> RedisCliRunner:
        compose_paths.append(compose_file_path)
        return when_running_redis

    return when_creating_redis_cli, compose_paths, redis_calls
