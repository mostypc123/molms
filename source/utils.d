module utils;
import vibe.vibe;
import logger : log;

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
      <body>
        <nav>
          <a href="/profiles">Users</a> |
          <a href="/home">Home</a>
        </nav>
        <main style="margin:5px">`
          ~ body ~
      ` </main>
      </body>
    </html>
  `);
}

string sessionUser(HTTPServerRequest req) {
  if (!req.session) {
    return "";
  }

  return req.session.get!string("user", "");
}

void handleError(HTTPServerResponse res, string context, Exception e) {
  log.error(context ~ ": " ~ e.msg);

  if (!res.headerWritten) {
    res.writeHtmlBody(html("Something went wrong."), 500);
  }
}
