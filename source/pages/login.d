module pages.login;

import vibe.vibe;
import utils;

const string page = import("login.html");

void loginPage(HTTPServerRequest req, HTTPServerResponse res) {
  res.writeHtmlBody(html(page));
}
