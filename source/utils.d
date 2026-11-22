module utils;
import vibe.vibe;

void writeHtmlBody(HTTPServerResponse res, string html, int code = 200) {
  res.statusCode = code;
  res.headers["Content-Type"] = "text/html; charset=utf-8";

  res.writeBody(
    html, "text/html; charset=utf-8"
  );
}

void writeCssBody(HTTPServerResponse res, string css, int code = 200) {
  res.statusCode = code;
  res.headers["Content-Type"] = "text/css; charset=utf-8";

  res.writeBody(
    css, "text/css; charset=utf-8"
  );
}

string html(string body, string title = "molms") {
  return (`
    <!doctype html>
    <html lang="en">
      <head>
        <title>` ~ title ~ `</title>
        <link rel="stylesheet" href="/css/default.css">
      </head>
      <body>`
        ~ body ~
      `</body>
    </html>
  `);
}
