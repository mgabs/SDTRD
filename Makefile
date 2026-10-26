.PHONY: test test-lint test-unit test-bdd bdd lint

test: test-lint test-unit test-bdd

lint: test-lint

test-lint:
	@sh tests/test_lint.sh

test-unit:
	@sh tests/test_init.sh

test-bdd:
	@sh tests/bdd/test_bdd.sh

bdd: test-bdd
