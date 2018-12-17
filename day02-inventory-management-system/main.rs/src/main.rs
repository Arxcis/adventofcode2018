use std::{
    collections::{HashMap, HashSet},
    io::{self, prelude::*},
};

fn parse_input(reader: impl BufRead) -> Vec<String> {
    //filter_map filters errors away.
    reader.lines().filter_map(|n| n.ok()).collect()
}

fn single_sum(box_name: &str) -> HashSet<u32> {
    let letter_count = box_name.chars().fold(HashMap::new(), |mut acc, x| {
        *acc.entry(x).or_insert(0) += 1;
        acc
    });
    letter_count.values().fold(HashSet::new(), |mut acc, x| {
        acc.insert(*x);
        acc
    })
}

fn puzzle_1(box_names: &[String]) -> u32 {
    let mut exsactly_letters = HashMap::new();
    for m in box_names.iter().map(|n| single_sum(&n)) {
        for v in m.iter() {
            if *v == 2 || *v == 3 {
                *exsactly_letters.entry(v.clone()).or_insert(0) += 1;
            }
        }
    }
    exsactly_letters.values().product()
}

fn puzzle_2(box_names: &[String]) -> Option<String> {
    for (n, ref box_name) in box_names.iter().enumerate() {
        for other_box in box_names.iter().skip(n + 1) {
            let mut diff = 0;
            if box_name.chars().zip(other_box.chars()).all(|(a, b)| {
                if a != b {
                    diff += 1;
                }
                diff < 2
            }) {
                return Some(
                    box_name
                        .chars()
                        .zip(other_box.chars())
                        .filter_map(|(a, b)| if a == b { Some(a) } else { None })
                        .collect(),
                );
            }
        }
    }
    None
}

fn main() {
    let stdin_input = io::stdin();
    let input = stdin_input.lock();
    let mut box_names = parse_input(input);
    box_names.sort_unstable();
    println!("{}", puzzle_1(&box_names));
    match puzzle_2(&box_names) {
        Some(n) => println!("{}", n),
        None => eprintln!("Did not find a value"),
    }
}
