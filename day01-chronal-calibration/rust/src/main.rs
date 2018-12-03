use std::{
    collections::HashSet,
    io::{self, prelude::*},
};

fn puzzle_1(state_changes: &[i32]) -> i32 {
    state_changes.iter().sum()
}

fn puzzle_2(state_changes: &[i32]) -> i32 {
    let mut set = HashSet::new();
    let mut state = 0;

    for change in state_changes.iter().cycle() {
        if !set.insert(state) {
            break;
        }
        state += change;
    }
    state
}

fn parse_file(reader: impl BufRead) -> std::io::Result<Vec<i32>> {
    //converts input in type of a file or stdin into an array of vec
    Ok(reader
        .lines()
        .map(|l| {
            let s = match l {
                Ok(n) => n,
                Err(e) => {
                    eprintln!("Something wrong happend when loading the file:\n {:?}", e);
                    std::process::abort();
                }
            };
            match i32::from_str_radix(&s, 10) {
                Ok(n) => n,
                Err(e) => {
                    eprintln!("Colud not convert {} to number{:?}", &s, e);
                    std::process::abort();
                }
            }
        })
        .collect())
}

fn main() -> std::io::Result<()> {
    let stdin_input = io::stdin();
    let input = stdin_input.lock();
    let state_changes = parse_file(input)?;
    println!("{}", puzzle_1(&state_changes));
    println!("{}", puzzle_2(&state_changes));

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::{fs::File, io::BufReader};

    fn tester(i: usize) -> (i32, Vec<i32>) {
        let file = File::open("../input").unwrap();
        let reader = BufReader::new(file);
        let state_changes = parse_file(reader).unwrap();
        let output_file = File::open("../output").unwrap();;
        let ans = BufReader::new(output_file)
            .lines()
            .skip(i)
            .next()
            .unwrap()
            .unwrap();
        let expected = i32::from_str_radix(&ans, 10).unwrap();
        (expected, state_changes)
    }

    #[test]
    fn puzzle_tester_1() {
        let (expected, state_changes) = tester(0);
        assert_eq!(expected, puzzle_1(&state_changes));
    }

    #[test]
    fn puzzle_tester_2() {
        let (expected, state_changes) = tester(1);
        assert_eq!(expected, puzzle_2(&state_changes));
    }
}
