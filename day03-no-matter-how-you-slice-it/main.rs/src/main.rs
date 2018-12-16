use std::{
    str::FromStr,
    collections::HashMap,
};

mod square;
use crate::square::{Square, ParseSquareError};

mod point;

mod size;

#[derive(Hash, Eq, PartialEq, Debug)]
struct Elf {
    id: String,
    square: Square,
}

impl FromStr for Elf {
    type Err = ParseSquareError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut numbers: Vec<_> = s.trim().split('@').map(|n| n.trim()).collect();

        match numbers.len() {
            2 => (),
            1 => return Err(ParseSquareError::ParseError("Missing one field")),
            0 => return Err(ParseSquareError::ParseError("No fields found")),
            _ => return Err(ParseSquareError::ParseError("To many fields found")),
        }

        let square_str = numbers.pop().unwrap();
        let square_fromstr = Square::from_str(&square_str)?;
        let id = numbers.pop().unwrap().trim().trim_matches('#');

        Ok(Self { id: id.to_string(), square: square_fromstr })
    }
}

fn parse_input() -> Vec<Elf> {
    //converts the input to a vector of strings
    grabinput::from_stdin().filter_map(|n| Elf::from_str(&n).ok()).collect()
}

fn puzzle_1(elfs: &[Elf]) -> usize {
    let mut map = HashMap::new();
    elfs
        .iter()
        .flat_map(|n| n.square.points())
        .for_each(|n| *map.entry(n).or_insert(0) += 1);
    map
        .values()
        .filter(|&n| *n > 1)
        .count()
    
}

fn puzzle_2(elfs: &[Elf]) -> String {
    let mut map = HashMap::new();
        elfs
        .iter()
        .for_each(|n| n
                  .square.points()
                  .for_each(|p| map
                            .entry(p)
                            .or_insert_with(Vec::new)
                            .push(n.id.clone())));
    elfs
        .iter()
        .filter(|n| n.square.points().all(|p| map.get(&p).unwrap().len() == 1))
        .next()
        .unwrap()
        .id.clone()
}

fn main() {
    let elfs = parse_input();
    println!("{}", puzzle_1(&elfs));
    println!("{}", puzzle_2(&elfs));
}
