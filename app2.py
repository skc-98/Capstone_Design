from flask import Flask, request, jsonify
from flask_cors import CORS  # 추가
import numpy as np
from tensorflow.keras.models import load_model
import json
from tensorflow.keras.preprocessing import image
import io

app = Flask(__name__)
CORS(app)  # 추가
model = load_model("keras_model.h5")  # 'model.h5'는 실제 모델 파일 경로

@app.route('/predict', methods=['POST'])
def predict():
    file = request.files['file']
    img = image.load_img(io.BytesIO(file.read()), target_size=(224, 224))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    predictions = model.predict(img_array)
    max_index = np.argmax(predictions[0])
    percentages = predictions[0] * 100
    labels = ['음료', '조각 케이크', '탕후루', '음료 + 디저트', '빙수']
    result = {labels[i]: f'{percentages[i]:.2f}%' for i in range(len(labels))}
    return jsonify({'prediction': str(max_index), 'result': result})


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
