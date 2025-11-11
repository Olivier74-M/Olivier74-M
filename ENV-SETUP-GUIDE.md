# Environment Variables Setup Guide

## Overview

The Bracework workflows require API keys and configuration. This guide explains how to set them up.

---

## Important: Two Ways to Set Environment Variables

### Option 1: n8n Cloud or Self-Hosted (Recommended)

If you're using **n8n Cloud** or **self-hosted n8n**, you configure environment variables directly in n8n:

**For n8n Cloud:**
1. Go to your n8n instance
2. Click your profile (top right) → Settings
3. Go to "Environment Variables" section
4. Add each variable:
   - `OPENAI_API_KEY`
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_KEY`

**For Self-Hosted n8n (Docker):**
Add to your `docker-compose.yml`:
```yaml
services:
  n8n:
    environment:
      - OPENAI_API_KEY=sk-proj-your-key-here
      - SUPABASE_URL=https://dqdgtsnxxhzrpfkpgcww.supabase.co
      - SUPABASE_SERVICE_KEY=eyJ...your-key-here
```

Or create a `.env` file and reference it in docker-compose:
```yaml
services:
  n8n:
    env_file:
      - .env
```

### Option 2: Local .env File (Development Reference)

For local development or reference, you can create a `.env` file:

```bash
# Copy the example file
cp .env.example .env

# Edit it with your values
nano .env  # or use your preferred editor
```

**NOTE:** The `.env` file is already in `.gitignore` - it will NOT be committed to git.

---

## Required Environment Variables

### 1. OpenAI API Key

**Where to get it:**
1. Go to: https://platform.openai.com/api-keys
2. Click "Create new secret key"
3. Name it "Bracework n8n"
4. Copy the key (starts with `sk-proj-...`)

**Set in n8n:**
```
Name: OPENAI_API_KEY
Value: sk-proj-abc123...
```

**Cost:** You'll need credits in your OpenAI account
- Add payment method: https://platform.openai.com/settings/organization/billing
- Recommended starting amount: $20

---

### 2. Supabase URL

**Where to get it:**
1. Go to: https://supabase.com/dashboard/project/dqdgtsnxxhzrpfkpgcww/settings/api
2. Find "Project URL" in the Configuration section
3. Copy it (should be: `https://dqdgtsnxxhzrpfkpgcww.supabase.co`)

**Set in n8n:**
```
Name: SUPABASE_URL
Value: https://dqdgtsnxxhzrpfkpgcww.supabase.co
```

---

### 3. Supabase Service Role Key

**Where to get it:**
1. Go to: https://supabase.com/dashboard/project/dqdgtsnxxhzrpfkpgcww/settings/api
2. Find "service_role" key in the "Project API keys" section
3. Click "Reveal" button
4. Copy the key (starts with `eyJ...`)

**⚠️ IMPORTANT:** This key has **full access** to your database (bypasses Row Level Security)
- Never expose it in client-side code
- Never commit it to git
- Only use it in secure server environments (like n8n)

**Set in n8n:**
```
Name: SUPABASE_SERVICE_KEY
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Verification

After setting environment variables in n8n, verify they work:

### Test in n8n Workflow

1. Create a test workflow
2. Add a "Code" node
3. Use this code:
```javascript
return [{
  json: {
    openai_key_set: !!$env.OPENAI_API_KEY,
    supabase_url: $env.SUPABASE_URL,
    supabase_key_set: !!$env.SUPABASE_SERVICE_KEY
  }
}];
```
4. Execute the node
5. You should see:
```json
{
  "openai_key_set": true,
  "supabase_url": "https://dqdgtsnxxhzrpfkpgcww.supabase.co",
  "supabase_key_set": true
}
```

---

## Troubleshooting

### Error: "Cannot access environment variable"

**Problem:** n8n can't find the environment variable

**Solutions:**
1. **n8n Cloud:** Make sure you saved the environment variables in Settings
2. **Self-hosted:** Restart n8n after adding environment variables
   ```bash
   docker-compose restart n8n
   ```
3. **Variable name:** Check spelling matches exactly (case-sensitive)

---

### Error: "Invalid API key" from OpenAI

**Problem:** OpenAI API key is wrong or expired

**Solutions:**
1. Check you copied the full key (starts with `sk-proj-`)
2. Verify key is active: https://platform.openai.com/api-keys
3. Check you have credits: https://platform.openai.com/settings/organization/billing

---

### Error: "Invalid API key" from Supabase

**Problem:** Supabase service key is wrong

**Solutions:**
1. Make sure you copied the **service_role** key, not the **anon** key
2. Check for extra spaces or line breaks when copying
3. Try regenerating the key in Supabase settings

---

## Security Best Practices

### ✅ DO:
- Store keys in n8n environment variables
- Use different keys for development vs production
- Rotate keys periodically
- Monitor API usage in OpenAI dashboard

### ❌ DON'T:
- Commit `.env` file to git (it's already in .gitignore)
- Share your service_role key with anyone
- Use service_role key in client-side code (websites, mobile apps)
- Hardcode keys in workflows

---

## Local Development Setup (Optional)

If you're running n8n locally with Docker:

### 1. Create .env file

```bash
cp .env.example .env
```

### 2. Fill in your keys

Edit `.env`:
```bash
OPENAI_API_KEY=sk-proj-your-actual-key
SUPABASE_URL=https://dqdgtsnxxhzrpfkpgcww.supabase.co
SUPABASE_SERVICE_KEY=eyJ-your-actual-key
```

### 3. Update docker-compose.yml

```yaml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n
    env_file:
      - .env
    ports:
      - "5678:5678"
    volumes:
      - ./n8n_data:/home/node/.n8n
```

### 4. Start n8n

```bash
docker-compose up -d
```

### 5. Access n8n

Open: http://localhost:5678

---

## What's Next?

After setting up environment variables:

1. ✅ **Deploy SQL scripts to Supabase** (see next section)
2. ✅ **Import n8n workflows**
3. ✅ **Test the workflows**

---

## Quick Reference

**Where to find things:**

| What | Where |
|------|-------|
| OpenAI API Keys | https://platform.openai.com/api-keys |
| OpenAI Billing | https://platform.openai.com/settings/organization/billing |
| Supabase API Settings | https://supabase.com/dashboard/project/dqdgtsnxxhzrpfkpgcww/settings/api |
| Supabase SQL Editor | https://supabase.com/dashboard/project/dqdgtsnxxhzrpfkpgcww/sql/new |
| n8n Environment Variables | n8n Settings → Environment Variables |

---

**Need help?** Check the troubleshooting section above or refer to:
- n8n Environment Variables docs: https://docs.n8n.io/hosting/environment-variables/
- Supabase API docs: https://supabase.com/docs/guides/api
