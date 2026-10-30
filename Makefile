.PHONY: test test-lint test-unit test-installer test-schema test-bdd bdd lint check-directives

test: test-lint test-unit test-installer test-schema test-bdd

lint: check-directives test-lint

check-directives:
	@if [ -d .lgtm/reviews ]; then \
		directives=$$(grep -rn "^#ref " .lgtm/reviews 2>/dev/null || true); \
		if [ -n "$$directives" ]; then \
			echo "ERROR: Unresolved LGTM directives in .lgtm/reviews/:" >&2; \
			echo "$$directives" >&2; \
			exit 1; \
		fi; \
	fi

test-lint:
	@sh tests/test_lint.sh

test-unit:
	@true

test-installer:
	@sh tests/test_installer.sh

test-schema:
	@sh tests/test_schema.sh

test-bdd:
	@sh tests/bdd/test_bdd.sh

bdd: test-bdd
