#!/usr/bin/env python3
"""
Godot MCP Server

This MCP server provides tools for creating and manipulating Godot games
through the Model Context Protocol.
"""

import asyncio
import json
from typing import Any, Sequence
import httpx
from mcp.server import Server
from mcp.types import (
    Tool,
    TextContent,
    ImageContent,
    EmbeddedResource,
)
import mcp.server.stdio


# Godot Bridge Server configuration
BRIDGE_HOST = "http://127.0.0.1:8765"
REQUEST_TIMEOUT = 30.0


class GodotClient:
    """HTTP client for communicating with Godot Bridge Server"""

    def __init__(self, base_url: str):
        self.base_url = base_url
        self.client = httpx.AsyncClient(timeout=REQUEST_TIMEOUT)

    async def request(self, endpoint: str, data: dict = None) -> dict:
        """Make a request to the Godot Bridge Server"""
        url = f"{self.base_url}{endpoint}"

        try:
            if data:
                response = await self.client.post(url, json=data)
            else:
                response = await self.client.get(url)

            response.raise_for_status()
            return response.json()

        except httpx.HTTPError as e:
            return {
                "status": "error",
                "error": f"HTTP error: {str(e)}",
                "code": 500
            }
        except Exception as e:
            return {
                "status": "error",
                "error": f"Unexpected error: {str(e)}",
                "code": 500
            }

    async def close(self):
        """Close the HTTP client"""
        await self.client.aclose()


# Initialize MCP server and Godot client
app = Server("godot-mcp-server")
godot = GodotClient(BRIDGE_HOST)


@app.list_tools()
async def list_tools() -> list[Tool]:
    """List all available tools"""
    return [
        # Scene Management Tools
        Tool(
            name="create_scene",
            description="Create a new empty Godot scene (2D or 3D)",
            inputSchema={
                "type": "object",
                "properties": {
                    "scene_name": {
                        "type": "string",
                        "description": "Name of the scene"
                    },
                    "scene_type": {
                        "type": "string",
                        "enum": ["2D", "3D"],
                        "description": "Type of scene to create",
                        "default": "2D"
                    }
                },
                "required": ["scene_name"]
            }
        ),
        Tool(
            name="load_scene",
            description="Load an existing Godot scene from file",
            inputSchema={
                "type": "object",
                "properties": {
                    "scene_path": {
                        "type": "string",
                        "description": "Path to the scene file (e.g., res://scenes/main.tscn)"
                    }
                },
                "required": ["scene_path"]
            }
        ),
        Tool(
            name="save_scene",
            description="Save the current scene to a file",
            inputSchema={
                "type": "object",
                "properties": {
                    "scene_path": {
                        "type": "string",
                        "description": "Path where to save the scene (optional, uses current if not specified)"
                    }
                }
            }
        ),
        Tool(
            name="get_scene_tree",
            description="Get the current scene tree structure with all nodes",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),

        # Node Management Tools
        Tool(
            name="create_node",
            description="Create a new node in the scene",
            inputSchema={
                "type": "object",
                "properties": {
                    "node_type": {
                        "type": "string",
                        "description": "Type of node to create (e.g., Node2D, Sprite2D, CharacterBody2D, Node3D, MeshInstance3D, etc.)"
                    },
                    "node_name": {
                        "type": "string",
                        "description": "Name for the new node"
                    },
                    "parent_path": {
                        "type": "string",
                        "description": "Path to parent node (optional, defaults to scene root)"
                    }
                },
                "required": ["node_type", "node_name"]
            }
        ),
        Tool(
            name="delete_node",
            description="Delete a node from the scene",
            inputSchema={
                "type": "object",
                "properties": {
                    "node_path": {
                        "type": "string",
                        "description": "Path to the node to delete"
                    }
                },
                "required": ["node_path"]
            }
        ),
        Tool(
            name="set_node_property",
            description="Set a property on a node",
            inputSchema={
                "type": "object",
                "properties": {
                    "node_path": {
                        "type": "string",
                        "description": "Path to the node"
                    },
                    "property": {
                        "type": "string",
                        "description": "Name of the property to set"
                    },
                    "value": {
                        "description": "Value to set (can be any type)"
                    }
                },
                "required": ["node_path", "property", "value"]
            }
        ),
        Tool(
            name="get_node_property",
            description="Get a property value from a node",
            inputSchema={
                "type": "object",
                "properties": {
                    "node_path": {
                        "type": "string",
                        "description": "Path to the node"
                    },
                    "property": {
                        "type": "string",
                        "description": "Name of the property to get"
                    }
                },
                "required": ["node_path", "property"]
            }
        ),
        Tool(
            name="move_node",
            description="Move a node to a new parent",
            inputSchema={
                "type": "object",
                "properties": {
                    "node_path": {
                        "type": "string",
                        "description": "Path to the node to move"
                    },
                    "new_parent": {
                        "type": "string",
                        "description": "Path to the new parent node"
                    }
                },
                "required": ["node_path", "new_parent"]
            }
        ),
        Tool(
            name="set_node_transform",
            description="Set node's transform (position, rotation, scale)",
            inputSchema={
                "type": "object",
                "properties": {
                    "node_path": {
                        "type": "string",
                        "description": "Path to the node"
                    },
                    "position": {
                        "description": "Position as {x, y} for 2D or {x, y, z} for 3D"
                    },
                    "rotation": {
                        "description": "Rotation (float for 2D, {x, y, z} for 3D)"
                    },
                    "scale": {
                        "description": "Scale as {x, y} for 2D or {x, y, z} for 3D"
                    }
                },
                "required": ["node_path"]
            }
        ),
        Tool(
            name="list_available_nodes",
            description="List all available node types in Godot",
            inputSchema={
                "type": "object",
                "properties": {
                    "filter": {
                        "type": "string",
                        "enum": ["", "2D", "3D", "Control"],
                        "description": "Filter by node category (optional)"
                    }
                }
            }
        ),

        # Script Management Tools
        Tool(
            name="create_script",
            description="Create a new GDScript file",
            inputSchema={
                "type": "object",
                "properties": {
                    "script_path": {
                        "type": "string",
                        "description": "Path for the script file (e.g., res://scripts/player.gd)"
                    },
                    "script_content": {
                        "type": "string",
                        "description": "GDScript code content"
                    },
                    "template": {
                        "type": "string",
                        "enum": ["", "node", "node2d", "node3d", "characterbody2d", "characterbody3d", "rigidbody2d", "rigidbody3d", "resource"],
                        "description": "Template to use (optional)"
                    }
                },
                "required": ["script_path"]
            }
        ),
        Tool(
            name="attach_script",
            description="Attach a script to a node",
            inputSchema={
                "type": "object",
                "properties": {
                    "node_path": {
                        "type": "string",
                        "description": "Path to the node"
                    },
                    "script_path": {
                        "type": "string",
                        "description": "Path to the script file"
                    }
                },
                "required": ["node_path", "script_path"]
            }
        ),
        Tool(
            name="update_script",
            description="Update an existing script file",
            inputSchema={
                "type": "object",
                "properties": {
                    "script_path": {
                        "type": "string",
                        "description": "Path to the script file"
                    },
                    "script_content": {
                        "type": "string",
                        "description": "New GDScript code content"
                    }
                },
                "required": ["script_path", "script_content"]
            }
        ),

        # CSG Tools (3D)
        Tool(
            name="create_csg_shape",
            description="Create a CSG (Constructive Solid Geometry) shape for 3D modeling",
            inputSchema={
                "type": "object",
                "properties": {
                    "shape_type": {
                        "type": "string",
                        "enum": ["box", "sphere", "cylinder", "torus", "polygon", "mesh", "combiner"],
                        "description": "Type of CSG shape"
                    },
                    "properties": {
                        "type": "object",
                        "description": "Shape-specific properties (size, radius, position, material, etc.)"
                    },
                    "parent_path": {
                        "type": "string",
                        "description": "Path to parent node (optional)"
                    }
                },
                "required": ["shape_type"]
            }
        ),
        Tool(
            name="set_csg_operation",
            description="Set the CSG boolean operation (union, intersection, subtraction)",
            inputSchema={
                "type": "object",
                "properties": {
                    "node_path": {
                        "type": "string",
                        "description": "Path to the CSG node"
                    },
                    "operation": {
                        "type": "string",
                        "enum": ["union", "intersection", "subtraction"],
                        "description": "CSG operation type"
                    }
                },
                "required": ["node_path", "operation"]
            }
        ),

        # Game Execution Tools
        Tool(
            name="run_scene",
            description="Run a scene in play mode",
            inputSchema={
                "type": "object",
                "properties": {
                    "scene_path": {
                        "type": "string",
                        "description": "Path to scene to run (optional, runs current scene if not specified)"
                    }
                }
            }
        ),
        Tool(
            name="stop_scene",
            description="Stop the currently running scene",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),
        Tool(
            name="send_input",
            description="Send input events to the running game",
            inputSchema={
                "type": "object",
                "properties": {
                    "input_type": {
                        "type": "string",
                        "enum": ["key", "mouse_button", "mouse_motion", "action"],
                        "description": "Type of input event"
                    },
                    "input_data": {
                        "type": "object",
                        "description": "Input-specific data (key code, mouse position, etc.)"
                    }
                },
                "required": ["input_type", "input_data"]
            }
        ),

        # Capture Tools
        Tool(
            name="capture_screenshot",
            description="Capture a screenshot of the current game viewport",
            inputSchema={
                "type": "object",
                "properties": {
                    "output_path": {
                        "type": "string",
                        "description": "Path to save screenshot (optional)"
                    },
                    "return_base64": {
                        "type": "boolean",
                        "description": "Return image as base64 (default: true)",
                        "default": True
                    }
                }
            }
        ),
    ]


@app.call_tool()
async def call_tool(name: str, arguments: Any) -> Sequence[TextContent | ImageContent | EmbeddedResource]:
    """Handle tool calls"""

    # Map tool names to Godot Bridge endpoints
    endpoint_map = {
        "create_scene": "/scene/create",
        "load_scene": "/scene/load",
        "save_scene": "/scene/save",
        "get_scene_tree": "/scene/tree",
        "create_node": "/node/create",
        "delete_node": "/node/delete",
        "set_node_property": "/node/property/set",
        "get_node_property": "/node/property/get",
        "move_node": "/node/move",
        "set_node_transform": "/node/transform",
        "list_available_nodes": "/resource/nodes",
        "create_script": "/script/create",
        "attach_script": "/script/attach",
        "update_script": "/script/update",
        "create_csg_shape": "/csg/create",
        "set_csg_operation": "/csg/operation",
        "run_scene": "/game/run",
        "stop_scene": "/game/stop",
        "send_input": "/game/input",
        "capture_screenshot": "/capture/screenshot",
    }

    if name not in endpoint_map:
        return [TextContent(
            type="text",
            text=f"Unknown tool: {name}"
        )]

    endpoint = endpoint_map[name]

    # Make request to Godot Bridge
    result = await godot.request(endpoint, arguments if arguments else {})

    # Format response
    if result.get("status") == "success":
        # Handle screenshot with base64 image
        if name == "capture_screenshot" and "base64" in result:
            base64_data = result.pop("base64")
            return [
                TextContent(
                    type="text",
                    text=json.dumps(result, indent=2)
                ),
                ImageContent(
                    type="image",
                    data=base64_data,
                    mimeType="image/png"
                )
            ]

        # Regular text response
        return [TextContent(
            type="text",
            text=json.dumps(result, indent=2)
        )]
    else:
        # Error response
        error_msg = result.get("error", "Unknown error")
        return [TextContent(
            type="text",
            text=f"Error: {error_msg}\n\nDetails:\n{json.dumps(result, indent=2)}"
        )]


async def main():
    """Run the MCP server"""
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )


if __name__ == "__main__":
    asyncio.run(main())
