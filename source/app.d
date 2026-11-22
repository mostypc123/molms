import vibe.vibe;
import logger : log, Log;
import config : Config;

import css;
import utils : handleError;
import database;

import pages.courses;
import pages.profiles;
import pages.welcome;
import pages.login;
import pages.home;

void main(string[] args) {
  string configFile = "example_config.json";
  if (args.length > 2 && args[1] == "--config-path") {
    configFile = args[2];
  }

  auto router = new URLRouter;
  log = new Log;
  auto config = new Config(configFile);
  auto db = new Database(config.dbFile);
  if (config.writeLogFile) {
    log.enableWriteToFile(config.logFile);
  }

  auto settings = new HTTPServerSettings;
  settings.bindAddresses = config.bindAdresses;
  settings.port = config.port;
  settings.sessionStore = new MemorySessionStore;
  if (config.devmode != true) {
    settings.sessionOptions = SessionOption.httpOnly | SessionOption.secure;
  } else {
    log.warn("dev mode is enabled");
  }

  log.info("welcome to molms!");

  router.get("/css/default.css", &defaultCss);
  router.get("/", &loginPage);

  router.post("/login", (req, res) @trusted {
    try {
      string user = req.form.get("user", "");
      string pass = req.form.get("pass", "");

      if (user.length == 0 || pass.length == 0) {
        res.redirect("/");
        return;
      }

      bool onboarding = !db.userExists(user);

      if (db.addUser(user, pass)) {
        auto session = res.startSession();

        session.set("user", user);

        res.redirect(onboarding ? "/welcome" : "/home");
      } else {
        res.redirect("/");
      }
    } catch (Exception e) {
      log.error("login failed: " ~ e.msg);
      if (!res.headerWritten) {
        res.redirect("/");
      }
    }
  });

  router.get("/logout", (req, res) @trusted {
    try {
      if (req.session) {
        res.terminateSession();
      }
      res.redirect("/");
    } catch (Exception e) {
      res.handleError("logout", e);
    }
  });

  router.addCourseHandling(db);
  router.addProfilesPage(db);
  router.addWelcomePage(db);
  router.addHomePage(db);

  listenHTTP(settings, router);
  runEventLoop();
}
