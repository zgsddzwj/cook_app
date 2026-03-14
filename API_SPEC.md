# SnapCook Backend API Specification

## Base URL
```
Development: http://localhost:8000
Production: https://api.snapcook.app
```

## Authentication
All API requests require an API key in the header:
```http
X-API-Key: your_api_key_here
```

---

## API Endpoints

### 1. Health Check
**GET** `/health`

Check if the server is running.

**Response:**
```json
{
  "status": "ok",
  "version": "1.0.0",
  "timestamp": "2025-03-14T10:30:00Z"
}
```

---

### 2. Ingredient Recognition
**POST** `/api/v1/ingredients/recognize`

Recognize ingredients from uploaded images using OpenAI Vision.

**Request:**
```http
Content-Type: multipart/form-data
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `images` | File[] | Yes | 1-9 images of ingredients (JPEG/PNG, max 5MB each) |

**Response:**
```json
{
  "success": true,
  "data": {
    "ingredients": [
      {
        "name": "Tomato",
        "amount": "3 pieces",
        "category": "Vegetables",
        "confidence": 0.95
      },
      {
        "name": "Onion",
        "amount": "1 piece",
        "category": "Vegetables",
        "confidence": 0.92
      }
    ],
    "processing_time": 2.34
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_IMAGE",
    "message": "Image format not supported or file too large"
  }
}
```

---

### 3. Recipe Generation
**POST** `/api/v1/recipes/generate`

Generate recipes based on available ingredients and preferences.

**Request Body:**
```json
{
  "ingredients": [
    {"name": "Tomato", "amount": "3 pieces"},
    {"name": "Onion", "amount": "1 piece"},
    {"name": "Chicken", "amount": "500g"}
  ],
  "preferences": {
    "time": "30-60 min",
    "flavor": "Spicy",
    "equipment": "Pan",
    "servings": 2
  },
  "language": "en"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "recipes": [
      {
        "id": "recipe_001",
        "title": "Spicy Chicken Stir-Fry",
        "description": "A quick and flavorful chicken dish with fresh vegetables",
        "time": "35 min",
        "calories": "450 kcal",
        "servings": 2,
        "tags": ["Spicy", "Quick", "High Protein"],
        "ingredients": [
          {"name": "Chicken", "amount": "300g"},
          {"name": "Tomato", "amount": "2 pieces"},
          {"name": "Onion", "amount": "1 piece"}
        ],
        "steps": [
          "Cut chicken into bite-sized pieces",
          "Heat oil in a pan over medium-high heat",
          "Stir-fry chicken for 5 minutes",
          "Add vegetables and cook for another 5 minutes"
        ]
      }
    ],
    "generated_at": "2025-03-14T10:30:00Z"
  }
}
```

---

### 4. App Version Check
**GET** `/api/v1/app/version`

Check for app updates (used by the update dialog).

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `platform` | string | Yes | `ios` or `android` |
| `version` | string | Yes | Current app version (e.g., "1.0.0") |

**Response:**
```json
{
  "success": true,
  "data": {
    "latest_version": "1.1.0",
    "build_number": 2,
    "force_update": false,
    "update_url": "https://apps.apple.com/app/snapcook",
    "title": "New Version Available",
    "message": "Version 1.1.0 brings new features and improvements!",
    "release_notes": "- Improved AI recognition\n- Bug fixes"
  }
}
```

---

### 5. Get Popular Recipes
**GET** `/api/v1/recipes/popular`

Get trending/popular recipes.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | int | No | Number of recipes (default: 10, max: 50) |
| `category` | string | No | Filter by category: `breakfast`, `lunch`, `dinner`, `dessert` |

**Response:**
```json
{
  "success": true,
  "data": {
    "recipes": [
      {
        "id": "recipe_001",
        "title": "Classic Spaghetti Carbonara",
        "image_url": "https://...",
        "time": "25 min",
        "calories": "550 kcal",
        "tags": ["Italian", "Dinner", "Pasta"],
        "rating": 4.8,
        "view_count": 15234
      }
    ],
    "total": 100
  }
}
```

---

### 6. Recipe Feedback
**POST** `/api/v1/recipes/{recipe_id}/feedback`

Submit user feedback on generated recipes.

**Request Body:**
```json
{
  "rating": 5,
  "comment": "Delicious and easy to make!",
  "user_id": "user_123",
  "device_id": "device_abc123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Feedback submitted successfully"
}
```

---

### 7. Analytics Events
**POST** `/api/v1/analytics/events`

Track user actions (optional, for improving the app).

**Request Body:**
```json
{
  "event_name": "ingredient_recognized",
  "user_id": "user_123",
  "device_id": "device_abc123",
  "timestamp": "2025-03-14T10:30:00Z",
  "properties": {
    "ingredient_count": 5,
    "processing_time": 2.3
  }
}
```

**Response:**
```json
{
  "success": true
}
```

---

## Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `INVALID_API_KEY` | 401 | API key is missing or invalid |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INVALID_IMAGE` | 400 | Image format not supported or too large |
| `AI_SERVICE_ERROR` | 503 | OpenAI service temporarily unavailable |
| `INTERNAL_ERROR` | 500 | Internal server error |

---

## Rate Limits

| Endpoint | Limit |
|----------|-------|
| `/health` | 100/minute |
| `/api/v1/ingredients/recognize` | 10/minute |
| `/api/v1/recipes/generate` | 10/minute |
| Other endpoints | 60/minute |

---

## Data Models

### Ingredient
```json
{
  "name": "string",
  "amount": "string",
  "category": "string (Vegetables|Meat|Dairy|Fruits|Seasoning|Other)",
  "confidence": "float (0-1)"
}
```

### Recipe
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "time": "string",
  "calories": "string",
  "servings": "int",
  "tags": ["string"],
  "ingredients": [Ingredient],
  "steps": ["string"]
}
```
