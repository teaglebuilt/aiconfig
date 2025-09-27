import json
import os
import sys
from datetime import datetime
from pathlib import Path


def get_session_id(input_data):
    """Get the current session ID from input data or fallback"""
    # Try to get session_id from the input data first
    session_id = input_data.get('session_id')
    if session_id:
        return session_id

    # Fallback to environment variable
    session_id = os.environ.get('CLAUDE_SESSION_ID')
    if session_id and session_id != 'unknown':
        return session_id

    # Use "unknown" for missing session ID
    return "unknown"


def get_context_bundle_dir():
    """Get or create the context_bundles directory"""
    context_dir = Path.cwd() / ".claude" / "context_bundles"
    context_dir.mkdir(parents=True, exist_ok=True)
    return context_dir


def generate_bundle_filename(input_data):
    """Generate filename with date prefix and session ID"""
    session_id = get_session_id(input_data)

    # Add date prefix for clarity (e.g., 16_sep_session_abc123.json)
    now = datetime.now()
    date_prefix = now.strftime("%d_%b").lower()

    filename = f"{date_prefix}_session_{session_id}.json"
    return filename


def load_or_create_bundle(input_data):
    """Load existing bundle or create new one"""
    context_dir = get_context_bundle_dir()
    filename = generate_bundle_filename(input_data)
    bundle_path = context_dir / filename

    if bundle_path.exists():
        try:
            with open(bundle_path, 'r', encoding='utf-8') as f:
                return json.load(f), bundle_path
        except:
            pass

    # Create new bundle
    bundle = {
        "session_id": get_session_id(input_data),
        "created_at": datetime.now().isoformat(),
        "operations": []
    }
    return bundle, bundle_path


def save_bundle(bundle, bundle_path):
    """Save bundle to file"""
    try:
        with open(bundle_path, 'w', encoding='utf-8') as f:
            json.dump(bundle, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"Error saving context bundle: {e}", file=sys.stderr)

def record_operation():
    """Record the current operation to context bundle"""
    try:
        # Read input from stdin
        input_data = json.loads(sys.stdin.read())

        # Extract operation details
        operation_type = "unknown"
        tool_details = {}

        # Determine operation type from tool name
        tool_name = input_data.get('tool_name', '')
        tool_input = input_data.get('tool_input', {})

        if tool_name:
            operation_type = tool_name.lower()

            # Extract relevant details based on tool type
            if tool_name in ['Read', 'Edit', 'Write', 'MultiEdit']:
                if 'file_path' in tool_input:
                    tool_details['file_path'] = tool_input['file_path']
                if tool_name in ['Edit', 'MultiEdit'] and 'old_string' in tool_input:
                    tool_details['old_string'] = tool_input['old_string'][:100] + "..." if len(tool_input['old_string']) > 100 else tool_input['old_string']
                if tool_name in ['Write', 'Edit', 'MultiEdit'] and 'content' in tool_input:
                    content = tool_input.get('content', '')
                    tool_details['content_length'] = len(content)
                if tool_name == 'MultiEdit' and 'edits' in tool_input:
                    tool_details['edit_count'] = len(tool_input['edits'])

            elif tool_name == 'Bash':
                if 'command' in tool_input:
                    tool_details['command'] = tool_input['command']
                if 'description' in tool_input:
                    tool_details['description'] = tool_input['description']

            elif tool_name == 'Task':
                if 'subagent_type' in tool_input:
                    tool_details['subagent_type'] = tool_input['subagent_type']
                if 'prompt' in tool_input:
                    prompt = tool_input['prompt']
                    tool_details['prompt'] = prompt[:100] + "..." if len(prompt) > 100 else prompt

            elif tool_name == 'Glob':
                if 'pattern' in tool_input:
                    tool_details['pattern'] = tool_input['pattern']
                if 'path' in tool_input:
                    tool_details['path'] = tool_input['path']

            elif tool_name == 'Grep':
                if 'pattern' in tool_input:
                    tool_details['pattern'] = tool_input['pattern']
                if 'path' in tool_input:
                    tool_details['path'] = tool_input['path']
                if 'output_mode' in tool_input:
                    tool_details['output_mode'] = tool_input['output_mode']

            elif tool_name == 'WebFetch':
                if 'url' in tool_input:
                    tool_details['url'] = tool_input['url']
                if 'prompt' in tool_input:
                    prompt = tool_input['prompt']
                    tool_details['prompt'] = prompt[:100] + "..." if len(prompt) > 100 else prompt

            elif tool_name == 'WebSearch':
                if 'query' in tool_input:
                    tool_details['query'] = tool_input['query']

            elif tool_name == 'TodoWrite':
                if 'todos' in tool_input:
                    tool_details['todo_count'] = len(tool_input['todos'])

            # Generic fallback for any other parameters
            else:
                # Add up to 3 most relevant parameters for unknown tools
                for key, value in list(tool_input.items())[:3]:
                    if isinstance(value, (str, int, float, bool)):
                        tool_details[key] = str(value)[:100] + "..." if len(str(value)) > 100 else value

        elif 'prompt' in input_data:
            operation_type = "prompt"
            prompt = input_data['prompt']
            tool_details['prompt'] = prompt[:100] + "..." if len(prompt) > 100 else prompt

        # Load/create bundle
        bundle, bundle_path = load_or_create_bundle(input_data)

        # Create operation record
        operation = {
            "operation": operation_type,
            "timestamp": datetime.now().isoformat(),
        }

        # Add all tool details to the operation
        operation.update(tool_details)

        # Add to bundle
        bundle["operations"].append(operation)
        bundle["last_updated"] = datetime.now().isoformat()

        # Save bundle
        save_bundle(bundle, bundle_path)

        # Output for debugging (optional)
        if operation_type == "task" and "subagent_type" in tool_details:
            print(f"Subagent invoked: {tool_details['subagent_type']} | Bundle: {bundle_path.name}", file=sys.stderr)
        else:
            print(f"Context bundle updated: {bundle_path.name}", file=sys.stderr)

    except Exception as e:
        print(f"Error in context_bundle_builder: {e}", file=sys.stderr)



if __name__ == "__main__":
    print("Context bundle builder started", file=sys.stderr)
    record_operation()
    sys.exit(0)
