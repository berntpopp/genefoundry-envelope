SCHEMA := envelope-v1.2.schema.json

.PHONY: check test
test: ## Python: schema, vectors, sanitize vectors, standard example
	uvx --with jsonschema --with pytest pytest -q tests

check: test ## Command lines from the README over every vector (uvx; npx when present)
	uvx check-jsonschema==0.39.0 --schemafile $(SCHEMA) vectors/valid/*.json
	@for f in vectors/invalid/*.json; do \
		if uvx check-jsonschema==0.39.0 --schemafile $(SCHEMA) "$$f" >/dev/null 2>&1; then echo "check-jsonschema accepted $$f"; exit 1; fi; \
	done; echo "check-jsonschema rejected every invalid vector"
	@if command -v npx >/dev/null 2>&1; then \
		npx --yes ajv-cli@5.0.0 validate --spec=draft2020 -s $(SCHEMA) -d "vectors/valid/*.json" || exit 1; \
		for f in vectors/invalid/*.json; do \
			if npx --yes ajv-cli@5.0.0 validate --spec=draft2020 -s $(SCHEMA) -d "$$f" >/dev/null 2>&1; then echo "ajv accepted $$f"; exit 1; fi; \
		done; echo "ajv rejected every invalid vector"; \
	else echo "npx not on PATH: ajv check skipped"; fi

