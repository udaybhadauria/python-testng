# Variables
PYTHON=python
PIP=pip

# Targets
install:
	$(PIP) install -r requirements.txt

test:
	$(PYTHON) -m pytest

report:
	$(PYTHON) -m pytest --html=reports/report.html --self-contained-html

docker-build:
	docker build -t python-testng .

docker-run:
	docker run --rm python-testng

send-email:
	$(PYTHON) notifications/send_email.py

send-slack:
	$(PYTHON) notifications/send_slack.py

clean:
	rm -rf __pycache__ .pytest_cache reports/*.html

help:
	@echo "Makefile Usage:"
	@echo "  make install        Install dependencies"
	@echo "  make test           Run basic tests"
	@echo "  make report         Run tests and generate HTML report"
	@echo "  make docker-build   Build Docker image"
	@echo "  make docker-run     Run Docker container to execute tests"
	@echo "  make send-email     Send email notification"
	@echo "  make send-slack     Send Slack notification"
	@echo "  make clean          Clean up cache and reports"
