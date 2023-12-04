import pandas as pd
import numpy as np
import tensorflow as tf
import keras

data = pd.read_excel('final.xlsx')

y_data = data['Possibility'].values
x_data = []

for i, rows in data.iterrows():
   x_data.append([rows['kcal'], rows['Protein(g)'], rows['Fat(g)'], rows['Carbohydrate(g)']])

model = tf.keras.models.Sequential([
    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dense(1, activation='sigmoid'),  
])  

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
model.fit(np.array(x_data), np.array(y_data), epochs=100)

# 모델 저장
model.save("model.h5")

# 예측
prediction_data = [[2500.0, 93.0, 66.0, 300.0], [1000.0, 20.0, 30.0, 200.0]]
prediction = model.predict(prediction_data)

print(prediction)
