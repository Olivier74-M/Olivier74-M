// Build GPT-4 Vision prompt with images
// More robust version that handles data format variations

// Get template - handle both array and direct object
const templateNode = $('Fetch Prompt Template').item.json;
const template = Array.isArray(templateNode) ? templateNode[0] : templateNode;

if (!template || !template.system_prompt) {
  throw new Error('Template data is missing or invalid. Expected system_prompt field.');
}

const context = $input.item.json;

// For MVP: Remove placeholder variables from system prompt
// (e.g., {property_details}, {client_concern}, etc.)
let systemPrompt = template.system_prompt;

// Remove lines that contain unreplaced placeholder variables
systemPrompt = systemPrompt
  .split('\n')
  .filter(line => !line.includes('{') || !line.includes('}'))
  .join('\n')
  .trim();

// Build user message
const userMessageText = `Here's all the information from my site visit:\n\n${context.all_text_context}\n\n${context.image_count > 0 ? `I've also included ${context.image_count} photos from the site for your review.` : ''}`;

// Build message content array for GPT-4 Vision
const userContent = [
  {
    type: 'text',
    text: userMessageText
  }
];

// Add images to content array
if (context.images && context.images.length > 0) {
  context.images.forEach(img => {
    if (img.url) {
      userContent.push({
        type: 'image_url',
        image_url: {
          url: img.url,
          detail: 'high'
        }
      });
    }
  });
}

// Build complete messages array
const messages = [
  {
    role: 'system',
    content: systemPrompt
  },
  {
    role: 'user',
    content: userContent
  }
];

// Return GPT-4 Vision request
return [{
  json: {
    model: 'gpt-4o',
    messages: messages,
    max_tokens: 4000,
    temperature: 0.7
  }
}];
