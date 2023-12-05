use lazy_static::lazy_static;
use std::collections::HashMap;
use regex::Regex;

const INPUT: &str = "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..";


fn extract_all_numbers(input: &str) -> Vec<&str> {
    lazy_static! {
        static ref RE: Regex = Regex::new(r"(?P<number>\d+)").unwrap();
    }
    RE.find_iter(input).map(|mat| mat.as_str()).collect()
}

#[derive(Hash, Eq, PartialEq, Debug)]
struct PartPosition(usize, usize);

fn is_part_number(num: &str, num_row: usize, num_index: usize, symbols_map: &Vec<Vec<char>>) -> (bool, PartPosition) {
    let height = symbols_map.len();
    let width = symbols_map[0].len();
    let num_length = num.chars().count();

    // Search the previous line.
    let scan_start_index = if num_index > 0 {num_index - 1} else {num_index};
    let scan_end_index = if num_index + num_length < width {num_index + num_length} else {width - 1};
    if num_row > 0 {
        for i in scan_start_index..(scan_end_index + 1) {
            if symbols_map[num_row - 1][i] != ' ' {
                return (true, PartPosition(num_row - 1, i));
            }
        }
    }
    
    // Search the next line.
    if num_row + 1 < height {
        for i in scan_start_index..(scan_end_index + 1) {
            // println!("num_row: {} | i {} | symbol {}", num_row + 1, i, symbols_map[num_row + 1][i]);
            if symbols_map[num_row + 1][i] != ' ' {
                return (true, PartPosition(num_row + 1, i));
            }
        }
    }
    
    // Search same line.
    if symbols_map[num_row][scan_start_index] != ' ' {
        return (true, PartPosition(num_row, scan_start_index));
    }
    if symbols_map[num_row][scan_end_index] != ' ' {
        return (true, PartPosition(num_row, scan_end_index));
    }
    
    // println!("num_index: {} | num_length {}", num_index, num_length);
    // println!("scan_start_index: {} | scan_end_index {}", scan_start_index, scan_end_index);
    return (false, PartPosition(0, 0));
}

fn day3_part1() {
    // Find input height and width.
    let height = INPUT.lines().count();
    let width = INPUT.lines().last().unwrap().chars().count();
    println!("width={} nlines={}", width, height);
    
    // Figure out location of all symbols (characters that are not numbers or '.').
    let mut symbols_map = vec![vec![' '; width]; height];
    
    for (h, line) in INPUT.lines().enumerate() {
        for (w, element) in line.chars().enumerate() {
            if element != '.' && !element.is_digit(10) {
                symbols_map[h][w] = element;
            }
        }
    }
    for l in symbols_map.iter() {
        println!("{:?}", l);
    }

    // Scan for numbers, account the ones that have a symbol adjacent to them.
    let mut sum_numbers = 0;
    let mut num_row = 0;
    for line in INPUT.lines() {
        // println!("\n{}", line);
        let numbers = extract_all_numbers(line);
        // println!("{}", numbers.into_iter().collect::<Vec<&str>>().join(", "));
        let mut next_index_search_start = 0;
        for num in numbers {
            // This is where I had a bug. On a line with a single-digit number that should count
            // this would return the index for a different number starting with the same digit,
            // on a position that would make the algorithm not count it.
            // Original: let num_index = line.find(num).unwrap();
            // Solved by calculating the index based on the portion of the string that wasn't yet processed.
            let relative_index = line[next_index_search_start..].find(num).unwrap();
            let num_index = next_index_search_start + relative_index;
            next_index_search_start = num_index + num.chars().count();

            let (should_account, _) = is_part_number(num, num_row, num_index, &symbols_map);
            if should_account {
                sum_numbers += num.parse::<i32>().unwrap();
            } else {
                println!("{} should NOT be counted", num);
            }
        }
        num_row += 1;
    }
    println!("********** Part 1: the grand total: {}", sum_numbers);
}

#[derive(Debug)]
struct GearNumber {
    value: i32,
    gear_position: PartPosition
}

fn day3_part2() {
    // Find input height and width.
    let height = INPUT.lines().count();
    let width = INPUT.lines().last().unwrap().chars().count();
    println!("width={} nlines={}", width, height);
    
    // Figure out location of all possible gears ('*' characters).
    let mut possible_gears_map = vec![vec![' '; width]; height];
    let mut possible_gear_positions: HashMap<PartPosition, i32> = HashMap::new();
    for (h, line) in INPUT.lines().enumerate() {
        for (w, element) in line.chars().enumerate() {
            if element == '*' {
                possible_gear_positions.insert(PartPosition(h, w), 0);
                possible_gears_map[h][w] = element;
            }
        }
    }

    // Scan for gear numbers.
    let mut gear_numbers = Vec::new();

    let mut num_row = 0;
    for line in INPUT.lines() {
        let numbers = extract_all_numbers(line);
        let mut next_index_search_start = 0;
        for num in numbers {
            let relative_index = line[next_index_search_start..].find(num).unwrap();
            let num_index = next_index_search_start + relative_index;
            next_index_search_start = num_index + num.chars().count();

            let (should_account, gear_position) = is_part_number(num, num_row, num_index, &possible_gears_map);
            if should_account {
                gear_numbers.push(GearNumber{
                    value: num.parse::<i32>().unwrap(),
                    gear_position: gear_position
                })
            }
        }
        num_row += 1;
    }
    
    // For each possible gear position, figure out how many gear numbers.
    for gn in gear_numbers.iter() {
        println!("{:?}", gn);
        *possible_gear_positions.get_mut(&gn.gear_position).unwrap() += 1;
    }

    // Sum the gear ratio for all real gears (with exactly 2 gear numbers).
    let mut sum_numbers = 0;
    for (gear_position, number_count) in possible_gear_positions {
        let mut gear_ratio = 1;
        if number_count == 2 {
            println!("{:?}", gear_position);
            for gn in gear_numbers.iter() {
                if gear_position == gn.gear_position {
                   gear_ratio *= gn.value;
                }
            }
            sum_numbers += gear_ratio
        }
    }
    println!("********** Part 2: the grand total: {}", sum_numbers);
}

fn main() {
    day3_part1();
    day3_part2();
}

