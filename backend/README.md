# SnapCook Backend API

Python FastAPI backend for SnapCook app.

## Features

- 🔍 **Ingredient Recognition** - AI-powered food ingredient detection from images
- 🍳 **Recipe Generation** - Create recipes based on available ingredients
- 📱 **App Update Check** - Version management for mobile app
- 📊 **Analytics** - Track user interactions
- 🔒 **API Key Authentication** - Secure API access
- 🚀 **Fast & Scalable** - Built with FastAPI + async/await

## Tech Stack

- **Framework**: FastAPI
- **Python**: 3.11+
- **AI Service**: OpenAI GPT-4o Vision
- **Server**: Uvicorn + Nginx
- **Process Manager**: Systemd

## Quick Start

### Local Development

```bash
# 1. Clone and enter directory
cd backend

# 2. Create virtual environment
python3.11 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment
cp .env.example .env
# Edit .env and add your OpenAI API key

# 5. Run development server
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# 6. Test
open http://localhost:8000/docs
```

### Production Deployment

```bash
# On your server (Ubuntu 20.04/22.04)
git clone <your-repo>
cd snapcook/backend
chmod +x deploy.sh
sudo ./deploy.sh
```

Then edit the environment file:
```bash
sudo nano /opt/snapcook-api/.env
```

Start the service:
```bash
sudo snapcook-start
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/api/v1/ingredients/recognize` | Recognize ingredients from images |
| POST | `/api/v1/recipes/generate` | Generate recipe from ingredients |
| GET | `/api/v1/app/version` | Check for app updates |
| GET | `/api/v1/recipes/popular` | Get popular recipes |
| POST | `/api/v1/recipes/{id}/feedback` | Submit recipe feedback |
| POST | `/api/v1/analytics/events` | Track analytics events |

See [API_SPEC.md](../API_SPEC.md) for detailed documentation.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes | OpenAI API key |
| `API_KEY` | Yes | API key for Flutter app authentication |
| `HOST` | No | Server host (default: 0.0.0.0) |
| `PORT` | No | Server port (default: 8000) |
| `ENVIRONMENT` | No | dev/staging/production |

## Project Structure

```
backend/
├── main.py              # Main FastAPI application
├── requirements.txt     # Python dependencies
├── .env.example         # Environment variables template
├── deploy.sh            # Production deployment script
└── README.md            # This file
```

## API Testing

Use the interactive docs at `/docs`:
```
http://your-server/docs
```

Or test with curl:
```bash
# Health check
curl http://localhost/health

# Version check
curl "http://localhost/api/v1/app/version?platform=ios&version=1.0.0"
```

## Management Commands

After deployment, use these commands:

```bash
snapcook-start      # Start service
snapcook-stop       # Stop service
snapcook-restart    # Restart service
snapcook-status     # Check status
snapcook-logs       # View logs
```

## Troubleshooting

### Service won't start
```bash
# Check logs
sudo journalctl -u snapcook-api -n 50

# Check environment file
sudo cat /opt/snapcook-api/.env

# Test manually
cd /opt/snapcook-api
source venv/bin/activate
python main.py
```

### API returns 401
- Check that `API_KEY` in `.env` matches the key in Flutter app

### OpenAI errors
- Verify `OPENAI_API_KEY` is valid
- Check OpenAI account has available credits

## License

MIT License
