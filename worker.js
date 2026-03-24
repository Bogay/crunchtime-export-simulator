export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname.endsWith('.wasm') || url.pathname.endsWith('.pck')) {
      const key = url.pathname.slice(1); // e.g. "index.wasm"
      const object = await env.WASM_BUCKET.get(key);
      if (!object) return new Response('Not found', { status: 404 });

      const headers = new Headers();
      object.writeHttpMetadata(headers);
      headers.set('etag', object.httpEtag);
      headers.set('Cross-Origin-Opener-Policy', 'same-origin');
      headers.set('Cross-Origin-Embedder-Policy', 'require-corp');
      headers.set('Content-Encoding', 'gzip');

      if (url.pathname.endsWith('.wasm')) {
        headers.set('Content-Type', 'application/wasm');
      } else if (url.pathname.endsWith('.pck')) {
        headers.set('Content-Type', 'application/octet-stream');
      }

      return new Response(object.body, {
        headers,
      });
    }
    return env.ASSETS.fetch(request);
  }
}
