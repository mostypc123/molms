module logger;

import std.file : readText, write, FileException, exists;
import std.stdio : File, writeln;
import std.json;

class Log {
  public {
    void enableWriteToFile(string file) {
      logFile = file;
      writeLogsToFile = true;
    }

    void info(string msg) {
      writeln("\033[94;1minfo\033[0m: " ~ msg);
      updateLogFile("info", msg);
    }

    void error(string msg) {
      writeln("\033[91;1merror\033[0m: " ~ msg);
      updateLogFile("error", msg);
    }

    void warn(string msg) {
      writeln("\033[93;1mwarning\033[0m: " ~ msg);
      updateLogFile("warning", msg);
    }
  }

  private {
    bool writeLogsToFile = false;
    string logFile;

    void updateLogFile(string type, string msg) {
      if (!writeLogsToFile) {
        return;
      }

      try {
        if (!logFile.exists()) {
          logFile.write("{}");
        }

        auto parsedJson = parseJSON(readText(logFile));

        if (!("logs" in parsedJson)) {
          parsedJson.object["logs"] = JSONValue((JSONValue[]).init);
        } else if (parsedJson["logs"].type != JSONType.array) {
          writeln(logFile ~ " has broken json: logs is not an array");
          return;
        }

        parsedJson["logs"].array ~= JSONValue(["type": type, "message": msg]);
        logFile.write(parsedJson.toPrettyString());
      } catch (Exception e) {
        writeln("Failed to update log file: " ~ e.msg);
      }
    }
  }
}

Log log;
