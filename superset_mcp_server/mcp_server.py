from mcp.server.fastmcp import FastMCP
from fastapi import FastAPI, HTTPException, Request
from starlette.status import HTTP_401_UNAUTHORIZED
import uvicorn
import os
import json
from typing import Dict, Any, Callable
from functools import wraps

from pathlib import Path

# Assuming SupersetClient and open_api_spec_parser are in the same directory
from .superset_client import SupersetClient
from .open_api_spec_parser import OpenApiParser

# Initialize MCP and FastAPI app
mcp = FastMCP("Superset", port='8000')
app = FastAPI(title="Superset MCP Server")

# --- Authentication Middleware ---
@app.middleware("http")
async def auth_middleware(request: Request, call_next):
    """
    Authentication middleware to verify JWT tokens.
    """
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(
            status_code=HTTP_401_UNAUTHORIZED,
            detail="Missing or invalid authorization header"
        )
    token = auth_header.split(" ")[1]
    if token == os.environ.get('TOKEN'):
        try:
            response = await call_next(request)
            return response
        except Exception as e:
            raise e
    else:
        raise HTTPException(
            status_code=HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )

# --- Superset Client Initialization ---
def get_superset_client() -> SupersetClient:
    """
    Initializes and authenticates a SupersetClient instance using environment variables.
    """
    base_url = os.environ.get('SUPERSET_API_URL')
    username = os.environ.get('SUPERSET_USERNAME')
    password = os.environ.get('SUPERSET_PASSWORD')

    if not all([base_url, username, password]):
        raise RuntimeError("Missing Superset API configuration environment variables.")

    client = SupersetClient(base_url, username, password)
    if not client.authenticate():
        raise RuntimeError("Failed to authenticate with Superset API.")
    return client

# --- Dynamic Tool Registration ---
def register_superset_tools_dynamically(openapi_spec_path: str, mcp_methods_path: str):
    """
    Dynamically registers Superset API methods as MCP tools based on a configuration file.
    Only registers 'GET' methods in safe mode.
    """
    try:
        parser = OpenApiParser(openapi_spec_path, mcp_methods_path)
        methods_data = parser.parse_methods()
    except FileNotFoundError as e:
        raise e

    # Check for safe mode and only allow GET methods
    safe_mode = os.environ.get('SAFE_MODE', 'true').lower() == 'true'

    for method_info in methods_data:
        # Check if the method should be used and if it's a GET request in safe mode
        if not safe_mode or method_info['method_type'].lower() == 'get':

            method_path = method_info['method'].replace('/api/v1', '')
            method_type = method_info['method_type']
            
            # Sanitize the path to create a valid function name
            func_name = 'superset_' + method_path.replace('/', '_').strip('_') \
                + f'_{method_type}'

            # --- Start of new description logic ---
            # Extract and format parameter details
            parameter_details = "\n".join([
                f"    - Name: {p['name']}, Type: {p['schema'].get('type', 'N/A')}, Required: {p['required']}"
                for p in method_info['parameters']
            ])

            description = method_info['full_description'] \
                if method_info['full_description'] \
                else method_info['short_description']
            full_description_string = (
                f"Description from OpenAPI spec: {description}\n"
                f"Custom Description:\n"
                f"{method_info['custom_description']}\n\n"
                f"Parameters (all of them must be passed to 'kwargs' as dict):\n"
                f"{parameter_details}\n\n"
                f"Input Format (example_request):\n"
                f"```json\n{json.dumps(method_info['example_request'], indent=4)}\n```\n\n"
                f"Output Format (response_schema):\n"
                f"```json\n{json.dumps(method_info['response_schema'], indent=4)}\n```"
            )
            # --- End of new description logic ---

            # Create a simple, dynamic function using a closure
            def create_tool_function(path: str, http_method: str) -> Callable:
                async def dynamic_tool(parameters):
                    """Dynamically generated tool."""
                    client = get_superset_client()
                    return client.make_request(
                        method_name=path,
                        method_type=http_method,
                        payload=parameters
                    )
                return dynamic_tool

            # Instantiate and decorate the dynamic function
            tool_function = create_tool_function(method_path, method_type)
            # Assign a more descriptive name and docstring for the tool
            tool_function.__name__ = func_name
            tool_function.__doc__ = full_description_string
            mcp.tool(name=func_name, description=full_description_string)(tool_function)

# Assume the OpenAPI spec file and MCP methods file exist in the same directory
OPENAPI_SPEC_PATH = Path(__file__).parent / 'openapi_spec.json'
MCP_METHODS_PATH = Path(__file__).parent / 'mcp_methods.json'
register_superset_tools_dynamically(OPENAPI_SPEC_PATH, MCP_METHODS_PATH)

# --- Main Function to Run the Server ---
def main():
    if os.environ.get('TOKEN') and os.environ.get('TRANSPORT_TYPE', 'stdio') == 'sse':
        app.mount("/", mcp.sse_app())
        uvicorn.run(app, host="0.0.0.0", port=8000)
    else:
        transport_type = os.environ.get('TRANSPORT_TYPE')
        if transport_type == 'sse':
            mcp.run(transport="sse")
        else:
            mcp.run(transport="stdio")

if __name__ == "__main__":
    main()