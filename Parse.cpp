#define _WIN32_WINNT 0x0601
#define CPPHTTPLIB_USE_WIN32_FILE_API

#include "C:\CPC_Files\httplib.h"
#include "C:\CPC_Files\json.hpp"

#include <fstream>
#include <iostream>
#include <filesystem>

using namespace httplib;
using namespace std;
using json = nlohmann::json;
namespace fs = std::filesystem;

string sanitize(string name) {
    for (char &c : name) {
        if (c == ' ') c = '_';
        if (c == '.') c = '_';
    }
    return name;
}

int main() {
    Server svr;

    svr.Post("/", [&](const Request &req, Response &res) {
        try {

            json data = json::parse(req.body);
            string name = sanitize(data.value("name", "problem"));

            string folder = "problems/" + name;
            fs::create_directories(folder);

            ofstream jf(folder + "/data.json");
            jf << data.dump(4);
            jf.close();

            cout << "Created: " << name << endl;

            ifstream src("C:/CPC_Files/template.cpp");
            ofstream dst(name + ".cpp");
            dst << src.rdbuf();

            if (data.contains("tests")) {
                auto tests = data["tests"];
                for (int i = 0; i < tests.size(); i++) {
                    ofstream in(folder + "/input" + to_string(i) + ".txt");
                    ofstream out(folder + "/output" + to_string(i) + ".txt");

                    in << tests[i]["input"].get<string>();
                    out << tests[i]["output"].get<string>();
                }
            }

            res.set_content("OK", "text/plain");
            svr.stop();
        }
        catch (...) {
            res.status = 500;
        }
    });

    cout << "Listening on port 27121...\n";
    svr.listen("localhost", 27121);
}