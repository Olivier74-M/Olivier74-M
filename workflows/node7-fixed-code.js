// Extract and parse GPT-4 response
const response = $input.first().json;
const generatedContent = response.choices[0].message.content;
const tokensUsed = response.usage.total_tokens;

// Get template info to check if line items expected
const templateData = $('Fetch Prompt Template').first().json;
const template = Array.isArray(templateData) ? templateData[0] : templateData;
const includesLineItems = template.includes_line_items || false;

// For MVP: Just save full markdown
const lineItemsJson = [];

return [{
  json: {
    markdown: generatedContent,
    line_items_json: lineItemsJson,
    tokens_used: tokensUsed,
    status: 'draft'
  }
}];
