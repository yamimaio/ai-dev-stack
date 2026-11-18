// Tiny JSON reader for macOS, run with: osascript -l JavaScript json-pick.js <file> <mode> [regex]
// Uses only what ships with macOS (JavaScript for Automation), so the host needs no Python or Node.
ObjC.import('Foundation');
function run(argv) {
  var txt = $.NSString.stringWithContentsOfFileEncodingError(argv[0], $.NSUTF8StringEncoding, null).js;
  var data = JSON.parse(txt);
  if (argv[1] === 'sha') return data.sha;
  if (argv[1] === 'files') {
    var re = new RegExp(argv[2]);
    return data
      .filter(function (f) { return f.type === 'file' && re.test(f.path) && !/mmproj/i.test(f.path); })
      .map(function (f) { return [f.path, f.lfs ? f.lfs.oid : '', f.lfs ? f.lfs.size : f.size].join('\t'); })
      .join('\n');
  }
  throw new Error('unknown mode ' + argv[1]);
}
