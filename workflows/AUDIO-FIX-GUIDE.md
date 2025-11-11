# Fix for "Fetch Audio (binary)" Node Error

## The Problem

You're getting this error:
```
Invalid URL: {{$json.media.audio_url}}. URL must start with "http" or "https".
```

**Root Cause**: In n8n, expressions must start with `=` to be evaluated. Without the `=` prefix, n8n treats the text as a literal string instead of evaluating the expression.

## Quick Fix (If Node Already Exists)

If you already have a "Fetch Audio (binary)" node in your workflow:

1. **Open the "Fetch Audio (binary)" node** in your n8n editor
2. **Find the URL field**
3. **Change from**: `{{$json.media.audio_url}}`
4. **Change to**: `={{$json.media.audio_url}}` (note the `=` at the beginning)
5. **Save the node**

## The Correct Expression Format

In n8n:
- ❌ **WRONG**: `{{$json.media.audio_url}}` - Treated as literal text
- ✅ **CORRECT**: `={{$json.media.audio_url}}` - Evaluated as an expression

## Complete Audio Support Implementation

To properly handle audio captures similar to how images are handled, you need:

### 1. Add audio_url extraction in Pass-through node

Add this assignment to your "Pass-through" node:

```json
{
  "id": "audio-url-extraction",
  "name": "media.audio_url",
  "value": "={{$json.body.media?.audio_url || null}}",
  "type": "string"
}
```

### 2. Add "Has Audio?" conditional node

After the image processing branch, add an IF node to check for audio:

**Node Configuration**:
- **Name**: "Has Audio?"
- **Type**: IF (n8n-nodes-base.if)
- **Condition**:
  - Left Value: `={{$json.media?.audio_url}}`
  - Operation: `is not empty`

### 3. Add "Fetch Audio (binary)" node

For the TRUE branch of "Has Audio?":

**Node Configuration**:
- **Name**: "Fetch Audio (binary)"
- **Type**: HTTP Request (n8n-nodes-base.httpRequest)
- **Method**: GET
- **URL**: `={{$json.media.audio_url}}` ⚠️ **Note the = prefix!**
- **Response**:
  - Format: `File`
  - Property Name: `audio`

### 4. Add audio storage nodes

Similar to image storage, you'll need:

1. **Move Audio Binary Data** - Rename keys node
2. **Upload Audio to Supabase** - HTTP Request (PUT)
3. **Sign Audio URL** - HTTP Request (POST)
4. **Prepare Audio URL** - Set node
5. **Upsert Audio Capture** - HTTP Request (POST)

## Example Workflow Flow

```
Pass-through
    ↓
Has Image? ──YES──→ [Image Processing] ──→ Merge Audio/Image
    ↓                                            ↑
    NO                                           |
    ↓                                            |
Has Audio? ──YES──→ [Audio Processing] ─────────┘
    ↓
    NO
    ↓
Pass-through (no media)
```

## Testing Audio Uploads

Send a test webhook with audio:

```bash
curl -X POST http://localhost:5678/webhook/new-capture \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Voice note test",
    "media": {
      "audio_url": "https://example.com/sample.mp3",
      "kind": "audio"
    },
    "org_id": "test-org-123"
  }'
```

## Common Issues

### Issue: "Invalid URL" error
**Solution**: Make sure the URL expression starts with `=`

### Issue: "URL is null or undefined"
**Solution**: Check that `media.audio_url` is being extracted in the Pass-through node

### Issue: "No data from previous node"
**Solution**: Verify the "Has Audio?" node is properly connected

## Storage Configuration

Audio files should be stored in a separate bucket or folder:

- **Bucket**: `audio` (or `media/audio`)
- **File naming**: `{{ new Date().toISOString().replace(/[:.TZ]/g,'-') }}.mp3`
- **MIME type**: `{{$binary.audio.mimeType || 'audio/mpeg'}}`

## Next Steps

1. Apply the quick fix to stop the current error
2. Implement full audio support using the pattern above
3. Test with sample audio URLs
4. Update your Supabase schema to handle audio captures

---

**Need Help?** If you're still stuck, share:
1. A screenshot of your "Fetch Audio (binary)" node configuration
2. The execution log showing the error
3. The workflow structure around the audio node
