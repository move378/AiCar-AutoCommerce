ifeq ($(OS), Windows_NT)
    PYTHON = venv/Scripts/python
    PIP = venv/Scripts/pip
    PLAYWRIGHT = venv/Scripts/playwright
else
    PYTHON = venv/bin/python
    PIP = venv/bin/pip
    PLAYWRIGHT = venv/bin/playwright
endif

install:
	python -m venv venv
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	$(PLAYWRIGHT) install

crawl:
	$(PYTHON) main.py