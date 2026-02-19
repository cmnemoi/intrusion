from __future__ import annotations

import io
import json
from collections.abc import Sequence

from scripts.dev_set_level import TARGET_LEVEL, RedisCliFactory, RedisCliRunner, main


RedisCall = tuple[list[str], str | None]


def test_should_set_user_xp_for_target_level_and_remove_legacy_level_field() -> None:
    # Given
    raw_player = '{"username":"alice","money":12,"xp":3,"level":2}'
    redis_cli_factory, _, redis_calls = given_redis_cli_factory(
        ["intrusion:user:42", raw_player, "OK"]
    )
    output = io.StringIO()

    # When
    exit_code = main(
        arguments=["alice"],
        environment={},
        output=output,
        redis_cli_factory=redis_cli_factory,
    )

    # Then
    assert exit_code == 0
    assert redis_calls[2][0] == ["-x", "SET", "intrusion:user:42"]
    assert redis_calls[2][1] is not None
    stored_player = json.loads(redis_calls[2][1])
    assert stored_player["xp"] == 10
    assert "level" not in stored_player
    assert (
        output.getvalue()
        == f"User 'alice' (intrusion:user:42) now has level {TARGET_LEVEL}.\n"
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
