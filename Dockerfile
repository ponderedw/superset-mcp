# Use a slim Python image for a smaller footprint
FROM python:3.12-slim

# Set environment variables for Poetry and Python
ENV POETRY_HOME="/usr/local/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=false \
    POETRY_NO_INTERACTION=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache \
    PYTHONUNBUFFERED=1

# Install Poetry
# We use a multi-stage build pattern here to keep the final image small
# First stage installs Poetry and dependencies
RUN pip install --no-cache-dir poetry

# Set the working directory inside the container
WORKDIR /app

# Copy only the necessary files for dependency installation to leverage Docker's layer caching
COPY pyproject.toml poetry.lock ./

COPY superset_mcp_server/. superset_mcp_server/.

# Install dependencies without development packages
RUN poetry install --no-root

# Expose the port the FastAPI application will run on
EXPOSE 8000

# Run the application using the poetry run command to ensure dependencies are loaded correctly.
CMD ["poetry", "run", "python", "superset_mcp_server/mcp_server.py"]