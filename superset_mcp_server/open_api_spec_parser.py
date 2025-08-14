import json
import os
from typing import List, Dict, Any

class OpenApiParser:
    """
    A class to parse OpenAPI specification and extract method details.
    """
    def __init__(self, openapi_spec_path: str, mcp_methods_path: str):
        """
        Initializes the parser with paths to the OpenAPI spec and MCP methods files.

        Args:
            openapi_spec_path (str): The file path to the OpenAPI specification JSON.
            mcp_methods_path (str): The file path to the MCP methods JSON.
        """
        self.openapi_spec_path = openapi_spec_path
        self.mcp_methods_path = mcp_methods_path
        self.openapi_spec = self._load_json_file(self.openapi_spec_path)
        self.mcp_methods = self._load_json_file(self.mcp_methods_path)
        self.methods_to_process = self.mcp_methods.get('mcp_methods', [])

    def _load_json_file(self, file_path: str) -> Dict[str, Any]:
        """
        Loads and returns the content of a JSON file.

        Args:
            file_path (str): The path to the JSON file.

        Returns:
            Dict[str, Any]: The content of the JSON file.
        """
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")
        with open(file_path, 'r') as f:
            return json.load(f)

    def _get_schema_details(self, ref_path: str) -> Dict[str, Any]:
        """
        Resolves a schema reference path and returns the schema details.

        Args:
            ref_path (str): The reference path (e.g., '#/components/schemas/AdvancedDataTypeSchema').

        Returns:
            Dict[str, Any]: The resolved schema dictionary.
        """
        parts = ref_path.split('/')[1:]  # Remove '#'
        schema = self.openapi_spec
        for part in parts:
            schema = schema.get(part, {})
        return schema
    
    def _generate_example_from_schema(self, schema: Dict[str, Any]) -> Any:
        """
        Generates a basic example object from a schema, using default values if available.
        """
        if "default" in schema:
            return schema["default"]
        
        schema_type = schema.get("type")

        if schema_type == "object":
            example = {}
            properties = schema.get("properties", {})
            for prop_name, prop_schema in properties.items():
                example[prop_name] = self._generate_example_from_schema(prop_schema)
            return example
        elif schema_type == "array":
            items_schema = schema.get("items", {})
            return [self._generate_example_from_schema(items_schema)]
        elif schema_type == "string":
            return "string"
        elif schema_type == "integer":
            return 0
        elif schema_type == "boolean":
            return False
        else:
            return None

    def parse_methods(self) -> List[Dict[str, Any]]:
        """
        Parses the OpenAPI spec for the specified methods and returns a list of dictionaries.

        Returns:
            List[Dict[str, Any]]: A list of dictionaries, each containing details for a method.
                                  Example format:
                                  [
                                      {
                                          "method": "/api/v1/advanced_data_type/convert",
                                          "short_description": "Return an AdvancedDataTypeResponse",
                                          "full_description": "Returns an AdvancedDataTypeResponse object populated with the passed in args.",
                                          "parameters": [...],
                                          "method_type": "get",
                                          "response_schema": {...},
                                          "response_description": "AdvancedDataTypeResponse object has been returned.",
                                          "custom_description": "That's a function that must be used!!!",
                                          "example_request": {...}
                                      },
                                      ...
                                  ]
        """
        parsed_methods = []
        paths = self.openapi_spec.get('paths', {})

        for mcp_method in self.methods_to_process:
            method_path = mcp_method.get('method')
            custom_description = mcp_method.get('custom_description', '')

            if method_path in paths:
                path_item = paths[method_path]
                for http_method, method_spec in path_item.items():
                    if http_method in ['get', 'post', 'put', 'delete']:
                        # Initialize fields with defaults
                        parameters_list = []
                        response_schema = {}
                        response_description = ''
                        short_description = method_spec.get('summary', '')
                        full_description = method_spec.get('description', '')
                        
                        example_request_payload = {}

                        # Extract parameters and build example request
                        parameters = method_spec.get('parameters', [])
                        
                        for param in parameters:
                            param_details = {
                                "name": param.get("name"),
                                "in": param.get("in"),
                                "required": param.get("required", False),
                                "description": param.get("description", ""),
                                "schema": {}
                            }
                            
                            schema_obj = {}
                            if "content" in param and "application/json" in param["content"]:
                                schema_obj = param["content"]["application/json"].get("schema", {})
                            elif "schema" in param:
                                schema_obj = param.get("schema", {})

                            if "$ref" in schema_obj:
                                ref = schema_obj["$ref"]
                                resolved_schema = self._get_schema_details(ref)
                                param_details["schema"] = resolved_schema
                                if param.get("in") == "query":
                                    example_request_payload[param.get("name")] = self._generate_example_from_schema(resolved_schema)
                            else:
                                param_details["schema"] = schema_obj
                                if param.get("in") == "query":
                                    example_request_payload[param.get("name")] = self._generate_example_from_schema(schema_obj)

                            parameters_list.append(param_details)

                        # Extract response schema and description (for 200 code)
                        responses = method_spec.get('responses', {})
                        if '200' in responses:
                            response_description = responses['200'].get('description', '')
                            response_content = responses['200'].get('content', {})
                            if 'application/json' in response_content:
                                schema_ref = response_content['application/json'].get('schema', {})
                                if '$ref' in schema_ref:
                                    response_schema = self._get_schema_details(schema_ref['$ref'])
                                else:
                                    response_schema = schema_ref
                        
                        # Handle example from requestBody if available
                        request_body = method_spec.get('requestBody', {})
                        if request_body:
                            content = request_body.get('content', {})
                            if 'application/json' in content:
                                schema_obj = content['application/json'].get('schema', {})
                                if '$ref' in schema_obj:
                                    ref = schema_obj['$ref']
                                    resolved_schema = self._get_schema_details(ref)
                                    example_request_payload = self._generate_example_from_schema(resolved_schema)
                                else:
                                    example_request_payload = self._generate_example_from_schema(schema_obj)

                        parsed_methods.append({
                            "method": method_path,
                            "short_description": short_description,
                            "full_description": full_description,
                            "parameters": parameters_list,
                            "method_type": http_method,
                            "response_schema": response_schema,
                            "response_description": response_description,
                            "custom_description": custom_description,
                            "example_request": example_request_payload
                        })
        return parsed_methods
