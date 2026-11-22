module pages.login;

import vibe.vibe;
import utils;

const string page = import("login.html");

void loginPage(HTTPServerRequest req, HTTPServerResponse res) {
  try {
    res.writeHtmlBody(html(page));
  } catch (Exception e) {
    res.handleError("login page", e);
  }
}
