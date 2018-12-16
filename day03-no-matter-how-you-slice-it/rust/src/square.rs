use std::{
    str::FromStr,
    num::ParseIntError,
};

use crate::point::{Point, ParsePointError};
use crate::size::{Size, ParseSizeError};


#[derive(Debug)]
pub enum ParseSquareError {
    IntError(ParseIntError),
    SizeError(&'static str),
    PointError(&'static str),
    ParseError(&'static str),
}

impl From<ParseIntError> for ParseSquareError {
    fn from(p: ParseIntError) -> ParseSquareError {
        ParseSquareError::IntError(p)
    }
}

impl From<ParsePointError> for ParseSquareError {
    fn from(p: ParsePointError) -> ParseSquareError {
        match p {
            ParsePointError::IntError(n) => ParseSquareError::IntError(n),
            ParsePointError::ParseError(n) => ParseSquareError::PointError(n),
        }
    }
}

impl From<ParseSizeError> for ParseSquareError {
    fn from(p: ParseSizeError) -> ParseSquareError {
        match p {
            ParseSizeError::IntError(n) => ParseSquareError::IntError(n),
            ParseSizeError::ParseError(n) => ParseSquareError::SizeError(n),
        }
    }
}

#[derive(Clone, Hash, Eq, PartialEq, Debug)]
pub struct Square {
    corner: Point,
    size: Size,
}

impl Square {
    pub fn points(&self) -> SquareIter {
        SquareIter{
            sqr: self.clone(),
            x: 0,
            y: self.size.get_y(),
        }
    }
}

impl FromStr for Square {
    type Err = ParseSquareError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let numbers: Vec<_> = s.trim().split(':').map(|n| n.trim()).collect();

        match numbers.len() {
            2 => (),
            1 => return Err(ParseSquareError::ParseError("Missing one field")),
            0 => return Err(ParseSquareError::ParseError("No fields found")),
            _ => return Err(ParseSquareError::ParseError("To many fields found")),
        }
        
        let point_fromstr = Point::from_str(&numbers[0])?;
        let size_fromstr = Size::from_str(&numbers[1])?;

        Ok(Self { corner: point_fromstr, size: size_fromstr })
    }
}

pub struct SquareIter {
    sqr: Square,
    x: u32,
    y: u32,
}


impl Iterator for SquareIter {
    type Item = Point;

    fn next(&mut self) -> Option<Self::Item> {
        if self.x == 0 {
            if self.y == 0 {
                return None;
            }
            self.x = self.sqr.size.get_x();
            self.y -= 1;
        }
        self.x -= 1;
        Some(Point::new(self.x, self.y) + self.sqr.corner)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn iterating() {
        let mut expected = Vec::new();
        for x in 3..6 {
            for y in 2..4 {
                expected.push(Point::new(x, y));
            }
        }
        let actual: Vec<_> = Square::from_str("3,2: 3x2")
            .unwrap()
            .points()
            .collect();
        assert_eq!(expected.len(), actual.len());
        for e in expected {
            assert!(actual.contains(&e), "{:?} is missing");
        }
    }
}
