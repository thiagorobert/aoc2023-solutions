use lazy_static::lazy_static;
use std::collections::HashSet;
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


fn extract_all_numbers(input: &str) -> HashSet<&str> {
    lazy_static! {
        static ref RE: Regex = Regex::new(r"(?P<number>\d+)").unwrap();
    }
    RE.find_iter(input).map(|mat| mat.as_str()).collect()
}

fn is_part_number(num: &str, num_row: usize, num_index: usize, symbols_map: &Vec<Vec<char>>) -> bool {
    let height = symbols_map.len();
    let width = symbols_map[0].len();
    let num_length = num.chars().count();
    println!("num_index: {} | num_length {}", num_index, num_length);

    // Search the previous line.
    let scan_start_index = if num_index > 0 {num_index - 1} else {num_index};
    let mut scan_end_index = if num_index + num_length + 1 < width {num_index + num_length + 1} else {width};
    if num_row > 0 {
        for i in scan_start_index..scan_end_index {
            if symbols_map[num_row - 1][i] != ' ' {
                return true;
            }
        }
    }
    
    // Search the next line.
    if num_row + 1 < height {
        for i in scan_start_index..scan_end_index {
            if symbols_map[num_row + 1][i] != ' ' {
                return true;
            }
        }
    }
    
    // Search same line.
    scan_end_index = if num_index + num_length < width {num_index + num_length} else {width - 1};
    if symbols_map[num_row][scan_start_index] != ' ' || symbols_map[num_row][scan_end_index] != ' ' {
        return true;
    }
    
    return false;
}

fn main() {
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
        println!("\n{}", line);
        let numbers = extract_all_numbers(line);
        // println!("{}", numbers.into_iter().collect::<Vec<&str>>().join(", "));
        for num in numbers {
            println!("{}", num);
            let num_index = line.find(num).unwrap();
            
            //if is_part_number(num, symbols_map) {
            let should_account = is_part_number(num, num_row, num_index, &symbols_map);
            println!("should_account: {}", should_account);
            if should_account {
                sum_numbers += num.parse::<i32>().unwrap();
            }
        }
//        for element in line.chars() {
//            if element.is_digit(10) {
//                symbols_map[height][width] = element;
//            }
//            width += 1;
//        }
        num_row += 1;
    }
    println!("********** Part 1: the grand total: {}", sum_numbers);
}

