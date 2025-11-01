from ultralytics import YOLO

# Load your YOLOv8n PyTorch model
model1 = YOLO('/Users/sonwabise/Croply_AI/croply_ai/assets/models/Pest_Detection_Model.pt')
model2 = YOLO('/Users/sonwabise/Croply_AI/croply_ai/assets/models/Plant_Growth_Stage_Model.pt')
# Export to TFLite
model1.export(format='tflite', int8=True)  # 'int8=True' for quantized model (optional)
model2.export(format='tflite', int8=True)  # 'int8=True' for quantized model (optional)
print("Model conversion to TFLite completed.")