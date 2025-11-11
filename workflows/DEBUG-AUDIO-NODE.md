# Debug: Fetch Audio Node Error

## The Error
```
Invalid URL: {{$json.media.audio_url}}. URL must start with "http" or "https".
```

This means the expression is **NOT being evaluated** - n8n is treating it as literal text.

---

## Step-by-Step Fix

### Step 1: Check What Data the Node Receives

**IMPORTANT**: Before fixing the Fetch Audio node, we need to see what data it's receiving.

1. Open your failed execution in n8n
2. Click on the **node BEFORE "Fetch Audio (binary)"**
   - This might be: "Has Audio?" or "Pass-through" or another node
3. Click the **"Output"** tab
4. Look for the data structure

**What you should see**:
```json
{
  "media": {
    "audio_url": "https://example.com/audio.mp3"
  },
  "job_id": "...",
  "normalized": { ... }
}
```

**If you DON'T see `media.audio_url`**, that's your problem! The data isn't being extracted properly.

---

### Step 2: Fix the Pass-through Node (Extract audio_url)

The Pass-through node needs to extract `audio_url` from the webhook data.

**Open the "Pass-through" node** and add this assignment:

1. Click **"+ Add Assignment"**
2. Configure:
   - **Name**: `media.audio_url`
   - **Type**: `String`
   - **Value**: `={{$json.body.media?.audio_url || null}}`

**Screenshot of what it should look like**:
```
Assignments:
- job_id: ={{$json.id}}
- raw: ={{$json}}
- normalized.text: ={{$json.body.text || null}}
- normalized.lang_hint: ={{$json.body.lang_hint || null}}
- meta.source: ={{$json.body?.source || "webhook"}}
- meta.received_at: ={{new Date().toISOString()}}
- media.image_url: ={{$json.body.media?.image_url || null}}
- media.audio_url: ={{$json.body.media?.audio_url || null}}  ← ADD THIS
```

3. Click **Save** or click outside the node

---

### Step 3: Fix the Fetch Audio Node URL Expression

Now fix the "Fetch Audio (binary)" node:

1. **Click on the "Fetch Audio (binary)" node** to open it
2. Find the **URL** field
3. **CRITICAL**: Make sure it looks EXACTLY like this:

   ```
   ={{$json.media.audio_url}}
   ```

   **NOT like this**:
   ```
   {{$json.media.audio_url}}    ← WRONG (missing =)
   ```

4. The field should show a **purple highlight** or **fx icon** indicating it's an expression
5. Click **Save** or click outside the node

---

### Step 4: Verify the Expression is Active

After saving, the URL field should show:
- A **purple/lavender background** (indicating expression mode), OR
- An **fx icon** next to the field

If it looks like plain text (white background, no fx icon), you're still in fixed/literal mode.

**To force expression mode**:
1. Click in the URL field
2. Look for a toggle button or dropdown that says **"Expression"** vs **"Fixed"**
3. Select **"Expression"** mode
4. Then enter: `{{$json.media.audio_url}}`
5. The field should automatically add the `=` prefix when you switch to expression mode

---

### Step 5: Test Again

1. **Save the workflow** (top-right button)
2. Run your curl command again:
   ```bash
   curl -X POST http://localhost:5678/webhook/new-capture \
     -H "Content-Type: application/json" \
     -d '{
       "text": "Audio test",
       "media": {
         "audio_url": "https://www2.cs.uic.edu/~i101/SoundFiles/BabyElephantWalk60.wav",
         "kind": "audio"
       }
     }'
   ```

3. Check the new execution

---

## Alternative: Visual Check in n8n Editor

### How to Know if Expression Mode is Active

When you click on the "Fetch Audio (binary)" node:

**Expression Mode (CORRECT)**:
```
URL: [fx] {{$json.media.audio_url}}
     └── This icon means expression mode is active
```

**Fixed/Literal Mode (WRONG)**:
```
URL: [ ] {{$json.media.audio_url}}
     └── No icon means it's treated as literal text
```

---

## Troubleshooting

### Issue: "Still showing the same error"

**Possible causes**:
1. ❌ You didn't save the node after changing it
2. ❌ Expression mode is not enabled
3. ❌ The `media.audio_url` field doesn't exist in the data

**Solution**:
- Save the workflow
- Check the previous node's output to verify `media.audio_url` exists
- Make sure expression mode is active (look for the fx icon)

### Issue: "Now it says URL is undefined or null"

This means:
- ✅ Expression mode is working!
- ❌ But `media.audio_url` doesn't exist in the data

**Solution**: Go back to Step 2 and fix the Pass-through node to extract `audio_url`

### Issue: "How do I know if the Pass-through fix worked?"

After fixing the Pass-through node:
1. Run a new test
2. Click on the "Pass-through" node in the execution
3. Check the **Output** tab
4. You should see: `"media": { "audio_url": "https://..." }`

---

## Quick Checklist

Before testing again, verify:

- [ ] Pass-through node extracts `media.audio_url` (Step 2)
- [ ] Fetch Audio node URL has the `=` prefix (Step 3)
- [ ] Expression mode is active (look for fx icon)
- [ ] Workflow is saved
- [ ] Workflow is active (toggle is ON)

---

## Visual Guide: URL Field Configuration

### ❌ WRONG Configuration
```
Node: Fetch Audio (binary)
Method: GET
URL: {{$json.media.audio_url}}        ← Plain text, no evaluation
     ^no fx icon, white background
```

### ✅ CORRECT Configuration
```
Node: Fetch Audio (binary)
Method: GET
URL: [fx] ={{$json.media.audio_url}}  ← Expression, will be evaluated
     ^fx icon, purple/lavender background
```

---

## Need More Help?

If you're still stuck, share:

1. **Screenshot** of the "Fetch Audio (binary)" node URL field
2. **Output data** from the node BEFORE "Fetch Audio" (copy the JSON)
3. **The exact curl command** you're using to test

This will help me pinpoint exactly what's wrong!

---

## Next Steps After Fix

Once this works, you should see:
- ✅ "Fetch Audio (binary)" node downloads the audio file
- ✅ Binary data appears in the node output
- ✅ You can proceed to upload it to Supabase (if that's set up)
