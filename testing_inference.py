from inference_sdk import InferenceHTTPClient

# Step 1: Connect to your Roboflow workspace
client = InferenceHTTPClient(
    api_url="https://serverless.roboflow.com",
    api_key="f25wkYvbi6pVeecAtE2m"
)

# Step 2: Run your trained model workflow
result = client.run_workflow(
    workspace_name="croply-ai",
    workflow_id="croply-ai-final-2",
    images={
        "image": "C:/Users/lutho/Downloads/leaf.webp"  # path to your test image file
    },
    use_cache=True  # optional, speeds up repeated requests
)

# Step 3: Display the returned inference data
print(result)
