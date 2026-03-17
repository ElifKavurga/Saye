# Frontend Entegrasyon Notu

Emine'nin teslim noktasi hazir:

- `POST /api/reports`
- `POST /emergency/start`

Swagger arayuzu:

- `GET /swagger-ui/index.html`
- OpenAPI JSON: `GET /v3/api-docs`

Frontend tarafinda kullanilacak temel akışlar:

## 1. Durum Bildir

Endpoint: `POST /api/reports`

Ornek request:

```json
{
  "userId": 30,
  "category": "SUC",
  "description": "Parkta supheli bir durum var",
  "latitude": 41.0082,
  "longitude": 28.9784
}
```

Beklenen davranis:

- `200 OK`
- `data.id` doner
- `data.status` ilk olusumda `PENDING` olur

## 2. Acil Durum Baslat

Endpoint: `POST /emergency/start`

Ornek request:

```json
{
  "userId": 42,
  "latitude": 41.0082,
  "longitude": 28.9784,
  "sharedTo": ["905551112233", "905441112233"]
}
```

Beklenen davranis:

- `200 OK`
- `data.active = true`
- `data.id` acil durum event id'sidir
- `sharedTo` doluysa notification log olusur

## Notlar

- Report path'i projede `/api/reports` olarak tanimli. Frontend `POST /reports` yerine bunu cagirmali.
- Acil durum ekrani aktif durumu kontrol etmek icin `GET /emergency/status?userId=42` endpointini kullanabilir.
