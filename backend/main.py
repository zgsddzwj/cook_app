"""
SnapCook Backend API
FastAPI + OpenAI integration
Author: Your Name
"""

import os
import time
import uuid
from datetime import datetime
from typing import List, Optional

import httpx
from fastapi import FastAPI, File, Form, HTTPException, UploadFile, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
API_KEY = os.getenv("API_KEY", "dev_key")  # For simple API authentication
OPENAI_BASE_URL = "https://api.openai.com/v1"

if not OPENAI_API_KEY:
    raise ValueError("OPENAI_API_KEY environment variable is required")

# FastAPI app
app = FastAPI(
    title="SnapCook API",
    description="Backend API for SnapCook ingredient recognition and recipe generation",
    version="1.0.0",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==================== Models ====================

class Ingredient(BaseModel):
    name: str
    amount: str
    category: str
    confidence: Optional[float] = None


class Preference(BaseModel):
    time: Optional[str] = "Any"
    flavor: Optional[str] = "Any"
    equipment: Optional[str] = "Any"
    servings: Optional[int] = 2


class Recipe(BaseModel):
    id: str
    title: str
    description: str
    time: str
    calories: str
    servings: int
    tags: List[str]
    ingredients: List[Ingredient]
    steps: List[str]


class RecognizeResponse(BaseModel):
    success: bool
    data: dict


class GenerateRecipeRequest(BaseModel):
    ingredients: List[Ingredient]
    preferences: Preference
    language: Optional[str] = "en"


class VersionCheckResponse(BaseModel):
    latest_version: str
    build_number: int
    force_update: bool
    update_url: str
    title: str
    message: str
    release_notes: str


class FeedbackRequest(BaseModel):
    rating: int
    comment: Optional[str] = None
    user_id: Optional[str] = None
    device_id: Optional[str] = None


class AnalyticsEvent(BaseModel):
    event_name: str
    user_id: Optional[str] = None
    device_id: Optional[str] = None
    timestamp: datetime
    properties: Optional[dict] = {}


# ==================== Helper Functions ====================

async def call_openai_vision(images_base64: List[str]) -> List[Ingredient]:
    """Call OpenAI Vision API to recognize ingredients"""
    
    # Build content with images
    content = []
    for img_base64 in images_base64:
        content.append({
            "type": "image_url",
            "image_url": {
                "url": f"data:image/jpeg;base64,{img_base64}"
            }
        })
    
    content.append({
        "type": "text",
        "text": "Identify all food ingredients in these images. Return as JSON with format: {\"ingredients\": [{\"name\": \"ingredient name\", \"amount\": \"estimated quantity\", \"category\": \"category\"}]}. Categories: Vegetables, Meat, Dairy, Fruits, Seasoning, Other. Be specific with ingredient names."
    })
    
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(
            f"{OPENAI_BASE_URL}/chat/completions",
            headers={
                "Authorization": f"Bearer {OPENAI_API_KEY}",
                "Content-Type": "application/json"
            },
            json={
                "model": "gpt-4o-mini",
                "messages": [
                    {
                        "role": "user",
                        "content": content
                    }
                ],
                "temperature": 0.3,
                "max_tokens": 1000
            }
        )
        
        if response.status_code != 200:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="AI service temporarily unavailable"
            )
        
        result = response.json()
        content_text = result["choices"][0]["message"]["content"]
        
        # Parse JSON from response
        import json
        import re
        
        # Extract JSON from markdown if present
        json_match = re.search(r'```json\n(.*?)\n```', content_text, re.DOTALL)
        if json_match:
            content_text = json_match.group(1)
        
        data = json.loads(content_text)
        ingredients = []
        
        for ing in data.get("ingredients", []):
            ingredients.append(Ingredient(
                name=ing.get("name", ""),
                amount=ing.get("amount", "Unknown"),
                category=ing.get("category", "Other"),
                confidence=0.9  # OpenAI doesn't provide confidence scores
            ))
        
        return ingredients


async def call_openai_recipe(ingredients: List[Ingredient], preferences: Preference) -> Recipe:
    """Call OpenAI to generate recipe"""
    
    ingredients_text = ", ".join([f"{ing.name}({ing.amount})" for ing in ingredients])
    
    prompt = f"""Create a recipe using these ingredients: {ingredients_text}

Preferences:
- Cooking time: {preferences.time}
- Flavor: {preferences.flavor}
- Equipment: {preferences.equipment}
- Servings: {preferences.servings}

Return a JSON object with this exact structure:
{{
  "title": "Recipe name",
  "description": "Brief description",
  "time": "Estimated time like '30 min'",
  "calories": "Estimated calories like '450 kcal'",
  "servings": {preferences.servings},
  "tags": ["tag1", "tag2"],
  "ingredients": [
    {{"name": "ingredient", "amount": "quantity"}}
  ],
  "steps": ["Step 1", "Step 2", "Step 3"]
}}

Make it practical and delicious."""
    
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(
            f"{OPENAI_BASE_URL}/chat/completions",
            headers={
                "Authorization": f"Bearer {OPENAI_API_KEY}",
                "Content-Type": "application/json"
            },
            json={
                "model": "gpt-4o-mini",
                "messages": [
                    {
                        "role": "system",
                        "content": "You are a professional chef. Create practical, delicious recipes. Always return valid JSON."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                "temperature": 0.7,
                "max_tokens": 1500
            }
        )
        
        if response.status_code != 200:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="AI service temporarily unavailable"
            )
        
        result = response.json()
        content_text = result["choices"][0]["message"]["content"]
        
        # Parse JSON
        import json
        import re
        
        json_match = re.search(r'```json\n(.*?)\n```', content_text, re.DOTALL)
        if json_match:
            content_text = json_match.group(1)
        
        data = json.loads(content_text)
        
        # Convert to Recipe model
        recipe_ingredients = [
            Ingredient(
                name=ing.get("name", ""),
                amount=ing.get("amount", ""),
                category="Other"
            )
            for ing in data.get("ingredients", [])
        ]
        
        return Recipe(
            id=f"recipe_{uuid.uuid4().hex[:8]}",
            title=data.get("title", "Untitled Recipe"),
            description=data.get("description", ""),
            time=data.get("time", "Unknown"),
            calories=data.get("calories", "Unknown"),
            servings=data.get("servings", 2),
            tags=data.get("tags", []),
            ingredients=recipe_ingredients,
            steps=data.get("steps", [])
        )


def verify_api_key(api_key: str):
    """Verify API key"""
    if api_key != API_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API key"
        )


# ==================== API Endpoints ====================

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "ok",
        "version": "1.0.0",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.post("/api/v1/ingredients/recognize")
async def recognize_ingredients(
    images: List[UploadFile] = File(...),
    api_key: str = Form(...)
):
    """Recognize ingredients from uploaded images"""
    
    # Verify API key
    verify_api_key(api_key)
    
    # Validate number of images
    if len(images) > 9:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum 9 images allowed"
        )
    
    start_time = time.time()
    
    try:
        # Convert images to base64
        images_base64 = []
        for image in images:
            content = await image.read()
            import base64
            images_base64.append(base64.b64encode(content).decode())
        
        # Call OpenAI
        ingredients = await call_openai_vision(images_base64)
        
        processing_time = round(time.time() - start_time, 2)
        
        return {
            "success": True,
            "data": {
                "ingredients": [ing.dict() for ing in ingredients],
                "processing_time": processing_time
            }
        }
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Recognition failed: {str(e)}"
        )


@app.post("/api/v1/recipes/generate")
async def generate_recipe(request: GenerateRecipeRequest, api_key: str = Form(...)):
    """Generate recipe based on ingredients and preferences"""
    
    verify_api_key(api_key)
    
    try:
        recipe = await call_openai_recipe(request.ingredients, request.preferences)
        
        return {
            "success": True,
            "data": {
                "recipes": [recipe.dict()],
                "generated_at": datetime.utcnow().isoformat()
            }
        }
    
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Recipe generation failed: {str(e)}"
        )


@app.get("/api/v1/app/version")
async def check_version(platform: str, version: str):
    """Check for app updates"""
    
    # TODO: Replace with database or config file
    latest_version = "1.0.0"
    current_version = version
    
    # Simple version comparison
    def parse_version(v):
        return tuple(map(int, v.split(".")))
    
    needs_update = parse_version(latest_version) > parse_version(current_version)
    
    return {
        "success": True,
        "data": {
            "latest_version": latest_version,
            "build_number": 1,
            "force_update": False,
            "update_url": "https://apps.apple.com/app/snapcook" if platform == "ios" else "https://play.google.com/store/apps/details?id=com.snapcook.app",
            "title": "New Version Available" if needs_update else "Up to Date",
            "message": "Please update to get the latest features!" if needs_update else "You have the latest version.",
            "release_notes": "- Bug fixes and improvements"
        }
    }


@app.get("/api/v1/recipes/popular")
async def get_popular_recipes(
    limit: int = 10,
    category: Optional[str] = None,
    api_key: str = ""
):
    """Get popular recipes"""
    
    verify_api_key(api_key)
    
    # TODO: Fetch from database
    # For now, return mock data
    mock_recipes = [
        {
            "id": "recipe_001",
            "title": "Classic Spaghetti Carbonara",
            "image_url": "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg",
            "time": "25 min",
            "calories": "550 kcal",
            "tags": ["Italian", "Dinner", "Pasta"],
            "rating": 4.8,
            "view_count": 15234
        },
        {
            "id": "recipe_002",
            "title": "Chicken Tikka Masala",
            "image_url": "https://www.themealdb.com/images/media/meals/wyxwsp1486979827.jpg",
            "time": "45 min",
            "calories": "600 kcal",
            "tags": ["Indian", "Spicy", "Dinner"],
            "rating": 4.7,
            "view_count": 12890
        }
    ]
    
    return {
        "success": True,
        "data": {
            "recipes": mock_recipes[:limit],
            "total": len(mock_recipes)
        }
    }


@app.post("/api/v1/recipes/{recipe_id}/feedback")
async def submit_feedback(recipe_id: str, feedback: FeedbackRequest, api_key: str = Form(...)):
    """Submit recipe feedback"""
    
    verify_api_key(api_key)
    
    # TODO: Store in database
    print(f"Feedback received for {recipe_id}: {feedback.rating} stars")
    
    return {
        "success": True,
        "message": "Feedback submitted successfully"
    }


@app.post("/api/v1/analytics/events")
async def track_event(event: AnalyticsEvent, api_key: str = Form(...)):
    """Track analytics events"""
    
    verify_api_key(api_key)
    
    # TODO: Store in database or send to analytics service
    print(f"Event: {event.event_name}, User: {event.user_id}")
    
    return {"success": True}


# ==================== Error Handlers ====================

@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "code": exc.status_code,
                "message": exc.detail
            }
        }
    )


@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "error": {
                "code": "INTERNAL_ERROR",
                "message": "An unexpected error occurred"
            }
        }
    )


# ==================== Main ====================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
