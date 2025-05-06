
PROJECT            := pandemic
MVN                := mvn -B
VERSION            := $(shell $(MVN) help:evaluate -Dexpression=project.version -q -DforceStdout)
JAR					:= target/pandemic-$(VERSION)-shaded.jar
IMAGE               := ghcr.io/tonixsmm/$(PROJECT):$(VERSION)


build:
	@echo "Building $(PROJECT) package (skipping tests)…"
	$(MVN) package -DskipTests

test:
	@echo "Running unit tests…"
	$(MVN) test

lint:
	@echo "Running Checkstyle + SpotBugs…"
	$(MVN) spotless:apply verify -DskipTests

ci: clean test lint

clean:
	$(MVN) clean

run: build
	@echo "Running $(PROJECT) from local JAR"
	java -jar $(JAR)

docker-build: ci
	@echo "Building Docker image $(IMAGE)"
	docker build -t $(IMAGE) .

docker-run: docker-build
	@echo "Launching container – Ctrl‑C to stop"
	docker run --rm -it $(IMAGE)

javadoc:
	@echo "Generating Javadoc (target/site/apidocs)"
	$(MVN) javadoc:javadoc

spellcheck:
	@echo "Spell‑checking source tree"
	-codespell src/

setup-dependencies:
	sudo apt update
	sudo apt install -y openjdk-17-jdk maven python3-pip
	sudo pip3 install codespell
