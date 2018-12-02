use std::{
    io::{
        BufReader, prelude::*
    },
    fs::File,
    collections::HashSet,
};

fn puzzle_1(state_changes: &Vec<i32>) {
    let ans: i32 = state_changes.iter().sum();
    println!("The resulting frequency is: {}", ans);
}

fn puzzle_2(state_changes: &Vec<i32>) {
    let mut set = HashSet::new();
    let mut state = 0;

    for change in state_changes.iter().cycle() {
        if !set.insert(state) {
            break;
        }
        state += change;
    }
    println!("The first frequency your device reaches twice is: {}", state);
}

fn parse_file(name: &str) -> std::io::Result<Vec<i32>> {
    let file = File::open(name)?;
    let reader = BufReader::new(file);
    
    //converts the file to a vec of i32
    Ok(reader.lines()
        .map(|l| {
            let s = match l{
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

fn main() ->std::io::Result<()> {
    let state_changes = parse_file("../input")?;
    puzzle_1(&state_changes);
    puzzle_2(&state_changes);
    
    Ok(())
}

