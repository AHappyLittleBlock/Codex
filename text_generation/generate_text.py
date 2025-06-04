import os
import argparse
import re

try:
    import openai
except ImportError:
    openai = None

try:
    import google.generativeai as genai
except ImportError:
    genai = None

def clean_text(text: str) -> str:
    """Remove completely blank lines from text."""
    lines = [line for line in text.splitlines() if line.strip()]
    return "\n".join(lines)

def generate_with_openai(prompt: str) -> str:
    if openai is None:
        raise RuntimeError("openai package is not installed")
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY environment variable not set")
    openai.api_key = api_key
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}]
    )
    text = response.choices[0].message["content"]
    return clean_text(text)

def generate_with_gemini(prompt: str) -> str:
    if genai is None:
        raise RuntimeError("google-generativeai package is not installed")
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY environment variable not set")
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-pro")
    response = model.generate_content(prompt)
    text = response.text
    return clean_text(text)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prompt", required=True, help="Prompt text")
    parser.add_argument(
        "--provider", choices=["openai", "gemini"], default="openai",
        help="Which API to use"
    )
    args = parser.parse_args()
    if args.provider == "openai":
        result = generate_with_openai(args.prompt)
    else:
        result = generate_with_gemini(args.prompt)
    print(result)

if __name__ == "__main__":
    main()
