const string theme = import("default.css");

import vibe.vibe;
import utils;

void defaultCss(HTTPServerRequest req, HTTPServerResponse res) {
  res.writeCssBody(theme);
}
