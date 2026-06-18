Harici telefondan çalıştırmak ve yüklemek için
cmd ekranını ilk olarak çalışan projede aç ve 

--------
adb devices 
--------

gir çıkan seçeneklerden biri telefon 

--------
adb reverse tcp:5000 tcp:5000 muhtemelen senin telefonun
--------

bu koduda gir hiç birşey olmayacak köprü kuruldu ve daha sonra 

jupyter terminalden 
----------------
cd "C:\Users\90537\OneDrive\Desktop\bitkilerde-hastalık-tespiti" -- Yol nerede ise oraya kopyala bilgisayarında farklı ise öyle yap
----------------

daha sonrada 
------------------------
python app.py  yaz ve çıktı aşağıdaki gibi ise doğru yoldasın
---------------- 

2026-05-19 14:05:32.286024: I tensorflow/core/util/port.cc:153] oneDNN custom operations are on. You may see slightly different numerical results due to floating-point round-off errors from different computation orders. To turn them off, set the environment variable `TF_ENABLE_ONEDNN_OPTS=0`.
2026-05-19 14:05:35.656830: I tensorflow/core/util/port.cc:153] oneDNN custom operations are on. You may see slightly different numerical results due to floating-point round-off errors from different computation orders. To turn them off, set the environment variable `TF_ENABLE_ONEDNN_OPTS=0`.
2026-05-19 14:05:46.436527: I tensorflow/core/platform/cpu_feature_guard.cc:210] This TensorFlow binary is optimized to use available CPU instructions in performance-critical operations.
To enable the following instructions: AVX2 AVX512F AVX512_VNNI FMA, in other operations, rebuild TensorFlow with the appropriate compiler flags.
 * Serving Flask app 'app'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://192.168.1.103:5000
Press CTRL+C to quit
 * Restarting with watchdog (windowsapi)
2026-05-19 14:05:50.482539: I tensorflow/core/util/port.cc:153] oneDNN custom operations are on. You may see slightly different numerical results due to floating-point round-off errors from different computation orders. To turn them off, set the environment variable `TF_ENABLE_ONEDNN_OPTS=0`.
2026-05-19 14:05:55.577324: I tensorflow/core/util/port.cc:153] oneDNN custom operations are on. You may see slightly different numerical results due to floating-point round-off errors from different computation orders. To turn them off, set the environment variable `TF_ENABLE_ONEDNN_OPTS=0`.
2026-05-19 14:06:06.081435: I tensorflow/core/platform/cpu_feature_guard.cc:210] This TensorFlow binary is optimized to use available CPU instructions in performance-critical operations.
To enable the following instructions: AVX2 AVX512F AVX512_VNNI FMA, in other operations, rebuild TensorFlow with the appropriate compiler flags.
 * Debugger is active!
 * Debugger PIN: 146-497-649 bu yazılar çıkacak iş tamamdır çalışır. 
