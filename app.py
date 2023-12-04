from flask import Flask, request, jsonify
from flask_cors import CORS  # 추가
import numpy as np
from tensorflow.keras.models import load_model
import json

app = Flask(__name__)
CORS(app)  # 추가
model = load_model("model.h5")  # 'model.h5'는 실제 모델 파일 경로

@app.route('/predict', methods=['POST'])
def predict():
    data = json.loads(request.data)  # JSON 데이터를 딕셔너리로 변환
    prediction = model.predict([[float(data['kcal']), float(data['protein']), float(data['fat']), float(data['carbohydrate'])]])
    result = prediction[0][0]
    return jsonify({'prediction': str(result)})  # 결과를 JSON 형식으로 변환하여 전송

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
