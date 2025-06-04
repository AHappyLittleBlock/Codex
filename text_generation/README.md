# Text Generation Example

This folder contains a small script that can call either the OpenAI or Google Gemini API to generate text. Provide a prompt on the command line and the script will return the generated text with blank lines removed.

## Requirements

- Python 3
- `openai`
- `google-generativeai`

Install the dependencies:

```bash
pip install openai google-generativeai
```

Set your API keys as environment variables:

```bash
export OPENAI_API_KEY=your-openai-key
export GEMINI_API_KEY=your-gemini-key
```

## Usage

Call the script with a prompt and choose the provider:

```bash
python generate_text.py --provider openai --prompt "write a short poem"
```

Supported providers are `openai` and `gemini`.

The script prints the generated text with any completely blank lines removed.
