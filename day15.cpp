#include <iostream>
#include <fstream>
#include <string>

const std::string INPUT_FILE = "day15.input";
const std::string delimiter = ",";

int silly_hash(std::string input) {
    const char *cin = input.c_str();
    int current_value = 0;
    for (int i = 0; i < input.length(); i++) {
        current_value += int(cin[i]);
        current_value *= 17;
        current_value = current_value % 256;
    }
    return current_value;
}

int main(int argc, char *argv[]) {
    std::ifstream f;
    f.open(INPUT_FILE);
    std::string input;
    if (f.is_open()) {
        f >>  input;
    }
    f.close();

    int result = 0;
    size_t pos = 0;
    std::string token;
    input.append(delimiter);
    while ((pos = input.find(delimiter)) != std::string::npos) {
        token = input.substr(0, pos);
        result += silly_hash(token);
        input.erase(0, pos + delimiter.length());
    }
    std::cout << "Part 1 grand total: " << result << std::endl;
    exit(0);
}