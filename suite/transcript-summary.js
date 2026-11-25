// Summarises one Claude Code transcript (.jsonl) for scoring: each tool call, errors, the final
// answer, duration and prompt-cache use. Run with: osascript -l JavaScript transcript-summary.js <file>
// Uses only what ships with macOS (JavaScript for Automation).
ObjC.import('Foundation');
function clip(s, n) { s = String(s); return s.length > n ? s.slice(0, n) + '…' : s; }
function run(argv) {
  var txt = $.NSString.stringWithContentsOfFileEncodingError(argv[0], $.NSUTF8StringEncoding, null).js;
  var out = [], first = null, last = null, lastText = '', models = {}, calls = 0, errors = 0;
  var cacheRead = [], uncached = [];
  txt.split('\n').forEach(function (line) {
    if (!line.trim()) return;
    var e; try { e = JSON.parse(line); } catch (x) { return; }
    if (e.timestamp) { first = first || e.timestamp; last = e.timestamp; }
    var m = e.message; if (!m || !m.content) return;
    if (e.type === 'user' && typeof m.content === 'string') { out.push('USER: ' + clip(m.content, 300)); return; }
    if (!Array.isArray(m.content)) return;
    if (e.type === 'assistant') {
      if (m.model) models[m.model] = 1;
      if (m.usage) { cacheRead.push(m.usage.cache_read_input_tokens || 0); uncached.push(m.usage.input_tokens || 0); }
    }
    m.content.forEach(function (c) {
      if (c.type === 'tool_use') {
        calls++;
        var i = c.input || {};
        var arg = i.command || i.file_path || i.pattern || i.path || i.prompt || i.description || JSON.stringify(i);
        out.push('TOOL ' + c.name + ': ' + clip(arg, 400));
      } else if (c.type === 'tool_result' && c.is_error) {
        errors++;
        var r = Array.isArray(c.content) ? c.content.map(function (x) { return x.text || ''; }).join(' ') : c.content;
        out.push('  ERROR: ' + clip(r, 300));
      } else if (c.type === 'text' && e.type === 'assistant') {
        lastText = c.text;
        out.push('SAID: ' + clip(c.text, 200));
      } else if (c.type === 'text' && e.type === 'user') {
        out.push('USER: ' + clip(c.text, 300));
      }
    });
  });
  var secs = first && last ? Math.round((Date.parse(last) - Date.parse(first)) / 1000) : -1;
  out.push('FINAL ANSWER: ' + clip(lastText, 1500));
  out.push('SUMMARY: tool_calls=' + calls + ' tool_errors=' + errors + ' seconds=' + secs +
           ' models=' + Object.keys(models).join(','));
  out.push('CACHE per turn (cache_read / uncached input tokens): ' +
           cacheRead.map(function (c, k) { return c + '/' + uncached[k]; }).slice(0, 12).join(' '));
  return out.join('\n');
}
