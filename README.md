
<p align="center">
    <img src="assets/icons/logo_horizontal.png">
</p>
<p align="center">
<a href="https://github.com/janus-llm/janus-llm/actions/workflows/pages.yml" target="_blank">
    <img src="https://github.com/janus-llm/janus-llm/actions/workflows/pages.yml/badge.svg" alt="Pages">
</a>
<a href="https://github.com/janus-llm/janus-llm/actions/workflows/publish.yml" target="_blank">
    <img src="https://github.com/janus-llm/janus-llm/actions/workflows/publish.yml/badge.svg" alt="Publish">
</a>
<a href="https://github.com/psf/black" target="_blank">
    <img src="https://img.shields.io/badge/code%20style-black-000000.svg" alt="Code Style: black">
</a>
<a href="https://pypi.org/project/janus-llm" target="_blank">
    <img src="https://img.shields.io/pypi/pyversions/janus-llm" alt="Python versions">
</a>
<a href="https://pypi.org/project/janus-llm" target="_blank">
    <img src="https://img.shields.io/pypi/v/janus-llm?color=%2334D058&label=pypi%20package" alt="Package version">
</a>
</p>

## Overview

Janus (`janus-llm`) uses LLMs to aid in the modernization of legacy IT systems. The repository can currently do the following:

1. Chunk code of over 100 programming languages to fit within different model context windows and add to a [Chroma](https://trychroma.com) vector database.
2. Translate from one programming language to another on a file-by-file basis using an LLM with varying results (with the `translate.py` script).
3. Translate from a binary file to a programming language using Ghidra decompilation.
4. Do 1-3 with a CLI tool (`janus`).

## Roadmap

### Priorities

1. Scripts interacting with Chroma Vector DB for RAG translation and understanding.
2. Evaluation of outputs in CLI using LLM self-evaluation or static analysis.

## Installation

```shell
pip install janus-llm
```

### Installing from Source

Clone the repository:

```shell
git clone git@github.com:janus-llm/janus-llm.git
```

**NOTE**: Make sure you're using Python 3.10 or 3.11.

Then, install the requirements:

```shell
curl -sSkL https://install.python-poetry.org | python -
export PATH=$PATH:$HOME/.local/bin
poetry install
```

### PlantUML example

Files of a single type can be "translated" to PlantUML diagrams. See the following example:

```shell
janus translate --input-dir INPUT_DIR --output-dir OUTPUT_DIR --source-lang SOURCE_LANG --target-lang plantuml --prompt-template janus-llm/janus/prompts/templates/uml-diagram/
```

Please note that using plantuml as an input language in regular translation is very likely broken.

### RAG

Retrieval Augmented Generation is a framework that combines chunks of "context" from a database into a prompting scheme to provide more information to a generative model at inference time. This fork supports RAG by adding the in-collection and n-db-results parameters at translation time.

After database initialization, a collection must first be created and embedded by running the appropriate janus db commands. For example, to add a collection of cpp files within the start/ directory, a user might run:

```shell
janus db add collection-cpp --input-lang cpp --input-dir start/
```

Then, that user might craft a prompting scheme that includes {CONTEXT}. This will be replaced by the top integer number of n-db-results of context from that collection at inference time. An example can be found at ./prompts/templates/simple-rag/

That user might finally pass the collection and their prompting scheme into the model during translation:

```shell
janus translate --input-dir start --source-lang cpp --output-dir finish-with-retrieval --in-collection collection-cpp --target-lang python --llm-name LLM_NAME --prompt-template ~/forked/janus-llm/janus/prompts/templates/simple-rag/ -n 2
```

Users can also perform a translation, build a collection out of the result, and ask the model to iterate on its first attempt. The creative application of context can have a big impact on the end result.  

Collection input types do not have to match, so a collection can be built out of one language and used for translation of another.


### Contributing

See our [contributing pages](https://janus-llm.github.io/janus-llm/contributing.html)

### Copyright
Copyright ©2024 The MITRE Corporation. ALL RIGHTS RESERVED. Approved for Public Release; Distribution Unlimited. Public Release Case Number 23-4084.
