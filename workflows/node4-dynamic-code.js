// Assemble context from all captures
const captures = $input.all();

// Get job_id from webhook to pass through
const jobId = $('Webhook – Generate Document').first().json.job_id;

// Separate by type (using 'type' column, not 'media_type')
const images = captures.filter(c => c.json.type === 'image');
const audio = captures.filter(c => c.json.type === 'audio');
const text = captures.filter(c => c.json.type === 'text');

// Build image array for GPT-4 Vision
const imageData = images.map(img => ({
  url: img.json.signed_url,
  analysis: img.json.ocr_text || '',
  timestamp: img.json.created_at
}));

// Combine all text context
const imageContext = images
  .map(img => `IMAGE (OCR): ${img.json.ocr_text || 'No text extracted'}`)
  .join('\n\n');

const audioContext = audio
  .map(a => `AUDIO TRANSCRIPT: ${a.json.transcript || a.json.transcription || 'No transcript available'}`)
  .join('\n\n');

const textContext = text
  .map(t => `NOTE: ${t.json.text_content || ''}`)
  .join('\n\n');

// Combine everything
const allTextContext = [
  imageContext,
  audioContext,
  textContext
].filter(Boolean).join('\n\n');

// Return assembled context WITH job_id
return [{
  json: {
    job_id: jobId,
    images: imageData,
    transcripts: audio.map(a => a.json.transcript || a.json.transcription).filter(Boolean).join('\n\n'),
    notes: text.map(t => t.json.text_content).filter(Boolean).join('\n\n'),
    image_count: images.length,
    audio_count: audio.length,
    text_count: text.length,
    all_text_context: allTextContext
  }
}];
