use std::{
    str::FromStr,
    num::ParseIntError,
    ops::Add,
};

#[derive(Debug)]
pub enum ParsePointError {
    IntError(ParseIntError),
    ParseError(&'static str),
}

impl From<ParseIntError> for ParsePointError {
    fn from(p: ParseIntError) -> ParsePointError {
        ParsePointError::IntError(p)
    }
}

#[derive(Eq, PartialEq, Hash, Debug, Clone, Copy)]
pub struct Point {
    pub x: u32,
    pub y: u32,
}

impl Point {
    pub fn new(x: u32, y: u32) -> Self {
        Self{x, y}
    }
}

impl FromStr for Point {
    type Err = ParsePointError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let numbers: Vec<_> = s.trim().split(',').map(|n| n.trim()).collect();

        match numbers.len() {
            2 => (),
            1 => return Err(ParsePointError::ParseError("Only one number found")),
            0 => return Err(ParsePointError::ParseError("No numbers found")),
            _ => return Err(ParsePointError::ParseError("To many numbers for a Point")),
        }
        
        let x_fromstr = numbers[0].parse::<u32>()?;
        let y_fromstr = numbers[1].parse::<u32>()?;

        Ok(Self { x: x_fromstr, y: y_fromstr })
    }
}

impl Add for Point {
    type Output = Point;

    fn add(self, other: Point) -> Point {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn adding() {
        assert_eq!(Point::new(3, 5), Point::new(0, 3) + Point::new(3, 2));
    }
}
