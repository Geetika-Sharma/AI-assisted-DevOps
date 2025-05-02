import ollama

PROMPT = """
ONLY Generate an ideal Dockerfile for {language} with best practices. Do not provide any explanation or additional information.
The Dockerfile should be for a {language} application that is designed to run in a production environment.
The Dockerfile should include the following:
- Use a specific base image that is suitable for {language} applications.
- Install any necessary dependencies and tools.
- Set the working directory
- Copy the necessary files into the container.
- Expose the necessary ports.
- Set the command to run the application.
- Use multi-stage builds if applicable.
- Use environment variables for configuration.
- Use a non-root user for security. 
- Use best practices for caching and layer optimization.
"""

def generate_dockerfile(language):
    response = ollama.chat(
        model='gemma3',
        messages=[{'role': 'user',
                   'content': PROMPT.format(language=language)}]
    )
    return response['message']['content']

if __name__ == "__main__":
    language = input("Enter the programming language (e.g., Python, Node.js, Java): ")
    dockerfile = generate_dockerfile(language)
    print("\nGenerated Dockerfile:\n")
    print(dockerfile)