# Saye - Proaktif Güvenlik ve Risk Uyarı Sistemi 

Saye, bireylerin günlük yaşamda karşılaşabileceği güvenlik risklerini (fiziksel ve psikolojik) olay yaşanmadan önce tespit eden ve kullanıcıyı uyaran yenilikçi bir mobil uygulamadır. Klasik panik butonlarının aksine proaktif bir yaklaşım sunarak, harita üzerindeki riskli bölgeleri analiz eder.

> 📸 *Proje arayüzüne ait fotoğraflar ve ekran görüntüleri yakında eklenecektir.*

## 🌟 Temel Özellikler
* **Proaktif Risk Haritası:** Kullanıcının anlık konumuna göre belirli bir yarıçaptaki (örn. 1 km) aydınlatma yetersizliği, asayiş sorunları veya sahipsiz hayvan gibi ihbarları analiz ederek bölgenin risk seviyesini (Düşük, Orta, Yüksek) hesaplar.
* **Akıllı İhbar Sistemi:** Kullanıcılar bulundukları bölgedeki olumsuz durumları harita üzerinden anlık olarak sisteme bildirebilir.
* **Tek Tıkla SOS (Acil Durum):** Acil durumlarda tek bir dokunuşla önceden belirlenen güvenli kişilere canlı konum gönderilir ve yardım istenir.
* **Takip Algılama (Yakında):** Bluetooth sinyalleri üzerinden uzun süreli aynı cihaz yakınlığını tespit ederek olası "takip edilme" durumlarında kullanıcıyı uyarır.

## 🚀 İşleyiş (Nasıl Çalışır?)
1. **Veri Toplama:** Mobil uygulama (Frontend), kullanıcının konum (GPS) verilerini anlık olarak sunucuya (Backend) iletir.
2. **Coğrafi Analiz (Spatial Query):** Backend, PostGIS yeteneklerini kullanarak kullanıcının etrafındaki güncel ihbarları tarar. Olayların uzaklığına ve kategorisine göre özel bir algoritmada risk puanı üretilir.
3. **Dinamik Arayüz:** Çıkan risk puanı uygulamaya iletilir. Eğer kullanıcı riskli bir bölgeye giriyorsa uygulama arayüzü renk değiştirerek uyarı verir ve gerekirse kullanıcıdan riskli bölgeye giriş için onay ister.

## 💻 Kullanılan Teknolojiler
Projemiz, modern ve ölçeklenebilir bir mimari ile geliştirilmiştir:

**Frontend (Mobil):**
* Flutter (Dart)
* Provider / ChangeNotifier (State Management)
* Secure Storage (Token Yönetimi)

**Backend:**
* Java 17 & Spring Boot 3.x
* Katmanlı Mimari (Controller, Service, Repository)
* Spring Security & JWT (Kimlik Doğrulama)

**Veritabanı:**
* PostgreSQL
* PostGIS (Coğrafi Veri İşleme ve Mesafe Hesaplamaları)
* Hibernate Spatial

## 🛠️ Kurulum ve Çalıştırma

**Backend:**
1. Bilgisayarınızda PostgreSQL ve PostGIS kurulu olmalıdır.
2. `saye_db` adında boş bir veritabanı oluşturun.
3. Spring Boot projesini çalıştırdığınızda tablo yapıları ve `CREATE EXTENSION postgis;` komutu otomatik çalışacaktır.

**Frontend:**
1. `lib/services/api_service.dart` içerisindeki IP adresini kendi ortamınıza göre yapılandırın (Emülatör için `10.0.2.2`).
2. `flutter pub get` ile bağımlılıkları indirin.
3. `flutter run` komutu ile uygulamayı başlatın.

## Hızlı Hata Ayıklama

1. Backend çalışıyor mu kontrol et: `http://localhost:8080/health` endpointini aç.
2. DB bağlantısı için kontrol et: `http://localhost:8080/health/db` endpointi
3. Emülatör kullanıyorsan base URL `http://10.0.2.2:8080` olmalı.
4. Android sürümü (ör. 8.x) tek başına çoğu zaman sebep olmaz, yanlış URL/port veya backend-db bağlantısı daha olasıdır.
