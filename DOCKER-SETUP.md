# Docker Setup for n8n with Environment Variables

## Quick Start

### 1. Configure Environment Variables

The `.env` file contains all necessary environment variables for n8n:

```bash
# Edit the .env file and add your actual keys
nano .env
```

**Required variables:**
- `OPENAI_API_KEY` - Your OpenAI API key (starts with `sk-...`)
- `SUPABASE_URL` - Already set to: `https://dqdgtsnxxhzrpfkpgcww.supabase.co`
- `SUPABASE_SERVICE_KEY` - Your Supabase service role key

### 2. Running n8n with Docker

#### Option A: Using docker run (Simple)

```bash
docker run -d \
  --name n8n \
  -p 5678:5678 \
  --env-file .env \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

#### Option B: Using docker-compose (Recommended)

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    env_file:
      - .env
    volumes:
      - ~/.n8n:/home/node/.n8n
```

Then run:

```bash
docker-compose up -d
```

### 3. Restart After Environment Changes

Whenever you update the `.env` file, restart the container:

```bash
# If using docker run:
docker restart n8n

# If using docker-compose:
docker-compose restart
```

### 4. Verify Environment Variables in n8n

1. Open n8n at http://localhost:5678
2. Open your workflow
3. Click on the **env_probe** node
4. Click "Execute Node"
5. Check that you see `OPENAI_API_KEY` in the output

## Troubleshooting

### Container won't start
```bash
# Check logs
docker logs n8n

# Or with docker-compose
docker-compose logs
```

### Environment variables not loading
- Make sure .env file is in the same directory as your docker command
- Restart the container after changing .env
- Check file permissions: `chmod 600 .env`

### Find running containers
```bash
docker ps
```

### Stop and remove container
```bash
docker stop n8n
docker rm n8n
```

## Security Notes

- ⚠️ **Never commit the `.env` file to git** (already in .gitignore)
- Keep your API keys secure
- Use `.env.example` as a template for others
