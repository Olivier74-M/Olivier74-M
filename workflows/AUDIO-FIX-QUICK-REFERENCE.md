# Quick Fix: Fetch Audio Node Error

## The Problem
```
Error: Invalid URL: {{$json.media.audio_url}}
```

## The Solution (1 minute fix)

1. Open your "Fetch Audio (binary)" node in n8n
2. Find the **URL** field
3. Change this:
   ```
   {{$json.media.audio_url}}
   ```
   To this:
   ```
   ={{$json.media.audio_url}}
   ```
   **Note the `=` at the start!**

4. Save the node

## Why This Works

In n8n, expressions **MUST** start with `=` to be evaluated:
- ❌ `{{$json.media.audio_url}}` → Treated as literal text
- ✅ `={{$json.media.audio_url}}` → Evaluated as an expression

## Full Implementation

For complete audio support similar to image handling, see:
- `AUDIO-FIX-GUIDE.md` - Complete implementation guide

## Testing

After the fix, send a test webhook:

```bash
curl -X POST http://localhost:5678/webhook/new-capture \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Audio test",
    "media": {
      "audio_url": "https://example.com/sample.mp3",
      "kind": "audio"
    }
  }'
```

The audio should now be fetched successfully.

## Still Having Issues?

Check these common problems:

1. **URL still showing as literal**: Make sure you saved the node after adding `=`
2. **URL is null**: Verify the Pass-through node extracts `media.audio_url`
3. **Different error**: Share the new error message for further help

## Need to Add Full Audio Support?

Your current workflow only handles images. To add complete audio processing:

1. Add `media.audio_url` extraction in Pass-through node (line 87-90):
   ```json
   {
     "id": "audio-url-extraction",
     "name": "media.audio_url",
     "value": "={{$json.body.media?.audio_url || null}}",
     "type": "string"
   }
   ```

2. Add "Has Audio?" conditional after the "Has Image?" branch

3. Create audio processing nodes (Fetch → Upload → Sign → Upsert)

See `AUDIO-FIX-GUIDE.md` for the complete walkthrough.
