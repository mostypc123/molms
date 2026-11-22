import std.file : readText, FileException;
import std.algorithm : map;
import std.array : array;
import std.conv : to;
import std.json;
import logger;

class Config {
  public {
    void updateConfig(string file) {
      string content;

      try {
        content = readText(file);
      } catch (FileException e) {
        log.error("Failed to read config file" ~ e.msg);
        return;
      }

      json = parseJSON(content);

      try {
        port = json["host"]["port"].get!ushort;
      } catch (JSONException e) {}

      try {
        writeLogFile = json["log"]["write"].get!bool;
        logFile = json["log"]["file"].get!string;
      } catch (JSONException e) {}

      try {
        devmode = json["host"]["devmode"].get!bool;
      } catch (JSONException e) {}

      try {
        dbFile = json["database"]["file"].get!string;
      } catch (JSONException e) {}

      try {
        bindAdresses = json["host"]["bindAdresses"].array.map!(v => v.str).array;
      } catch (JSONException e) {}
    }

    this(string file) {
      updateConfig(file);
    }

    JSONValue json;

    ushort port = 8080;
    bool writeLogFile = false;
    string logFile = "log.json";
    string[] bindAdresses = ["127.0.0.1"];
    string dbFile = "db.db";
    bool devmode = false;
  }
}
