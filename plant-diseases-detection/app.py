from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
from PIL import Image
import io

app = Flask(__name__)

# Modelini yüklüyoruz
model = tf.keras.models.load_model('bitkilerde-hastalık-tespiti.keras') # Kendi model ismin neyse o kalacak

# Modelin orijinal İngilizce sınıfları (Sırası çok önemli, bozma)
siniflar = [
    'Apple___Apple_scab', 'Apple___Black_rot', 'Apple___Cedar_apple_rust', 'Apple___healthy', 
    'Blueberry___healthy', 'Cherry_(including_sour)___Powdery_mildew', 'Cherry_(including_sour)___healthy', 
    'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot', 'Corn_(maize)___Common_rust_', 
    'Corn_(maize)___Northern_Leaf_Blight', 'Corn_(maize)___healthy', 'Grape___Black_rot', 
    'Grape___Esca_(Black_Measles)', 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)', 'Grape___healthy', 
    'Orange___Haunglongbing_(Citrus_greening)', 'Peach___Bacterial_spot', 'Peach___healthy', 
    'Pepper,_bell___Bacterial_spot', 'Pepper,_bell___healthy', 'Potato___Early_blight', 
    'Potato___Late_blight', 'Potato___healthy', 'Raspberry___healthy', 'Soybean___healthy', 
    'Squash___Powdery_mildew', 'Strawberry___Leaf_scorch', 'Strawberry___healthy', 
    'Tomato___Bacterial_spot', 'Tomato___Early_blight', 'Tomato___Late_blight', 'Tomato___Leaf_Mold', 
    'Tomato___Septoria_leaf_spot', 'Tomato___Spider_mites Two-spotted_spider_mite', 'Tomato___Target_Spot', 
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus', 'Tomato___Tomato_mosaic_virus', 'Tomato___healthy'
]

# YENİ EKLENEN KISIM: İngilizce -> Türkçe Sözlüğü
ceviriler = {
    'Apple___Apple_scab': 'Elma - Karaleke Hastalığı',
    'Apple___Black_rot': 'Elma - Kara Çürüklük',
    'Apple___Cedar_apple_rust': 'Elma - Sedir Pası',
    'Apple___healthy': 'Elma - Sağlıklı',
    'Blueberry___healthy': 'Yaban Mersini - Sağlıklı',
    'Cherry_(including_sour)___Powdery_mildew': 'Kiraz - Külleme Hastalığı',
    'Cherry_(including_sour)___healthy': 'Kiraz - Sağlıklı',
    'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot': 'Mısır - Gri Yaprak Lekesi',
    'Corn_(maize)___Common_rust_': 'Mısır - Pas Hastalığı',
    'Corn_(maize)___Northern_Leaf_Blight': 'Mısır - Kuzey Yaprak Yanıklığı',
    'Corn_(maize)___healthy': 'Mısır - Sağlıklı',
    'Grape___Black_rot': 'Üzüm - Kara Çürüklük',
    'Grape___Esca_(Black_Measles)': 'Üzüm - Esca (Siyah Kızamık)',
    'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)': 'Üzüm - Yaprak Yanıklığı',
    'Grape___healthy': 'Üzüm - Sağlıklı',
    'Orange___Haunglongbing_(Citrus_greening)': 'Portakal - Narenciye Yeşillenme Hastalığı',
    'Peach___Bacterial_spot': 'Şeftali - Bakteriyel Leke',
    'Peach___healthy': 'Şeftali - Sağlıklı',
    'Pepper,_bell___Bacterial_spot': 'Dolmalık Biber - Bakteriyel Leke',
    'Pepper,_bell___healthy': 'Dolmalık Biber - Sağlıklı',
    'Potato___Early_blight': 'Patates - Erken Yanıklık',
    'Potato___Late_blight': 'Patates - Geç Yanıklık',
    'Potato___healthy': 'Patates - Sağlıklı',
    'Raspberry___healthy': 'Ahududu - Sağlıklı',
    'Soybean___healthy': 'Soya Fasulyesi - Sağlıklı',
    'Squash___Powdery_mildew': 'Kabak - Külleme Hastalığı',
    'Strawberry___Leaf_scorch': 'Çilek - Yaprak Yanıklığı',
    'Strawberry___healthy': 'Çilek - Sağlıklı',
    'Tomato___Bacterial_spot': 'Domates - Bakteriyel Leke',
    'Tomato___Early_blight': 'Domates - Erken Yanıklık',
    'Tomato___Late_blight': 'Domates - Geç Yanıklık',
    'Tomato___Leaf_Mold': 'Domates - Yaprak Küfü',
    'Tomato___Septoria_leaf_spot': 'Domates - Septoria Yaprak Lekesi',  
    'Tomato___Spider_mites Two-spotted_spider_mite': 'Domates - Kırmızı Örümcek',
    'Tomato___Target_Spot': 'Domates - Hedef Lekesi',
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus': 'Domates - Sarı Yaprak Kıvırcıklık Virüsü',
    'Tomato___Tomato_mosaic_virus': 'Domates - Mozaik Virüsü',
    'Tomato___healthy': 'Domates - Sağlıklı'
}

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'hata': 'Dosya bulunamadı'}), 400

    file = request.files['file']
    image = Image.open(io.BytesIO(file.read())).convert('RGB')
    image = image.resize((128, 128)) 
    
    image_arr = tf.keras.preprocessing.image.img_to_array(image)
    image_arr = np.expand_dims(image_arr, axis=0)
    
    tahminler = model.predict(image_arr)
    en_yuksek_ihtimal_index = np.argmax(tahminler[0])
    guven_skoru = float(tahminler[0][en_yuksek_ihtimal_index])
    
    # Orjinal İngilizce sonucu alıyoruz
    orjinal_sonuc = siniflar[en_yuksek_ihtimal_index]
    
    # İngilizce sonucu sözlükte arayıp Türkçe karşılığını buluyoruz. 
    # (Eğer sözlükte yoksa güvenlik amaçlı İngilizcesini döndürür)
    turkce_sonuc = ceviriler.get(orjinal_sonuc, orjinal_sonuc)

    # API'den artık Türkçe sonucu gönderiyoruz
    return jsonify({
        'hastalik': turkce_sonuc,
        'guven_skoru': round(guven_skoru * 100, 2)
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)