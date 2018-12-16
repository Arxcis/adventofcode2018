use std::{
    str::FromStr,
    num::ParseIntError,
};

#[derive(Debug)]
pub enum ParseSizeError {
    IntError(ParseIntError),
    ParseError(&'static str),
}

impl From<ParseIntError> for ParseSizeError {
    fn from(p: ParseIntError) -> ParseSizeError {
        ParseSizeError::IntError(p)
    }
}

#[derive(Hash, Eq, PartialEq, Debug, Clone)]
pub struct Size {
    x: u32,
    y: u32,
}

impl Size {
    pub fn get_x(&self) -> u32 {
        self.x
    }
    pub fn get_y(&self) -> u32 {
        self.y
    }
}

impl FromStr for Size {
    type Err = ParseSizeError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let numbers: Vec<_> = s.trim().split('x').collect();

        match numbers.len() {
            2 => (),
            1 => return Err(ParseSizeError::ParseError("Only one number found")),
            0 => return Err(ParseSizeError::ParseError("No numbers found")),
            _ => return Err(ParseSizeError::ParseError("To many numbers for a Size")),
        }
        
        let x_fromstr = numbers[0].parse::<u32>()?;
        let y_fromstr = numbers[1].parse::<u32>()?;

        Ok(Self { x: x_fromstr, y: y_fromstr })
    }
}
