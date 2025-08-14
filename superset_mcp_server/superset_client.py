import requests
import json
import os
from typing import Dict, Any

class SupersetClient:
    """
    A client to interact with the Superset API, handling authentication
    and making requests to fetch chart data.
    """

    def __init__(self, base_url: str, username: str, password: str):
        """
        Initializes the client with the base URL, username, and password.

        Args:
            base_url (str): The base URL of the Superset instance.
            username (str): The username for API authentication.
            password (str): The password for API authentication.
        """
        self.base_url = base_url
        self.username = username
        self.password = password
        self.access_token = None
        self.headers = {
            'Content-Type': 'application/json'
        }

    def authenticate(self) -> bool:
        login_url = f'{self.base_url}/api/v1/security/login'
        payload = {
            'password': self.password,
            'provider': 'db',
            'refresh': 'true',
            'username': self.username
        }
        
        try:
            response = requests.post(login_url, json=payload)
            response.raise_for_status()  # Raise an exception for bad status codes (4xx or 5xx)
            
            self.access_token = response.json()['access_token']
            self.headers['Authorization'] = f'Bearer {self.access_token}'
            return True
        except requests.exceptions.RequestException:
            self.access_token = None
            return False
        except KeyError:
            self.access_token = None
            return False

    def encode_dict_values(self, data):
        """Convert all dictionary values to JSON strings"""
        return {
            k: json.dumps(v) if isinstance(v, dict) else v 
            for k, v in data.items()
        }

    def make_request(self, method_name: str, method_type: str, payload: Dict[str, Any] = None) -> Any:
        """
        Makes a dynamic API request to a specified Superset endpoint.

        Args:
            method_name (str): The API endpoint path (e.g., '/chart').
            method_type (str): The HTTP method type ('get', 'post', 'delete', etc.).
            payload (Dict[str, Any], optional): The JSON payload for the request body or query parameters.

        Returns:
            Any: The JSON response from the API, or None if the request fails.
        """
        
        
        if not self.access_token:
            return None
        
        # Hardcoding '/api/v1' as requested.
        url = f'{self.base_url}/api/v1{method_name}'
        
        # Determine the request function based on the method_type
        request_func = getattr(requests, method_type.lower(), None)
        if not request_func:
            return None

        payload = self.encode_dict_values(payload)

        try:
            if method_type.lower() == 'get':
                # GET requests use params for query parameters
                response = request_func(url, params=payload if payload else None, headers=self.headers)
            elif method_type.lower() == 'delete':
                # DELETE requests use params for query parameters (for bulk delete)
                response = request_func(url, params=payload if payload else None, headers=self.headers)
            else:
                # POST, PUT, etc. requests use the json parameter for the request body
                response = request_func(url, json=payload, headers=self.headers)

            response.raise_for_status()
            
            return response.json()
        except requests.exceptions.RequestException:
            return None
