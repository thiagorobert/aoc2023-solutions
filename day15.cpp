#include <fstream>
#include <iostream>
#include <map>
#include <string>
#include <vector>

using namespace std;

const string INPUT_FILE = "day15.input";
const string comma = ",";
const string dash = "-";
const string equals = "=";

string read_input() {
    ifstream f;
    f.open(INPUT_FILE);
    string input;
    if (f.is_open()) {
        f >>  input;
    }
    f.close();
    input.append(comma);
    return input;
}

int silly_hash(string input) {
    const char *cin = input.c_str();
    int current_value = 0;
    for (int i = 0; i < input.length(); i++) {
        current_value += int(cin[i]);
        current_value *= 17;
        current_value = current_value % 256;
    }
    return current_value;
}

vector<string> get_steps(string input) {
  vector<string> steps;
    size_t pos = 0;
    string token;
    while ((pos = input.find(comma)) != string::npos) {
        token = input.substr(0, pos);
        steps.push_back(token);
        input.erase(0, pos + comma.length());
    }
    return steps;
}

void part1(vector<string> steps) {
    int result = 0;
    for (int i = 0; i < steps.size(); i++) {
        result += silly_hash(steps[i]);
    }
    cout << "Part 1 grand total: " << result << endl;
}

class Lens {
  public:
    string label;
    int focal_length;
    Lens(string label, int focal_length) {
        this->label = label;
        this->focal_length = focal_length;
    }
};

int lens_index(map<int, vector<Lens>> boxes, int box_number, string label) {
    if (boxes.count(box_number)) {
        for (int i = 0; i < boxes[box_number].size(); i++) {
            if (boxes[box_number][i].label == label) {
                return i;
            }
        }
    }
    return -1;
}

void part2(vector<string> steps) {
    map<int, vector<Lens>> boxes;

    string label;
    for (int i = 0; i < steps.size(); i++) {
        string step = steps[i];
        int focal_length = -1;
        size_t pos = 0;
        if ((pos = step.find(dash)) != string::npos) {
            label = step.substr(0, pos);
        } else if ((pos = step.find(equals)) != string::npos) {
            label = step.substr(0, pos);
            focal_length = stoi(step.substr(pos + 1, step.length()));
        }
        int box_number = silly_hash(label);
        int li = lens_index(boxes, box_number, label);
        if (focal_length != -1) {
            Lens lens(label, focal_length);
            if (li != -1) {
                boxes[box_number][li] = lens;
            } else {
                boxes[box_number].push_back(lens);
            }
        } else {
            if (li != -1) {
                boxes[box_number].erase(boxes[box_number].begin() + li);
            }
        }
    }

    int result = 0;
    for (map<int, vector<Lens>>::iterator it = boxes.begin(); it != boxes.end(); it++) {
        for (int i = 0; i <  it->second.size(); i++) {
            int focusing_power = it->first + 1;
            focusing_power *= i + 1;
            focusing_power *= it->second[i].focal_length;
            result += focusing_power;
        }
    }

    cout << "Part 2 grand total: " << result << endl;
}

int main(int argc, char *argv[]) {
    string input = read_input();
    vector<string> steps = get_steps(input);
    part1(steps);
    part2(steps);

    exit(0);
}